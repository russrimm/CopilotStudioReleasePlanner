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
  [string[]]$TargetFiles = @('README.md'),
  [switch]$EnsureNextHeadingRange = $true
)

$todayObj = Get-Date
$today = $todayObj.ToString('yyyy-MM-dd')

# Last 30 days: inclusive span ending today with 30 calendar days total => start = today - 29 days
$lastStart = $todayObj.AddDays(-29)
$lastStartStr = $lastStart.ToString('yyyy-MM-dd')
$lastEndStr = $today

# Next 30 days forward window: inclusive span starting today; end = today + 29 days (30 calendar days total)
$nextStart = $todayObj
$nextEnd = $todayObj.AddDays(29)
$nextStartStr = $nextStart.ToString('yyyy-MM-dd')
$nextEndStr = $nextEnd.ToString('yyyy-MM-dd')

$patternLast = '^## Last 30 Days Feature Changes \([^)]*\)'
$replacementLast = "## Last 30 Days Feature Changes ($lastStartStr to $lastEndStr)"

$patternNextWithRange = '^## Next 30 Days Planned Changes \([^)]*\)'
$replacementNext = "## Next 30 Days Planned Changes ($nextStartStr to $nextEndStr)"

# Secondary pattern: heading present but missing range (e.g., "## Next 30 Days Planned Changes (Forward Look)")
$patternNextAny = '^## Next 30 Days Planned Changes.*$'

$filesUpdated = 0
foreach ($file in $TargetFiles) {
  $full = Join-Path $RepoRoot $file
  if (-not (Test-Path $full)) { Write-Host "[skip] $full not found"; continue }
  $content = Get-Content $full -Raw
  $newContent = $content
  $changed = $false

  # Debug diagnostics
  $debugLast = [Regex]::Matches($newContent, $patternLast, 'IgnoreCase, Multiline').Count
  Write-Host "[debug] Last-pattern matches: $debugLast"
  $debugNext = [Regex]::Matches($newContent, $patternNextWithRange, 'IgnoreCase, Multiline').Count
  Write-Host "[debug] Next-pattern (with range) matches: $debugNext"
  $debugNextAny = [Regex]::Matches($newContent, $patternNextAny, 'IgnoreCase, Multiline').Count
  Write-Host "[debug] Next-pattern (any) matches: $debugNextAny"

  if ($debugLast -gt 0) {
    $updatedLocal = [Regex]::Replace($newContent, $patternLast, $replacementLast, 'IgnoreCase, Multiline')
    if ($updatedLocal -ne $newContent) { $newContent = $updatedLocal; $changed = $true; Write-Host "[updated:last] $file -> $lastStartStr to $lastEndStr" } else { Write-Host "[no change:last] $file already current" }
  } else { Write-Warning "Last 30 Days heading not found in $file" }

  if ($EnsureNextHeadingRange) {
    if ($debugNext -gt 0) {
      $updatedLocal2 = [Regex]::Replace($newContent, $patternNextWithRange, $replacementNext, 'IgnoreCase, Multiline')
      if ($updatedLocal2 -ne $newContent) { $newContent = $updatedLocal2; $changed = $true; Write-Host "[updated:next] (range refresh) $file -> $nextStartStr to $nextEndStr" } else { Write-Host "[no change:next] $file already current" }
    } elseif ($debugNextAny -gt 0) {
      $updatedLocal3 = [Regex]::Replace($newContent, $patternNextAny, $replacementNext, 'IgnoreCase, Multiline')
      if ($updatedLocal3 -ne $newContent) { $newContent = $updatedLocal3; $changed = $true; Write-Host "[updated:next] (added missing range) $file -> $nextStartStr to $nextEndStr" } else { Write-Host "[no change:next] pattern found but no diff" }
    } else {
      Write-Warning "Next 30 Days heading not found in $file"
    }
  }

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
