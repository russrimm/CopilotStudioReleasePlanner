# Copilot Studio – All Publicly Disclosed Future Planned Features
Created by: Russ Rimmerman

Comprehensive forward-looking backlog (public sources only). Replaces the narrow "Next 30 Days" view by aggregating all known planned / preview items beyond the last 30‑day shipped window.

Legend: **GA** = Generally Available, **Preview** = Public preview / early access, **Planned GA** = published target (month/date), **TBD** = not yet published.

Source Basis: Microsoft Learn "What's new" + Power Platform Release Plans (current published waves) + linked feature docs/blogs. Dates & scope subject to change; always re‑validate before gating dependencies or communicating externally.

---
## Navigational Index
- [Imminent (Current Wave / Named Month Targets)](#imminent-current-wave--named-month-targets)
- [Model & Reasoning Enhancements](#model--reasoning-enhancements)
- [Knowledge & Retrieval Expansion](#knowledge--retrieval-expansion)
- [Governance, Security & Compliance](#governance-security--compliance)
- [Extensibility & Integration](#extensibility--integration)
- [Authoring & Productivity UX](#authoring--productivity-ux)
- [Analytics & Quality Feedback](#analytics--quality-feedback)
- [Channels & Surface Expansion](#channels--surface-expansion)
- [Autonomy & Orchestration](#autonomy--orchestration)
- [Templates & Accelerators](#templates--accelerators)
- [TBD / Longer-Horizon Items](#tbd--longer-horizon-items)

---
## Imminent (Current Wave / Named Month Targets)
<!-- BEGIN:IMMINENT_TABLE -->
| Feature | Target (Month / Date) | Current Status | Expected Change | Impact | Prep Recommendations |
|---------|-----------------------|----------------|-----------------|--------|---------------------|
| WhatsApp channel publishing | Sep 2025 (Planned GA) | Preview | Preview → GA | Expands mobile / international channel reach | Finalize localization & rate limiting; test message templates |
| Block maker-provided credentials control | Sep 2025 rollout | Preview | Wider tenant availability | Strengthens credential governance & reduces risk | Inventory existing maker creds; plan migration to managed auth |
| Catalog governance tagging enrichment | Sep 2025 | Preview | Maturation / enhanced GA metadata | Improves compliant reuse & discovery | Define mandatory metadata schema (owner, PII, risk class) |
| Generated answer quality analytics enhancements | Sep 2025 (iterative) | GA | Incremental enhancements | Finer attribution of answer gaps | Align dashboard KPIs & triage cadence |
| MCP server UX refinements | Late 2025 (ongoing) | GA | Progressive enhancements | Lowers friction for external capability onboarding | Update internal MCP integration checklist |
<!-- END:IMMINENT_TABLE -->

## Model & Reasoning Enhancements
| Feature | Status | Planned GA (If Known) | Purpose / Value | Prep Suggestions |
|---------|--------|-----------------------|-----------------|------------------|
| Deep reasoning models | Preview | TBD | Advanced multi-step reasoning for complex task chains | Identify high-complexity scenarios & evaluation rubric |
| GPT‑4.1 mini experimental model | Preview | TBD | Lower latency experimentation tier | Define benchmark latency & quality thresholds |
| Microsoft 365 Copilot Tuning | Preview | TBD | Domain adaptation & tuning for enterprise context | Curate governed, labeled high-quality datasets |
| Bring Your Own Models (Azure AI Foundry) | Preview | TBD | Integrate custom / fine-tuned models | Establish model governance, cost & drift monitoring |
| Multilingual generative orchestration expansion | Preview | TBD | Broader multilingual planner coverage | Prioritize locales; validate prompt patterns per language |

## Knowledge & Retrieval Expansion
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| Unstructured knowledge sources | Preview | TBD | Index & query broad unstructured corpora | Map unstructured repos; define retention & sensitivity tagging |
| Enhanced file upload experience (bulk, UX) | Preview | TBD | Scales ingestion with better ergonomics | Establish file taxonomy & naming conventions |
| 1000 file per agent scale increase | Preview | TBD | Higher ceiling for knowledge set size | Implement relevance pruning & grouping strategy |
| Tabular data knowledge refinements | GA (enhancing) | N/A | Better structured data retrieval | Optimize source normalization & column naming |
| Azure AI Search hybrid improvements (future iterations) | GA (evolving) | N/A | Improved grounded relevance | Monitor query performance & adjust synonyms |

## Governance, Security & Compliance
| Feature | Status | Planned GA | Impact | Prep |
|---------|--------|-----------|--------|-----|
| Block maker-provided credentials control | Preview | Sep 2025 rollout | Credential governance & reduction of shadow secrets | Credential inventory & migration runbook |
| MIP sensitivity label surfacing | Preview | TBD | Data classification in context | Align label taxonomy; pilot with sensitive set |
| Customer Managed Keys (enhancements) | GA (enhancements) | N/A | Extended encryption control fidelity | Monitor key rotation & audit policies |
| Audit logs / extended event taxonomy | GA (iterative) | N/A | Deeper operational visibility | Expand log parsing & retention pipelines |

## Extensibility & Integration
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| MCP server UX refinements | GA (enhancing) | Late 2025 (iterative) | Easier external tool onboarding | Standardize tool naming & tagging |
| Connect agent to other agents (delegation) | Preview | TBD | Composable multi-agent workflows | Define delegation policies & loop safeguards |
| Reusable component collections | Preview | TBD | Modular reuse accelerates build velocity | Identify high-reuse logic blocks |
| BYO Models (Azure AI Foundry) | Preview | TBD | Custom model integration | Governance & cost policy definition |

## Authoring & Productivity UX
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| Tooling UX overhaul (progressive widgets, grouping) | GA (progressive) | N/A | Faster authoring & clarity | Gather maker feedback & backlog UX gaps |
| In-app global search enhancements (future iterations) | GA (enhancing) | N/A | Faster asset navigation | Tag assets consistently |
| Prompt editor advanced validation (regex, test harness) | GA (enhancing) | N/A | Higher prompt quality & safety | Maintain prompt test suites |

## Analytics & Quality Feedback
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| Generated answer quality analytics enhancements | GA (iterative) | Sep 2025 wave | Better defect source isolation | Define triage SLA & resolution taxonomy |
| Knowledge analysis for autonomous agents (refinements) | GA (enhancing) | N/A | Attribution of knowledge contribution | Calibrate scoring weights |
| ROI / savings analytics enrichments | GA (enhancing) | N/A | Deeper business impact insights | Align business KPI mapping |
| User feedback analytics (granularity, clustering) | GA (enhancing) | N/A | Faster qualitative improvement loop | Automate feedback labeling pipeline |

## Channels & Surface Expansion
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| WhatsApp channel publishing | Preview | Sep 2025 (Planned GA) | High‑reach mobile channel | Localization QA; test opt-in flows |
| SharePoint channel enhancements | GA (enhancing) | N/A | Intranet integration depth | Governance & lifecycle policy |
| Microsoft 365 Copilot publish refinements | GA (enhancing) | N/A | Seamless productivity surface integration | Align permission & visibility model |
| Potential future channel pilots (undisclosed) | N/A | N/A | Not publicly documented | Monitor official announcements |

## Autonomy & Orchestration
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| Deep reasoning models (multi-step) | Preview | TBD | Complex autonomous problem solving | Scenario benchmarking & safety guardrails |
| Autonomous task delegation (agent-to-agent) | Preview | TBD | Scalable orchestration | Define delegation depth & rollback strategy |
| Multilingual generative orchestration expansion | Preview | TBD | Planner language breadth | Validate locale prompt variants |

## Templates & Accelerators
| Feature | Status | Planned GA | Value | Prep |
|---------|--------|-----------|-------|-----|
| Document Processor autonomous template | Preview | TBD | Accelerated doc automation | Identify candidate doc workflows |
| Additional solution templates (future waves) | TBD | TBD | Faster standardized adoption | Track release plan updates |

## TBD / Longer-Horizon Items
Items with disclosed preview but no firm GA month/date; monitor official channels.

| Feature | Current Status | Notes / Watchpoints | Suggested Monitoring Action |
|---------|---------------|----------------------|----------------------------|
| Microsoft 365 Copilot Tuning | Preview | Data governance & evaluation maturity key | Establish data curation pipeline |
| BYO Models (Azure AI Foundry) | Preview | Cost & performance variance | Define cost guardrails |
| Reusable component collections | Preview | Drives internal design system patterns | Catalog candidate components |
| Deep reasoning models | Preview | Safety & interpretability considerations | Draft evaluation matrix |
| Multilingual orchestration expansion | Preview | Locale parity & quality gating | Track language rollout notes |
| GPT‑4.1 mini experimental model | Preview | May evolve / be replaced | Benchmark quarterly |
| MCP server UX refinements | GA (enhancing) | Continuous incremental UX | Review changelog monthly |

---
### Adoption Readiness Checklist (Forward-Focused)
- Governance: Credential inventory complete; metadata schema approved.
- Data: High-quality labeled sets curated for tuning / reasoning evaluation.
- Taxonomy: File & knowledge grouping standards documented & enforced.
- Analytics: Quality & ROI dashboards instrumented with triage workflow.
- Multilingual: Target locale prioritization matrix approved.
- Security: Sensitivity label mapping & DLP policy alignment validated.

### Risk & Mitigation Highlights
| Risk | Vector | Mitigation |
|------|--------|------------|
| Credential sprawl | Maker-owned secrets | Enforce managed auth & rotation policy |
| Knowledge dilution | Large uncurated file sets | Implement relevance pruning & grouping |
| Model drift / cost overruns | Experimental or BYO models | Set budget alerts & evaluation cadence |
| Governance blind spots | Incomplete metadata tagging | Enforce required fields pipeline |
| Quality regression | Rapid feature enablement w/o metrics | Gate launches on baseline quality benchmarks |

---
_Last updated: 2025-09-10_
