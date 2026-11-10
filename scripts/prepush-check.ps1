# Blocks a push if tracked files or commits leak identity, secrets or build junk.
# Personal terms live OUTSIDE the repo in $env:MR_BLOCKLIST (one regex per line).
$ErrorActionPreference = 'Continue'
$root = git rev-parse --show-toplevel
Set-Location $root
$fail = @()

$junk = git ls-files | Select-String -Pattern '(__pycache__|\.pyc$|^_site|^preview\.log|^\.env|id_(rsa|ed25519))'
if ($junk) { $fail += "Tracked junk files:`n$($junk -join "`n")" }

$generic = 'github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{20,}|BEGIN [A-Z ]*PRIVATE KEY|[A-Za-z]:\\Users\\|/home/[a-z]+/'
$hits = git grep -a -n -I -E $generic -- . ':!scripts/prepush-check.ps1' ':!scripts/check-sensitive.ps1' 2>$null
$hitsBin = git grep -a -l -E 'github_pat_|[A-Za-z]:\\Users\\' -- . ':!scripts/*' 2>$null
if ($hits) { $fail += "Secret/path patterns:`n$($hits -join "`n")" }
if ($hitsBin) { $fail += "Binary files with secret/path patterns:`n$($hitsBin -join "`n")" }

$bl = $env:MR_BLOCKLIST
if (-not $bl) { $bl = (Join-Path $root '..\mr-roboto-private\blocklist.txt') }
if (Test-Path $bl) {
  $p = git grep -a -n -i -E -f $bl -- . 2>$null
  if ($p) { $fail += "Blocklisted personal terms in tracked files:`n$($p -join "`n")" }
  $meta = git log --all --format='%an|%ae|%cn|%ce|%s%n%b'
  foreach ($line in (Get-Content $bl)) {
    if ($line.Trim() -and ($meta -match "(?i)$line")) { $fail += "Blocklisted term '$line' in commit metadata" }
  }
} else { $fail += "Blocklist not found at $bl (refusing to push unchecked)" }

$authors = git log --all --format='%an <%ae>' | Sort-Object -Unique
$bad = $authors | Where-Object { $_ -ne 'Mr. Roboto <mrroboto@users.noreply.invalid>' }
if ($bad) { $fail += "Unexpected commit authors:`n$($bad -join "`n")" }

if ($fail) { Write-Host "PUSH BLOCKED`n" -ForegroundColor Red; $fail | ForEach-Object { Write-Host $_ }; exit 1 }
Write-Host 'prepush-check: clean' -ForegroundColor Green
