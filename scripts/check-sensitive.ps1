# Fails if publishable content looks like it contains secrets or environment-specific identifiers.
# Usage: pwsh scripts/check-sensitive.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# Known-safe values (documented vendor defaults) that are allowed to appear.
$allowedIps = @('192.168.8.1')

$rules = [ordered]@{
  'private key block'      = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'Telegram bot token'     = '\b\d{8,}:[A-Za-z0-9_-]{30,}\b'
  'GitHub token'           = '\b(ghp|gho|ghu|ghs|ghr|github_pat)_[A-Za-z0-9_]{20,}'
  'API key (sk-/AKIA/xox)' = '\b(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,})'
  'MAC address'            = '\b[0-9A-Fa-f]{2}([:-][0-9A-Fa-f]{2}){5}\b'
  'Tailscale/dyn-DNS host' = '\b[a-z0-9-]+\.(ts\.net|duckdns\.org|no-ip\.\w+|dyndns\.\w+)\b'
  'WireGuard-style key'    = '\b[A-Za-z0-9+/]{43}=(?![A-Za-z0-9+/=])'
  'IPv4 address'           = '\b(?:\d{1,3}\.){3}\d{1,3}\b'
  'owner identity'         = '(?i)\bChri[s]tian(B2113)?\b'
  'training source name'   = '(?i)\b(W[G]U|Western Gove[r]nors|Comp[T]IA|Ci[s]co|Ud[e]my|Cours[e]ra)\b'
}

$files = Get-ChildItem -Path (Join-Path $root 'lessons'), (Join-Path $root 'templates') -Filter *.md -Recurse
$findings = foreach ($f in $files) {
  $lineNo = 0
  foreach ($line in Get-Content $f.FullName) {
    $lineNo++
    foreach ($name in $rules.Keys) {
      foreach ($m in [regex]::Matches($line, $rules[$name])) {
        if ($name -eq 'IPv4 address' -and ($allowedIps -contains $m.Value -or $m.Value -match '^(0|127|255|192\.0\.2|198\.51\.100|203\.0\.113)\.')) { continue }
        if ($name -eq 'MAC address' -and $m.Value -ieq '00:00:5E:00:53:01') { continue }
        [pscustomobject]@{ File = $f.Name; Line = $lineNo; Rule = $name; Match = $m.Value }
      }
    }
  }
}

if ($findings) {
  $findings | Format-Table -AutoSize | Out-String | Write-Host
  Write-Error "Sensitive-content check failed: $(@($findings).Count) finding(s)."
  exit 1
}
Write-Host 'Sensitive-content check passed.'
