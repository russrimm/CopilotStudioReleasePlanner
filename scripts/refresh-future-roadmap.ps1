<#
.SYNOPSIS
  Regenerates future roadmap sections (Near ≤60d, Horizon) plus derived blocks from features.json.
.DESCRIPTION
  Uses enhanced manifest (features.json) to:
   - Partition features into Near (plannedGA within 60d OR decisionNeededBy within 60d) and Horizon (others with future activity)
   - Build FUTURE_NEAR and FUTURE_HORIZON tables
   - Auto-calculate lifecycle funnel counts (Preview, Planned, Enhancing, GA, Dormant, Stale Preview)
   - Generate flattened list & feature IDs blocks
   - Generate policy coverage matrix (union of policy keys across features)
   - Provide risk heatmap placeholder classification by riskImpact + riskLikelihood
  Writes into README.md markers:
    FUTURE_NEAR, FUTURE_HORIZON, LIFECYCLE_FUNNEL, FLATTENED_FEATURES, FEATURE_IDS, POLICY_MATRIX, RISK_HEATMAP
#>
param(
  [int]$NearWindowDays = 60
)
$ErrorActionPreference='Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$readme = Join-Path $root 'README.md'
$manifestPath = Join-Path $root 'features.json'
if(-not (Test-Path $manifestPath)){ throw 'features.json not found' }
$features = Get-Content $manifestPath -Raw | ConvertFrom-Json
$now = Get-Date

function Parse-Date($val){
  if(-not $val){ return $null }
  $formats = 'yyyy-MM-dd','yyyy-MM','yyyy-MM-ddTHH:mm:ss'
  foreach($f in $formats){
    [DateTime]$parsed = [DateTime]::MinValue
    if([DateTime]::TryParseExact($val,$f,$null,[System.Globalization.DateTimeStyles]::None,[ref]$parsed)){
      return $parsed
    }
  }
  [DateTime]$generic = [DateTime]::MinValue
  if([DateTime]::TryParse($val,[ref]$generic)){
    return $generic
  }
  return $null
}

# Derive helper properties
foreach($f in $features){
  $f | Add-Member -NotePropertyName plannedDateObj -NotePropertyValue (Parse-Date $f.plannedGA) -Force
  $f | Add-Member -NotePropertyName decisionDateObj -NotePropertyValue (Parse-Date $f.decisionNeededBy) -Force
  $f | Add-Member -NotePropertyName previewStartObj -NotePropertyValue (Parse-Date $f.previewStart) -Force
  $f | Add-Member -NotePropertyName lastUpdateObj -NotePropertyValue (Parse-Date $f.lastUpdate) -Force
}

$nearCutoff = $now.AddDays($NearWindowDays)

$near = $features |
  Where-Object {
    ($_.plannedDateObj -and $_.plannedDateObj -le $nearCutoff) -or
    ($_.decisionDateObj -and $_.decisionDateObj -le $nearCutoff)
  } |
  Sort-Object -Property @{ Expression = { if ($_.plannedDateObj) { 0 } else { 1 } }; Ascending = $true }, @{ Expression = { $_.plannedDateObj }; Ascending = $true }, @{ Expression = { $_.decisionDateObj }; Ascending = $true }

$nearSlugs = $near.slug
$horizon = $features | Where-Object { $nearSlugs -notcontains $_.slug }

function Format-StatusGlyph($s){
  if($s -match '^GA') { return '✅ ' + $s }
  if($s -match 'Preview') { return '🧪 ' + $s }
  if($s -match 'enhanc' -or $s -match 'Enhancing') { return '🔍 ' + $s }
  return $s
}

function Build-NearTable($items){
  $header = '| Item (Summary) | Target | Status | Why It Matters | Immediate Prep | Decision Needed By |'
  $sep =    '|----------------|--------|--------|----------------|----------------|--------------------|'
  $rows = foreach($f in $items){
    $target = if($f.plannedGA){ if($f.plannedGA -eq 'TBD'){ 'TBD' } else { $f.plannedGA } } else { '' }
    $status = Format-StatusGlyph $f.currentStatus
    $prepDate = if($f.decisionDateObj){ $f.decisionDateObj.ToString('yyyy-MM-dd') } else { '' }
  $disp = if($f.docUrl){ "[$($f.name)]($($f.docUrl))" } else { $f.name }
  "| $disp | $target | $status | $($f.purpose) | (auto) | $prepDate |"
  }
  return ($header,$sep)+$rows -join "`n"
}

function Build-HorizonTable($items){
  $header = '| Item (Summary) | Target | Status | Why It Matters | Immediate Prep | Stale? |'
  $sep =    '|----------------|--------|--------|----------------|----------------|--------|'
  $rows = foreach($f in $items){
    $target = if($f.plannedGA){ $f.plannedGA } else { 'TBD' }
    $status = Format-StatusGlyph $f.currentStatus
    $stale = ''
    if($f.currentStatus -match 'Preview' -and $f.previewStartObj){
      if(($now - $f.previewStartObj).TotalDays -gt 180){ $stale = '⚠' } else { $stale = '–' }
    } else { $stale = '–' }
  $disp = if($f.docUrl){ "[$($f.name)]($($f.docUrl))" } else { $f.name }
  "| $disp | $target | $status | $($f.purpose) | (auto) | $stale |"
  }
  return ($header,$sep)+$rows -join "`n"
}

$nearTable = Build-NearTable $near
$horizonTable = Build-HorizonTable $horizon

# Lifecycle funnel counts
$previewCount = ($features | Where-Object { $_.lifecycleStage -eq 'Preview' }).Count
$plannedCount = ($features | Where-Object { $_.plannedGA -and $_.lifecycleStage -notin 'GA','Enhancing','Preview' }).Count
$enhancingCount = ($features | Where-Object { $_.lifecycleStage -match 'Enhancing' }).Count
$gaCount = ($features | Where-Object { $_.lifecycleStage -eq 'GA' }).Count
$dormantCount = ($features | Where-Object { $_.lastUpdateObj -and ($now - $_.lastUpdateObj).TotalDays -gt 90 }).Count
$stalePreview = ($features | Where-Object { $_.lifecycleStage -eq 'Preview' -and $_.previewStartObj -and ($now - $_.previewStartObj).TotalDays -gt 180 }).Count

$lifecycleTable = @(
  '| Stage | Count | Notes |',
  '|-------|-------|-------|',
  "| 🧪 Preview | $previewCount | active early access |",
  "| 📅 Planned | $plannedCount | date published, pre-preview |",
  "| 🔍 Enhancing | $enhancingCount | post-GA iteration |",
  "| ✅ GA | $gaCount | fully released |",
  "| 💤 Dormant | $dormantCount | >90d no update |",
  "| ⚠ Stale Preview | $stalePreview | >180d preview |"
) -join "`n"

# Flattened list
$flatList = $features | Sort-Object name | ForEach-Object {
  $glyph = if($_.lifecycleStage -eq 'GA'){ '✅' } elseif($_.lifecycleStage -eq 'Preview'){ '🧪' } elseif($_.lifecycleStage -match 'Enhancing'){ '🔍' } else { '📅' }
  $disp = if($_.docUrl){ "[$($_.name)]($($_.docUrl))" } else { $_.name }
  "- $disp ($glyph $($_.lifecycleStage))"
} | Out-String

# Feature IDs
$ids = ($features | ForEach-Object { $_.slug }) -join ', '

# Policy matrix
$allPolicyKeys = $features | ForEach-Object { $_.policies.PSObject.Properties.Name } | Where-Object { $_ } | Sort-Object -Unique
$policyHeader = '| Feature | ' + ($allPolicyKeys -join ' | ') + ' |'
$policySep = '|---------|' + ($allPolicyKeys | ForEach-Object { '-----|' }) -join ''
$policyRows = foreach($f in $features){
  $cells = foreach($k in $allPolicyKeys){ if($f.policies -and $f.policies.$k){ '✓' } else { '–' } }
  $disp = if($f.docUrl){ "[$($f.name)]($($f.docUrl))" } else { $f.name }
  '| ' + $disp + ' | ' + ($cells -join ' | ') + ' |'
}
$policyTable = ($policyHeader,$policySep)+$policyRows -join "`n"

# Risk heatmap classification
$impactLevels = 'Low','Medium','High'
$likelihoodLevels = 'Low','Medium','High'
$grid = @{}
foreach($i in $impactLevels){ foreach($l in $likelihoodLevels){ $grid["$i|$l"] = @() } }
foreach($f in $features){
  $key = "$($f.riskImpact)|$($f.riskLikelihood)"
  if($grid.ContainsKey($key)){ $grid[$key] += $f.slug }
}
function Cell($impact,$likelihood){ $v = $grid["$impact|$likelihood"]; if($v.Count -gt 0){ ($v -join ', ') } else { ' ' } }
$riskTable = @(
  '| Impact \\ Likelihood | Low | Medium | High |',
  '|---------------------|-----|--------|------|',
  "| High | $(Cell 'High' 'Low') | $(Cell 'High' 'Medium') | $(Cell 'High' 'High') |",
  "| Medium | $(Cell 'Medium' 'Low') | $(Cell 'Medium' 'Medium') | $(Cell 'Medium' 'High') |",
  "| Low | $(Cell 'Low' 'Low') | $(Cell 'Low' 'Medium') | $(Cell 'Low' 'High') |"
) -join "`n"

$readmeContent = Get-Content $readme -Raw
function Replace-Block($content,$marker,$new){
  $pattern = "(?s)<!-- BEGIN:$marker -->.*?<!-- END:$marker -->"
  if($content -notmatch $pattern){ return $content }
  return [regex]::Replace($content,$pattern,"<!-- BEGIN:$marker -->`n$new`n<!-- END:$marker -->")
}

$readmeContent = Replace-Block $readmeContent 'FUTURE_NEAR' $nearTable
$readmeContent = Replace-Block $readmeContent 'FUTURE_HORIZON' $horizonTable
$readmeContent = Replace-Block $readmeContent 'LIFECYCLE_FUNNEL' $lifecycleTable
$readmeContent = Replace-Block $readmeContent 'FLATTENED_FEATURES' ($flatList.TrimEnd())
$readmeContent = Replace-Block $readmeContent 'FEATURE_IDS' $ids
$readmeContent = Replace-Block $readmeContent 'POLICY_MATRIX' $policyTable
$readmeContent = Replace-Block $readmeContent 'RISK_HEATMAP' $riskTable

Set-Content -Path $readme -Value $readmeContent -Encoding UTF8
Write-Host 'Future roadmap sections refreshed.'