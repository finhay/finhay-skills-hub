$RepoUrl = "https://github.com/finhay/finhay-skills-hub.git"
$Branch = "main"
$WorkDir = "_tmp_finhay_skills_hub"
$CurDir = Get-Location

Remove-Item -Path "$CurDir\finhay-market", "$CurDir\finhay-portfolio" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$CurDir\finhay-market.zip", "$CurDir\finhay-portfolio.zip" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$CurDir\$WorkDir" -Recurse -Force -ErrorAction SilentlyContinue

git clone -b $Branch $RepoUrl "$CurDir\$WorkDir"

Get-ChildItem -Path "$CurDir\$WorkDir\skills" -Directory | ForEach-Object {
    Copy-Item -Path "$CurDir\$WorkDir\finhay.sh", "$CurDir\$WorkDir\finhay.ps1" -Destination $_.FullName -Force
}

Set-Location "$CurDir\$WorkDir\skills"
Compress-Archive -Path "finhay-market" -DestinationPath "$CurDir\finhay-market.zip" -Force
Compress-Archive -Path "finhay-portfolio" -DestinationPath "$CurDir\finhay-portfolio.zip" -Force

Set-Location "$CurDir"
Remove-Item -Path "$CurDir\$WorkDir" -Recurse -Force

Write-Host "Done. Created $CurDir\finhay-market.zip and $CurDir\finhay-portfolio.zip."
