# Copilot Studio – Rolling Updates Hub

Ultra‑condensed view of what just changed and what is coming next. Scroll only if you need deeper analytics, governance, or risk context.

---

## Last 30 Days Feature Changes (2025-08-12 to 2025-09-10)
Most recent launches, promotions, and previews (auto‑rolling window).

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

_Quick Legend:_ **GA** Generally Available • **Preview** Early access • **Planned GA** Published target month/date • **TBD** Not yet published.

---

## Reference Links
Curated pointers (kept brief). Deeper analytical sections follow.

**Historical Updates**
- 12‑Month Catalog: [Last 12 Months](./archive/Last_12_Months_Features.md)
- 6‑Month Snapshot: [Last 6 Months](./archive/Last_6_Months_Features.md)

**Forward Roadmap**
- Full Future Detail: [All Future Planned Features](./Future_Planned_Features.md)
- Near Term (≤60d): jump to [Future (Near)](#future-planned-changes-near-term-≤60d)
- Longer Horizon: [Future (Horizon)](./Future_Horizon_Features.md)

**Governance & Risk**
- Security Focus: [Security & Compliance](#security--compliance-focus)
- Policy Coverage Matrix: [Policies](#policy-coverage-matrix)
- Risk Heatmap: [Risk](#risk-heatmap)
- Churn Spotlight: [Recent Transitions](#churn-spotlight-recent-status-transitions)

**Operational Aids**
- Prep Matrix: [Preparation Priorities](#prep-priority-matrix)
- Lifecycle Funnel: [Lifecycle](#lifecycle-funnel)
 

**Sources**
- What's New (Learn)  
- Power Platform Release Plans  
- Individual Feature Docs (linked inline)

---

## At a Glance
<!-- BEGIN:AT_A_GLANCE -->
| Metric | Count | Notes |
|--------|-------|-------|
| GA features (last 30d window) | 5 | Newly GA or GA confirmations |
| Preview items (last 30d window) | 6 | Active evaluation required |
| Preview → GA transitions (window) | 2 | Status promotions |
| Security / Governance related updates | 5 | Auto keyword heuristic |
| Multimodal / Execution updates | 2 | Interpreter & file/image pipeline |
<!-- END:AT_A_GLANCE -->
_Counts auto-maintained; modify via refresh script._

Status: ![GA](https://img.shields.io/badge/GA-4-brightgreen) ![Preview](https://img.shields.io/badge/Preview-11-orange) ![Planned_GA](https://img.shields.io/badge/Planned_GA-5-blue) ![TBD](https://img.shields.io/badge/TBD-6-lightgrey)

Lifecycle: ✅ GA • 🧪 Preview • 📅 Planned • 🔍 Enhancing • 💤 Dormant • ⚠ Stale (>180d Preview)

---

## Rolling Timeline Strip
<small>Visual month-by-month status glyph view (last 4 months + current + next 2 months).</small>
<!-- BEGIN:TIMELINE_STRIP -->
| Month | Key Moves |
|-------|-----------|
| 2025-06 | 🧪 File groups preview |
| 2025-07 | (quiet) |
| 2025-08 | ✅ File groups GA; 🧪 1000 files; ✅ Code interpreter; 🧪 MIP labels |
| 2025-09 | 🧪 Credential blocking; 🧪 WhatsApp (GA prep) |
| 2025-10 | (forecast) 📅 Governance tagging GA |
| 2025-11 | (forecast) 🔍 MCP UX enhancements |
<!-- END:TIMELINE_STRIP -->
_Auto-generated; edit via scripts or manifest._

---

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

## Future Planned Changes (Concise Summary)
High‑signal publicly disclosed upcoming items. Full backlog + categorization in [All Future Planned Features](./Future_Planned_Features.md).

## Future Planned Changes (Near Term ≤60d)
High‑signal publicly disclosed upcoming items expected inside ~60 day horizon.

<!-- BEGIN:FUTURE_NEAR -->
| Item (Summary) | Target | Status | Why It Matters | Immediate Prep | Decision Needed By |
|----------------|--------|--------|----------------|----------------|--------------------|
| WhatsApp channel publishing | 2025-09 | 🧪 Preview | Mobile reach channel | (auto) | 2025-09-20 |
| Block maker-provided credentials | 2025-09 | 🧪 Preview | Eliminate unmanaged credentials | (auto) | 2025-09-25 |
| Catalog governance tagging enrichment | 2025-09 | 🧪 Preview | Metadata for discovery & compliance | (auto) | 2025-09-30 |
| 1000 files per agent | 2025-11 | 🧪 Preview | Higher knowledge object limits | (auto) |  |
| Generated answer quality analytics |  | ✅ GA (enhancing) | Identify low quality answer clusters | (auto) | 2025-09-18 |
<!-- END:FUTURE_NEAR -->

## Future Planned Changes (Horizon)
Moved to dedicated page for clarity and easier long-horizon curation: see [Future Horizon Features](./Future_Horizon_Features.md).

<!-- NOTE: The following FUTURE_HORIZON block is intentionally retained (even though detailed horizon items live in a separate file) so automation and delta tracking scripts have both markers available. It may contain a condensed snapshot or be left minimal. -->
<!-- BEGIN:FUTURE_HORIZON -->
| Item (Summary) | Target | Status | Why It Matters | Immediate Prep | Stale? |
|----------------|--------|--------|----------------|----------------|--------|
| [File groups](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-file-groups) | TBD | ✅ GA | Group related files & scope instructions | (auto) | – |
| [Code interpreter](https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts) | TBD | ✅ GA | NL to Python execution | (auto) | – |
| MIP sensitivity labels | 2025-12 | 🧪 Preview | Surface sensitivity labels in content | (auto) | – |
| MCP server UX refinements | TBD | ✅ GA (enhancements) | Improve external tool onboarding | (auto) | – |
| Deep reasoning models | TBD | 🧪 Preview | Advanced multi-step reasoning | (auto) | – |
| Bring Your Own Models | TBD | 🧪 Preview | Custom model extensibility | (auto) | – |
| Multilingual orchestration | TBD | 🧪 Preview | Broader language coverage | (auto) | – |
| GPT-4.1 mini experimental model | TBD | 🧪 Preview | Lower latency experimentation | (auto) | – |
| Reusable component collections | TBD | 🧪 Preview | Accelerate modular reuse | (auto) | – |
| Microsoft 365 Copilot Tuning | TBD | 🧪 Preview | Enterprise domain adaptation | (auto) | – |
<!-- END:FUTURE_HORIZON -->

<details open>
<summary>Key Guidance</summary>

1. Treat TBD / Planned GA as provisional; re‑verify before dependency commitments.  
2. Governance first: credentials, catalog metadata, sensitivity labeling.  
3. Quality instrumentation precedes scale—baseline before rollout.  
4. Advanced models (deep reasoning, BYO, tuning) need curated high-quality datasets & evaluation matrices.  
5. Avoid knowledge bloat—prune low-signal files before exploiting 1000-file scale.  

</details>

## Delta Since Last Refresh
Automated summary of changes detected between Near / Horizon future roadmap tables.

<!-- BEGIN:DELTA -->
2025-09-11 15:12 UTC - Future summary updated (hash 955409FB77CC31CF97AE5488E8421FCA64585E8F4CCC79CCB6A343F414E8C85B
 → E4E2B1CC7137842241F3387227939C3B9C780655CFBE6C77811236052464E427). Added: Generated answer quality analytics, Multilingual orchestration, [File groups](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-file-groups), Block maker-provided credentials, GPT-4.1 mini experimental model, 1000 files per agent, [Code interpreter](https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts), Bring Your Own Models, MIP sensitivity labels | Removed: Multilingual generative orchestration expansion, Block maker-provided credentials control, Answer quality analytics enhancements, Bring Your Own Models (Azure AI Foundry), GPT‑4.1 mini experimental model | Modified: Reusable component collections, ----------------, Deep reasoning models, Catalog governance tagging enrichment, Item (Summary), WhatsApp channel publishing, MCP server UX refinements, Microsoft 365 Copilot Tuning
<!-- END:DELTA -->

## Lifecycle Funnel
Summary of feature counts by lifecycle stage.
<!-- BEGIN:LIFECYCLE_FUNNEL -->
| Stage | Count | Notes |
|-------|-------|-------|
| 🧪 Preview | 11 | active early access |
| 📅 Planned | 0 | date published, pre-preview |
| 🔍 Enhancing | 2 | post-GA iteration |
| ✅ GA | 2 | fully released |
| 💤 Dormant | 0 | >90d no update |
| ⚠ Stale Preview | 0 | >180d preview |
<!-- END:LIFECYCLE_FUNNEL -->

## Policy Coverage Matrix
Matrix of policy/controls coverage (✓ implemented / – not applicable / ◻ gap).
<!-- BEGIN:POLICY_MATRIX -->
| Feature | AuthGovernance | DLP | Labels | Logging |
|---------|-----| -----| -----| -----|
| [File groups](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-file-groups) | – | ✓ | – | ✓ |
| [Code interpreter](https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts) | – | – | – | ✓ |
| 1000 files per agent | – | – | – | – |
| Block maker-provided credentials | ✓ | ✓ | – | ✓ |
| WhatsApp channel publishing | – | – | – | – |
| MIP sensitivity labels | – | ✓ | ✓ | ✓ |
| Catalog governance tagging enrichment | – | ✓ | – | ✓ |
| Generated answer quality analytics | – | – | – | – |
| MCP server UX refinements | – | – | – | – |
| Deep reasoning models | – | – | – | – |
| Bring Your Own Models | – | – | – | – |
| Multilingual orchestration | – | – | – | – |
| GPT-4.1 mini experimental model | – | – | – | – |
| Reusable component collections | – | – | – | – |
| Microsoft 365 Copilot Tuning | – | – | – | – |
<!-- END:POLICY_MATRIX -->

## Risk Heatmap
Impact vs likelihood (qualitative quick scan).
<!-- BEGIN:RISK_HEATMAP -->
| Impact \\ Likelihood | Low | Medium | High |
|---------------------|-----|--------|------|
| High | m365-copilot-tuning | thousand-files, deep-reasoning-models |   |
| Medium | file-groups, whatsapp-channel, mcp-server-ux, gpt41-mini-experimental | code-interpreter, credential-blocking, catalog-governance-tagging, byo-models, reusable-component-collections |   |
| Low | answer-quality-analytics | mip-sensitivity-labels, multilingual-orchestration |   |
<!-- END:RISK_HEATMAP -->

## All Features (Flattened)
Single list for accessibility / quick grep.
<!-- BEGIN:FLATTENED_FEATURES -->
- 1000 files per agent (🧪 Preview)
- Block maker-provided credentials (🧪 Preview)
- Bring Your Own Models (🧪 Preview)
- Catalog governance tagging enrichment (🧪 Preview)
- [Code interpreter](https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts) (✅ GA)
- Deep reasoning models (🧪 Preview)
- [File groups](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-file-groups) (✅ GA)
- Generated answer quality analytics (🔍 Enhancing)
- GPT-4.1 mini experimental model (🧪 Preview)
- MCP server UX refinements (🔍 Enhancing)
- Microsoft 365 Copilot Tuning (🧪 Preview)
- MIP sensitivity labels (🧪 Preview)
- Multilingual orchestration (🧪 Preview)
- Reusable component collections (🧪 Preview)
- WhatsApp channel publishing (🧪 Preview)
<!-- END:FLATTENED_FEATURES -->

## Feature IDs
Stable slugs for scripting / referencing.
<!-- BEGIN:FEATURE_IDS -->
file-groups, code-interpreter, thousand-files, credential-blocking, whatsapp-channel, mip-sensitivity-labels, catalog-governance-tagging, answer-quality-analytics, mcp-server-ux, deep-reasoning-models, byo-models, multilingual-orchestration, gpt41-mini-experimental, reusable-component-collections, m365-copilot-tuning
<!-- END:FEATURE_IDS -->

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

Site theme: Modernist (GitHub Pages)









