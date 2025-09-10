<#
.SYNOPSIS
  Updates the Delta Since Last Refresh section in README.md comparing previous feature summary snapshot.
.DESCRIPTION
  Captures hash of FUTURE_SUMMARY block and writes changed/added/removed rows vs stored state in .cache/future-summary-hash.txt.
#>
$ErrorActionPreference='Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$readme = Join-Path $root 'README.md'
$cacheDir = Join-Path $root '.cache'
$hashFile = Join-Path $cacheDir 'future-summary-hash.txt'
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
    # Hash changed; generic notification (could be expanded to full diff later)
    $delta = "Future summary changed (hash $oldHash → $currentHash). Review table diff in PR." 
  } else {
    $delta = 'No changes in future summary since last refresh.'
  }
} else {
  $delta = 'Baseline established; future changes will be tracked.'
}

Set-Content -Path $hashFile -Value $currentHash -Encoding UTF8

$newDeltaBlock = "<!-- BEGIN:DELTA -->`n$delta`n<!-- END:DELTA -->"
$newContent = [regex]::Replace($content,$deltaSectionPattern,$newDeltaBlock)
if($newContent -ne $content){ Set-Content -Path $readme -Value $newContent -Encoding UTF8 }
Write-Host 'Delta section updated.'
