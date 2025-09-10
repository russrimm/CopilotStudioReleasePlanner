<#
.SYNOPSIS
  Simple markdown link checker (HTTP HEAD/GET) for repository docs.
.DESCRIPTION
  Scans .md files (excluding archive optionally) and tests external HTTP/HTTPS links.
  Emits a summary and non-zero exit if failures above threshold.
#>
param(
  [switch]$IncludeArchive,
  [int]$MaxFailures = 5
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$files = Get-ChildItem -Path $root -Recurse -Include *.md | Where-Object { $IncludeArchive -or $_.FullName -notmatch 'archive' }

$regex = '(?<!\\)\[(?<text>[^\]]+)\]\((?<url>https?[^)#\s]+)'
$failures = @()

foreach($f in $files){
  $content = Get-Content $f.FullName -Raw
  [regex]::Matches($content,$regex) | ForEach-Object {
    $url = $_.Groups['url'].Value
    try {
      $resp = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 15 -ErrorAction Stop
      if(-not ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400)){
        $failures += [pscustomobject]@{File=$f.Name;Url=$url;Status=$resp.StatusCode}
      }
    } catch {
      # Retry with GET
      try {
        $resp = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 20 -ErrorAction Stop
        if(-not ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400)){
          $failures += [pscustomobject]@{File=$f.Name;Url=$url;Status=$resp.StatusCode}
        }
      } catch {
        $failures += [pscustomobject]@{File=$f.Name;Url=$url;Status='Error'}
      }
    }
  }
}

if($failures.Count -gt 0){
  Write-Host "Link check failures: $($failures.Count)" -ForegroundColor Yellow
  $failures | Format-Table -AutoSize | Out-String | Write-Host
}

if($failures.Count -gt $MaxFailures){
  Write-Error "Too many link failures ($($failures.Count))"
  exit 1
} else {
  Write-Host 'Link check completed.' -ForegroundColor Green
}
