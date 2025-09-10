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

function Get-RequiredEnv {
  param([string]$Name)
  $val = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($val)) { throw "Missing required environment variable: $Name" }
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

$endpoint   = Get-RequiredEnv 'AZURE_OPENAI_ENDPOINT'
$apiKey     = Get-RequiredEnv 'AZURE_OPENAI_KEY'
$deployment = Get-RequiredEnv 'AZURE_OPENAI_DEPLOYMENT'
# Optional distinct model name for unified Responses API (some tenants use model IDs instead of deployment alias here)
$explicitModel = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_MODEL')

# Basic sanity validation on deployment name to catch accidental inclusion of query parameters.
if ($deployment -match '[\?=&\s]') {
  Write-Host "[warn] Deployment name '$deployment' contains unexpected characters (? & = or whitespace). This may cause 404 errors. Set AZURE_OPENAI_DEPLOYMENT to the exact deployment id (e.g. 'gpt-4o-mini')."
}
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

# GPT-5 family: prefer explicit '2024-12-01-preview' unless user overrides to preview/v1.
if ((($deployment -match '^gpt-5') -or ($explicitModel -and $explicitModel -match '^gpt-5'))) {
  $gpt5Preferred = '2024-12-01-preview'
  if ($apiVersion -match '(?i)^v?1$') {
    Write-DebugInfo "apiVersion '$apiVersion' accepted for GPT-5 (v1 semantic)."
  } elseif ($apiVersion -match '(?i)preview' -and $apiVersion -ne $gpt5Preferred) {
    Write-DebugInfo "apiVersion '$apiVersion' is a generic preview; leaving as-is but noting preferred=$gpt5Preferred." 
  } elseif ($apiVersion -ne $gpt5Preferred) {
    Write-DebugInfo "Overriding apiVersion from '$apiVersion' to '$gpt5Preferred' for GPT-5 family."
    $apiVersion = $gpt5Preferred
  }
}
$fallbackEnv = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_API_VERSION_FALLBACKS')
if ([string]::IsNullOrWhiteSpace($fallbackEnv)) {
  if ((($deployment -match '^gpt-5') -or ($explicitModel -and $explicitModel -match '^gpt-5'))) {
    # GPT-5: only try preferred then generic preview as a secondary.
    $fallbackVersions = @('2024-12-01-preview','preview') | Where-Object { $_ -ne $apiVersion }
  } else {
    $fallbackVersions = @('preview','2024-12-01-preview','2024-11-01-preview','2024-08-01-preview','2024-06-01','2024-02-15-preview') | Where-Object { $_ -ne $apiVersion }
  }
} else {
  $fallbackVersions = $fallbackEnv.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and $_ -ne $apiVersion }
  if ((($deployment -match '^gpt-5') -or ($explicitModel -and $explicitModel -match '^gpt-5')) -and ($fallbackVersions -notcontains '2024-12-01-preview')) {
    $fallbackVersions = @('2024-12-01-preview') + $fallbackVersions
  }
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
    [string]$UserContent,
    [bool]$UseCompletionParam
  )
  $base = @{ 
    messages = @(
      @{ role='system'; content=$SystemPrompt },
      @{ role='user'; content=$UserContent }
    );
  }
  if (-not $UseCompletionParam) {
    # For non GPT-5 models keep deterministic low temperature; GPT-5 route removes unsupported parameter risk.
    $base.temperature = 0.1
  }
  if ($UseCompletionParam) {
    # Newer GPT-5 family expects max_completion_tokens instead of max_tokens
    $base.max_completion_tokens = 1800
  } else {
    $base.max_tokens = 1800
  }
  return $base
}

$isGpt5 = (($deployment -match '^gpt-5') -or ($explicitModel -and $explicitModel -match '^gpt-5'))
$payloadObj = New-ChatPayload -SystemPrompt $systemPrompt -UserContent $userContent -UseCompletionParam:$isGpt5
Write-DebugInfo ("Chat payload token param used: " + ($isGpt5 ? 'max_completion_tokens' : 'max_tokens'))
if ($isGpt5) { Write-DebugInfo 'GPT-5 family detected: chat fallback will be skipped (responses-only strategy).' }

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
  # Chat Completions keeps the legacy deployments scoped path; Responses uses unified /v1/responses with model in body
  if ($UseResponsesEndpoint) {
  $localUri = "$normalizedEndpoint/openai/v1/responses?api-version=$ApiVersion"
  } else {
  $localUri = "$normalizedEndpoint/openai/deployments/$deployment/chat/completions?api-version=$ApiVersion"
  }
  Write-DebugInfo "Request URI: $localUri"
  $responseHeaders = @{}
  # Prepare body depending on endpoint type
  if ($UseResponsesEndpoint) {
    # Minimal, spec-aligned responses payload (simplify to reduce 400 risk):
    # docs allow either a simple string in "input" or a structured array. We combine instructions + user content.
    $modelForResponses = if ([string]::IsNullOrWhiteSpace($explicitModel)) { $deployment } else { $explicitModel }
    $combinedInput = "SYSTEM:\n$systemPrompt\n\nUSER:\n$userContent"
    $respPayloadObj = @{
      model = $modelForResponses
      input = $combinedInput
      max_output_tokens = 1800
    }
    $body = $respPayloadObj | ConvertTo-Json -Depth 4
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
function Write-AttemptResult($res, $apiVer, $usingResponses) {
  if ($res.success) {
    Write-DebugInfo "Success with version=$apiVer endpoint=$([bool]$usingResponses ? 'responses' : 'chat') RequestId=$($res.headers['x-ms-request-id'])"
  } else {
    Write-Host "[attempt.fail] version=$apiVer endpoint=$([bool]$usingResponses ? 'responses' : 'chat') status=$($res.status) code=$($res.code)"
    if ($res.message) { Write-Host "[attempt.message] $($res.message)" }
    if ($res.status -eq 404 -and -not $usingResponses) {
      Write-Host "[hint] 404 on chat endpoint often means the deployment name '$deployment' is wrong or the api-version '$apiVer' is unavailable for chat. Will probe deployments before deciding fallback."
    }
    if ($DebugMode -and $res.body) { $snippet = if ($res.body.Length -gt 600) { $res.body.Substring(0,600)+'...' } else { $res.body }; Write-Host "[attempt.body.snippet] $snippet" }
  }
}

function Test-RetryResponses($res) {
  if (-not $res) { return $false }
  if ($res.success) { return $false }
  # Retry responses for 400 (BadRequest) and 404 (possible unsupported chat route / missing deployment path) to probe unified API.
  if ($res.status -notin @(400,404)) { return $false }
  $msg = ($res.message + ' ' + $res.body)
  if ($msg -match '(?i)responses endpoint' -or $msg -match '(?i)use the responses api' -or $msg -match '(?i)reasoning') { return $true }
  # Broad heuristic always on to gather evidence while stabilizing.
  return $true
}

function Test-FallbackVersion($res) {
  if (-not $res) { return $false }
  if ($res.success) { return $false }
  # Treat 400 and 404 as potentially version-related (404 often surfaces on newly introduced api-version with legacy path).
  if ($res.status -notin @(400,404)) { return $false }
  $codesTrigger = @('OperationNotSupported','DeploymentNotFound','ModelNotFound','BadRequest','404')
  if ($codesTrigger -contains $res.code) { Write-DebugInfo "FallbackVersion trigger: code=$($res.code)"; return $true }
  $msg = ($res.message + ' ' + $res.body)
  if ($msg -match '(?i)only for api versions' -or $msg -match '(?i)enabled only for api versions' -or $msg -match '(?i)not supported' ) { Write-DebugInfo 'FallbackVersion trigger: message pattern match'; return $true }
  return $false
}

$allVersions = @($apiVersion)
if (-not $DisableVersionFallback) { $allVersions += $fallbackVersions }

# For GPT-5 family, expand version candidate list aggressively if we hit 'API version not supported'.
$gpt5VersionCandidates = @(
  '2025-01-01-preview',
  '2024-12-01-preview',
  '2024-11-01-preview',
  '2024-10-21-preview',
  '2024-10-15-preview',
  '2024-10-01-preview',
  '2024-09-01-preview',
  '2024-08-01-preview',
  '2024-07-01-preview',
  'preview',
  '2024-06-01'
) | Select-Object -Unique

if ($isGpt5) {
  # Prepend candidates not already present
  foreach ($cand in $gpt5VersionCandidates) { if ($allVersions -notcontains $cand) { $allVersions += $cand } }
}

if ($isGpt5) { Write-DebugInfo ("GPT-5 version candidate order: " + (($allVersions | Select-Object -Unique) -join ' | ')) }

# Preflight probe: for GPT-5, attempt a quick deployments GET to see which versions return 200; prefer those first.
if ($isGpt5) {
  $reachable = @()
  foreach ($vProbe in ($allVersions | Select-Object -Unique)) {
    try {
      $probeUri = ($endpoint.TrimEnd('/')) + "/openai/deployments?api-version=$vProbe"
      $respProbe = Invoke-RestMethod -Method Get -Uri $probeUri -Headers @{ 'api-key'=$apiKey } -TimeoutSec 30
      if ($respProbe.data) { $reachable += $vProbe }
    } catch {
      # ignore
    }
    if ($reachable.Count -ge 3) { break }
  }
  if ($reachable.Count -gt 0) {
    Write-DebugInfo ("Preflight reachable apiVersions (first passes): " + ($reachable -join ','))
    # Reorder: reachable first, then rest
    $ordered = @()
    foreach ($r in $reachable) { if ($ordered -notcontains $r) { $ordered += $r } }
    foreach ($v in ($allVersions | Select-Object -Unique)) { if ($ordered -notcontains $v) { $ordered += $v } }
    $allVersions = $ordered
  } else {
    Write-DebugInfo 'Preflight probe found no immediately reachable versions; proceeding with full list.'
  }
}

$forceResponsesEnv = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_FORCE_RESPONSES')
$preferResponsesFirst = $false
if ($forceResponsesEnv -and $forceResponsesEnv -match '^(?i:true|1|yes)$') { $preferResponsesFirst = $true }
if (-not $forceResponsesEnv) { $preferResponsesFirst = $true; Write-DebugInfo 'FORCE_RESPONSES not set; enabling responses-first heuristic due to prior persistent chat 404s.' }

$finalResponse = $null
foreach ($ver in ($allVersions | Select-Object -Unique)) {
  if ($preferResponsesFirst) {
    Write-DebugInfo "Attempting version $ver (responses-first)"; $rRespFirst = Invoke-AzureOpenAIRequest -ApiVersion $ver -UseResponsesEndpoint:$true; Write-AttemptResult $rRespFirst $ver $true; $attempts += $rRespFirst
    if ($rRespFirst.success) { $finalResponse = @{ version=$ver; responses=$true; data=$rRespFirst.response }; break }
    if ($isGpt5) {
      # Adaptive retry removal for unsupported parameter on responses
      if (-not $rRespFirst.success -and $rRespFirst.body -match 'Unsupported parameter:') {
        if ($rRespFirst.body -match "Unsupported parameter: '?max_output_tokens" -and $payloadObj.max_completion_tokens) {
          Write-DebugInfo "Removing max_output_tokens and retrying same version $ver (adaptive parameter pruning)."
          # Remove the parameter and retry once
          $script:adaptiveRetried = $true
          function Invoke-Gpt5AdaptiveRetry($apiVer) {
            $normalizedEndpoint = $endpoint.TrimEnd('/')
            $uri = "$normalizedEndpoint/openai/v1/responses?api-version=$apiVer"
            $modelForResponses = if ([string]::IsNullOrWhiteSpace($explicitModel)) { $deployment } else { $explicitModel }
            $combinedInput = "SYSTEM:`n$systemPrompt`n`nUSER:`n$userContent"
            $retryObj = @{ model=$modelForResponses; input=$combinedInput }
            $retryBody = $retryObj | ConvertTo-Json -Depth 3
            try { $rr = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ 'api-key'=$apiKey; 'Content-Type'='application/json' } -Body $retryBody -TimeoutSec 120; return @{ success=$true; response=$rr; headers=@{}} } catch { return @{ success=$false; status=$_.Exception.Response.StatusCode.value__; body=$_.ErrorDetails.Message; code='adaptive_retry_fail'; message='Adaptive retry failed' } }
          }
          $adaptive = Invoke-Gpt5AdaptiveRetry $ver
          $attempts += $adaptive
          if ($adaptive.success) { $finalResponse = @{ version=$ver; responses=$true; data=$adaptive.response }; break }
        }
      }
      Write-DebugInfo "Skipping chat fallback for GPT-5 on version $ver; moving to next version if classified as version-related."
      if (-not (Test-FallbackVersion $rRespFirst)) { Write-DebugInfo 'Abort: responses failure not version-related; stopping chain.'; break }
      else { continue }
    }
    # Non GPT-5 path: try chat fallback
    Write-DebugInfo "Fallback to chat for version $ver after responses-first failure"; $rChat = Invoke-AzureOpenAIRequest -ApiVersion $ver -UseResponsesEndpoint:$false; Write-AttemptResult $rChat $ver $false; $attempts += $rChat
    if ($rChat.success) { $finalResponse = @{ version=$ver; responses=$false; data=$rChat.response }; break }
    if (-not (Test-FallbackVersion $rChat)) { Write-DebugInfo 'Abort: not classified as version-related after responses-first path.'; break }
    continue
  }

  Write-DebugInfo "Attempting version $ver (chat)"; $res = Invoke-AzureOpenAIRequest -ApiVersion $ver -UseResponsesEndpoint:$false; Write-AttemptResult $res $ver $false; $attempts += $res
  # If we get a 404 on chat, proactively probe deployments once per version to validate target exists
  if (-not $res.success -and $res.status -eq 404) {
    try {
      $probeUriOn404 = ($endpoint.TrimEnd('/')) + "/openai/deployments?api-version=$ver"
      Write-DebugInfo "Probing deployments due to 404: $probeUriOn404"
      $probe404 = Invoke-RestMethod -Method Get -Uri $probeUriOn404 -Headers @{ 'api-key'=$apiKey }
      $names404 = ($probe404.data | ForEach-Object { $_.id })
      Write-DebugInfo ("Deployments available: " + ($names404 -join ','))
      if ($names404 -notcontains $deployment) { Write-Host "[warn] Deployment '$deployment' not found in current listing; verify AZURE_OPENAI_DEPLOYMENT." }
    } catch { Write-DebugInfo "Probe after 404 failed: $($_.Exception.Message)" }
  }
  if ($res.success) { $finalResponse = @{ version=$ver; responses=$false; data=$res.response }; break }
  # Always consider responses retry on 400 now (broadened heuristic inside Test-RetryResponses)
  if (Test-RetryResponses $res) {
    Write-DebugInfo "Retrying same version $ver via responses endpoint"; $res2 = Invoke-AzureOpenAIRequest -ApiVersion $ver -UseResponsesEndpoint:$true; Write-AttemptResult $res2 $ver $true; $attempts += $res2
    if ($res2.success) { $finalResponse = @{ version=$ver; responses=$true; data=$res2.response }; break }
    if (-not (Test-FallbackVersion $res2)) { Write-DebugInfo 'Abort: responses attempt not classified version-related; stopping chain.'; break }
  } elseif (-not (Test-FallbackVersion $res)) {
    Write-DebugInfo ("Abort: status=$($res.status) not classified version-related; stopping chain."); break
  }
}

if (-not $finalResponse) {
  Write-Error 'All attempts failed.'
  # Attempt a lightweight deployments probe for additional diagnostics (non-fatal).
  try {
    $probeVer = $apiVersion
    $probeUri = ($endpoint.TrimEnd('/')) + "/openai/deployments?api-version=$probeVer"
    Write-Host "[probe] GET $probeUri"
    $probe = Invoke-RestMethod -Method Get -Uri $probeUri -Headers @{ 'api-key'=$apiKey }
    $probeNames = ($probe.data | ForEach-Object { $_.id }) -join ','
    Write-Host "[probe.result] deployments=$probeNames"
  } catch { Write-Host "[probe.error] $($_.Exception.Message)" }
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
