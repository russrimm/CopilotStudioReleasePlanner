param(
  [string]$Status,
  [string]$Category,
  [switch]$Planned
)
$ErrorActionPreference='Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$manifest = Join-Path $root 'features.json'
if(-not (Test-Path $manifest)){ throw 'features.json not found' }
$items = Get-Content $manifest -Raw | ConvertFrom-Json
if($Status){ $items = $items | Where-Object { $_.currentStatus -match $Status }
}
if($Category){ $items = $items | Where-Object { $_.category -match $Category }
}
if($Planned){ $items = $items | Where-Object { $_.plannedGA }
}
$items | Sort-Object name | ForEach-Object {
  [pscustomobject]@{ Name=$_.name; Status=$_.currentStatus; PlannedGA=$_.plannedGA; Category=$_.category }
} | Format-Table -AutoSize