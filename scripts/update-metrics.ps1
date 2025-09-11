<#
.SYNOPSIS
  Updates the At a Glance metrics & status badges in README.md using features.json + LAST30 table.
.DESCRIPTION
  Parses features.json for overall status counts (GA, Preview, Planned GA (non-TBD), TBD bucket).
  Parses LAST30_TABLE window in README to count GA and Preview items and transitions.
  Rewrites the AT_A_GLANCE block and status badges line.
#>
$ErrorActionPreference='Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$readme = Join-Path $root 'README.md'
$manifest = Join-Path $root 'features.json'
if(-not (Test-Path $manifest)){ throw 'features.json not found' }
$json = Get-Content $manifest -Raw | ConvertFrom-Json

# Status tallies (overall future landscape)
$ga = ($json | Where-Object { $_.currentStatus -match '^GA' }).Count
$preview = ($json | Where-Object { $_.currentStatus -match 'Preview' }).Count
$planned = ($json | Where-Object { $_.plannedGA -and $_.plannedGA -notmatch 'TBD' }).Count
$tbd = ($json | Where-Object { ($_.plannedGA -and $_.plannedGA -match 'TBD') -or ($_.currentStatus -match 'TBD') }).Count

$content = Get-Content $readme -Raw
$last30 = [regex]::Match($content,'(?s)<!-- BEGIN:LAST30_TABLE -->(.*?)<!-- END:LAST30_TABLE -->')
if(-not $last30.Success){ throw 'LAST30_TABLE markers not found' }
$rows = $last30.Groups[1].Value -split "`n" | Where-Object { $_ -match '^\|' } | Select-Object -Skip 2
$windowGA = ($rows | Where-Object { $_ -match '\|\s*GA' }).Count
$windowPreview = ($rows | Where-Object { $_ -match '\|\s*Preview' }).Count
$transitions = ($rows | Where-Object { $_ -match 'was Preview' -or $_ -match 'Preview → GA' }).Count

# Heuristic counts for thematic categories in window
$securityTerms = 'credential','sensitivity label','sensitivity','governance','catalog','label '
$securityCount = 0
foreach($r in $rows){
  if($securityTerms | Where-Object { $r -match $_ }){ $securityCount++ }
}
$multimodal = ($rows | Where-Object { $_ -match '(?i)image' -or $_ -match '(?i)interpreter' -or $_ -match 'file & image' }).Count

# Build new AT_A_GLANCE table
$newTable = @(
  '| Metric | Count | Notes |',
  '|--------|-------|-------|',
  "| GA features (last 30d window) | $windowGA | Newly GA or GA confirmations |",
  "| Preview items (last 30d window) | $windowPreview | Active evaluation required |",
  "| Preview → GA transitions (window) | $transitions | Status promotions |",
  "| Security / Governance related updates | $securityCount | Auto keyword heuristic |",
  "| Multimodal / Execution updates | $multimodal | Interpreter & file/image pipeline |"
) -join "`n"

$updated = [regex]::Replace($content,'(?s)<!-- BEGIN:AT_A_GLANCE -->.*?<!-- END:AT_A_GLANCE -->',"<!-- BEGIN:AT_A_GLANCE -->`n$newTable`n<!-- END:AT_A_GLANCE -->")

# Update badges line
$badgePattern = 'Status: !\[GA\].*'
$badgeLine = "Status: ![GA](https://img.shields.io/badge/GA-$ga-brightgreen) ![Preview](https://img.shields.io/badge/Preview-$preview-orange) ![Planned_GA](https://img.shields.io/badge/Planned_GA-$planned-blue) ![TBD](https://img.shields.io/badge/TBD-$tbd-lightgrey)"
if($updated -match $badgePattern){
  $updated = [regex]::Replace($updated,$badgePattern,[System.Text.RegularExpressions.MatchEvaluator]{ param($m) $badgeLine })
}

if($updated -ne $content){ Set-Content -Path $readme -Value $updated -Encoding UTF8; Write-Host 'Metrics updated.' } else { Write-Host 'No metrics changes.' }

# Also refresh lifecycle funnel counts if markers present (non-authoritative; main generation occurs in refresh-future-roadmap but this keeps them updated if roadmap script not run)
try {
  $lcMatch = [regex]::Match($updated,'(?s)<!-- BEGIN:LIFECYCLE_FUNNEL -->(.*?)<!-- END:LIFECYCLE_FUNNEL -->')
  if($lcMatch.Success){
    $features = $json
    $now = Get-Date
    function ParseDate([string]$v){
      if([string]::IsNullOrWhiteSpace($v)){ return $null }
      try { return [DateTime]::Parse($v, [System.Globalization.CultureInfo]::InvariantCulture) } catch { return $null }
    }
    $previewCount = ($features | Where-Object { $_.lifecycleStage -eq 'Preview' }).Count
    $plannedCount = ($features | Where-Object { $_.plannedGA -and $_.plannedGA -notmatch 'TBD' -and $_.lifecycleStage -notin 'GA','Enhancing','Preview' }).Count
    $enhancingCount = ($features | Where-Object { $_.lifecycleStage -match 'Enhancing' }).Count
    $gaCount = ($features | Where-Object { $_.lifecycleStage -eq 'GA' }).Count
    $dormantCount = ($features | Where-Object { $_.lastUpdate -and (ParseDate $_.lastUpdate) -and ($now - (ParseDate $_.lastUpdate)).TotalDays -gt 90 }).Count
    $stalePreview = ($features | Where-Object { $_.lifecycleStage -eq 'Preview' -and $_.previewStart -and (ParseDate $_.previewStart) -and ($now - (ParseDate $_.previewStart)).TotalDays -gt 180 }).Count
    $lcTable = @(
      '| Stage | Count | Notes |',
      '|-------|-------|-------|',
      "| 🧪 Preview | $previewCount | active early access |",
      "| 📅 Planned | $plannedCount | date published, pre-preview |",
      "| 🔍 Enhancing | $enhancingCount | post-GA iteration |",
      "| ✅ GA | $gaCount | fully released |",
      "| 💤 Dormant | $dormantCount | >90d no update |",
      "| ⚠ Stale Preview | $stalePreview | >180d preview |"
    ) -join "`n"
    $updated2 = [regex]::Replace($updated,'(?s)<!-- BEGIN:LIFECYCLE_FUNNEL -->.*?<!-- END:LIFECYCLE_FUNNEL -->',"<!-- BEGIN:LIFECYCLE_FUNNEL -->`n$lcTable`n<!-- END:LIFECYCLE_FUNNEL -->")
    if($updated2 -ne $updated){ Set-Content -Path $readme -Value $updated2 -Encoding UTF8; Write-Host 'Lifecycle funnel refreshed.' }
  }
} catch { Write-Warning "Lifecycle funnel refresh failed: $($_.Exception.Message)" }