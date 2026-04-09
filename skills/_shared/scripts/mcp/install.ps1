$ErrorActionPreference = "Stop"

function Invoke-FinhayInstall {
    Write-Host ""
    Write-Host "  Finhay MCP Server — Cai dat cho Claude Desktop"
    Write-Host ""

    # --- Check & install Node.js ---
    $NodeExe = $null
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $NodeExe = "node"
    } else {
        Write-Host "  Node.js chua duoc cai dat. Dang cai dat..."
        Write-Host ""

        $TmpDir = Join-Path $env:TEMP "finhay-node-install"
        New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

        $NodeMsi = Join-Path $TmpDir "node-installer.msi"
        $NodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"

        Write-Host "  Dang tai Node.js tu nodejs.org..."
        Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeMsi -UseBasicParsing

        Write-Host "  Dang cai dat Node.js (vui long nhan Yes neu co prompt UAC)..."
        $MsiProcess = Start-Process msiexec.exe -ArgumentList "/i", "`"$NodeMsi`"", "/quiet", "/norestart" -Wait -PassThru
        if ($MsiProcess.ExitCode -ne 0) {
            throw "Node.js installer tra ve ma loi $($MsiProcess.ExitCode). Hay cai thu cong tai https://nodejs.org"
        }

        Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue

        # Refresh PATH from system environment
        $MachinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
        $UserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
        $env:PATH = "$MachinePath;$UserPath"

        # Try common Node.js install paths
        $NodePaths = @(
            "$env:ProgramFiles\nodejs\node.exe",
            "${env:ProgramFiles(x86)}\nodejs\node.exe"
        )
        foreach ($p in $NodePaths) {
            if (Test-Path $p) {
                $NodeExe = $p
                $env:PATH = "$(Split-Path $p);$env:PATH"
                break
            }
        }

        if (-not $NodeExe) {
            if (Get-Command node -ErrorAction SilentlyContinue) {
                $NodeExe = "node"
            }
        }

        if (-not $NodeExe) {
            throw "Khong the tim thay Node.js sau khi cai. Hay dong PowerShell, mo lai va chay lenh nay mot lan nua."
        }

        $NodeVersion = & $NodeExe -v
        Write-Host "  Node.js $NodeVersion da duoc cai dat."
        Write-Host ""
    }

    # --- Credentials ---
    $CredsDir = Join-Path $env:USERPROFILE ".finhay\credentials"
    $CredsFile = Join-Path $CredsDir ".env"

    $ApiKey = ""
    $ApiSecret = ""

    if (Test-Path $CredsFile) {
        $Content = Get-Content $CredsFile -Raw
        $KeyMatch = [regex]::Match($Content, 'FINHAY_API_KEY=(.+)')
        $SecretMatch = [regex]::Match($Content, 'FINHAY_API_SECRET=(.+)')

        if ($KeyMatch.Success -and $SecretMatch.Success) {
            $ExistingKey = $KeyMatch.Groups[1].Value.Trim()
            $ExistingSecret = $SecretMatch.Groups[1].Value.Trim()
            $MaskedKey = $ExistingKey.Substring(0, [Math]::Min(8, $ExistingKey.Length)) + "***"

            Write-Host "  Tim thay credentials tai $CredsFile"
            Write-Host "  API Key: $MaskedKey"
            Write-Host ""
            $Reuse = Read-Host "  Su dung credentials nay? (Y/n)"
            if ($Reuse -ne "n") {
                $ApiKey = $ExistingKey
                $ApiSecret = $ExistingSecret
            }
            Write-Host ""
        }
    }

    if (-not $ApiKey) {
        Write-Host "  Tao API Key tai: https://www.finhay.com.vn/finhay-skills"
        Write-Host ""
        $ApiKey = Read-Host "  API Key"
        if (-not $ApiKey) {
            throw "API Key khong duoc de trong."
        }

        $SecureSecret = Read-Host "  API Secret" -AsSecureString
        $ApiSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureSecret)
        )
        if (-not $ApiSecret) {
            throw "API Secret khong duoc de trong."
        }

        # Save credentials
        New-Item -ItemType Directory -Force -Path $CredsDir | Out-Null
        @"
FINHAY_API_KEY=$ApiKey
FINHAY_API_SECRET=$ApiSecret
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
"@ | Set-Content -Path $CredsFile -Encoding UTF8

        Write-Host ""
        Write-Host "  Credentials: $CredsFile"
        Write-Host ""
    }

    # --- Claude Desktop config ---
    # Check Microsoft Store version first
    $LocalAppData = $env:LOCALAPPDATA
    $StorePath = Join-Path $LocalAppData "Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json"
    $StandardPath = Join-Path $env:APPDATA "Claude\claude_desktop_config.json"

    if (Test-Path (Split-Path $StorePath -Parent)) {
        $ConfigPath = $StorePath
    } else {
        $ConfigPath = $StandardPath
    }

    $ConfigDir = Split-Path $ConfigPath -Parent
    New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

    $FinhayEntry = @{
        command = "npx"
        args = @("-y", "finhay-mcp-server")
    }

    if (Test-Path $ConfigPath) {
        $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (-not $Config.mcpServers) {
            $Config | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{}
        }
        if ($Config.mcpServers.finhay) {
            Write-Host "  Claude Desktop config da co entry 'finhay', cap nhat lai."
        }
        $Config.mcpServers | Add-Member -NotePropertyName "finhay" -NotePropertyValue $FinhayEntry -Force
        $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
    } else {
        @{
            mcpServers = @{
                finhay = $FinhayEntry
            }
        } | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
    }

    Write-Host "  Claude Desktop config: $ConfigPath"
    Write-Host ""
    Write-Host "  Da cai dat thanh cong!"
    Write-Host "  Hay khoi dong lai Claude Desktop de su dung."
    Write-Host ""
}

try {
    Invoke-FinhayInstall
} catch {
    Write-Host ""
    Write-Host "  Loi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
