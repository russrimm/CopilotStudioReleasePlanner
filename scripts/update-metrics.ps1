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
$securityTerms = 'credential','sensitivity','governance','label'
$security = ($rows | Where-Object { $securityTerms | ForEach-Object { if($_ -match $_){ $true } } })
$securityCount = $security.Count
$multimodal = ($rows | Where-Object { $_ -match 'image' -or $_ -match 'Code interpreter' -or $_ -match 'file & image' }).Count

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