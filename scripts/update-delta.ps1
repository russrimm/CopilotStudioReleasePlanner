<#
.SYNOPSIS
  Updates the Delta Since Last Refresh section in README.md with diff of FUTURE_NEAR + FUTURE_HORIZON tables.
.DESCRIPTION
  Concatenates both future roadmap tables and computes row-level adds/removals/modifications keyed by feature name.
  Persists hash & snapshot for change detection.
#>
$ErrorActionPreference='Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$readme = Join-Path $root 'README.md'
$cacheDir = Join-Path $root '.cache'
$hashFile = Join-Path $cacheDir 'future-summary-hash.txt'
$snapshotFile = Join-Path $cacheDir 'future-summary-snapshot.txt'
if(-not (Test-Path $cacheDir)){ New-Item -ItemType Directory -Path $cacheDir | Out-Null }

$content = Get-Content $readme -Raw
$near = [regex]::Match($content,'(?s)<!-- BEGIN:FUTURE_NEAR -->(.*?)<!-- END:FUTURE_NEAR -->')
$horizon = [regex]::Match($content,'(?s)<!-- BEGIN:FUTURE_HORIZON -->(.*?)<!-- END:FUTURE_HORIZON -->')
if(-not $near.Success){ throw 'Future near marker not found.' }
$nearPart = $near.Groups[1].Value.Trim()
$horizonPart = if($horizon.Success){ $horizon.Groups[1].Value.Trim() } else { '' }
$block = if([string]::IsNullOrWhiteSpace($horizonPart)){ $nearPart } else { ($nearPart+"`n"+$horizonPart).Trim() }
 $horizonNote = if($horizon.Success){ '' } else { ' (horizon section absent in README; treated as empty)' }
$currentHash = (Get-FileHash -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($block)))).Hash

$deltaSectionPattern = '(?s)<!-- BEGIN:DELTA -->.*?<!-- END:DELTA -->'

if(Test-Path $hashFile){
  $oldHash = Get-Content $hashFile -Raw
  if($oldHash -ne $currentHash){
    $oldSnapshot = if(Test-Path $snapshotFile){ Get-Content $snapshotFile -Raw } else { '' }
    $newSnapshot = $block
    $oldLines = $oldSnapshot -split "`n" | Where-Object { $_ -match '^\|' }
    $newLines = $newSnapshot -split "`n" | Where-Object { $_ -match '^\|' }

    function Get-Key($line){
      if(-not $line){ return $null }
      $parts = $line -split '\|'
      if($parts.Length -lt 3){ return $null }
      # first element usually empty (leading pipe)
      return $parts[1].Trim()
    }

    $added = @()
    $removed = @()
    $modified = @()

    # Build dictionaries for quick lookup
    $oldMap = @{}
    foreach($l in $oldLines){
      $k = Get-Key $l
      if($k){ $oldMap[$k] = $l }
    }
    $newMap = @{}
    foreach($l in $newLines){
      $k = Get-Key $l
      if($k){ $newMap[$k] = $l }
    }

    foreach($k in $newMap.Keys){ if(-not $oldMap.ContainsKey($k)){ $added += $k } }
    foreach($k in $oldMap.Keys){ if(-not $newMap.ContainsKey($k)){ $removed += $k } }
    foreach($k in $newMap.Keys){ if($oldMap.ContainsKey($k) -and $oldMap[$k] -ne $newMap[$k]){ $modified += $k } }

    $deltaParts = @()
    if($added.Count -gt 0){ $deltaParts += 'Added: ' + ($added -join ', ') }
    if($removed.Count -gt 0){ $deltaParts += 'Removed: ' + ($removed -join ', ') }
    if($modified.Count -gt 0){ $deltaParts += 'Modified: ' + ($modified -join ', ') }
    if(-not $deltaParts){ $deltaParts += 'Hash changed but no row-level differences detected.' }
    $delta = "Future summary updated (hash $oldHash → $currentHash). " + ($deltaParts -join ' | ') + $horizonNote
  } else {
    $delta = 'No changes in future roadmap tables since last refresh.' + $horizonNote
  }
} else {
  $delta = 'Baseline established; future changes will be tracked.' + $horizonNote
}

Set-Content -Path $hashFile -Value $currentHash -Encoding UTF8
Set-Content -Path $snapshotFile -Value $block -Encoding UTF8

$timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm UTC')
$newDeltaBlock = "<!-- BEGIN:DELTA -->`n$timestamp - $delta`n<!-- END:DELTA -->"
$newContent = [regex]::Replace($content,$deltaSectionPattern,$newDeltaBlock)
if($newContent -ne $content){ Set-Content -Path $readme -Value $newContent -Encoding UTF8 }
Write-Host 'Delta section updated.'
