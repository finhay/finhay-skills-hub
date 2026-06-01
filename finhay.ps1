$CredsDir = Join-Path $HOME ".finhay\credentials"
$CredsFile = Join-Path $CredsDir ".env"
$Session2faFile = Join-Path $CredsDir ".2fa-session"
$BaseUrlDefault = "https://open-api.fhsc.com.vn"
$Repo = "finhay/finhay-skills-hub"
$Branch = "main"

$script:_In2FARecovery = $false

if ($PSCommandPath) {
    $SkillDir = Split-Path -Parent $PSCommandPath
    $Skill = Split-Path -Leaf $SkillDir
    $VersionRaw = Get-Content (Join-Path $SkillDir ".version") -Raw -ErrorAction SilentlyContinue
}
$Ver = if ($VersionRaw) { $VersionRaw.Trim() } else { "unknown" }
$Os = [System.Environment]::OSVersion.VersionString

$Deps = @(
    @{ Name = "Node.js"; Cmd = "node"; VersionArg = "--version"; WingetId = "OpenJS.NodeJS.LTS"; InstallUrl = "https://nodejs.org/en/download" },
    @{ Name = "Git"; Cmd = "git"; VersionArg = "--version"; WingetId = "Git.Git"; InstallUrl = "https://git-scm.com/download/win" }
)

function Show-Help {
    Write-Host "Usage: .\finhay.ps1 {auth|doctor|deps|infer|request|2fa|sync}"
}

function Load-2FAToken {
    if (-not (Test-Path $Session2faFile)) { return "" }
    $lines = Get-Content $Session2faFile -ErrorAction SilentlyContinue
    $token = ""
    $exp = ""
    foreach ($line in $lines) {
        if ($line -match '^session_token=(.+)$') { $token = $matches[1] }
        elseif ($line -match '^expires_at_epoch=(.+)$') { $exp = $matches[1] }
    }
    if (-not $token -or -not $exp) { return "" }
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    if ([long]$exp -gt $now) { return $token } else { return "" }
}

function Save-2FAToken {
    param($Token, $ExpiresAt, $ExpiresAtEpoch)
    if (-not (Test-Path $CredsDir)) { New-Item -ItemType Directory -Path $CredsDir | Out-Null }
    $content = "session_token=$Token`nexpires_at=$ExpiresAt`nexpires_at_epoch=$ExpiresAtEpoch"
    Set-Content -Path $Session2faFile -Value $content
}

function Clear-2FAToken {
    if (Test-Path $Session2faFile) { Remove-Item -Path $Session2faFile -Force -ErrorAction SilentlyContinue }
}

# True only when we can actually prompt a human for input.
# In an agent / piped context input is redirected → returns $false.
function Test-Interactive {
    try {
        if ([Console]::IsInputRedirected) { return $false }
    } catch {
        return $false
    }
    return [Environment]::UserInteractive
}

function Invoke-2FAInteractive {
    # Fail safe before spending an OTP: if there is no TTY we cannot read the
    # 6-digit code, so do NOT send a request (it would burn 1 of 5/day and then
    # block on an unanswerable prompt). Tell the caller to run Step 5 manually.
    if (-not (Test-Interactive)) {
        Write-Host "🔐 Cần 2FA session nhưng môi trường không có TTY để nhập OTP tự động."
        Write-Host "   KHÔNG tự gửi OTP (tránh phí hạn mức 5 lần/ngày). Hãy chạy preflight (Step 5):"
        Write-Host "     1) .\finhay.ps1 2fa request                    # gửi OTP qua email"
        Write-Host "     2) .\finhay.ps1 2fa verify <ticket_id> <otp>   # lưu session"
        Write-Host "     3) chạy lại lệnh place/modify/cancel"
        return $false
    }
    $reqBody = "{`"channel`":`"EMAIL`"}"
    $reqResp = Request-Internal -Method "POST" -Endpoint "/auth/v1/openapi/2fa/request" -Body $reqBody
    if (-not $reqResp) { return $false }
    $reqJson = $reqResp | ConvertFrom-Json
    if (-not $reqJson.ticket_id) {
        Write-Error "2FA request failed: $reqResp"
        return $false
    }

    Write-Host ("📨 OTP đã gửi tới {0}. Hết hạn sau 5 phút." -f $reqJson.masked_destination)
    $otp = Read-Host "Nhập OTP 6 số"
    if (-not $otp) { Write-Error "OTP rỗng."; return $false }

    $verifyBody = "{`"ticket_id`":`"$($reqJson.ticket_id)`",`"otp_code`":`"$otp`"}"
    $verifyResp = Request-Internal -Method "POST" -Endpoint "/auth/v1/openapi/2fa/verify" -Body $verifyBody
    if (-not $verifyResp) { return $false }
    $verifyJson = $verifyResp | ConvertFrom-Json
    if (-not $verifyJson.session_token) {
        Write-Error "2FA verify failed: $verifyResp"
        return $false
    }

    Save-2FAToken -Token $verifyJson.session_token -ExpiresAt $verifyJson.expires_at -ExpiresAtEpoch $verifyJson.expires_at_epoch
    Write-Host ("✅ 2FA session đã được lưu, hết hạn {0}" -f $verifyJson.expires_at)
    return $true
}

function Request-Internal {
    param($Method, $Endpoint, $Query, $Body)
    
    $AK = $env:FINHAY_API_KEY
    $AS = $env:FINHAY_API_SECRET
    $BU = $env:FINHAY_BASE_URL
    $UI = $env:USER_ID

    if (Test-Path $CredsFile) {
        $FileData = ConvertFrom-StringData (Get-Content $CredsFile -Raw)
        if (-not $AK) { $AK = $FileData.FINHAY_API_KEY }
        if (-not $AS) { $AS = $FileData.FINHAY_API_SECRET }
        if (-not $BU) { $BU = $FileData.FINHAY_BASE_URL }
        if (-not $UI) { $UI = $FileData.USER_ID }
    }

    if (-not $AK -or -not $AS) { 
        Write-Error "ERROR: Credentials not found. Run .\finhay.ps1 auth first."
        return 
    }
    if (-not $BU) { $BU = $BaseUrlDefault }
    $TS = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $Nonce = [Guid]::NewGuid().ToString("n").Substring(0, 32)

    $MethodUpper = $Method.ToUpper()

    $EncodedQuery = ""
    if ($Query) {
        $EncodedQuery = $Query -replace ' ', '%20' -replace '\[', '%5B' -replace '\]', '%5D'
    }

    $SignPath = $Endpoint
    if ($EncodedQuery) { $SignPath = "$Endpoint`?$EncodedQuery" }

    $BodyHash = ""
    if ($Body) {
        $Sha = [System.Security.Cryptography.SHA256]::Create()
        $BodyHashBytes = $Sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Body))
        $BodyHash = [BitConverter]::ToString($BodyHashBytes).Replace("-", "").ToLower()
        $Payload = "$TS`n$MethodUpper`n$SignPath`n$BodyHash"
    } else {
        $Payload = "$TS`n$MethodUpper`n$SignPath`n"
    }

    $Hmac = New-Object System.Security.Cryptography.HMACSHA256
    $Hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($AS)
    $SigBytes = $Hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Payload))
    $Sig = [BitConverter]::ToString($SigBytes).Replace("-", "").ToLower()

    $Url = "$BU$Endpoint"
    if ($EncodedQuery) { $Url += "?$EncodedQuery" }

    $Agent = if ($env:AGENT_NAME) { $env:AGENT_NAME } else { "unknown" }

    $Headers = @{
        "X-FH-APIKEY" = $AK;
        "X-FH-USER-ID" = $UI;
        "X-FH-TIMESTAMP" = $TS;
        "X-FH-NONCE" = $Nonce;
        "X-FH-SIGNATURE" = $Sig;
        "X-FH-OPENAPI-SKILL-VERSION" = $Ver;
        "X-FH-OPENAPI-OS" = $Os;
        "X-FH-OPENAPI-AGENT" = $Agent;
        "User-Agent" = "finhay-skills-hub/${Skill}@${Ver} (${Agent}; ${Os})"
    }
    if ($BodyHash) { $Headers["X-FH-BODYHASH"] = $BodyHash }

    $token2fa = Load-2FAToken
    if ($token2fa) { $Headers["X-FH-2FA-TOKEN"] = $token2fa }

    try {
        $Params = @{ Uri = $Url; Method = $Method; Headers = $Headers; ContentType = "application/json" }
        if ($Body) { $Params.Body = $Body }
        $Resp = Invoke-RestMethod @Params
        return $Resp | ConvertTo-Json -Depth 10
    } catch {
        $statusCode = $null
        $errorBody = ""
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $errorBody = $reader.ReadToEnd()
            } catch {}
        }

        if ($statusCode -eq 403 -and -not $script:_In2FARecovery) {
            $errJson = $null
            try { $errJson = $errorBody | ConvertFrom-Json } catch {}
            if ($errJson -and $errJson.error_code -in @('OTP_SESSION_REQUIRED','OTP_SESSION_EXPIRED','OTP_SESSION_INVALID','OTP_SESSION_REVOKED')) {
                Clear-2FAToken
                Write-Host ("🔐 Cần xác thực OTP cho thao tác này (error: {0})." -f $errJson.error_code)
                $script:_In2FARecovery = $true
                try {
                    if (Invoke-2FAInteractive) {
                        Write-Host "🔁 Retry lệnh gốc..."
                        return Request-Internal -Method $Method -Endpoint $Endpoint -Query $Query -Body $Body
                    }
                } finally {
                    $script:_In2FARecovery = $false
                }
                return
            }
        }

        Write-Error "ERROR: HTTP $statusCode - $errorBody"
        return
    }
}

function Cmd-Auth {
    Write-Host "=== Xac thuc ket noi tai khoan FHSC ==="
    $existingCreds = $false
    if (Test-Path $CredsFile) {
        $FileData = ConvertFrom-StringData (Get-Content $CredsFile -Raw)
        $existingAk = $FileData.FINHAY_API_KEY
        $existingAs = $FileData.FINHAY_API_SECRET
        if ($existingAk -and $existingAs) {
            $existingCreds = $true
            Write-Host "Tim thay thong tin Credentials $CredsFile"
            $akPrefix = if ($existingAk.Length -ge 8) { $existingAk.Substring(0, 8) } else { $existingAk }
            Write-Host ("  API Key    : {0}********" -f $akPrefix)
            Write-Host  "  Secret Key : ****************"
            $confirm = Read-Host "Ban co muon thay the khong? [y/N]"
            if ($confirm -notmatch "^[Yy]$") { return }
        }
    }

    if (-not (Test-Path $CredsDir)) { New-Item -ItemType Directory -Path $CredsDir | Out-Null }
    $promptSuffix = if ($existingCreds) { " moi" } else { "" }
    $ak = Read-Host "Nhap API Key$promptSuffix"

    Write-Host -NoNewline "Nhap Secret Key${promptSuffix}: "
    $as = ""
    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Enter') { Write-Host ""; break }
        if ($key.Key -eq 'Backspace') {
            if ($as.Length -gt 0) { $as = $as.Substring(0, $as.Length - 1); Write-Host -NoNewline "`b `b" }
        } else {
            $as += $key.KeyChar; Write-Host -NoNewline "*"
        }
    }

    $Content = "FINHAY_API_KEY=$ak`nFINHAY_API_SECRET=$as`nFINHAY_BASE_URL=$BaseUrlDefault"
    Set-Content -Path $CredsFile -Value $Content

    if ($existingCreds) {
        Write-Host "Cap nhat Credentials thanh cong. Hay khoi dong lai Agent de su dung."
    } else {
        Write-Host "Tao Credentials thanh cong tai $CredsFile"
        Write-Host "Hay khoi dong lai Agent de su dung."
    }
}

function Cmd-Doctor {
    $AK = $env:FINHAY_API_KEY
    $AS = $env:FINHAY_API_SECRET
    if (Test-Path $CredsFile) {
        try {
            $FileData = ConvertFrom-StringData (Get-Content $CredsFile -Raw)
            if (-not $AK) { $AK = $FileData.FINHAY_API_KEY }
            if (-not $AS) { $AS = $FileData.FINHAY_API_SECRET }
        } catch {}
    }

    if ($AK -and $AS) { 
        Write-Host "✅ Credentials: OK"
        $DisplayBU = if ($BU) { $BU } else { $BaseUrlDefault }
        Write-Host "🌐 Base URL: $DisplayBU"
    } else { 
        Write-Host "❌ Credentials: MISSING (Set environment variables or run auth)" 
    }
    
    Write-Host "Environment: PowerShell $($PSVersionTable.PSVersion)"
}

function Install-Dep {
    param($Dep)
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host ("WinGet not available. Install manually from {0}" -f $Dep.InstallUrl)
        return
    }
    Write-Host ("Installing {0} via WinGet..." -f $Dep.Name)
    winget install --id $Dep.WingetId -e --silent --accept-source-agreements --accept-package-agreements
}

function Check-Dep {
    param($Dep)
    if (Get-Command $Dep.Cmd -ErrorAction SilentlyContinue) {
        $Version = (& $Dep.Cmd $Dep.VersionArg) 2>$null
        Write-Host ("✅ {0}: {1}" -f $Dep.Name, $Version)
        return
    }
    Write-Host ("❌ {0}: MISSING" -f $Dep.Name)
    $confirm = Read-Host ("Install {0} now? [y/N]" -f $Dep.Name)
    if ($confirm -match "^[Yy]$") { Install-Dep $Dep }
    else { Write-Host ("Install manually from {0}" -f $Dep.InstallUrl) }
}

function Cmd-Deps {
    foreach ($Dep in $Deps) { Check-Dep $Dep }
}

function Cmd-Infer {
    $Data = Request-Internal -Method "GET" -Endpoint "/users/v1/users/me"
    $UserJson = $Data | ConvertFrom-Json
    $UserId = $UserJson.data.user_id
    
    if (-not $UserId) { 
        Write-Error "ERROR: Could not resolve USER_ID. Check your credentials."
        if ($Data) { Write-Host $Data }
        return 
    }
    
    $SbaData = Request-Internal -Method "GET" -Endpoint "/users/v1/users/$UserId/sub-accounts"
    $SbaJson = $SbaData | ConvertFrom-Json
    
    if (-not (Test-Path $CredsDir)) { New-Item -ItemType Directory -Path $CredsDir | Out-Null }
    $NewContent = if (Test-Path $CredsFile) { Get-Content $CredsFile | Where-Object { $_ -notmatch "^(USER_ID|SUB_ACCOUNT_)" } } else { @() }
    
    $NewContent += "USER_ID=$UserId"
    Write-Host "`$env:USER_ID=`"$UserId`""
    
    $Accounts = if ($SbaJson.result) { $SbaJson.result } else { $SbaJson.data }
    $OrderCaptured = $false
    foreach ($acc in $Accounts) {
        if (-not $acc.type) { continue }
        $Type = $acc.type.ToString().ToUpper()
        $Id = $acc.id
        $Ext = $acc.sub_account_ext
        $NewContent += "SUB_ACCOUNT_$($Type)=$Id"
        $NewContent += "SUB_ACCOUNT_EXT_$($Type)=$Ext"
        Write-Host "`$env:SUB_ACCOUNT_$($Type)=`"$Id`""
        Write-Host "`$env:SUB_ACCOUNT_EXT_$($Type)=`"$Ext`""
        # Sub-account dành riêng cho đặt lệnh — discriminator: subAccountExt kết thúc bằng ".4"
        if ((-not $OrderCaptured) -and ($Ext -like '*.4')) {
            $NewContent += "SUB_ACCOUNT_ORDER=$Id"
            $NewContent += "SUB_ACCOUNT_EXT_ORDER=$Ext"
            Write-Host "`$env:SUB_ACCOUNT_ORDER=`"$Id`""
            Write-Host "`$env:SUB_ACCOUNT_EXT_ORDER=`"$Ext`""
            $OrderCaptured = $true
        }
    }
    Set-Content -Path $CredsFile -Value ($NewContent -join "`n")
    Write-Host "✅ Account IDs resolved and saved to $CredsFile"
}

function Cmd-2FA {
    param($Sub, $A1, $A2)
    switch ($Sub) {
        "request" {
            Request-Internal -Method "POST" -Endpoint "/auth/v1/openapi/2fa/request" -Body "{`"channel`":`"EMAIL`"}"
        }
        "verify" {
            if (-not $A1 -or -not $A2) {
                Write-Error "Usage: 2fa verify <ticket_id> <otp_code>"
                return
            }
            $body = "{`"ticket_id`":`"$A1`",`"otp_code`":`"$A2`"}"
            $resp = Request-Internal -Method "POST" -Endpoint "/auth/v1/openapi/2fa/verify" -Body $body
            if (-not $resp) { return }
            $json = $resp | ConvertFrom-Json
            if (-not $json.session_token) {
                Write-Error "verify failed: $resp"
                return
            }
            Save-2FAToken -Token $json.session_token -ExpiresAt $json.expires_at -ExpiresAtEpoch $json.expires_at_epoch
            Write-Host ("✅ 2FA session đã lưu vào {0}, hết hạn {1}" -f $Session2faFile, $json.expires_at)
        }
        "status" {
            if (-not (Test-Path $Session2faFile)) {
                Write-Host "❌ Chưa có 2FA session. Chạy write request hoặc '.\finhay.ps1 2fa request' để bắt đầu."
                return
            }
            $lines = Get-Content $Session2faFile
            $exp_iso = ""
            $exp_epoch = ""
            foreach ($line in $lines) {
                if ($line -match '^expires_at=(.+)$') { $exp_iso = $matches[1] }
                elseif ($line -match '^expires_at_epoch=(.+)$') { $exp_epoch = $matches[1] }
            }
            $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            if ($exp_epoch -and [long]$exp_epoch -gt $now) {
                Write-Host ("✅ 2FA session đang hoạt động, hết hạn {0}" -f $exp_iso)
            } else {
                Write-Host ("⚠ 2FA session đã hết hạn ({0}). Cần verify OTP lại (Step 5) trước khi đặt lệnh." -f $exp_iso)
            }
        }
        "revoke" {
            $token = Load-2FAToken
            if (-not $token) {
                Clear-2FAToken
                Write-Host "Không có session active để revoke. File local đã được xoá."
                return
            }
            Request-Internal -Method "POST" -Endpoint "/auth/v1/openapi/2fa/revoke" -Body "{`"session_token`":`"$token`"}" | Out-Null
            Clear-2FAToken
            Write-Host "✅ 2FA session đã revoke (cả server + local)."
        }
        default {
            Write-Host "Usage: .\finhay.ps1 2fa <subcommand>"
            Write-Host "  request                        Yêu cầu OTP qua email"
            Write-Host "  verify <ticket_id> <otp_code>  Verify OTP và lưu session JWT"
            Write-Host "  status                         Xem trạng thái session hiện tại"
            Write-Host "  revoke                         Huỷ session (cả server + local)"
        }
    }
}

function Cmd-Sync {
    param($Skill)
    if (-not $Skill) { exit 1 }
    Write-Host "Syncing $Skill..."
    $RawUrl = "https://raw.githubusercontent.com/$Repo/$Branch"
    $ApiUrl = "https://api.github.com/repos/$Repo/git/trees/$Branch?recursive=1"
    $Tree = Invoke-RestMethod $ApiUrl
    $Files = $Tree.tree | Where-Object { $_.path -like "skills/$Skill/*" -and $_.type -eq "blob" }
    if (-not $Files) { exit 1 }
    $Tmp = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $Tmp | Out-Null
    foreach ($f in $Files) {
        $Dest = Join-Path $Tmp ($f.path.Substring("skills/".Length))
        $DestDir = Split-Path $Dest
        if (-not (Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir | Out-Null }
        Invoke-WebRequest -Uri "$RawUrl/$($f.path)" -OutFile $Dest
    }
    $LocalSkillPath = Join-Path "skills" $Skill
    if (-not (Test-Path "skills")) { New-Item -ItemType Directory -Path "skills" | Out-Null }
    if (Test-Path $LocalSkillPath) { Remove-Item -Path $LocalSkillPath -Recurse -Force }
    Copy-Item -Path (Join-Path $Tmp $Skill) -Destination "skills" -Recurse -Force
    Invoke-WebRequest -Uri "$RawUrl/finhay.sh" -OutFile (Join-Path $LocalSkillPath "finhay.sh")
    Invoke-WebRequest -Uri "$RawUrl/finhay.ps1" -OutFile (Join-Path $LocalSkillPath "finhay.ps1")
    Remove-Item -Path $Tmp -Recurse -Force
    Write-Host "✅ $Skill synced."
}

$Command = $args[0]
$ArgsList = $args[1..$args.Length]
switch ($Command) {
    "auth"    { Cmd-Auth }
    "doctor"  { Cmd-Doctor }
    "deps"    { Cmd-Deps }
    "infer"   { Cmd-Infer }
    "request" { Request-Internal -Method $ArgsList[0] -Endpoint $ArgsList[1] -Query $ArgsList[2] -Body $ArgsList[3] }
    "2fa"     { Cmd-2FA -Sub $ArgsList[0] -A1 $ArgsList[1] -A2 $ArgsList[2] }
    "sync"    { Cmd-Sync -Skill $ArgsList[0] }
    default   { Show-Help }
}
