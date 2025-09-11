<#!
.SYNOPSIS
  Generates rolling +/-30 day feature change tables in index.html from features.json.
.DESCRIPTION
  Reads features.json and produces two HTML tables:
    - Last 30 days (features with lastUpdate or gaDate / previewStart within window)
    - Next 30 days (features with plannedGA or decisionNeededBy inside forward window)
  Replaces content between markers:
    <!-- BEGIN:LAST30_DYNAMIC --> ... <!-- END:LAST30_DYNAMIC -->
    <!-- BEGIN:NEXT30_DYNAMIC --> ... <!-- END:NEXT30_DYNAMIC -->
  Also updates the window <p id="last30-window"> and <p id="next30-window"> elements with actual date spans.
.NOTES
  Idempotent; safe to run daily (e.g., via GitHub Action).
#>
[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path "$PSScriptRoot/.."),
  [string]$FeaturesFile = 'features.json',
  [string]$IndexFile = 'index.html'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "[rolling] Script start"

function ParseDate([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $null }
  $formats = 'yyyy-MM-dd','yyyy-MM','yyyy/MM/dd','yyyy/MM'
  foreach ($f in $formats) {
    [DateTime]$dtOut = [DateTime]::MinValue
    if ([DateTime]::TryParseExact($s,$f,$null,[System.Globalization.DateTimeStyles]::None,[ref]$dtOut)) { return $dtOut }
  }
  return $null
}

$featuresPath = Join-Path $RepoRoot $FeaturesFile
$indexPath    = Join-Path $RepoRoot $IndexFile
if (-not (Test-Path $featuresPath)) { throw "features.json not found at $featuresPath" }
if (-not (Test-Path $indexPath)) { throw "index.html not found at $indexPath" }

$raw = Get-Content $featuresPath -Raw | ConvertFrom-Json
$today = (Get-Date).Date
$lastStart = $today.AddDays(-29)
$lastEnd   = $today
$nextStart = $today
$nextEnd   = $today.AddDays(29)

function InWindow($dt,$start,$end) { if (-not $dt) { return $false }; $d=$dt.Date; return ($d -ge $start -and $d -le $end) }

$lastRows = @()
Write-Host "[rolling] Loaded $($raw.Count) features"  # early debug
$nextRows = @()

foreach ($f in $raw) {
  $names = $f.PSObject.Properties.Name
  $previewStart = if ($names -contains 'previewStart') { ParseDate $f.previewStart } else { $null }
  $gaRaw = if ($names -contains 'gaDate') { $f.gaDate } elseif ($names -contains 'initialRelease') { $f.initialRelease } else { $null }
  $gaDate = ParseDate $gaRaw
  $lastUpdate = if ($names -contains 'lastUpdate') { ParseDate $f.lastUpdate } else { $null }
  $decisionBy = if ($names -contains 'decisionNeededBy') { ParseDate $f.decisionNeededBy } else { $null }
  $plannedGA  = if ($names -contains 'plannedGA') { ParseDate $f.plannedGA } else { $null }

  # LAST 30: capture if any relevant activity date in window
  $activityDate = $lastUpdate
  $changeLabel = $null
  if (InWindow $gaDate $lastStart $lastEnd) { $activityDate = $gaDate; $changeLabel = 'GA release' }
  elseif (InWindow $previewStart $lastStart $lastEnd) { $activityDate = $previewStart; $changeLabel = 'Preview start' }
  elseif (InWindow $lastUpdate $lastStart $lastEnd) { $changeLabel = 'Update' }
  if ($activityDate -and (InWindow $activityDate $lastStart $lastEnd)) {
    $statusNow = $f.currentStatus
    $what = if ($changeLabel) { $changeLabel } else { 'Activity' }
    $why  = $f.purpose
    $action = switch -regex ($statusNow) {
      'GA' { 'Adopt & baseline metrics'; break }
      'Preview' { 'Evaluate & gather feedback'; break }
      default { 'Monitor' }
    }
    $lastRows += [PSCustomObject]@{
      Feature = $f.name
      Status  = $statusNow
      Date    = $activityDate.ToString('yyyy-MM-dd')
      What    = $what
      Why     = $why
      Action  = $action
      Doc     = $f.docUrl
    }
  }

  # NEXT 30: look at planned GA or decisionNeededBy in forward window
  $forwardDate = $decisionBy
  $forwardType = 'Decision'
  if ($plannedGA -and (InWindow $plannedGA $nextStart $nextEnd)) { $forwardDate = $plannedGA; $forwardType = 'Planned GA' }
  elseif ($decisionBy -and (InWindow $decisionBy $nextStart $nextEnd)) { $forwardType = 'Decision Due' }
  if ($forwardDate -and (InWindow $forwardDate $nextStart $nextEnd)) {
    $conf = if ($plannedGA) { 'Medium' } else { 'Medium' }
    if ($f.currentStatus -match 'GA') { $conf = 'High' }
    $nextRows += [PSCustomObject]@{
      Feature = $f.name
      Target  = $forwardDate.ToString('yyyy-MM-dd')
      Status  = $f.currentStatus
      Why     = $f.purpose
      Prep    = if ($forwardType -eq 'Decision Due') { 'Prepare decision inputs' } else { 'Finalize adoption readiness' }
      Confidence = $conf
      Doc     = $f.docUrl
    }
  }
}

# Sort rows
$lastRows = $lastRows | Sort-Object Date, Feature
$nextRows = $nextRows | Sort-Object Target, Feature

function HtmlEscape($s){ if ($null -eq $s) { return '' }; return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;') }

function BuildLastHtml($rows){
  if (-not $rows -or $rows.Count -eq 0) { return '<div class="table-responsive dense"><em>No feature changes in window.</em></div>' }
  $sb = New-Object System.Text.StringBuilder
  $sb.Append('<div class="table-responsive dense"><table><thead><tr><th>Feature</th><th>Status</th><th>Date</th><th>What Changed</th><th>Why It Matters</th><th>Action</th></tr></thead><tbody>') | Out-Null
  foreach ($r in $rows) {
    $nameCell = if ($r.Doc) { '<a href="'+(HtmlEscape $r.Doc)+'">'+(HtmlEscape $r.Feature)+'</a>' } else { HtmlEscape $r.Feature }
    $sb.Append('<tr><td>'+ $nameCell + '</td><td>' + (HtmlEscape $r.Status) + '</td><td>' + (HtmlEscape $r.Date) + '</td><td>' + (HtmlEscape $r.What) + '</td><td>' + (HtmlEscape $r.Why) + '</td><td>' + (HtmlEscape $r.Action) + '</td></tr>') | Out-Null
  }
  $sb.Append('</tbody></table></div>') | Out-Null
  return $sb.ToString()
}

function BuildNextHtml($rows){
  if (-not $rows -or $rows.Count -eq 0) { return '<div class="table-responsive dense"><em>No planned or decision items in window.</em></div>' }
  $sb = New-Object System.Text.StringBuilder
  $sb.Append('<div class="table-responsive dense"><table><thead><tr><th>Feature</th><th>Target</th><th>Status</th><th>Why It Matters</th><th>Immediate Prep</th><th>Confidence</th></tr></thead><tbody>') | Out-Null
  foreach ($r in $rows) {
    $nameCell = if ($r.Doc) { '<a href="'+(HtmlEscape $r.Doc)+'">'+(HtmlEscape $r.Feature)+'</a>' } else { HtmlEscape $r.Feature }
    $sb.Append('<tr><td>'+ $nameCell + '</td><td>' + (HtmlEscape $r.Target) + '</td><td>' + (HtmlEscape $r.Status) + '</td><td>' + (HtmlEscape $r.Why) + '</td><td>' + (HtmlEscape $r.Prep) + '</td><td>' + (HtmlEscape $r.Confidence) + '</td></tr>') | Out-Null
  }
  $sb.Append('</tbody></table></div>') | Out-Null
  return $sb.ToString()
}

$lastHtml = BuildLastHtml $lastRows
$nextHtml = BuildNextHtml $nextRows

$indexContent = Get-Content $indexPath -Raw

function ReplaceBlock([string]$content,[string]$beginMarker,[string]$endMarker,[string]$replacement){
  $beginToken = "<!-- $beginMarker -->"
  $endToken = "<!-- $endMarker -->"
  $beginIndex = $content.IndexOf($beginToken)
  if ($beginIndex -lt 0) { throw "Begin marker $beginMarker not found" }
  $endIndex = $content.IndexOf($endToken,$beginIndex)
  if ($endIndex -lt 0) { throw "End marker $endMarker not found" }
  $before = $content.Substring(0, $beginIndex + $beginToken.Length)
  $after = $content.Substring($endIndex)
  return "$before`n$replacement`n$after"
}

Write-Host "[rolling] Computed windows last=$($lastStart.ToShortDateString())..$($lastEnd.ToShortDateString()) next=$($nextStart.ToShortDateString())..$($nextEnd.ToShortDateString())"
Write-Host "[rolling] Row counts pre-render: last=$($lastRows.Count) next=$($nextRows.Count)"
Write-Host "[rolling] Sample last html: $lastHtml"

$indexContent = ReplaceBlock $indexContent 'BEGIN:LAST30_DYNAMIC' 'END:LAST30_DYNAMIC' $lastHtml
$indexContent = ReplaceBlock $indexContent 'BEGIN:NEXT30_DYNAMIC' 'END:NEXT30_DYNAMIC' $nextHtml

# Update window text
$arrow = '->'
$lastWindowText = '<p class="sub" id="last30-window">Window: ' + $lastStart.ToString('yyyy-MM-dd') + ' ' + $arrow + ' ' + $lastEnd.ToString('yyyy-MM-dd') + '</p>'
$nextWindowText = '<p class="sub" id="next30-window">Window: ' + $nextStart.ToString('yyyy-MM-dd') + ' ' + $arrow + ' ' + $nextEnd.ToString('yyyy-MM-dd') + ' (targets & decision points)</p>'
$indexContent = $indexContent -replace '<p class="sub" id="last30-window">Window: \(auto\)</p>', $lastWindowText
$indexContent = $indexContent -replace '<p class="sub" id="next30-window">Window: \(auto\)</p>', $nextWindowText

Set-Content -Path $indexPath -Value $indexContent -NoNewline
Write-Host "[rolling] Updated index.html rolling windows: last=$($lastStart.ToString('yyyy-MM-dd')) to $($lastEnd.ToString('yyyy-MM-dd')); next=$($nextStart.ToString('yyyy-MM-dd')) to $($nextEnd.ToString('yyyy-MM-dd'))"
Write-Host "[rolling] Last rows: $($lastRows.Count) Next rows: $($nextRows.Count)"
Write-Host "[rolling] Wrote index.html ($([System.IO.File]::ReadAllText($indexPath).Length) chars)"
