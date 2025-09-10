param(
    [int]$MaxBytes = 1024
)

$ErrorActionPreference = 'Stop'

$pointerFiles = @(
    'CopilotStudio_Last_6_Months_Features.md',
    'CopilotStudio_Last_12_Months_Features.md'
)

$failures = @()

foreach ($file in $pointerFiles) {
    if (-not (Test-Path $file)) {
        $failures += "Missing pointer file: $file"
        continue
    }
    $info = Get-Item $file
    if ($info.Length -gt $MaxBytes) {
        $failures += "File too large ($($info.Length) bytes > $MaxBytes): $file"
    }
    $firstLine = Get-Content $file -TotalCount 1
    if ($firstLine -notmatch '^> This file has moved to archive:' ) {
        $failures += "Pointer signature mismatch in $file. First line: '$firstLine'"
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'VALIDATION FAILURES:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Pointer file validation passed.' -ForegroundColor Green
