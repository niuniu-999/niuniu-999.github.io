<#
deploy-cf.ps1 - publish the built site to Cloudflare Pages (accessible from mainland China,
no ICP filing needed, free plan is enough). Works without github.com.

One-time setup (browser):
  1) https://dash.cloudflare.com -> sign up / log in
  2) My Profile -> API Tokens -> Create Token -> template "Edit Cloudflare Workers"
     (or custom token with Account > Cloudflare Pages > Edit)
  3) copy Account ID from the dashboard URL / Workers & Pages overview

Then:
  $env:CLOUDFLARE_API_TOKEN  = "your-token"
  $env:CLOUDFLARE_ACCOUNT_ID = "your-account-id"
  powershell -ExecutionPolicy Bypass -File .\deploy-cf.ps1

Result: https://ctf-garden.pages.dev
#>
[CmdletBinding()]
param(
  [string]$Project = "ctf-garden",
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

$tok = $env:CLOUDFLARE_API_TOKEN
$acc = $env:CLOUDFLARE_ACCOUNT_ID
if (-not $tok) { $tok = $env:CF_API_TOKEN }
if (-not $acc) { $acc = $env:CF_ACCOUNT_ID }
if (-not $tok -or -not $acc) {
  Write-Host "missing CLOUDFLARE_API_TOKEN / CLOUDFLARE_ACCOUNT_ID" -ForegroundColor Yellow
  Write-Host "see the comment block at the top of this file for how to get them"
  exit 2
}
$env:CLOUDFLARE_API_TOKEN = $tok
$env:CLOUDFLARE_ACCOUNT_ID = $acc

if (-not $SkipBuild) {
  Write-Host "== build" -ForegroundColor Cyan
  & node ./quartz/bootstrap-cli.mjs build
  if ($LASTEXITCODE -ne 0) { throw "quartz build failed" }
}

if (-not (Test-Path "./public/index.html")) { throw "public/index.html missing, run a build first" }

$wrangler = "./node_modules/.bin/wrangler.cmd"
if (-not (Test-Path $wrangler)) {
  Write-Host "== installing wrangler (via npmmirror)" -ForegroundColor Cyan
  $env:npm_config_registry = "https://registry.npmmirror.com"
  & npm install --no-save --no-audit --no-fund wrangler@3
  $env:npm_config_registry = "https://registry.npmjs.org"
  if (-not (Test-Path $wrangler)) { throw "wrangler install failed" }
}

Write-Host "== deploy to Cloudflare Pages" -ForegroundColor Cyan
& $wrangler pages deploy ./public --project-name $Project --branch main --commit-dirty=true
if ($LASTEXITCODE -ne 0) { throw "pages deploy failed (exit $LASTEXITCODE)" }

Write-Host ""
Write-Host "site: https://$Project.pages.dev" -ForegroundColor Green
Write-Host "dashboard: https://dash.cloudflare.com/?to=/:account/pages/view/$Project"
