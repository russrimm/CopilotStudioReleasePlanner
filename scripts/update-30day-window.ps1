<#!
.SYNOPSIS
  Updates the 30-day window date range in README.md (and optionally other markdown files) for the section:
  '## Last 30 Days Feature Changes (<start> to <end>)'
.DESCRIPTION
  Calculates Start = (Today - 30 days + 1) to keep an inclusive 30-day span ending Today.
  Replaces the existing parenthetical date range while preserving the rest of the heading line.
  If no heading found, logs a warning and exits with code 0 (non-fatal).
.NOTES
  Intended to be run via GitHub Actions daily. Idempotent.
#>

Param(
  [string]$RepoRoot = (Resolve-Path "$PSScriptRoot/.."),
  [string[]]$TargetFiles = @('README.md')
)

$today = Get-Date -Format 'yyyy-MM-dd'
$start = (Get-Date).AddDays(-30).AddDays(1) # inclusive span of 30 days ending today
$startStr = $start.ToString('yyyy-MM-dd')
$endStr = (Get-Date).ToString('yyyy-MM-dd')

$pattern = '^## Last 30 Days Feature Changes \([^)]*\)'
$replacement = "## Last 30 Days Feature Changes ($startStr to $endStr)"

$filesUpdated = 0
foreach ($file in $TargetFiles) {
  $full = Join-Path $RepoRoot $file
  if (-not (Test-Path $full)) { Write-Host "[skip] $full not found"; continue }
  $content = Get-Content $full -Raw
  if ($content -match $pattern) {
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, $replacement, 'IgnoreCase, Multiline')
    if ($newContent -ne $content) {
      Set-Content -Path $full -Value $newContent -NoNewline
      Write-Host "[updated] $file -> $startStr to $endStr"
      $filesUpdated++
    } else {
      Write-Host "[no change] Pattern matched but dates already current in $file"
    }
  } else {
    Write-Warning "Section heading not found in $file"
  }
}

if ($filesUpdated -eq 0) {
  Write-Host "No files required updating.";
} else {
  Write-Host "$filesUpdated file(s) updated.";
}
