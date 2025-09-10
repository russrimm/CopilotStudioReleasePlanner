<#!
.SYNOPSIS
  AI-assisted refresh of the Rolling 30-Day tables in README.md using Azure OpenAI.
.DESCRIPTION
  Reads README.md, extracts the tables between markers:
    <!-- BEGIN:LAST30_TABLE --> ... <!-- END:LAST30_TABLE -->
    <!-- BEGIN:NEXT30_TABLE -->  ... <!-- END:NEXT30_TABLE -->
  Calls an Azure OpenAI Chat Completions deployment with strict JSON instructions.
  Expects JSON: {"last30_table":"...","next30_table":"..."}
  Validates headers unchanged; writes back only if differences.
  Supports -DryRun (no write) and -Offline (skip API call, treat as no-op success).
.REQUIRES
  Environment variables when not using -Offline:
    AZURE_OPENAI_ENDPOINT (e.g. https://my-resource.openai.azure.com)
    AZURE_OPENAI_KEY
    AZURE_OPENAI_DEPLOYMENT (deployment name)
#>
[CmdletBinding()]
param(
  [string]$ReadmePath = (Join-Path (Resolve-Path "$PSScriptRoot/..") 'README.md'),
  [switch]$DryRun,
  [switch]$Offline,
  [switch]$DebugMode
)

$ErrorActionPreference = 'Stop'

function Write-DebugInfo {
  param([string]$Message)
  if ($DebugMode) { Write-Host "[debug] $Message" }
}

function Require-Env($name) {
  $val = [Environment]::GetEnvironmentVariable($name)
  if ([string]::IsNullOrWhiteSpace($val)) { throw "Missing required environment variable: $name" }
  return $val
}

if (-not (Test-Path $ReadmePath)) { throw "README not found at $ReadmePath" }
$readme = Get-Content $ReadmePath -Raw

$patLast = '(?s)<!-- BEGIN:LAST30_TABLE -->(.*?)<!-- END:LAST30_TABLE -->'
$patNext = '(?s)<!-- BEGIN:NEXT30_TABLE -->(.*?)<!-- END:NEXT30_TABLE -->'
$mLast = [Regex]::Match($readme, $patLast)
$mNext = [Regex]::Match($readme, $patNext)
if (-not $mLast.Success -or -not $mNext.Success) { throw 'One or both table markers not found.' }

$lastTable = $mLast.Groups[1].Value.Trim()
$nextTable = $mNext.Groups[1].Value.Trim()

function Get-Header($table) {
  ($table -split "`n" | Where-Object { $_.Trim() -ne '' })[0]
}
$lastHeader = Get-Header $lastTable
$nextHeader = Get-Header $nextTable

if ($Offline) {
  Write-Host '[offline] Skipping AI call; tables unchanged.'
  exit 0
}

$endpoint   = Require-Env 'AZURE_OPENAI_ENDPOINT'
$apiKey     = Require-Env 'AZURE_OPENAI_KEY'
$deployment = Require-Env 'AZURE_OPENAI_DEPLOYMENT'

Write-DebugInfo "Env present: ENDPOINT=$([string]::IsNullOrWhiteSpace($endpoint) -eq $false); KEY=$([string]::IsNullOrWhiteSpace($apiKey) -eq $false); DEPLOYMENT=$deployment"

$systemPrompt = @'
You edit two markdown tables:
1) Last 30 days shipped changes
2) Next 30 days planned changes

Rules:
- Output ONLY JSON: {"last30_table":"...","next30_table":"..."}
- Tables must preserve existing headers EXACTLY (no column adds/removals, no casing changes).
- Update factual status/date shifts only if public & certain; else leave untouched.
- Add rows only if inside correct 30-day window (retrospective or forward) and publicly disclosed.
- Remove rows only if outside the window or clearly superseded.
- Keep cells concise (<=110 chars) and avoid newlines inside cells.
- If nothing to change, return original tables verbatim.
- No commentary, no markdown fences.
'@

$userContent = @"
Current date: $(Get-Date -Format yyyy-MM-dd)
Retrospective Table (between markers):
$lastTable

Forward Table (between markers):
$nextTable
"@

$payloadObj = @{ 
  messages = @(
    @{ role='system'; content=$systemPrompt },
    @{ role='user'; content=$userContent }
  );
  temperature = 0.1;
  max_tokens = 1800
}

$payload = $payloadObj | ConvertTo-Json -Depth 6
Write-DebugInfo ("Payload bytes: " + ([Text.Encoding]::UTF8.GetByteCount($payload)))
Write-DebugInfo "Payload preview (first 300 chars): "
if ($DebugMode) { $payload.Substring(0, [Math]::Min(300, $payload.Length)) | Write-Host }

$uri = "$endpoint/openai/deployments/$deployment/chat/completions?api-version=2024-02-15-preview"

try {
  $resp = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ 'api-key'=$apiKey; 'Content-Type'='application/json' } -Body $payload -TimeoutSec 120
  Write-DebugInfo "HTTP call succeeded."
} catch {
  Write-Error "Azure OpenAI request failed: $($_.Exception.GetType().FullName): $($_.Exception.Message)" 
  if ($_.ErrorDetails.Message) { Write-Host '[error details raw] ' + $_.ErrorDetails.Message }
  exit 1
}

$raw = $null
try { $raw = $resp.choices[0].message.content } catch { }
if (-not $raw) { 
  Write-Error 'No content returned from model. Full response JSON follows (truncated to 1200 chars).'
  $respJson = ($resp | ConvertTo-Json -Depth 10)
  $trunc = if ($respJson.Length -gt 1200) { $respJson.Substring(0,1200) + '...' } else { $respJson }
  Write-Host $trunc
  exit 1 
}
if ($raw -match '```json(.*?)```'s) { $raw = $Matches[1].Trim() }
Write-DebugInfo "Model raw length: $($raw.Length)"

try { $json = $raw | ConvertFrom-Json -ErrorAction Stop } catch { Write-Error 'Model output not valid JSON.'; if ($raw.Length -lt 1500) { Write-Host $raw } else { Write-Host ($raw.Substring(0,1500) + '...') }; exit 1 }
if (-not ($json.last30_table) -or -not ($json.next30_table)) { Write-Error 'JSON missing required keys.'; exit 1 }

$newLast = ($json.last30_table -replace '\r','').Trim()
$newNext = ($json.next30_table -replace '\r','').Trim()

if ((Get-Header $newLast) -ne $lastHeader) { Write-Error ('Last30 header changed; aborting. Expected: ' + $lastHeader + ' Got: ' + (Get-Header $newLast)); exit 2 }
if ((Get-Header $newNext) -ne $nextHeader) { Write-Error ('Next30 header changed; aborting. Expected: ' + $nextHeader + ' Got: ' + (Get-Header $newNext)); exit 2 }

if ($newLast -eq $lastTable -and $newNext -eq $nextTable) {
  Write-Host 'No changes suggested.'; exit 0
}

Write-Host 'Applying updates.'
$updated = [Regex]::Replace($readme, $patLast, "<!-- BEGIN:LAST30_TABLE -->`n$newLast`n<!-- END:LAST30_TABLE -->")
$updated = [Regex]::Replace($updated, $patNext, "<!-- BEGIN:NEXT30_TABLE -->`n$newNext`n<!-- END:NEXT30_TABLE -->")

if ($DryRun) {
  Write-Host '--- DRY RUN (first 5 lines of new Last30) ---'
  ($newLast -split "`n" | Select-Object -First 5) | ForEach-Object { 'NEW: ' + $_ }
  exit 0
}

Set-Content -Path $ReadmePath -Value $updated -NoNewline
Write-Host 'README updated.'
