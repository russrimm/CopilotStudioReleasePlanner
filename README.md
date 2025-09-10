# Copilot Studio – Rolling 30-Day Updates

This document focuses on two concise operational windows:
1. Last 30 days of shipped changes (retrospective)
2. Next 30 days of planned / targeted items (forward look, subject to change)

Full feature catalog (rolling 12 months + broader context) lives here: [Full Feature Catalog](./archive/Last_12_Months_Features.md)

Legend: **GA** = Generally Available, **Preview** = Public preview / early access, **Planned GA** = published target (month/date), **TBD** = not yet published.

Source basis: Official Microsoft Learn "What's new in Copilot Studio" + Power Platform release plans (current waves) + linked public feature docs. Forward-looking items are indicative only—validate dates before dependency commitments.

---

## Last 30 Days Feature Changes (2025-08-10 to 2025-09-09)
Focused digest of Copilot Studio updates, promotions, and new previews in the most recent 30‑day window. (Date range auto-updated daily by workflow.)

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
| [WhatsApp channel publishing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-whatsapp) | Preview (Planned GA Sep 2025) | 2025-08→09 | Stabilizing ahead of GA window | Expands external reach to mobile-first audiences | Define messaging policy + rate limiting; test content localization. |
| [MIP sensitivity label surfacing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/sensitivity-label-copilot-studio) | Preview | 2025-08 (ongoing) | Incremental preview refinements | Prevents oversharing; enforces data classification boundaries | Map label taxonomy to agent knowledge sources; pilot with high-sensitivity set. |
| SSO Consent Card (inline consent) | Preview | 2025-08 (expanding) | Wider tenant rollout | Reduces friction & support tickets for OAuth flows | Update onboarding docs to remove legacy redirect instructions. |
| Agent catalog + governance tagging (internal refinement) | Preview→GA | 2025-08 | Metadata enrichment & search improvements | Faster discovery & reduces duplicate agent logic | Define required metadata (owner, data scope, PII flags) for catalog entries. |
<!-- END:LAST30_TABLE -->

### Key Adoption Themes (30 Days)
1. Multimodal + Execution: Code interpreter & image/file pipeline unlock compound automation (consider cost & governance).  
2. Knowledge Scale & Structure: File groups + high file count preview necessitate taxonomy strategy to avoid dilution.  
3. Quality Feedback Loop: New analytics (answer gaps) enables measurable iteration cadence.  
4. Secure Extensibility: MCP guided connection + credential blocking preview tighten external integration posture.  
5. Channel Expansion: WhatsApp preview drives need for concise, locale-ready conversational design.  

### Immediate Actions Checklist
- [ ] Stand up weekly “Answer Quality” review using new analytics dashboard.
- [ ] Draft file grouping & naming convention before bulk 1000-file ingestion preview scales.
- [ ] Audit maker-owned credentials; prepare migration runbook for preview credential blocking control.
- [ ] Pilot code interpreter in a sandbox; log execution metrics & outliers.
- [ ] Tag all MCP-added tools with owner + data sensitivity metadata.
- [ ] Run localization QA on WhatsApp message variants (fallback & error prompts). 

## Next 30 Days Planned Changes (2025-09-09 to 2025-10-09)
Publicly disclosed planned GA / preview milestones expected within the next 30 days. All dates are tentative; verify against the live release plan before production gating.

<!-- BEGIN:NEXT30_TABLE -->
| Planned Item | Target (Approx) | Expected Status Change | Rationale / Impact | Prep Recommendation |
|--------------|-----------------|------------------------|--------------------|---------------------|
| WhatsApp channel publishing | Sep 2025 | Preview → GA (planned) | Broader mobile conversational reach | Finalize localization & rate-limit policies |
| Block maker-provided credentials for authentication | Sep 2025 | New Preview controls broaden rollout | Tightens credential governance posture | Inventory legacy credentials & draft migration runbook |
| Generated answer quality iterative analytics enhancements | Sep 2025 | Incremental GA refinements | Finer-grain gap attribution | Align weekly QA dashboard to new metrics |
| Catalog governance tagging enrichment | Sep 2025 | Preview maturation | Faster compliant reuse of internal agents | Define mandatory metadata schema (owner, PII flag) |
| (Placeholder) Additional MCP server UX refinements | Late Sep 2025 | Minor GA enhancement | Lowers friction for external tool onboarding | Update internal MCP integration checklist |
<!-- END:NEXT30_TABLE -->

### Forward-Look Notes
- Future items are intentionally limited to a 30-day horizon to reduce noise.
- Excludes confidential / undisclosed roadmap content.
- If no credible public targets exist for the window, this section may collapse to a placeholder note.

## Notes & Disclaimers
- Planned GA dates may shift per official Microsoft communications; always verify in current release plans.
- Preview features should not be relied upon for production SLAs until GA unless explicitly approved.
- Some features (e.g., catalog discovery, file groups) transitioned from preview to GA during the window—table reflects initial release month plus current status.

## Source References
- What's new in Copilot Studio: https://learn.microsoft.com/en-us/microsoft-copilot-studio/whats-new
- Power Platform Release Plan 2024 Wave 2: https://learn.microsoft.com/en-us/power-platform/release-plan/2024wave2/microsoft-copilot-studio/
- Power Platform Release Plan 2025 Wave 1: https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave1/microsoft-copilot-studio/
- Power Platform Release Plan 2025 Wave 2 (preview): https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave2/microsoft-copilot-studio/
- Individual feature docs (examples): Azure AI Search knowledge, Model Context Protocol, Code Interpreter, File Groups, Adaptive Card designer, Customer Managed Keys.

---
_Last updated: 2025-09-09 (rolling windows)_
