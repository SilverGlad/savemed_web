param(
  [string]$ScriptPath = (Join-Path $PSScriptRoot 'fingerprint_web_entrypoint.ps1')
)

$ErrorActionPreference = 'Stop'
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRootName = "savemed-fingerprint-tests-$([guid]::NewGuid().ToString('N'))"
$tempRoot = [System.IO.Path]::GetFullPath((Join-Path $tempBase $tempRootName))
$tempBasePrefix = $tempBase.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar

if (!$tempRoot.StartsWith($tempBasePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw 'Fingerprint test directory resolved outside the system temp directory.'
}
if (Test-Path -LiteralPath $tempRoot) {
  throw 'Fingerprint test directory already exists; refusing to reuse it.'
}
New-Item -ItemType Directory -Path $tempRoot | Out-Null

function Assert-True {
  param([bool]$Condition, [string]$Message)
  if (!$Condition) { throw $Message }
}

function New-Fixture {
  param(
    [string]$Name,
    [string]$EntrypointName = 'main.dart.js',
    [bool]$CreateEntrypoint = $true
  )

  $webRoot = Join-Path $tempRoot $Name
  New-Item -ItemType Directory -Path $webRoot | Out-Null
  $bootstrap = '_flutter.buildConfig = {"builds":[{"mainJsPath":"' +
    $EntrypointName + '"}]};'
  [System.IO.File]::WriteAllText(
    (Join-Path $webRoot 'flutter_bootstrap.js'),
    $bootstrap,
    $utf8WithoutBom
  )
  if ($CreateEntrypoint) {
    [System.IO.File]::WriteAllText(
      (Join-Path $webRoot $EntrypointName),
      'SaveMed fingerprint fixture',
      $utf8WithoutBom
    )
  }
  return $webRoot
}

function Invoke-Fingerprint {
  param([string]$WebRoot)
  try {
    & $ScriptPath -WebRoot $WebRoot | Out-Null
    return $true
  } catch {
    return $false
  }
}

try {
  $validRoot = New-Fixture -Name 'valid'
  $sourcePath = Join-Path $validRoot 'main.dart.js'
  $sourceHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
  $fingerprintedName = "main.$sourceHash.dart.js"

  Assert-True (Invoke-Fingerprint -WebRoot $validRoot) 'Valid entrypoint fingerprinting failed.'
  Assert-True (!(Test-Path -LiteralPath $sourcePath)) 'Stable entrypoint was not removed after activation.'
  $fingerprintedPath = Join-Path $validRoot $fingerprintedName
  Assert-True (Test-Path -LiteralPath $fingerprintedPath -PathType Leaf) 'Fingerprint file was not created.'
  $bootstrapPath = Join-Path $validRoot 'flutter_bootstrap.js'
  $fingerprintedBootstrap = [System.IO.File]::ReadAllText($bootstrapPath)
  Assert-True ($fingerprintedBootstrap.Contains($fingerprintedName)) 'Bootstrap does not reference the fingerprinted file.'
  Assert-True ((Get-FileHash -LiteralPath $fingerprintedPath -Algorithm SHA256).Hash.ToLowerInvariant() -eq $sourceHash) 'Fingerprint file hash changed.'

  $firstBootstrap = $fingerprintedBootstrap
  Assert-True (Invoke-Fingerprint -WebRoot $validRoot) 'Repeated fingerprinting failed.'
  Assert-True ([System.IO.File]::ReadAllText($bootstrapPath) -eq $firstBootstrap) 'Repeated fingerprinting changed the bootstrap.'
  Assert-True ((Get-ChildItem -LiteralPath $validRoot -File | Where-Object Name -Like 'main.*.dart.js').Count -eq 1) 'Repeated fingerprinting created duplicate bundles.'

  $unsafeRoot = New-Fixture -Name 'unsafe' -EntrypointName '../outside.js' -CreateEntrypoint $false
  $unsafeBootstrapPath = Join-Path $unsafeRoot 'flutter_bootstrap.js'
  $unsafeBootstrap = [System.IO.File]::ReadAllText($unsafeBootstrapPath)
  $outsidePath = Join-Path $tempRoot 'outside.js'
  [System.IO.File]::WriteAllText($outsidePath, 'outside sentinel', $utf8WithoutBom)
  Assert-True (!(Invoke-Fingerprint -WebRoot $unsafeRoot)) 'Path traversal entrypoint was accepted.'
  Assert-True ([System.IO.File]::ReadAllText($unsafeBootstrapPath) -eq $unsafeBootstrap) 'Unsafe entrypoint failure mutated the bootstrap.'
  Assert-True ([System.IO.File]::ReadAllText($outsidePath) -eq 'outside sentinel') 'Unsafe entrypoint changed a neighboring file.'

  $unsupportedRoot = New-Fixture -Name 'unsupported' -EntrypointName 'index.html' -CreateEntrypoint $false
  $unsupportedBootstrapPath = Join-Path $unsupportedRoot 'flutter_bootstrap.js'
  $unsupportedBootstrap = [System.IO.File]::ReadAllText($unsupportedBootstrapPath)
  $unsupportedSentinelPath = Join-Path $unsupportedRoot 'index.html'
  [System.IO.File]::WriteAllText($unsupportedSentinelPath, 'html sentinel', $utf8WithoutBom)
  Assert-True (!(Invoke-Fingerprint -WebRoot $unsupportedRoot)) 'Non-Flutter entrypoint name was accepted.'
  Assert-True ([System.IO.File]::ReadAllText($unsupportedBootstrapPath) -eq $unsupportedBootstrap) 'Unsupported entrypoint failure mutated the bootstrap.'
  Assert-True ([System.IO.File]::ReadAllText($unsupportedSentinelPath) -eq 'html sentinel') 'Unsupported entrypoint changed a neighboring file.'

  $missingRoot = New-Fixture -Name 'missing' -CreateEntrypoint $false
  $missingBootstrapPath = Join-Path $missingRoot 'flutter_bootstrap.js'
  $missingBootstrap = [System.IO.File]::ReadAllText($missingBootstrapPath)
  Assert-True (!(Invoke-Fingerprint -WebRoot $missingRoot)) 'Missing entrypoint was accepted.'
  Assert-True ([System.IO.File]::ReadAllText($missingBootstrapPath) -eq $missingBootstrap) 'Missing entrypoint failure mutated the bootstrap.'

  Write-Output 'Fingerprint script tests passed (hashing, idempotence, name validation, traversal rejection, failure atomicity).'
} finally {
  $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
  if (!$resolvedTempRoot.StartsWith($tempBasePrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
      $resolvedTempRoot -eq $tempBase.TrimEnd('\', '/')) {
    throw 'Refusing to remove a path outside the dedicated fingerprint test directory.'
  }
  if (Test-Path -LiteralPath $resolvedTempRoot) {
    Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
  }
}
