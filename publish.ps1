<#
publish.ps1 - build the Quartz site and publish it to GitHub Pages.

Usage:
  pwsh -File publish.ps1
  pwsh -File publish.ps1 -Message "add reverse notes"
  pwsh -File publish.ps1 -SkipBuild

Flow:
  1) node ./quartz/bootstrap-cli.mjs build
  2) git add -A + commit
  3) git push origin HEAD:main
  4) if github.com:443 is blocked, fall back to the GitHub REST API
     (blob/tree/commit/ref) using the token stored in Windows Credential Manager.
#>
[CmdletBinding()]
param(
  [string]$Message = "",
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function Step([string]$t) { Write-Host ""; Write-Host "== $t" -ForegroundColor Cyan }
function Info([string]$t) { Write-Host "   $t" }

# ---------------------------------------------------------------- 1. build
if (-not $SkipBuild) {
  Step "build"
  & node ./quartz/bootstrap-cli.mjs build
  if ($LASTEXITCODE -ne 0) { throw "quartz build failed (exit $LASTEXITCODE)" }
} else {
  Step "build (skipped)"
}

# ---------------------------------------------------------------- 2. commit
Step "commit"
$un = (& git config user.name)
$ue = (& git config user.email)
if (-not $un) { & git config user.name "niuniu-999"; $un = "niuniu-999" }
if (-not $ue) { & git config user.email "yilongj98@gmail.com"; $ue = "yilongj98@gmail.com" }

& git add -A
& git add -f .gitignore 2>$null
$dirty = (& git status --porcelain)
if ($dirty) {
  if (-not $Message) { $Message = "notes: update " + (Get-Date -Format "yyyy-MM-dd HH:mm") }
  & git commit -q -m $Message
  if ($LASTEXITCODE -ne 0) { throw "git commit failed" }
  Info ("committed " + $Message)
} else {
  Info "no local changes"
  if (-not $Message) { $Message = (& git log -1 --format=%B) }
}

# ---------------------------------------------------------------- 3. push
Step "push"
$env:GIT_TERMINAL_PROMPT = "0"
$ErrorActionPreference = "Continue"
& git -c credential.helper=manager push origin HEAD:main 2>&1 | ForEach-Object { Write-Host "   $_" }
$pushOk = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = "Stop"
if ($pushOk) {
  Info "pushed with git"
  Write-Host ""
  Write-Host "Done: https://niuniu-999.github.io/" -ForegroundColor Green
  exit 0
}
Write-Host "   git push failed (github.com unreachable?) -> using REST API" -ForegroundColor Yellow

# ---------------------------------------------------------------- 4. REST API push
Step "api push"

$credIn = "protocol=https`nhost=github.com`n`n"
$cred = $credIn | & git -c credential.helper=manager credential fill 2>$null
$Token = ($cred | Where-Object { $_ -like "password=*" }) -replace "^password=", ""
if (-not $Token) { throw "no github credential in Windows Credential Manager (run: git credential-manager configure)" }

$origin = (& git remote get-url origin)
$clean = $origin -replace '\.git$', ''
$seg = $clean -split '[/:]'
$script:Repo = $seg[-1]
$script:Owner = $seg[-2]
Info "repo $Owner/$Repo"

function Invoke-Gh([string]$Method, [string]$Path, $Body = $null) {
  $p = @{
    Uri        = "https://api.github.com/repos/$Owner/$Repo$Path"
    Method     = $Method
    Headers    = @{ Authorization = "token $Token"; Accept = "application/vnd.github+json"; "User-Agent" = "ctf-garden-publish" }
    TimeoutSec = 90
  }
  if ($null -ne $Body) {
    $p.Body = [System.Text.Encoding]::UTF8.GetBytes(($Body | ConvertTo-Json -Depth 12 -Compress))
    $p.ContentType = "application/json; charset=utf-8"
  }
  try {
    Invoke-RestMethod @p
  } catch {
    $m = $_.Exception.Message
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $m = $m + " | " + $_.ErrorDetails.Message }
    throw "API $Method $Path failed: $m"
  }
}

function Upload-Blob([string]$sha) {
  $tmp = [System.IO.Path]::GetTempFileName()
  & cmd /c "git cat-file blob $sha > `"$tmp`"" | Out-Null
  $b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($tmp))
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  $r = Invoke-Gh POST "/git/blobs" @{ content = $b64; encoding = "base64" }
  if ($r.sha -ne $sha) { throw "blob sha mismatch: local $sha remote $($r.sha)" }
  $r.sha
}

$ref = Invoke-Gh GET "/git/ref/heads/main"
$remoteSha = $ref.object.sha
$remoteCommit = Invoke-Gh GET "/git/commits/$remoteSha"
$remoteTree = $remoteCommit.tree.sha
Info "remote head $($remoteSha.Substring(0,7))"

$remoteFlat = @{}
$treeResp = Invoke-Gh GET ("/git/trees/{0}?recursive=1" -f $remoteTree)
foreach ($e in $treeResp.tree) { if ($e.type -eq "blob") { $remoteFlat[$e.path] = @{ sha = $e.sha; mode = $e.mode } } }

$localFlat = @{}
foreach ($line in (& git ls-tree -r HEAD)) {
  $tab = $line.IndexOf("`t")
  if ($tab -lt 0) { continue }
  $meta = $line.Substring(0, $tab) -split ' '
  if ($meta[1] -ne 'blob') { continue }
  $localFlat[$line.Substring($tab + 1)] = @{ sha = $meta[2]; mode = $meta[0] }
}
Info ("local blobs {0} / remote blobs {1}" -f $localFlat.Count, $remoteFlat.Count)

$entries = New-Object System.Collections.Generic.List[object]
foreach ($p in $localFlat.Keys) {
  $ls = $localFlat[$p]
  if ($remoteFlat.ContainsKey($p) -and $remoteFlat[$p].sha -eq $ls.sha) { continue }
  $blobSha = Upload-Blob $ls.sha
  $mode = if ($ls.mode -in @('100755', '120000')) { $ls.mode } else { '100644' }
  $entries.Add(@{ path = $p; mode = $mode; type = 'blob'; sha = $blobSha })
  Info ("+ {0}" -f $p)
}
foreach ($p in $remoteFlat.Keys) {
  if ($localFlat.ContainsKey($p)) { continue }
  $entries.Add(@{ path = $p; mode = $remoteFlat[$p].mode; type = 'blob'; sha = $null })
  Info ("- {0}" -f $p)
}

if ($entries.Count -eq 0) {
  Info "local tree already equals remote tree, nothing to push"
  exit 0
}

$newTree = Invoke-Gh POST "/git/trees" @{ base_tree = $remoteTree; tree = $entries.ToArray() }
$msg = ((& git log -1 --format=%B) -join "`n").TrimEnd()
$newCommit = Invoke-Gh POST "/git/commits" @{ message = $msg; tree = $newTree.sha; parents = @($remoteSha) }
Invoke-Gh PATCH "/git/refs/heads/main" @{ sha = $newCommit.sha; force = $false } | Out-Null

Write-Host ""
Write-Host ("pushed via API: " + $newCommit.sha) -ForegroundColor Green
Write-Host "note: local and remote commit hashes differ (GitHub re-signs timestamps) but tree is identical."
Write-Host "      when github.com is reachable again run:  git fetch origin; git reset --hard origin/main"
Write-Host "actions: https://github.com/$Owner/$Repo/actions"
