
---
# Copilot Studio News – Documentation Authoring Standards
Created by: <a href="mailto:russ.rimmerman@microsoft.com">Russ Rimmerman</a>, Microsoft Cloud Solution Architect

## 1. Purpose
Provide a consistent, high-quality, source-backed set of documents describing Microsoft Copilot Studio feature changes (GA & Preview), their business/technical value, and actionable adoption guidance.

## 2. Scope
Applies to all markdown in this repository: feature tables, deep dives, discussions, guides, and update logs.

## 3. Mandatory Header Block
Each markdown file MUST begin with:
1. H1 title (succinct; ≤ 65 characters) beginning with “Copilot Studio” or the specific feature name.
2. The “Created by” attribution line (see top directive).
3. Optional: short (≤ 25 words) descriptor sentence.

## 4. Formatting Standards
- Use GitHub Flavored Markdown only (no raw HTML tables unless feature requires complex formatting).
- Tables: left-align text; wrap long cells to ≤ 110 characters per line for diff readability.
- Bold statuses (GA / Preview / Deprecated) once per row. Avoid color-coded images.
- Dates: ISO format `YYYY-MM-DD` where exact; use `Mon YYYY` if month-only.
- Use en dash (–) for ranges; em dash (—) for clause breaks.
- Avoid trailing whitespace; ensure newline at EOF.

## 5. Feature Entry Template
Use this mini-spec when adding or updating a feature:
```
### <Feature Name>
Status: GA | Preview | Planned (Month YYYY)
Initial Release: <Month YYYY or YYYY-MM-DD>
Primary Category: (choose one: Knowledge | Orchestration | Autonomy | Analytics | Security | Governance | Extensibility | Channels | Authoring | NLU | Models | Multimodal | Authentication)
Secondary Tags: comma-separated (optional)
Docs: <canonical Microsoft Learn URL>
Summary (≤ 30 words): <What it does>
Problem Solved: <User/business pain it addresses>
Key Benefits (bullets ≤ 5):
- <Benefit 1>
- <Benefit 2>
Adoption Prerequisites:
- <Licensing / permissions / connectors>
Rollout Considerations:
- <Risk / governance / rate limits>
Metrics to Track:
- <Ex: Containment %, ROI uplift, action success rate>
Breaking / Behavior Changes: (If none, state “None”)
Changelog History: <Concise bullets with dates>
```

## 6. Benefits Articulation Guidelines
Each benefit must be:
- Specific (avoid “better performance”—state quantifiable or directional impact).
- Outcome-oriented (user or business effect, not internal implementation detail).
- Non-redundant (no rephrasing the summary).

## 7. Source Integrity & Citation Rules
Priority order for authoritative references:
1. Microsoft Learn (product docs) – canonical link.
2. Official Release Plan entry (Wave doc) – only if adds GA/preview date clarity.
3. Microsoft TechCommunity or engineering blog for narrative background.
4. Support page (only for edge behavior or limitations).
Never cite: forums, social media, unverified blogs for status or dates.

## 8. Hyperlink Policy
- Each feature row must link the feature name to its canonical doc if public.
- If no canonical page: leave plaintext and add footnote `[*]` with “No dedicated public doc (as of <date>).”
- Avoid duplicate links in the same row/cell.

## 9. Accuracy & Validation Checklist (Run Before Commit)
- [ ] All GA dates verified same-day against Release Plan if newly added.
- [ ] Preview items explicitly labeled “Preview”; no implied production readiness.
- [ ] Removed deprecated/retired items from active summary tables (move to archive file if needed).
- [ ] Links resolve (HTTP 200) and are not locale-specific (prefer /en-us/ only if unavoidable).
- [ ] No confidential / NDA / internal code names.

## 10. Table Design Guidelines
- Keep a single “Purpose” column ≤ 12 words.
- Do not include large paragraphs inside table cells; move to a subsequent “Purpose Summaries” section.
- Maintain chronological ordering by initial release month (oldest → newest) unless producing a “Recent 6 Months” table (reverse optional).

## 11. Versioning & Changelog
- Add `_Last updated: YYYY-MM-DD_` at end of each primary document.
- For significant structural changes, create `CHANGELOG.md` entry:
```
## YYYY-MM-DD
- Restructured feature categories (added Multimodal)
- Added deep reasoning models section
```

## 12. Language & Tone
- Neutral, factual; avoid marketing superlatives (“revolutionary”, “game-changing”).
- Use present tense for current capabilities; future tense only for “Planned”.

## 13. Accessibility
- No ASCII art.
- Tables should have header rows; avoid merged cells.
- Link text should describe destination (avoid “here”).

## 14. Review Workflow
1. Contributor opens PR referencing sources.
2. Automated link checker & markdown linter run (future CI task).
3. Maintainer validates status & GA dates.
4. Merge; update `Last updated` stamp.

## 15. Common Pitfalls (Avoid)
| Pitfall | Resolution |
|---------|------------|
| Missing GA date or “Q*” vague quarter labels | Use month or TBD until published. |
| Copying marketing blog phrasing verbatim | Summarize objectively. |
| Mixing roadmap (future) items into shipped table | Keep roadmap in separate section. |
| Oversized benefit lists | Cap at 5 bullets. |
| Out-of-date preview still labeled “Preview” after GA | Sweep monthly vs release plan. |

## 16. Example (Abbreviated)
```
### Code Interpreter
Status: GA
Initial Release: Aug 2025
Primary Category: AI Actions
Docs: https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts
Summary: Natural language to Python code execution inside prompt builder & workflows.
Problem Solved: Reduces manual scripting & external tooling for data transformations.
Key Benefits:
- Accelerates creation of data-derived answers
- Lowers barrier to custom logic
- Enables repeatable analytic patterns
Adoption Prerequisites:
- Appropriate environment permissions
Rollout Considerations:
- Monitor execution cost & performance
Metrics to Track:
- # successful executions / errors
Breaking / Behavior Changes: None
Changelog History:
- 2025-08-05 GA release
```

## 17. Archiving Policy
- After a feature exceeds 12-month window, move from primary tables to `ARCHIVE_<YEAR>.md` with original row preserved.

## 18. Automation (Planned Enhancements)
- Link validation script (CI) – warn on 404s.
- Release Plan delta parser – propose PR with new/changed statuses.
- Table row generator CLI (inputs: name, status, doc URL → outputs markdown row + template stub).

## 19. Security & Governance Emphasis
Always call out:
- Encryption (CMK)
- Data protection (DLP, sensitivity labels)
- Authentication (FIC, SSO patterns)
- Auditability (logs, transcripts)
If absent: explicitly state “No change to existing security posture.”

## 20. Glossary (Keep Current)
| Term | Definition |
|------|------------|
| MCP | Model Context Protocol – standard to integrate external tools & context. |
| FIC | Federated Identity Credentials – identity federation for tokenless auth. |
| CMK | Customer Managed Keys – customer-controlled encryption keys. |
| DLP | Data Loss Prevention – policy engine restricting data exfiltration. |
| ROI Analytics | Built-in metrics mapping agent usage to cost/time savings. |

---
_Standards version: 2025-09-09_