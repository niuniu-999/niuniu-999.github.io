$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$lines = Get-Content -LiteralPath $hostsPath
$newLines = $lines | ForEach-Object {
  $_ -replace '^20\.205\.243\.166\s+github\.com.*$', '140.82.112.3 github.com' `
     -replace '^20\.205\.243\.168\s+api\.github\.com.*$', '140.82.114.3 api.github.com' `
     -replace '^20\.205\.243\.165\s+codeload\.github\.com.*$', '140.82.121.3 codeload.github.com'
}
Set-Content -LiteralPath $hostsPath -Value $newLines -Encoding utf8
ipconfig /flushdns | Out-Null
Write-Host "Hosts updated to 140.82.x.x. Press any key."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
