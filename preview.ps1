<#
preview.ps1 - local live preview while you edit notes.

  powershell -ExecutionPolicy Bypass -File .\preview.ps1
  powershell -ExecutionPolicy Bypass -File .\preview.ps1 -Port 8081

Opens http://localhost:8080 , rebuilds automatically when a file in content/
changes (same clean URLs as the live site). Ctrl+C to stop.
#>
[CmdletBinding()]
param([int]$Port = 8080)

$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "preview: http://localhost:$Port  (Ctrl+C to stop)" -ForegroundColor Green
& node ./quartz/bootstrap-cli.mjs build --serve --watch --port $Port
