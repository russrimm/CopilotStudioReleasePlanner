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
  [switch]$DebugMode,
  [switch]$DisableVersionFallback
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
<#
Version / Endpoint Strategy
1. Primary attempt uses explicit AZURE_OPENAI_API_VERSION env var or latest known stable preview (2024-12-01-preview).
2. If a 400 is returned with an OperationNotSupported / DeploymentNotFound / model gating hint and -DisableVersionFallback is NOT set,
   iterate through a curated fallback list (descending recency) until success.
3. If errors suggest "use the responses API" or we receive a 400 with a message containing 'responses' or 'reasoning',
   retry using the /responses endpoint for that same version before moving to next version.
Environment override for fallback chain (comma separated): AZURE_OPENAI_API_VERSION_FALLBACKS
#>
$apiVersion = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_API_VERSION')
if ([string]::IsNullOrWhiteSpace($apiVersion)) { $apiVersion = '2024-12-01-preview' }
$fallbackEnv = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_API_VERSION_FALLBACKS')
if ([string]::IsNullOrWhiteSpace($fallbackEnv)) {
  $fallbackVersions = @('2024-11-01-preview','2024-08-01-preview','2024-06-01','2024-02-15-preview')
} else {
  $fallbackVersions = $fallbackEnv.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and $_ -ne $apiVersion }
}
Write-DebugInfo "Primary apiVersion=$apiVersion Fallbacks=$([string]::Join(',', $fallbackVersions))"

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

function New-ChatPayload {
  param(
    [string]$SystemPrompt,
    [string]$UserContent
  )
  return @{ 
    messages = @(
      @{ role='system'; content=$SystemPrompt },
      @{ role='user'; content=$UserContent }
    );
    temperature = 0.1;
    max_tokens = 1800
  }
}

$payloadObj = New-ChatPayload -SystemPrompt $systemPrompt -UserContent $userContent

$payload = $payloadObj | ConvertTo-Json -Depth 6
Write-DebugInfo ("Payload bytes: " + ([Text.Encoding]::UTF8.GetByteCount($payload)))
Write-DebugInfo "Payload preview (first 300 chars): "
if ($DebugMode) { $payload.Substring(0, [Math]::Min(300, $payload.Length)) | Write-Host }

function Invoke-AzureOpenAIRequest {
  param(
    [string]$ApiVersion,
    [bool]$UseResponsesEndpoint = $false
  )
  $normalizedEndpoint = $endpoint.TrimEnd('/')
  $path = if ($UseResponsesEndpoint) { 'responses' } else { 'chat/completions' }
  $localUri = "$normalizedEndpoint/openai/deployments/$deployment/$path?api-version=$ApiVersion"
  Write-DebugInfo "Request URI: $localUri"
  $responseHeaders = @{}
  # Prepare body depending on endpoint type
  if ($UseResponsesEndpoint) {
    $respPayloadObj = @{ 
      input = @(
        @{ role='system'; content = @(@{ type='text'; text=$systemPrompt }) },
        @{ role='user'; content   = @(@{ type='text'; text=$userContent }) }
      );
      temperature = 0.1;
      max_output_tokens = 1800
    }
    $body = $respPayloadObj | ConvertTo-Json -Depth 8
  } else {
    $body = $payload
  }
  if ($DebugMode) { Write-Host "[debug] body.length=$($body.Length) useResponses=$UseResponsesEndpoint" }
  try {
    $r = Invoke-RestMethod -Method Post -Uri $localUri -Headers @{ 'api-key'=$apiKey; 'Content-Type'='application/json' } -Body $body -TimeoutSec 120 -ResponseHeadersVariable responseHeaders
    return @{ success=$true; response=$r; headers=$responseHeaders; uri=$localUri }
  } catch {
    $errRecord = $_
    $statusCode = $null; $reasonPhrase = $null; $rawBody=$null; $code=$null; $message=$null
    try { if ($errRecord.Exception.Response) { $statusCode = [int]$errRecord.Exception.Response.StatusCode; $reasonPhrase = $errRecord.Exception.Response.ReasonPhrase } } catch {}
    if ($errRecord.ErrorDetails -and $errRecord.ErrorDetails.Message) { $rawBody = $errRecord.ErrorDetails.Message }
    elseif ($errRecord.Exception.Response -and $errRecord.Exception.Response.ContentLength -gt 0) { try { $reader = New-Object IO.StreamReader($errRecord.Exception.Response.GetResponseStream()); $rawBody = $reader.ReadToEnd() } catch {} }
    if ($rawBody) {
      try { $parsed = $rawBody | ConvertFrom-Json -ErrorAction Stop; if ($parsed.error) { $code=$parsed.error.code; $message=$parsed.error.message } } catch {}
    }
    return @{ success=$false; status=$statusCode; reason=$reasonPhrase; body=$rawBody; code=$code; message=$message; uri=$localUri; responsesTried=$UseResponsesEndpoint }
  }
}

# Attempt sequence
$attempts = @()
function Log-AttemptResult($res, $apiVer, $usingResponses) {
  if ($res.success) {
    Write-DebugInfo "Success with version=$apiVer endpoint=$([bool]$usingResponses ? 'responses' : 'chat') RequestId=$($res.headers['x-ms-request-id'])"
  } else {
    Write-Host "[attempt.fail] version=$apiVer endpoint=$([bool]$usingResponses ? 'responses' : 'chat') status=$($res.status) code=$($res.code)"
    if ($res.message) { Write-Host "[attempt.message] $($res.message)" }
    if ($DebugMode -and $res.body) { $snippet = if ($res.body.Length -gt 600) { $res.body.Substring(0,600)+'...' } else { $res.body }; Write-Host "[attempt.body.snippet] $snippet" }
  }
}

function Should-RetryResponses($res) {
  if (-not $res) { return $false }
  if ($res.success) { return $false }
  if ($res.status -ne 400) { return $false }
  $msg = ($res.message + ' ' + $res.body)
  if ($msg -match '(?i)responses endpoint' -or $msg -match '(?i)use the responses api' -or $msg -match '(?i)reasoning') { return $true }
  return $false
}

function Should-FallbackVersion($res) {
  if (-not $res) { return $false }
  if ($res.success) { return $false }
  if ($res.status -ne 400) { return $false }
  $codesTrigger = @('OperationNotSupported','DeploymentNotFound','ModelNotFound','BadRequest')
  if ($codesTrigger -contains $res.code) { return $true }
  $msg = ($res.message + ' ' + $res.body)
  if ($msg -match '(?i)only for api versions' -or $msg -match '(?i)enabled only for api versions' -or $msg -match '(?i)not supported' ) { return $true }
  return $false
}

$allVersions = @($apiVersion)
if (-not $DisableVersionFallback) { $allVersions += $fallbackVersions }

$finalResponse = $null
foreach ($ver in ($allVersions | Select-Object -Unique)) {
  Write-DebugInfo "Attempting version $ver (chat)"; $res = Invoke-AzureOpenAIRequest -ApiVersion $ver -UseResponsesEndpoint:$false; Log-AttemptResult $res $ver $false; $attempts += $res
  if ($res.success) { $finalResponse = @{ version=$ver; responses=$false; data=$res.response }; break }
  if (Should-RetryResponses $res) {
    Write-DebugInfo "Retrying same version $ver via responses endpoint"; $res2 = Invoke-AzureOpenAIRequest -ApiVersion $ver -UseResponsesEndpoint:$true; Log-AttemptResult $res2 $ver $true; $attempts += $res2
    if ($res2.success) { $finalResponse = @{ version=$ver; responses=$true; data=$res2.response }; break }
    if (-not (Should-FallbackVersion $res2)) { Write-DebugInfo 'Not a version-related error; aborting fallback chain.'; break }
  } elseif (-not (Should-FallbackVersion $res)) {
    Write-DebugInfo 'Not a version-related 400; aborting fallback chain.'; break
  }
}

if (-not $finalResponse) {
  Write-Error 'All attempts failed.'
  foreach ($a in $attempts) {
    if (-not $a.success) {
      Write-Host "FAILED version=$($a.uri) status=$($a.status) code=$($a.code)" 
    }
  }
  exit 1
}

$resp = $finalResponse.data
Write-DebugInfo ("Selected version=$($finalResponse.version) endpoint=$([bool]$finalResponse.responses ? 'responses' : 'chat')")

$raw = $null
if (-not $finalResponse.responses) {
  try { $raw = $resp.choices[0].message.content } catch {}
} else {
  # Responses API shape: output or output_text or choices-like data
  if ($resp.output_text) { $raw = $resp.output_text }
  elseif ($resp.output -and $resp.output.Count -gt 0 -and $resp.output[0].content) {
    # Concatenate any message text parts
    $texts = @()
    foreach ($c in $resp.output[0].content) { if ($c.type -eq 'output_text' -and $c.text) { $texts += $c.text } elseif ($c.type -eq 'text' -and $c.text) { $texts += $c.text } }
    if ($texts.Count -gt 0) { $raw = [string]::Join("`n", $texts) }
  }
}
if (-not $raw) {
  Write-Error 'No content returned from model (after fallback logic). Full response JSON follows (truncated to 1500 chars).'
  $respJson = ($resp | ConvertTo-Json -Depth 12)
  $trunc = if ($respJson.Length -gt 1500) { $respJson.Substring(0,1500) + '...' } else { $respJson }
  Write-Host $trunc
  exit 1
}
if ($raw -match '(?s)```json(.*?)```') { $raw = $Matches[1].Trim() }
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
