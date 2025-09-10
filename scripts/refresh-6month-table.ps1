<#
DEPRECATED SCRIPT (No-Op)
This script previously refreshed a 6‑month feature table which has been retired.
It is intentionally left as a stub for historical reference and safety so that any
residual workflow invocation will not mutate repository content.

New automation:
  scripts/ai-refresh-rolling-windows.ps1 (AI content refresh)
  scripts/update-30day-window.ps1        (date window heading update)

Validation:
  scripts/validate-pointer-files.ps1 ensures root pointer markdown files remain lightweight.

Removal Option:
  Delete this file only after searching the repo for 'refresh-6month-table' to confirm no references.
  (kept intentionally for audit trail)
#>
Write-Host 'refresh-6month-table.ps1 is deprecated and performs no action.'
