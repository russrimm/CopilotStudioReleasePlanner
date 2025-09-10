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
  # Provide a raw model output string (e.g., captured from a prior run) to test parsing/repair logic.
  # When set, the script skips the live Azure OpenAI call and proceeds directly to JSON extraction.
  [string]$RawModelOutput,
  # Path to a file containing raw model output (alternative to -RawModelOutput string).
  [string]$RawModelOutputFile,
  # Retained for backward compatibility but ignored; version fallback disabled by directive.
  [switch]$DisableVersionFallback
)

Write-Host '[ai-refresh] Script start'

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

if ($RawModelOutputFile -and -not (Test-Path $RawModelOutputFile)) { throw "RawModelOutputFile path not found: $RawModelOutputFile" }
if (-not $RawModelOutput -and $RawModelOutputFile) { $RawModelOutput = Get-Content -Path $RawModelOutputFile -Raw }

if ($Offline -and -not $RawModelOutput) {
  Write-Host '[offline] Skipping AI call; tables unchanged.'
  exit 0
}

if (-not $RawModelOutput) {
  $endpoint   = Get-RequiredEnv 'AZURE_OPENAI_ENDPOINT'
  $apiKey     = Get-RequiredEnv 'AZURE_OPENAI_KEY'
  $deployment = Get-RequiredEnv 'AZURE_OPENAI_DEPLOYMENT'
  # Optional distinct model name for unified Responses API (some tenants use model IDs instead of deployment alias here)
  $explicitModel = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_MODEL')
} else {
  # Provide safe placeholders to satisfy later references; logic paths gated on $RawModelOutput.
  $endpoint = ''
  $apiKey = ''
  $deployment = 'raw-test'
  $explicitModel = $null
}

# Basic sanity validation on deployment name to catch accidental inclusion of query parameters.
if ($deployment -match '[\?=&\s]') {
  Write-Host "[warn] Deployment name '$deployment' contains unexpected characters (? & = or whitespace). This may cause 404 errors. Set AZURE_OPENAI_DEPLOYMENT to the exact deployment id (e.g. 'gpt-4o-mini')."
}
<#
Next Generation v1 API (versionless)
Using Azure OpenAI next-gen "v1" endpoints which do not require api-version.
All prior api-version logic removed.
#>
Write-DebugInfo 'Using next-gen v1 API (no api-version parameter).'  

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
    [bool]$UseResponsesEndpoint = $true, # default now responses API
    [switch]$ChatPathFallback
  )
  $normalizedEndpoint = $endpoint.TrimEnd('/')
  if ($UseResponsesEndpoint -and -not $ChatPathFallback) {
    $localUri = "$normalizedEndpoint/openai/v1/responses"
  } else {
    # Legacy chat path fallback (still versionless under next-gen doc guidance)
    $localUri = "$normalizedEndpoint/openai/v1/chat/completions"
  }
  Write-DebugInfo "Request URI: $localUri"
  $responseHeaders = @{}
  # Prepare body depending on endpoint type
  if ($UseResponsesEndpoint -and -not $ChatPathFallback) {
    # Minimal, spec-aligned responses payload (simplify to reduce 400 risk):
    # docs allow either a simple string in "input" or a structured array. We combine instructions + user content.
    $modelForResponses = if ([string]::IsNullOrWhiteSpace($explicitModel)) { $deployment } else { $explicitModel }
    $combinedInput = "SYSTEM:\n$systemPrompt\n\nUSER:\n$userContent"
    $respPayloadObj = @{
      model = $modelForResponses
      input = $combinedInput
      max_output_tokens = 1800
    }
    $useSchema = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_USE_JSON_SCHEMA')
    if ($useSchema -and $useSchema -match '^(?i:true|1|yes|on)$') {
      # New Responses API format: use text.format = json_schema (deprecates response_format)
      $respPayloadObj.text = @{
        format = 'json_schema'
        json_schema = @{
          name = 'RollingWindowTables'
          schema = @{ type='object'; additionalProperties=$false; required=@('last30_table','next30_table'); properties=@{ last30_table=@{ type='string' }; next30_table=@{ type='string' } } }
        }
      }
      Write-DebugInfo 'Added text.format=json_schema for strict output.'
    } else {
      $respPayloadObj.input += "`n`nReturn ONLY a single JSON object with keys last30_table and next30_table."
    }
  # Increase depth to avoid truncation of nested json_schema structure
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
    # Adaptive retry scenarios for evolving Responses API JSON schema formatting.
    $needsAdaptive = $false
    $adaptiveReason = $null
    if ($UseResponsesEndpoint) {
      if ($code -eq 'unsupported_parameter' -and $rawBody -match 'text.format') { $needsAdaptive = $true; $adaptiveReason = 'unsupported_text.format' }
      elseif ($code -eq 'unknown_parameter' -and $rawBody -match 'text.json_schema') { $needsAdaptive = $true; $adaptiveReason = 'unknown_text.json_schema' }
    }
    if ($needsAdaptive) {
      Write-DebugInfo "Adaptive retry ($adaptiveReason): removing text.* block and reinforcing JSON instruction." 
      try {
        $retryObj = $respPayloadObj
        if ($retryObj.ContainsKey('text')) { $retryObj.Remove('text') | Out-Null }
        if (-not ($retryObj.input -match 'Return ONLY a single JSON object')) {
          $retryObj.input += "`n`nReturn ONLY a single JSON object with keys last30_table and next30_table."
        }
  $retryBody = $retryObj | ConvertTo-Json -Depth 8
        $r2 = Invoke-RestMethod -Method Post -Uri $localUri -Headers @{ 'api-key'=$apiKey; 'Content-Type'='application/json' } -Body $retryBody -TimeoutSec 120 -ResponseHeadersVariable responseHeaders
        return @{ success=$true; response=$r2; headers=$responseHeaders; uri=$localUri; adaptiveRetry=$adaptiveReason }
      } catch {
        Write-DebugInfo "Adaptive retry failed: $($_.Exception.Message)"
      }
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
      Write-Host "[hint] 404 on chat endpoint often means the deployment (model) name '$deployment' is incorrect or not enabled."
    }
    if ($DebugMode -and $res.body) { $snippet = if ($res.body.Length -gt 600) { $res.body.Substring(0,600)+'...' } else { $res.body }; Write-Host "[attempt.body.snippet] $snippet" }
  }
}

<# Next-gen attempt logic (no api-version) #>
 $forceResponsesEnv = [Environment]::GetEnvironmentVariable('AZURE_OPENAI_FORCE_RESPONSES')
 $preferResponsesFirst = $true
 if ($forceResponsesEnv -and $forceResponsesEnv -match '^(?i:false|0|no)$') { $preferResponsesFirst = $false }

$finalResponse = $null
if ($preferResponsesFirst) {
  Write-DebugInfo 'Attempting responses primary (versionless v1)'; $rResp = Invoke-AzureOpenAIRequest -UseResponsesEndpoint:$true; Write-AttemptResult $rResp 'v1' $true; $attempts += $rResp
  if ($rResp.success) { $finalResponse = @{ version='v1'; responses=$true; data=$rResp.response } }
  elseif ($isGpt5) {
    # Adaptive parameter pruning if needed for GPT-5 responses
    if ($rResp.body -match "Unsupported parameter: '?max_output_tokens") {
      Write-DebugInfo 'Adaptive retry removing max_output_tokens.'
      $normalizedEndpoint = $endpoint.TrimEnd('/')
  $uri = "$normalizedEndpoint/openai/v1/responses"
      $modelForResponses = if ([string]::IsNullOrWhiteSpace($explicitModel)) { $deployment } else { $explicitModel }
      $combinedInput = "SYSTEM:`n$systemPrompt`n`nUSER:`n$userContent"
      $retryObj = @{ model=$modelForResponses; input=$combinedInput }
      $retryBody = $retryObj | ConvertTo-Json -Depth 3
      try {
        $rr = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ 'api-key'=$apiKey; 'Content-Type'='application/json' } -Body $retryBody -TimeoutSec 120
        $attempts += @{ success=$true; response=$rr; headers=@{}; uri=$uri }
  $finalResponse = @{ version='v1'; responses=$true; data=$rr }
      } catch {
        $attempts += @{ success=$false; status=$_.Exception.Response.StatusCode.value__; body=$_.ErrorDetails.Message; code='adaptive_retry_fail'; message='Adaptive retry failed'; uri=$uri }
      }
    }
    if (-not $finalResponse) {
      Write-DebugInfo 'Responses path failed for GPT-5; attempting chat fallback despite GPT-5 strategy.'
      $rChatG5 = Invoke-AzureOpenAIRequest -UseResponsesEndpoint:$false -ChatPathFallback; Write-AttemptResult $rChatG5 'v1' $false; $attempts += $rChatG5
      if ($rChatG5.success) { $finalResponse = @{ version='v1'; responses=$false; data=$rChatG5.response } }
    }
  } else {
    if (-not $rResp.success) {
      Write-DebugInfo 'Responses-first failed; attempting chat/completions fallback.'
      $rChat = Invoke-AzureOpenAIRequest -UseResponsesEndpoint:$false -ChatPathFallback; Write-AttemptResult $rChat 'v1' $false; $attempts += $rChat
      if ($rChat.success) { $finalResponse = @{ version='v1'; responses=$false; data=$rChat.response } }
    }
  }
} else {
  Write-DebugInfo 'Attempting chat-first (versionless v1)'; $rChatOnly = Invoke-AzureOpenAIRequest -UseResponsesEndpoint:$false -ChatPathFallback; Write-AttemptResult $rChatOnly 'v1' $false; $attempts += $rChatOnly
  if ($rChatOnly.success) { $finalResponse = @{ version='v1'; responses=$false; data=$rChatOnly.response } }
  elseif (-not $isGpt5) {
    Write-DebugInfo 'Chat-first failed; attempting responses fallback.'
    $rResp2 = Invoke-AzureOpenAIRequest -UseResponsesEndpoint:$true; Write-AttemptResult $rResp2 'v1' $true; $attempts += $rResp2
    if ($rResp2.success) { $finalResponse = @{ version='v1'; responses=$true; data=$rResp2.response } }
  } else {
    Write-DebugInfo 'Chat-first failed and GPT-5 strategy avoids responses fallback when forced chat-first.'
  }
}

if (-not $RawModelOutput) {
  if (-not $finalResponse) {
    Write-Error 'All attempts failed (v1 versionless).'
    foreach ($a in $attempts) { if (-not $a.success) { Write-Host "FAILED uri=$($a.uri) status=$($a.status) code=$($a.code)" } }
    exit 1
  }
  $resp = $finalResponse.data
  Write-DebugInfo ("Selected version=$($finalResponse.version) endpoint=$([bool]$finalResponse.responses ? 'responses' : 'chat')")
}

$raw = $null
if ($RawModelOutput) {
  Write-DebugInfo 'Using provided -RawModelOutput instead of live model response.'
  $raw = $RawModelOutput
  Write-DebugInfo ("Raw model output length=" + ($raw.Length))
} elseif ($finalResponse -and -not $finalResponse.responses) {
  try { $raw = $resp.choices[0].message.content } catch {}
} elseif ($finalResponse) {
  function Get-ResponsesText($rObj) {
    if (-not $rObj) { return $null }
    if ($rObj.output_text) { return $rObj.output_text }
    if ($rObj.output -and $rObj.output.Count -gt 0) {
      $texts = @(); foreach ($block in $rObj.output) { if ($block.content) { foreach ($c in $block.content) { if ($c.type -eq 'output_text' -and $c.text) { $texts += $c.text } elseif ($c.type -eq 'text' -and $c.text) { $texts += $c.text } } } }; if ($texts.Count -gt 0) { return ([string]::Join("`n", $texts)) }
    }
    return $null
  }
  $raw = Get-ResponsesText $resp
  $status = $resp.status
  if (-not $raw -and $status -and ($status -match '^(in_progress|queued)$')) {
    $pollSeconds = [int]([Environment]::GetEnvironmentVariable('AZURE_OPENAI_POLL_MAX_SECONDS')); if ($pollSeconds -le 0) { $pollSeconds = 60 }
    $interval = [int]([Environment]::GetEnvironmentVariable('AZURE_OPENAI_POLL_INTERVAL_SECONDS')); if ($interval -le 0) { $interval = 2 }
    Write-DebugInfo "Polling responses status (id=$($resp.id)) up to $pollSeconds s interval=$interval s (initial status=$status)."
    $deadline = (Get-Date).AddSeconds($pollSeconds); $normalizedEndpoint = $endpoint.TrimEnd('/')
    while ((Get-Date) -lt $deadline) {
      Start-Sleep -Seconds $interval
      try { $pollUri = "$normalizedEndpoint/openai/v1/responses/$($resp.id)"; $polled = Invoke-RestMethod -Method Get -Uri $pollUri -Headers @{ 'api-key'=$apiKey }; $status = $polled.status; Write-DebugInfo "Poll status=$status"; $raw = Get-ResponsesText $polled; if ($raw -or ($status -notmatch '^(in_progress|queued)$')) { $resp = $polled; break } } catch { Write-DebugInfo "Polling error: $($_.Exception.Message)"; break }
    }
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
$raw = $raw -replace '(?s)^```[A-Za-z0-9_-]*\n','' -replace '(?s)```$',''
Write-DebugInfo "Model raw length: $($raw.Length)"
Write-DebugInfo ("Model raw preview: " + ($raw.Substring(0, [Math]::Min(160,$raw.Length))))

function Convert-ModelJsonStrict([string]$text) { try { return ,(@($text | ConvertFrom-Json -ErrorAction Stop)[0]) } catch { return $null } }
function Get-JsonObjectCandidate([string]$text) {
  if (-not $text) { return $null }
  $parsed = Convert-ModelJsonStrict $text; if ($parsed) { return $parsed }
  $idxKey1 = $text.IndexOf('"last30_table"'); $idxKey2 = $text.IndexOf('"next30_table"')
  if ($idxKey1 -lt 0 -or $idxKey2 -lt 0) { return $null }
  $startBrace = $text.LastIndexOf('{', $idxKey1); if ($startBrace -lt 0) { return $null }
  $braceCount = 0; $candidate = $null
  for ($i=$startBrace; $i -lt $text.Length; $i++) { $ch=$text[$i]; if ($ch -eq '{') { $braceCount++ } elseif ($ch -eq '}') { $braceCount--; if ($braceCount -eq 0) { $candidate = $text.Substring($startBrace, ($i - $startBrace + 1)); break } } }
  if (-not $candidate) { return $null }
  $candidate = $candidate -replace '[“”]','"' -replace '[‘’]','"'
  $candidate = $candidate -replace ',\s*([}\]])','$1'
  return (Convert-ModelJsonStrict $candidate)
}
function Repair-ModelJson([string]$text) {
  $try1 = Get-JsonObjectCandidate $text; if ($try1) { return $try1 }
  if ($text -match '\\n') { $alt = $text -replace '\\n','\n'; $try2 = Get-JsonObjectCandidate $alt; if ($try2) { return $try2 } }
  return $null
}

# Escapes literal (unescaped) newline and carriage return characters that appear inside JSON string literals.
# Some model outputs incorrectly place raw line breaks inside string values (invalid JSON). This state-machine
# transformation preserves existing escape sequences while converting only literal line breaks inside strings
# to their escaped forms so ConvertFrom-Json can succeed.
function Convert-LiteralNewlinesInJsonStrings([string]$text) {
  if (-not $text) { return $text }
  $sb = New-Object System.Text.StringBuilder
  $inString = $false
  $escapeNext = $false
  foreach ($ch in $text.ToCharArray()) {
    if ($escapeNext) { [void]$sb.Append($ch); $escapeNext = $false; continue }
    if ($ch -eq '\\') { $escapeNext = $true; [void]$sb.Append($ch); continue }
    if ($ch -eq '"') { $inString = -not $inString; [void]$sb.Append($ch); continue }
    if ($inString -and $ch -eq "`n") { [void]$sb.Append('\\n'); continue }
    if ($inString -and $ch -eq "`r") { [void]$sb.Append('\\r'); continue }
    # Outside strings we simply drop standalone CR characters (common in Windows line endings) and keep newlines.
    if (-not $inString -and $ch -eq "`r") { continue }
    [void]$sb.Append($ch)
  }
  return $sb.ToString()
}

$json = Convert-ModelJsonStrict $raw
if (-not $json) {
  Write-DebugInfo 'Strict parse failed; attempting newline escape repair.'
  $escapedNewlines = Convert-LiteralNewlinesInJsonStrings $raw
  if ($escapedNewlines -ne $raw) {
    $json = Convert-ModelJsonStrict $escapedNewlines
    if ($json) { Write-DebugInfo 'Parse succeeded after escaping literal newlines inside strings.' }
  }
}
if (-not $json) {
  Write-DebugInfo 'Attempting heuristic structural repair.'
  $json = Repair-ModelJson $raw
}
if (-not $json) {
  Write-Error 'Model output not valid JSON (after repair attempts).'
  if ($raw.Length -lt 2000) { Write-Host $raw } else { Write-Host ($raw.Substring(0,2000) + '...') }
  exit 1
}
if (-not ($json.last30_table) -or -not ($json.next30_table)) { Write-Error 'JSON missing required keys after parse.'; exit 1 }

$newLast = ($json.last30_table -replace '\r','').Trim()
$newNext = ($json.next30_table -replace '\r','').Trim()

function Get-HeaderColumns([string]$h) {
  if (-not $h) { return @() }
  return ($h -split '\|') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
}
function Test-HeadersEquivalent($expected, $candidate) {
  $c1 = Get-HeaderColumns $expected
  $c2 = Get-HeaderColumns $candidate
  if ($c1.Count -ne $c2.Count) { return $false }
  for ($i=0; $i -lt $c1.Count; $i++) { if ($c1[$i] -ne $c2[$i]) { return $false } }
  return $true
}

$newLastHeader = Get-Header $newLast
if ($newLastHeader -ne $lastHeader) {
  if (Test-HeadersEquivalent $lastHeader $newLastHeader) {
    Write-DebugInfo 'Last30 header differs only by formatting; normalizing to original.'
    $lines = $newLast -split "`n"; if ($lines.Length -gt 0) { $lines[0] = $lastHeader; $newLast = ($lines -join "`n") }
  } else {
    Write-Error ('Last30 header changed; aborting. Expected: ' + $lastHeader + ' Got: ' + $newLastHeader); exit 2
  }
}

$newNextHeader = Get-Header $newNext
if ($newNextHeader -ne $nextHeader) {
  if (Test-HeadersEquivalent $nextHeader $newNextHeader) {
    Write-DebugInfo 'Next30 header differs only by formatting; normalizing to original.'
    $lines2 = $newNext -split "`n"; if ($lines2.Length -gt 0) { $lines2[0] = $nextHeader; $newNext = ($lines2 -join "`n") }
  } else {
    Write-Error ('Next30 header changed; aborting. Expected: ' + $nextHeader + ' Got: ' + $newNextHeader); exit 2
  }
}

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
