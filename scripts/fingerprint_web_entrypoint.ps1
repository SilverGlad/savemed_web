param(
  [string]$WebRoot = (Join-Path $PSScriptRoot '..\build\web')
)

$resolvedWebRoot = (Resolve-Path -LiteralPath $WebRoot).Path
$bootstrapPath = Join-Path $resolvedWebRoot 'flutter_bootstrap.js'

if (!(Test-Path -LiteralPath $bootstrapPath -PathType Leaf)) {
  throw "Flutter bootstrap not found in '$resolvedWebRoot'."
}

$bootstrap = [System.IO.File]::ReadAllText($bootstrapPath)
$configPattern = '(?<prefix>_flutter\.buildConfig\s*=\s*)(?<config>\{.*?\})(?<suffix>\s*;)'
$configMatch = [regex]::Match(
  $bootstrap,
  $configPattern,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

if (!$configMatch.Success) {
  throw 'Flutter build configuration was not found in flutter_bootstrap.js.'
}

$buildConfig = $configMatch.Groups['config'].Value | ConvertFrom-Json
if ($null -eq $buildConfig.builds -or $buildConfig.builds.Count -eq 0) {
  throw 'Flutter build configuration does not contain an entrypoint.'
}

$entrypointName = [string]$buildConfig.builds[0].mainJsPath
if ([string]::IsNullOrWhiteSpace($entrypointName) -or
    [System.IO.Path]::GetFileName($entrypointName) -ne $entrypointName -or
    $entrypointName -notmatch '^main(?:\.[0-9a-f]{64})?\.dart\.js$') {
  throw 'Flutter entrypoint path is missing or unsafe.'
}

$entrypointPath = Join-Path $resolvedWebRoot $entrypointName
if (!(Test-Path -LiteralPath $entrypointPath -PathType Leaf)) {
  throw "Flutter entrypoint '$entrypointName' was not found."
}

$entrypointBytes = [System.IO.File]::ReadAllBytes($entrypointPath)
$sha256 = [System.Security.Cryptography.SHA256]::Create()
try {
  $digest = [System.BitConverter]::ToString(
    $sha256.ComputeHash($entrypointBytes)
  ).Replace('-', '').ToLowerInvariant()
} finally {
  $sha256.Dispose()
}

$fingerprintedName = "main.$digest.dart.js"
$fingerprintedPath = Join-Path $resolvedWebRoot $fingerprintedName
if ($entrypointName -ne $fingerprintedName) {
  [System.IO.File]::WriteAllBytes($fingerprintedPath, $entrypointBytes)
}

$verifiedHash = (Get-FileHash -LiteralPath $fingerprintedPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($verifiedHash -ne $digest) {
  throw 'The fingerprinted Flutter entrypoint does not match its content hash.'
}

$buildConfig.builds[0].mainJsPath = $fingerprintedName
$serializedConfig = ConvertTo-Json -InputObject $buildConfig -Depth 100 -Compress
$rewrittenBootstrap = [regex]::Replace(
  $bootstrap,
  $configPattern,
  [System.Text.RegularExpressions.MatchEvaluator]{
    param($match)
    return $match.Groups['prefix'].Value + $serializedConfig +
      $match.Groups['suffix'].Value
  },
  1,
  [System.TimeSpan]::FromSeconds(5)
)

$rewrittenConfigMatch = [regex]::Match(
  $rewrittenBootstrap,
  $configPattern,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if (!$rewrittenConfigMatch.Success) {
  throw 'The updated Flutter build configuration is invalid.'
}

$rewrittenConfig = $rewrittenConfigMatch.Groups['config'].Value | ConvertFrom-Json
if ($rewrittenConfig.builds[0].mainJsPath -ne $fingerprintedName) {
  throw 'The updated Flutter build configuration does not reference the fingerprinted entrypoint.'
}

$bootstrapTempPath = "$bootstrapPath.tmp"
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText(
  $bootstrapTempPath,
  $rewrittenBootstrap,
  $utf8WithoutBom
)
Move-Item -LiteralPath $bootstrapTempPath -Destination $bootstrapPath -Force

if ($entrypointName -ne $fingerprintedName) {
  Remove-Item -LiteralPath $entrypointPath -Force
}

if (!(Test-Path -LiteralPath $fingerprintedPath -PathType Leaf)) {
  throw 'Fingerprinting the Flutter entrypoint did not complete successfully.'
}

Write-Output "Web entrypoint: $fingerprintedName ($($entrypointBytes.Length) bytes, SHA-256 $digest)."
