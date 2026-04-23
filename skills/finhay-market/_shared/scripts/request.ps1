param(
    [Parameter(Mandatory)][string]$Method,
    [Parameter(Mandatory)][string]$Endpoint,
    [string]$Query = "",
    [string]$Body  = ""
)

$ErrorActionPreference = "Stop"

$CredsPath = Join-Path $env:USERPROFILE ".finhay\credentials\.env"
Test-Path $CredsPath | Out-Null || { throw "ERROR: $CredsPath not found" }

Get-Content $CredsPath | ForEach-Object {
    if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
        [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process')
    }
}

$ApiKey    = $env:FINHAY_API_KEY
$ApiSecret = $env:FINHAY_API_SECRET
$BaseUrl   = $env:FINHAY_BASE_URL ?? "https://open-api.fhsc.com.vn"

if (-not $ApiKey -or -not $ApiSecret) {
    throw "ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required."
}

$Ts = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds().ToString()

$SkillName = "finhay-market"
$SkillVersion = "1.0.3"

$NonceBytes = [byte[]]::new(16)
[Security.Cryptography.RandomNumberGenerator]::Fill($NonceBytes)
$Nonce = ($NonceBytes | ForEach-Object { $_.ToString("x2") }) -join ""

$Payload = "$Ts`n$Method`n$Endpoint`n"
if ($Body) { $Payload += "$Body`n" }

$Hmac = [Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($ApiSecret))
$Sig  = ($Hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($Payload)) | ForEach-Object { $_.ToString("x2") }) -join ""

$Url = "${BaseUrl}${Endpoint}"
if ($Query) { $Url += "?$Query" }

$Headers = @{
    "User-Agent"     = "$SkillName/$SkillVersion"
    "X-FH-APIKEY"    = $ApiKey
    "X-FH-TIMESTAMP" = $Ts
    "X-FH-NONCE"     = $Nonce
    "X-FH-SIGNATURE" = $Sig
    "X-Origin-Method" = $Method
    "X-Origin-Path"   = $Endpoint
    "X-Origin-Query"  = $Query
}

$params = @{
    Uri        = $Url
    Method     = $Method
    Headers    = $Headers
    TimeoutSec = 30
}

if ($Body) {
    $params["Body"]        = $Body
    $params["ContentType"] = "application/json"
}

try {
    $Res  = Invoke-WebRequest @params
    $BodyRes = $Res.Content

    $Ec = ($BodyRes | ConvertFrom-Json).error_code
    if ($Ec -and $Ec -ne 0) {
        throw "ERROR: error_code=$Ec`n$BodyRes"
    }

    Write-Output $BodyRes
}
catch {
    $Code = $null
    try { $Code = $_.Exception.Response.StatusCode.value__ } catch {}

    if ($Code -and $Code -ge 400) {
        [Console]::Error.WriteLine("ERROR: HTTP $Code")
    } else {
        [Console]::Error.WriteLine($_.Exception.Message)
    }
    exit 1
}