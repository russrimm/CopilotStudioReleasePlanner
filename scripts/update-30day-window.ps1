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

$todayObj = Get-Date
$today = $todayObj.ToString('yyyy-MM-dd')

# Last 30 days: inclusive span ending today with 30 calendar days total => start = today - 29 days
$lastStart = $todayObj.AddDays(-29)
$lastStartStr = $lastStart.ToString('yyyy-MM-dd')
$lastEndStr = $today

# Next 30 days forward window: start today (forward look includes today) end = today + 30 days
$nextStart = $todayObj
$nextEnd = $todayObj.AddDays(30)
$nextStartStr = $nextStart.ToString('yyyy-MM-dd')
$nextEndStr = $nextEnd.ToString('yyyy-MM-dd')

$patternLast = '^## Last 30 Days Feature Changes \([^)]*\)'
$replacementLast = "## Last 30 Days Feature Changes ($lastStartStr to $lastEndStr)"

$patternNext = '^## Next 30 Days Planned Changes \([^)]*\)'
$replacementNext = "## Next 30 Days Planned Changes ($nextStartStr to $nextEndStr)"

$filesUpdated = 0
foreach ($file in $TargetFiles) {
  $full = Join-Path $RepoRoot $file
  if (-not (Test-Path $full)) { Write-Host "[skip] $full not found"; continue }
  $content = Get-Content $full -Raw
  $newContent = $content
  $changed = $false

  if ($newContent -match $patternLast) {
    $updatedLocal = [System.Text.RegularExpressions.Regex]::Replace($newContent, $patternLast, $replacementLast, 'IgnoreCase, Multiline')
    if ($updatedLocal -ne $newContent) { $newContent = $updatedLocal; $changed = $true; Write-Host "[updated:last] $file -> $lastStartStr to $lastEndStr" } else { Write-Host "[no change:last] $file already current" }
  } else { Write-Warning "Last 30 Days heading not found in $file" }

  if ($newContent -match $patternNext) {
    $updatedLocal2 = [System.Text.RegularExpressions.Regex]::Replace($newContent, $patternNext, $replacementNext, 'IgnoreCase, Multiline')
    if ($updatedLocal2 -ne $newContent) { $newContent = $updatedLocal2; $changed = $true; Write-Host "[updated:next] $file -> $nextStartStr to $nextEndStr" } else { Write-Host "[no change:next] $file already current" }
  } else { Write-Warning "Next 30 Days heading not found in $file" }

  if ($changed) {
    Set-Content -Path $full -Value $newContent -NoNewline
    $filesUpdated++
  }
}

if ($filesUpdated -eq 0) {
  Write-Host "No files required updating.";
} else {
  Write-Host "$filesUpdated file(s) updated.";
}
