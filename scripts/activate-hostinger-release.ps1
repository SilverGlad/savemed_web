[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)][string]$ReleaseName,
    [Parameter(Mandatory = $true)][string]$BackupName,
    [Parameter(Mandatory = $true)][ValidateSet('savemed.app')][string]$TargetDomain,
    [Parameter(Mandatory = $true)][string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
if ($ReleaseName -notmatch '^savemed-release-[a-z0-9-]+$' -or
    $BackupName -notmatch '^savemed-backup-[a-z0-9-]+$') {
    throw 'Release and backup must be explicit SaveMed directory names.'
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
$credential = New-Object System.Net.NetworkCredential($config.username, $config.password)

function Rename-RemoteDirectory([string]$Source, [string]$Target) {
    $request = [System.Net.FtpWebRequest]::Create("$($config.uri.TrimEnd('/'))/$Source")
    $request.Credentials = $credential
    $request.EnableSsl = $true
    $request.Method = [System.Net.WebRequestMethods+Ftp]::Rename
    $request.RenameTo = "/$Target"
    $request.UsePassive = $true
    $request.KeepAlive = $false
    $response = $request.GetResponse()
    $response.Dispose()
}

# Keep the old directory intact so activation can be reversed immediately.
if (!$PSCmdlet.ShouldProcess(
    "$TargetDomain via FTP host $($uri.Host)",
    "Replace /savemed with /$ReleaseName and keep /$BackupName for rollback"
)) {
    return
}

Rename-RemoteDirectory 'savemed' $BackupName
try {
    Rename-RemoteDirectory $ReleaseName 'savemed'
} catch {
    Rename-RemoteDirectory $BackupName 'savemed'
    throw
}
Write-Output "Activated /savemed; previous release preserved at /$BackupName"
