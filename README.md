---
title: Copilot Studio Rolling Updates Hub
lastUpdated: 2025-09-10
description: Rolling 30‑day changes plus concise future roadmap summary.
version: 1.2
---

# Copilot Studio – Rolling Updates Hub

Operational flight deck for Copilot Studio evolution:
1. Last 30 days shipped changes (retrospective)
2. Concise future planned changes (supersedes narrow "next 30 days")

Extended references:
• Full 12‑Month Catalog: [Last 12 Months](./archive/Last_12_Months_Features.md)  
• 6‑Month Snapshot: [Last 6 Months](./archive/Last_6_Months_Features.md)  
• Full Future Detail: [All Future Planned Features](./Future_Planned_Features.md)

Legend: **GA** = Generally Available, **Preview** = Public preview / early access, **Planned GA** = published target (month/date), **TBD** = not yet published.

Sources: Microsoft Learn "What's new" + public Power Platform release plans + linked feature docs. Re‑verify forward dates before gating dependencies.

## Navigation
[At a Glance](#at-a-glance) • [Last 30 Days](#last-30-days-feature-changes-2025-08-12-to-2025-09-10) • [Future Summary](#future-planned-changes-concise-summary) • [Immediate Actions](#immediate-actions-checklist) • [Security Focus](#security--compliance-focus) • [Churn Spotlight](#churn-spotlight-recent-status-transitions) • [Prep Matrix](#prep-priority-matrix) • [Delta Since Last Refresh](#delta-since-last-refresh) • [Sources](#source-references)

## At a Glance
<!-- BEGIN:AT_A_GLANCE -->
| Metric | Count | Notes |
|--------|-------|-------|
| GA features (last 30d window) | 5 | Newly GA or GA confirmations |
| Preview items (last 30d window) | 6 | Active evaluation required |
| Preview → GA transitions (window) | 2 | Status promotions |
| Security / Governance related updates | 12 | Auto keyword heuristic |
| Multimodal / Execution updates | 2 | Interpreter & file/image pipeline |
<!-- END:AT_A_GLANCE -->
_Counts auto-maintained; modify via refresh script._

Status: ![GA](https://img.shields.io/badge/GA-3-brightgreen) ![Preview](https://img.shields.io/badge/Preview-5-orange) ![Planned_GA](https://img.shields.io/badge/Planned_GA-3-blue) ![TBD](https://img.shields.io/badge/TBD-2-lightgrey)

---

## Last 30 Days Feature Changes (2025-08-12 to 2025-09-10)
Digest of promotions, launches, and new previews inside the rolling 30‑day window. (Date range auto-updated daily by workflow.)

<!-- BEGIN:LAST30_TABLE -->
| Feature | Status (Now) | Change Date (Approx) | What Changed | Why It Matters | Recommended Action |
|---------|--------------|----------------------|--------------|---------------|-------------------|
| [Code interpreter](https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts) | GA | 2025-08 | GA release | Natural language → Python execution for dynamic transformations & actions | Pilot on low-risk analytic tasks; define governance limits (execution time, data scope). |
| [File groups](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-file-groups) | GA (was Preview) | 2025-08 | Reached GA | Cohesive organization + scoped instructions for grouped files | Refactor ad hoc single-file sources into logical groups for better grounding precision. |
| [Generated answer rate & quality analytics](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-improve-agent-effectiveness#generated-answer-rate-and-quality) | GA | 2025-08 | New analytics section GA | Surfaces unanswered & low-quality clusters | Establish weekly triage; create remediation backlog tied to knowledge gaps. |
| [Expanded file & image upload pipeline](https://learn.microsoft.com/en-us/microsoft-copilot-studio/image-input-analysis) | GA | 2025-08 | Broader multimodal support & downstream pass-through | Unlocks richer workflows (e.g., image → extraction → action chain) | Add validation step ensuring sensitive images meet compliance before routing. |
| [MCP server guided connection](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-add-existing-server-to-agent#add-the-mcp-server-in-copilot-studio-recommended) | GA | 2025-08 | Guided add & tool registration GA | Lowers friction to integrate external capabilities | Standardize naming & tagging of MCP tools for searchability. |
| [Discover & install Microsoft-built agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-install-agent) | Phased GA | 2025-08 | Catalog experience maturing | In-product reuse of curated agents reduces duplicate build effort | Define review checklist (security, data scope, ownership) before catalog adoption. |
| [Use up to 1000 files per agent uploads](https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave2/microsoft-copilot-studio/planned-features#copilot-configuration) | Preview | 2025-08-18 | Preview availability | Scales knowledge ingestion dramatically | Plan taxonomy & retention policy early; avoid dumping uncurated content. |
| [Block maker-provided credentials for authentication](https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave2/microsoft-copilot-studio/planned-features#copilot-configuration) | Preview | 2025-09 | New preview control | Reduces credential sprawl & shadow auth risk | Inventory existing agents using maker creds; schedule migration to managed auth. |
| [WhatsApp channel publishing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-whatsapp) | Preview (Planned GA Sep 2025) | Aug–Sep 2025 | Stabilizing ahead of GA window | Expands mobile-first channel reach | Finalize messaging policy; set rate limits; test localization. |
| [MIP sensitivity label surfacing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/sensitivity-label-copilot-studio) | Preview | 2025-08 (ongoing) | Incremental preview refinements | Prevents oversharing; enforces data classification boundaries | Map label taxonomy to agent knowledge sources; pilot with high-sensitivity set. |
| SSO Consent Card (inline consent) | Preview | 2025-08 (expanding) | Wider tenant rollout | Reduces friction & support tickets for OAuth flows | Update onboarding docs to remove legacy redirect instructions. |
| Agent catalog + governance tagging (internal refinement) | Preview → GA | 2025-08 | Metadata enrichment & search improvements | Speeds discovery; reduces duplicate logic | Enforce required metadata (owner, data scope, PII flags). |
<!-- END:LAST30_TABLE -->

### Key Adoption Themes (30 Days)
<details open>
<summary>Expand / collapse themes</summary>

1. Multimodal & Execution – Code interpreter + image/file pipeline enable compound transformations (govern cost & data scope).  
2. Knowledge Scale & Structure – File groups + high file count preview require taxonomy & pruning discipline.  
3. Quality Feedback Loop – New answer quality analytics institutionalize weekly remediation cycles.  
4. Secure Extensibility – MCP guided connection + credential blocking preview harden integration posture.  
5. Channel Expansion – WhatsApp preview drives concise, locale-aware conversational design patterns.  

</details>

### Immediate Actions Checklist
- [ ] Stand up weekly "Answer Quality" review using analytics dashboard.
- [ ] Finalize file grouping & naming convention before scaling ingestion (1000-file preview).
- [ ] Audit maker-owned credentials; draft migration runbook for credential blocking control.
- [ ] Pilot code interpreter in sandbox; capture execution metrics & outliers.
- [ ] Tag MCP-added tools with owner + data sensitivity metadata.
- [ ] Run localization QA on WhatsApp variants (fallback & error prompts).
- [ ] Establish sensitivity label mapping validation workflow (MIP preview).

### Fast Win Candidates (Low Effort / High Impact)
| Feature | Why Quick Win | Action (Imperative) |
|---------|---------------|---------------------|
| File groups GA | Immediate organization & grounding precision | Refactor scattered single files into logical groups |
| Answer quality analytics | Direct visibility to improvement backlog | Stand up weekly triage & remediation flow |
| MCP guided connection | Reduces extensibility friction | Standardize tool naming & tagging conventions |
| Code interpreter | Rapid data transformation prototype value | Pilot with sandbox policies + execution limits |
| Catalog governance tagging | Prevents future sprawl | Enforce metadata schema via PR checklist |

## Security & Compliance Focus
<details open>
<summary>Recent items impacting governance posture</summary>

| Area | Change | Risk Mitigated | Action |
|------|--------|----------------|--------|
| Credentials | Maker-provided credential blocking (Preview) | Secret sprawl / unmanaged auth | Inventory & migrate to managed auth patterns |
| Data Classification | MIP label surfacing (Preview) | Oversharing sensitive content | Map labels → knowledge sources & test gating |
| Catalog Governance | Metadata enrichment (Preview→GA) | Orphaned / non-compliant agents | Enforce required metadata schema |

</details>

### No Security Posture Change Items (Recent)
| Feature | Note |
|---------|------|
| Code interpreter GA | Operational governance required but no inherent platform security model change |
| File groups GA | Structural organization feature only |
| Image/file pipeline GA expansion | Increases surface; posture unchanged (govern via content policies) |

## Churn Spotlight (Recent Status Transitions)
| Feature | From → To | Month | Adoption Note |
|---------|----------|-------|---------------|
| File groups | Preview → GA | Aug 2025 | Refactor ad hoc file sets into scoped groups |
| (Watching) WhatsApp channel publishing | Preview → Planned GA | Sep 2025 | Prepare localization & compliance review |

## Prep Priority Matrix
| Priority | Driver | Why | Next Step |
|----------|--------|-----|----------|
| P1 | Credential governance | Blocks secure scale | Execute migration runbook |
| P1 | Quality analytics loop | Accelerates improvement | Operationalize weekly triage |
| P2 | File taxonomy & grouping | Prevents knowledge dilution | Approve naming & archival policy |
| P2 | Multimodal governance | Avoids uncontrolled cost / data spread | Define execution guardrails |
| P3 | Deep reasoning model prep | Future complexity gains | Curate candidate workflows & eval rubric |

## Readiness Tags Reference
| Tag | Meaning | Example Use |
|-----|---------|-------------|
| Governance | Requires policy / metadata work | Credential blocking control |
| Data | Needs curated datasets | Deep reasoning models, BYO Models |
| Localization | Multilingual planning required | WhatsApp channel, Multilingual orchestration |
| Performance | Latency / cost benchmarking needed | GPT‑4.1 mini experimental model |
| Security | Direct impact on auth / classification | MIP labels, credential blocking |

## KPI Suggestions by Category
| Category | KPI | Rationale |
|----------|-----|-----------|
| Knowledge | Grounded answer % | Measures retrieval quality |
| Quality | Answer gap closure cycle time | Tracks remediation velocity |
| Governance | % assets with complete metadata | Ensures catalog hygiene |
| Security | Maker credentials remaining (#) | Progress toward managed auth |
| Multimodal | Avg execution cost per code run | Cost governance for interpreter |
| Channels | Message delivery success % (WhatsApp) | Channel reliability |
| Models | Latency p95 (experimental models) | Performance validation |

## Risk Watchlist
| Feature | Risk Vector | Mitigation / Owner |
|---------|------------|--------------------|
| Maker credential blocking (Preview) | Stalled migration leaves shadow secrets | Credential inventory & phased cutover (Security Ops) |
| 1000-file scale | Knowledge dilution / irrelevant grounding | Enforce grouping + periodic pruning (Knowledge Lead) |
| Deep reasoning models | Higher operational complexity & hallucination risk | Evaluation rubric & guardrail prompts (AI Team) |
| BYO Models | Cost overrun / drift | Budget alerts + retrain cadence (FinOps + ML) |
| Multilingual orchestration | Quality variance across locales | Locale-specific prompt QA (Localization) |

## Delta Since Last Refresh
<!-- BEGIN:DELTA -->
2025-09-10 16:44 UTC - Baseline established; future changes will be tracked.
<!-- END:DELTA -->

## Future Planned Changes (Concise Summary)
High‑signal publicly disclosed upcoming items. Full backlog + categorization in [All Future Planned Features](./Future_Planned_Features.md).

<!-- BEGIN:FUTURE_SUMMARY -->
| Item (Summary) | Target (If Published) | Current Status | Why It Matters | Immediate Prep |
|----------------|-----------------------|----------------|----------------|----------------|
| WhatsApp channel publishing | Sep 2025 (Planned GA) | Preview | Mobile / global reach channel expansion | Finalize localization & rate limiting policies |
| Block maker-provided credentials control | Sep 2025 rollout | Preview | Reduces credential sprawl; governance uplift | Inventory & plan migration off maker creds |
| Generated answer quality analytics enhancements | Sep 2025 (iterative) | GA (enhancing) | Deeper quality gap attribution | Align dashboard & triage cadence |
| Catalog governance tagging enrichment | Sep 2025 | Preview → GA maturation | Improves compliant reuse & discovery | Define mandatory metadata schema |
| MCP server UX refinements | Late 2025 (ongoing) | GA (enhancements) | Lowers friction onboarding external tools | Refresh internal integration checklist |
| Deep reasoning models | TBD GA | Preview | Advanced multi‑step reasoning scenarios | Identify candidate complex workflows |
| Microsoft 365 Copilot Tuning | TBD GA | Preview | Domain adaptation for enterprise context | Curate high‑quality, labeled training sets |
| Bring Your Own Models (Azure AI Foundry) | TBD GA | Preview | Custom model extensibility | Assess governance & cost controls |
| Multilingual generative orchestration expansion | TBD | Preview | Broader language coverage in planner | Prioritize locales & test prompts |
| GPT‑4.1 mini experimental model | TBD | Preview | Lower latency experimentation | Define benchmark scenarios & metrics |
| Reusable component collections | TBD | Preview | Modular reuse accelerates build velocity | Identify high‑reuse patterns to refactor |
<!-- END:FUTURE_SUMMARY -->

<details open>
<summary>Key Guidance</summary>

1. Treat TBD / Planned GA as provisional; re‑verify before dependency commitments.  
2. Governance first: credentials, catalog metadata, sensitivity labeling.  
3. Quality instrumentation precedes scale—baseline before rollout.  
4. Advanced models (deep reasoning, BYO, tuning) need curated high-quality datasets & evaluation matrices.  
5. Avoid knowledge bloat—prune low-signal files before exploiting 1000-file scale.  

</details>

## Notes & Disclaimers
– Planned GA dates can shift; always re‑validate.  
– Preview items lack production SLAs unless explicitly approved.  
– Status reflects current state (initial preview date may differ).  
– Future list excludes confidential / undisclosed roadmap content.

## Source References
- What's new in Copilot Studio: https://learn.microsoft.com/en-us/microsoft-copilot-studio/whats-new
- Power Platform Release Plan 2024 Wave 2: https://learn.microsoft.com/en-us/power-platform/release-plan/2024wave2/microsoft-copilot-studio/
- Power Platform Release Plan 2025 Wave 1: https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave1/microsoft-copilot-studio/
- Power Platform Release Plan 2025 Wave 2 (preview): https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave2/microsoft-copilot-studio/
- Individual feature docs (examples): Azure AI Search knowledge, Model Context Protocol, Code Interpreter, File Groups, Adaptive Card designer, Customer Managed Keys.

---
_Last updated: 2025-09-10 (automation: scheduled refresh, metrics & diff v1.2)_


