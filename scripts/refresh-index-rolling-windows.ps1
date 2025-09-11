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

function Parse-Date([string]$s) {
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

function In-Window($dt,$start,$end) { if (-not $dt) { return $false }; $d=$dt.Date; return ($d -ge $start -and $d -le $end) }

$lastRows = @()
Write-Host "[rolling] Loaded $($raw.Count) features"  # early debug
$nextRows = @()

foreach ($f in $raw) {
  $previewStart = Parse-Date $f.previewStart
  $gaDate       = Parse-Date ($f.gaDate ?? $f.initialRelease)
  $lastUpdate   = Parse-Date $f.lastUpdate
  $decisionBy   = Parse-Date $f.decisionNeededBy
  $plannedGA    = Parse-Date $f.plannedGA

  # LAST 30: capture if any relevant activity date in window
  $activityDate = $lastUpdate
  $changeLabel = $null
  if (In-Window $gaDate $lastStart $lastEnd) { $activityDate = $gaDate; $changeLabel = 'GA release' }
  elseif (In-Window $previewStart $lastStart $lastEnd) { $activityDate = $previewStart; $changeLabel = 'Preview start' }
  elseif (In-Window $lastUpdate $lastStart $lastEnd) { $changeLabel = 'Update' }
  if ($activityDate -and (In-Window $activityDate $lastStart $lastEnd)) {
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
  if ($plannedGA -and (In-Window $plannedGA $nextStart $nextEnd)) { $forwardDate = $plannedGA; $forwardType = 'Planned GA' }
  elseif ($decisionBy -and (In-Window $decisionBy $nextStart $nextEnd)) { $forwardType = 'Decision Due' }
  if ($forwardDate -and (In-Window $forwardDate $nextStart $nextEnd)) {
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

function Html-Escape($s){ return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>' ,'&gt;') }

function Build-LastTable($rows){
  if (-not $rows -or $rows.Count -eq 0) { return '<div class="table-responsive dense"><em>No feature changes in window.</em></div>' }
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<div class="table-responsive dense"><table><thead><tr><th>Feature</th><th>Status (Now)</th><th>Change Date</th><th>What Changed</th><th>Why It Matters</th><th>Recommended Action</th></tr></thead><tbody>')
  foreach ($r in $rows) {
    $name = if ($r.Doc) { "<a href=\"$($r.Doc)\">$(Html-Escape $r.Feature)</a>" } else { Html-Escape $r.Feature }
    [void]$sb.Append("<tr><td>$name</td><td>$(Html-Escape $r.Status)</td><td>$($r.Date)</td><td>$(Html-Escape $r.What)</td><td>$(Html-Escape $r.Why)</td><td>$(Html-Escape $r.Action)</td></tr>")
  }
  [void]$sb.Append('</tbody></table></div>')
  return $sb.ToString()
}

function Build-NextTable($rows){
  if (-not $rows -or $rows.Count -eq 0) { return '<div class="table-responsive dense"><em>No planned or decision items in window.</em></div>' }
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<div class="table-responsive dense"><table><thead><tr><th>Feature</th><th>Target</th><th>Status</th><th>Why It Matters</th><th>Immediate Prep</th><th>Confidence</th></tr></thead><tbody>')
  foreach ($r in $rows) {
    $name = if ($r.Doc) { "<a href=\"$($r.Doc)\">$(Html-Escape $r.Feature)</a>" } else { Html-Escape $r.Feature }
    [void]$sb.Append("<tr><td>$name</td><td>$($r.Target)</td><td>$(Html-Escape $r.Status)</td><td>$(Html-Escape $r.Why)</td><td>$(Html-Escape $r.Prep)</td><td>$(Html-Escape $r.Confidence)</td></tr>")
  }
  [void]$sb.Append('</tbody></table></div>')
  return $sb.ToString()
}

$lastHtml = Build-LastTable $lastRows
$nextHtml = Build-NextTable $nextRows

$indexContent = Get-Content $indexPath -Raw

function Replace-Block([string]$content,[string]$begin,[string]$end,[string]$replacement){
  $pattern = "(?s)<!-- $begin -->(.*?)<!-- $end -->"
  $beginToken = "<!-- $beginMarker -->"
  $endToken   = "<!-- $endMarker -->"
  $beginIndex = $content.IndexOf($beginToken)
  if ($beginIndex -lt 0) { throw "Begin marker $beginMarker not found" }
  $endIndex = $content.IndexOf($endToken,$beginIndex)
  if ($endIndex -lt 0) { throw "End marker $endMarker not found" }
  $startReplace = $beginIndex + $beginToken.Length
  $lengthReplace = $endIndex - $startReplace
  $before = $content.Substring(0,$startReplace)
  $after  = $content.Substring($endIndex)
  $new = "$before`n$replacement`n$after"
  return $new
}

Write-Host "[rolling] Computed windows last=$($lastStart.ToShortDateString())..$($lastEnd.ToShortDateString()) next=$($nextStart.ToShortDateString())..$($nextEnd.ToShortDateString())"
Write-Host "[rolling] Row counts pre-render: last=$($lastRows.Count) next=$($nextRows.Count)"

$indexContent = Replace-Block $indexContent 'BEGIN:LAST30_DYNAMIC' 'END:LAST30_DYNAMIC' $lastHtml
$indexContent = Replace-Block $indexContent 'BEGIN:NEXT30_DYNAMIC' 'END:NEXT30_DYNAMIC' $nextHtml

# Update window text
$indexContent = $indexContent -replace '<p class="sub" id="last30-window">Window: \(auto\)</p>', "<p class=\"sub\" id=\"last30-window\">Window: $($lastStart.ToString('yyyy-MM-dd')) → $($lastEnd.ToString('yyyy-MM-dd'))</p>"
$indexContent = $indexContent -replace '<p class="sub" id="next30-window">Window: \(auto\)</p>', "<p class=\"sub\" id=\"next30-window\">Window: $($nextStart.ToString('yyyy-MM-dd')) → $($nextEnd.ToString('yyyy-MM-dd')) (targets & decision points)</p>"

Set-Content -Path $indexPath -Value $indexContent -NoNewline
Write-Host "[rolling] Updated index.html rolling windows: last=$($lastStart.ToString('yyyy-MM-dd')) to $($lastEnd.ToString('yyyy-MM-dd')); next=$($nextStart.ToString('yyyy-MM-dd')) to $($nextEnd.ToString('yyyy-MM-dd'))"
Write-Host "[rolling] Last rows: $($lastRows.Count) Next rows: $($nextRows.Count)"
Write-Host "[rolling] Wrote index.html ($([System.IO.File]::ReadAllText($indexPath).Length) chars)"
