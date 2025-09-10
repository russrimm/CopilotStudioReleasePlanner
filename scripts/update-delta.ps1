<#
.SYNOPSIS
  Updates the Delta Since Last Refresh section in README.md with diff of FUTURE_SUMMARY table.
.DESCRIPTION
  Stores previous snapshot (table rows) and computes added / removed / modified lines.
  Persists hash for quick no-change detection and snapshot for detailed diff.
#>
$ErrorActionPreference='Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$readme = Join-Path $root 'README.md'
$cacheDir = Join-Path $root '.cache'
$hashFile = Join-Path $cacheDir 'future-summary-hash.txt'
$snapshotFile = Join-Path $cacheDir 'future-summary-snapshot.txt'
if(-not (Test-Path $cacheDir)){ New-Item -ItemType Directory -Path $cacheDir | Out-Null }

$content = Get-Content $readme -Raw
$match = [regex]::Match($content, '(?s)<!-- BEGIN:FUTURE_SUMMARY -->(.*?)<!-- END:FUTURE_SUMMARY -->')
if(-not $match.Success){ throw 'Future summary markers not found.' }
$block = $match.Groups[1].Value.Trim()
$currentHash = (Get-FileHash -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($block)))).Hash

$deltaSectionPattern = '(?s)<!-- BEGIN:DELTA -->.*?<!-- END:DELTA -->'

if(Test-Path $hashFile){
  $oldHash = Get-Content $hashFile -Raw
  if($oldHash -ne $currentHash){
    $oldSnapshot = if(Test-Path $snapshotFile){ Get-Content $snapshotFile -Raw } else { '' }
    $newSnapshot = $block
    $oldLines = $oldSnapshot -split "`n" | Where-Object { $_ -match '^\|' }
    $newLines = $newSnapshot -split "`n" | Where-Object { $_ -match '^\|' }
    $added = $newLines | Where-Object { $oldLines -notcontains $_ }
    $removed = $oldLines | Where-Object { $newLines -notcontains $_ }
    # Modified heuristic: matching first cell but line differs
    $modified = @()
    foreach($n in $newLines){
      $key = ($n -split '\|')[1].Trim()
      $matchOld = $oldLines | Where-Object { ($_. -split '\|')[1].Trim() -eq $key }
      if($matchOld -and ($matchOld -ne $n)){
        $modified += "~ $key"
      }
    }
    $deltaParts = @()
    if($added){ $deltaParts += "Added: " + ($added | ForEach-Object { ($_. -split '\|')[1].Trim() }) -join ', ' }
    if($removed){ $deltaParts += "Removed: " + ($removed | ForEach-Object { ($_. -split '\|')[1].Trim() }) -join ', ' }
    if($modified){ $deltaParts += "Modified: " + ($modified | ForEach-Object { $_.Substring(2) }) -join ', ' }
    if(-not $deltaParts){ $deltaParts += 'Hash changed but no row-level differences detected.' }
    $delta = "Future summary updated (hash $oldHash → $currentHash). " + ($deltaParts -join ' | ')
  } else {
    $delta = 'No changes in future summary since last refresh.'
  }
} else {
  $delta = 'Baseline established; future changes will be tracked.'
}

Set-Content -Path $hashFile -Value $currentHash -Encoding UTF8
Set-Content -Path $snapshotFile -Value $block -Encoding UTF8

$timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm UTC')
$newDeltaBlock = "<!-- BEGIN:DELTA -->`n$timestamp - $delta`n<!-- END:DELTA -->"
$newContent = [regex]::Replace($content,$deltaSectionPattern,$newDeltaBlock)
if($newContent -ne $content){ Set-Content -Path $readme -Value $newContent -Encoding UTF8 }
Write-Host 'Delta section updated.'
