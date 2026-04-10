param([Parameter(Mandatory)][string]$Skill)

$ErrorActionPreference = "Stop"

$Repo   = "finhay/finhay-skills-hub"
$Branch = "main"
$Raw    = "https://raw.githubusercontent.com/$Repo/$Branch"
$Api    = "https://api.github.com/repos/$Repo"
$Ttl    = 12 * 3600
$RefEnv = Join-Path $env:USERPROFILE ".finhay\ref\.env"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
while ([IO.Path]::GetFileName($Root) -ne "skills") {
    $P = Split-Path -Parent $Root
    if ($P -eq $Root) { throw "ERROR: skills/ not found" }
    $Root = $P
}

Test-Path (Join-Path $Root "$Skill\SKILL.md") | Out-Null || { throw "ERROR: skill not found: $Skill" }

$ref = @{}
if (Test-Path $RefEnv) {
    Get-Content $RefEnv | ForEach-Object {
        if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') { $ref[$Matches[1]] = $Matches[2] }
    }
}

$now   = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$token = ($Skill.ToUpper() -replace '[^A-Z0-9]+','_')
$SK    = "SKILL_${token}_SYNC_AT"

$sharedStale = ($now - [long]($ref["SHARED_SYNC_AT"] ?? 0)) -gt $Ttl
$skillStale  = ($now - [long]($ref[$SK]               ?? 0)) -gt $Ttl

if (-not ($sharedStale -or $skillStale)) { Write-Host "$Skill`: up-to-date"; exit 0 }

$tree = (Invoke-RestMethod "$Api/git/trees/${Branch}?recursive=1").tree |
        Where-Object type -eq "blob"

function Sync-Component($Name, $Dest, $Prefix) {
    $ver = try { (Invoke-WebRequest "$Raw/skills/$Prefix/.version").Content.Trim() } catch { "unknown" }

    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("sync-" + [IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $tmp | Out-Null

    try {
        $items = $tree | Where-Object { $_.path.StartsWith("skills/$Prefix/") }

        foreach ($i in $items) {
            $rel = $i.path.Substring(7)
            $out = Join-Path $tmp $rel
            New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null

            if ($i.mode -eq "120000") {
                $target = (Invoke-WebRequest "$Raw/$($i.path)").Content.Trim()
                New-Item -ItemType SymbolicLink -Path $out -Target $target -Force | Out-Null 2>$null
            } else {
                Invoke-WebRequest "$Raw/$($i.path)" -OutFile $out
            }
        }

        Remove-Item $Dest -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item (Join-Path $tmp $Prefix) $Dest -Recurse

        Get-ChildItem $Dest -Recurse -Filter *.sh | ForEach-Object {
            $_.Attributes = $_.Attributes -bor [IO.FileAttributes]::Normal
        }

        Write-Host "${Name}: synced ($ver)"
    }
    finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    }
}

if ($sharedStale) { Sync-Component "_shared" (Join-Path $Root "_shared") "_shared" }
if ($skillStale)  { Sync-Component $Skill   (Join-Path $Root $Skill)    $Skill }

if ($sharedStale) { $ref["SHARED_SYNC_AT"] = $now }
if ($skillStale)  { $ref[$SK] = $now }

$tmp2 = "$RefEnv.tmp"
$ref.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } | Set-Content $tmp2 -Encoding UTF8
Move-Item -Force $tmp2 $RefEnv