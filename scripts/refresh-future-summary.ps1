<#
.SYNOPSIS
  Regenerates the concise future summary table in README.md from Future_Planned_Features.md "Imminent" + selected longer-horizon items.
.DESCRIPTION
  Parses the Imminent table (between BEGIN:IMMINENT_TABLE markers) and selects top N strategic preview/TBD items
  from categorized sections to keep the README concise. Writes the table between BEGIN:FUTURE_SUMMARY markers in README.md.
.PARAMETER TopExtra
  Number of non-imminent backlog items (Preview/TBD) to include (default 6)
#>
<#
.DEPRECATED
  This script is deprecated after README v1.3 restructuring (FUTURE_SUMMARY replaced by FUTURE_NEAR & FUTURE_HORIZON).
  Use refresh-future-roadmap.ps1 instead. Keeping file to avoid workflow / contributor confusion.
#>
param(
  [int]$TopExtra = 6
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$readmePath = Join-Path $root 'README.md'
$futurePath = Join-Path $root 'Future_Planned_Features.md'

if(-not (Test-Path $readmePath) -or -not (Test-Path $futurePath)) {
  throw 'Required files not found.'
}

$future = Get-Content $futurePath -Raw
$readme = Get-Content $readmePath -Raw

function Get-TableRowsFromBlock($content, $beginMarker, $endMarker){
  $pattern = [regex]::Escape($beginMarker) + '(.*?)' + [regex]::Escape($endMarker)
  $m = [regex]::Match($content, $pattern, 'Singleline')
  if(-not $m.Success){ throw "Markers $beginMarker .. $endMarker not found" }
  $block = $m.Groups[1].Value
  # Return non-header data rows
  $rows = $block -split "`n" | Where-Object {$_ -match '^\|'}
  return $rows
}

$imminentRows = Get-TableRowsFromBlock -content $future -beginMarker '<!-- BEGIN:IMMINENT_TABLE -->' -endMarker '<!-- END:IMMINENT_TABLE -->'
# First two lines are header + separator
$imminentData = $imminentRows | Select-Object -Skip 2

# Heuristic: choose extra items by scanning sections for Preview status lines and distinct feature names
$extraCandidates = @()
$sectionOrder = 'Model & Reasoning Enhancements','Governance, Security & Compliance','Extensibility & Integration','Knowledge & Retrieval Expansion'

foreach($section in $sectionOrder){
  $sectionRegex = "## " + [regex]::Escape($section) + "(.*?)## "
  $match = [regex]::Match($future + '## ', $sectionRegex, 'Singleline')
  if($match.Success){
    $segment = $match.Groups[1].Value
    $rows = $segment -split "`n" | Where-Object {$_ -match '^\|'} | Select-Object -Skip 2
    foreach($r in $rows){
      if($r -match '\|'){ $extraCandidates += $r }
    }
  }
}

$extraFiltered = $extraCandidates | Where-Object {$_ -match '(?i)\|\s*Preview\s*\|'} | Select-Object -First $TopExtra

# Map Imminent table columns -> concise summary columns
# Imminent: | Feature | Target | Current Status | Expected Change | Impact | Prep |
# Summary:  | Item (Summary) | Target (If Published) | Current Status | Why It Matters | Immediate Prep |
$summaryHeader = '| Item (Summary) | Target (If Published) | Current Status | Why It Matters | Immediate Prep |'
$summarySep    = '|----------------|-----------------------|----------------|----------------|----------------|'

function Convert-ImminentRow($row){
  $parts = $row.Trim().Trim('|').Split('|').ForEach({ $_.Trim() })
  if($parts.Count -lt 6){ return $null }
  return "| $($parts[0]) | $($parts[1]) | $($parts[2]) | $($parts[4]) | $($parts[5]) |"
}

function Convert-ExtraRow($row){
  # Generic section rows often: | Feature | Status | Planned GA | Value | Prep |
  $parts = $row.Trim().Trim('|').Split('|').ForEach({ $_.Trim() })
  if($parts.Count -lt 5){ return $null }
  $feature = $parts[0]
  $target  = if($parts[2] -and $parts[2] -ne 'TBD' -and $parts[2] -ne 'N/A'){ $parts[2] } else { $parts[2] }
  $status  = $parts[1]
  $value   = $parts[3]
  $prep    = $parts[4]
  return "| $feature | $target | $status | $value | $prep |"
}

$convertedImminent = @()
foreach($row in $imminentData){
  $c = Convert-ImminentRow $row
  if($c){ $convertedImminent += $c }
}

$convertedExtra = @()
foreach($row in $extraFiltered){
  $c = Convert-ExtraRow $row
  if($c){ $convertedExtra += $c }
}

# Deduplicate feature names
$seen = @{}
$finalRows = @()
foreach($r in ($convertedImminent + $convertedExtra)){
  $fname = ($r -split '\|')[1].Trim()
  if(-not $seen.ContainsKey($fname)){
    $seen[$fname] = $true
    $finalRows += $r
  }
}

$table = ($summaryHeader, $summarySep) + $finalRows | Out-String

# Replace in README
$patternSummary = '(?s)<!-- BEGIN:FUTURE_SUMMARY -->.*?<!-- END:FUTURE_SUMMARY -->'
$newBlock = "<!-- BEGIN:FUTURE_SUMMARY -->`n$table`n<!-- END:FUTURE_SUMMARY -->"
$updatedReadme = [regex]::Replace($readme, $patternSummary, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newBlock })

if($updatedReadme -ne $readme){
  Set-Content -Path $readmePath -Value $updatedReadme -Encoding UTF8
  Write-Host 'Updated future summary table in README.md'
} else {
  Write-Host 'No changes detected (markers missing or generation identical).'
}
