param(
    [Parameter(Mandatory = $true)][string]$Destination,
    [string]$RemotePath = '/savemed',
    [Parameter(Mandatory = $true)][ValidateSet('savemed.app')][string]$TargetDomain,
    [Parameter(Mandatory = $true)][string]$ConfigPath,
    [string]$FtpScript = (Join-Path $HOME '.codex/skills/ftp-codex-host/scripts/ftp.ps1')
)

$ErrorActionPreference = 'Stop'

if ($RemotePath -notmatch '^/?savemed/?$') {
    throw 'This backup script is restricted to the SaveMed app directory.'
}
if (!(Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw 'The explicit FTP configuration file was not found.'
}
if (!(Test-Path -LiteralPath $FtpScript -PathType Leaf)) {
    throw 'The FTP helper script was not found.'
}
$ftpScriptContent = Get-Content -LiteralPath $FtpScript -Raw
if ($ftpScriptContent -notmatch '(?im)^\s*\$request\.EnableSsl\s*=\s*\$true\s*$') {
    throw 'The FTP helper does not require FTPS; use the HTTPS Hostinger file manager instead.'
}

$resolvedDestination = [System.IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $resolvedDestination) {
    throw 'Backup destination already exists; choose a new path to prevent overwriting a prior backup.'
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$uri = [uri]$config.uri
if ($uri.Scheme -ne 'ftp' -or [string]::IsNullOrWhiteSpace($uri.Host)) {
    throw 'The explicit FTP configuration has an invalid endpoint.'
}
if ($uri.UserInfo) {
    throw 'FTP credentials must be stored separately from the endpoint URI.'
}
if ($uri.AbsolutePath -ne '/') {
    throw 'The FTP endpoint must point to the account root.'
}
if ($uri.Host -eq '147.93.39.52') {
    throw 'This is a known legacy FTP endpoint, not the current savemed.app Hostinger account.'
}
if ([string]::IsNullOrWhiteSpace([string]$config.username) -or
    [string]::IsNullOrWhiteSpace([string]$config.password)) {
    throw 'The explicit FTP configuration is missing credentials.'
}

function Copy-RemoteDirectory([string]$Remote, [string]$Local) {
    New-Item -ItemType Directory -Path $Local -Force | Out-Null
    $listing = & $ftpScript -Action list -RemotePath $Remote -ConfigPath $ConfigPath
    foreach ($line in ($listing -split "`n")) {
        $columns = $line.Trim() -split '\s+', 9
        if ($columns.Count -ne 9) { continue }
        $name = $columns[8]
        if ($name -in @('.', '..')) { continue }
        if ($name.Contains('/') -or $name.Contains('\') -or
            $name -match '[<>:"|?*\x00-\x1F]' -or $name -match '[. ]$') {
            throw 'Invalid remote filename'
        }
        $target = [System.IO.Path]::GetFullPath((Join-Path $Local $name))
        $localRoot = [System.IO.Path]::GetFullPath($Local)
        if (!$localRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
            $localRoot += [System.IO.Path]::DirectorySeparatorChar
        }
        if (!$target.StartsWith($localRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw 'Remote entry resolves outside the local backup directory.'
        }
        $source = "$Remote/$name"
        if ($columns[0].StartsWith('d')) {
            Copy-RemoteDirectory $source $target
        } elseif ($columns[0].StartsWith('-')) {
            & $ftpScript -Action download -RemotePath $source -LocalPath $target -ConfigPath $ConfigPath
        } else {
            throw "Unsupported entry: $source"
        }
    }
}

Copy-RemoteDirectory $RemotePath $resolvedDestination
