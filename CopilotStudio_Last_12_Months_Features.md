# Copilot Studio – Key Features & Updates (Last 12 Months)

Coverage window: September 2024 – August 2025 (current date: 2025-09-09)

Legend: **GA** = Generally Available, **Preview** = Public preview / early access, **Planned GA** = published target (month/date), **TBD** = not yet published.

> Source data consolidated from official Microsoft Learn "What's new in Copilot Studio" pages and Power Platform release plans (2024 Wave 2, 2025 Wave 1, 2025 Wave 2 previews) plus related linked docs.

## Hyperlinked Feature Table

| Feature (linked) | Category | Initial Release | Current Status | GA (Actual / Planned) | Purpose |
|------------------|----------|-----------------|----------------|-----------------------|---------|
| [Generative answers cite non‑text elements](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-add-file-upload#annotated-image-support) | Knowledge / Retrieval | Sep 2024 | GA | Sep 2024 | Richer citations incl. images/annotations. |
| [Voice‑optimized generative responses & citations](https://learn.microsoft.com/en-us/microsoft-copilot-studio/voice-generative-answers) | Conversational / Voice | Oct 2024 | GA | Oct 2024 | Tailors generative output for voice agents. |
| [Publish agents directly to Microsoft 365 Copilot](https://www.microsoft.com/en-us/microsoft-copilot/blog/copilot-studio/unveiling-copilot-agents-built-with-microsoft-copilot-studio-to-supercharge-your-business/#enable-copilot) | Channels / Extensibility | Oct 2024 | GA | Oct 2024 | Surface custom agents in Microsoft 365. |
| [In-product creation experience (SharePoint / Business Chat)](https://www.microsoft.com/en-us/microsoft-copilot/blog/copilot-studio/unveiling-copilot-agents-built-with-microsoft-copilot-studio-to-supercharge-your-business/#empower-users) | Authoring UX | Oct 2024 | GA | Oct 2024 | Simplifies low‑code agent creation. |
| [Reusable component collections](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-export-import-copilot-components) | Authoring | Oct 2024 | Preview | TBD | Reuse/share structured agent assets. |
| [Integrated solution explorer](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-overview) | ALM / Governance | Oct 2024 | GA | Oct 2024 | Manage solutions & lifecycle. |
| [GPT‑4o model updates (answers/orchestration/creation)](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-generative-actions) | AI Quality | Aug–Oct 2024 | GA | Oct 2024 | Improved reasoning & multimodal quality. |
| [Autonomous agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-triggers-about) | Autonomy | Nov 2024 (Preview) | GA | Mar 2025 | Triggered background task execution. |
| [Azure AI Search knowledge source](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-azure-ai-search) | Knowledge | Nov 11 2024 | GA | May 15 2025 | Hybrid semantic + vector retrieval. |
| [Real-time knowledge connectors](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-real-time-connectors) | Knowledge | Nov 2024 | GA | Nov 2024 | Live system-of-record grounding. |
| [Multilingual voice-enabled agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/multilingual) | Language / Voice | Nov 2024 | GA | Nov 2024 | Expanded language + voice reach. |
| [Automatic security scan](https://learn.microsoft.com/en-us/microsoft-copilot-studio/security-scan) | Security | Nov 2024 | GA | Nov 2024 | Detects risky patterns. |
| [Welcome message configuration](https://learn.microsoft.com/en-us/microsoft-copilot-studio/environments-first-run-experience) | Governance | Nov 2024 | GA | Nov 2024 | Standard privacy/compliance notices. |
| [Image analysis in agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/image-input-analysis) | Multimodal | Dec 2024 | GA | Dec 2024 | Interpret uploaded images. |
| [Arabic language support](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-language-support) | Language | Dec 2024 | GA | Dec 2024 | Adds Arabic locale. |
| [Usage-based billing model](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-messages-management) | Billing | Dec 2024 | GA | Dec 2024 | Aligns cost with usage. |
| [Sharing controls & limits](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-sharing-controls-limits) | Governance | Dec 2024 | GA | Dec 2024 | Restrict agent sharing. |
| [Audit logs (Purview)](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-logging-copilot-studio#see-audited-events-agent-usage) | Compliance | Jan 2025 | GA | Jan 2025 | Central interaction logging. |
| [Chinese (Traditional) support](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-language-support) | Language | Jan 2025 | GA | Jan 2025 | Adds zh‑TW locale. |
| [Default data policy enforcement](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-data-loss-prevention) | DLP | Jan–Feb 2025 | GA | Feb 2025 | Baseline DLP protection. |
| [Hebrew language support](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-language-support) | Language | Feb 2025 | GA | Feb 2025 | Adds he‑IL locale (text). |
| [AI response generated trigger](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-triggers-about) | Orchestration | Feb 2025 | GA | Feb 2025 | Intercept/modify LLM outputs. |
| [Publish custom agents to M365 Copilot Chat](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams) | Channels | Feb 2025 | Preview | TBD | Direct publishing to M365 chat. |
| [Expanded enterprise data connectors](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-graph-connections#supported-enterprise-data-sources-using-microsoft-copilot-connectors-preview) | Knowledge | Feb 2025 | Preview | TBD | More enterprise data sources. |
| Cross-prompt injection mitigation | Security | Feb 2025 | GA | Feb 2025 | Hardens against prompt injection. |
| [Model Context Protocol support](https://www.microsoft.com/en-us/microsoft-copilot/blog/copilot-studio/introducing-model-context-protocol-mcp-in-copilot-studio-simplified-integration-with-ai-apps-and-agents/) | Extensibility | Mar 2025 | GA | Mar 2025 | Standard external integration. |
| [Generative orchestration GA](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-generative-actions) | Orchestration | Mar 2025 | GA | Mar 2025 | Unified planner for actions & knowledge. |
| [Deep reasoning models](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-reasoning-models) | AI Models | Mar 2025 | Preview | TBD | Advanced multi-step reasoning. |
| [Conversation transcripts node-level](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-transcripts-powerapps#enhanced-transcripts) | Analytics | Mar 2025 | GA | Mar 2025 | Fine-grained path tracing. |
| [Build agent flows in Studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/flows-overview) | Automation | Mar 2025 | GA | Mar 2025 | Native workflow authoring. |
| [Customer Managed Keys](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-customer-managed-keys) | Security / Encryption | Apr 2025 (Preview) | GA | May 20 2025 | Customer encryption control. |
| [Viva Insights ROI analytics](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-cost-savings) | Analytics | Apr 2025 | GA | Apr 2025 | Business impact visibility. |
| [Graph connectors expansion (9)](https://techcommunity.microsoft.com/blog/microsoft_365blog/what%E2%80%99s-new-and-what%E2%80%99s-next-for-microsoft-graph-connectors/4398319) | Knowledge | Apr 2025 | GA | Apr 2025 | Broader SaaS data grounding. |
| [Connect agent to other agents](https://go.microsoft.com/fwlink/?linkid=2320061) | Autonomy / Composition | May 2025 | Preview | TBD | Agent-to-agent delegation. |
| [Adaptive Card designer integration](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/adaptive-cards-overview) | Authoring UI | May 2025 | GA | May 2025 | Rich interactive responses. |
| [SharePoint channel publishing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-sharepoint) | Channels | May 20 2025 | GA | May 20 2025 | Deploy on SharePoint sites. |
| [VS Code extension](https://aka.ms/Build2025/CopilotStudioBlog) | Dev Experience | May 2025 | GA | May 2025 | Local editing & CI/CD. |
| [Document Processor template](https://learn.microsoft.com/en-us/microsoft-copilot-studio/template-managed-document-processor) | Templates | May 2025 | Preview | TBD | Prebuilt doc automation. |
| [Web search for agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-copilot-studio#enable-web-search-for-your-agent) | Knowledge | May 2025 | GA | May 2025 | Live web grounding. |
| Bring Your Own Models (Azure AI Foundry) | AI Extensibility | May 2025 | Preview | TBD | Integrate custom fine-tuned models. |
| [Unstructured knowledge sources](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-unstructured-data) | Knowledge | May 19 2025 | Preview | TBD | Index unstructured repositories. |
| [Enhanced file upload experience](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-add-file-upload) | Knowledge UX | May 2025 | Preview | TBD | Easier multi-file ingestion. |
| [Tabular data knowledge](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-real-time-connectors) | Knowledge | May 2025 | GA | May 2025 | Structured tabular retrieval. |
| [Federated Identity Credentials](https://learn.microsoft.com/en-us/microsoft-copilot-studio/configuration-authentication-azure-ad) | Authentication | May 2025 | GA | May 2025 | Tokenless secure auth. |
| Tooling UX overhaul | Authoring Tools | Jun 2025 | GA (progressive) | Jun 2025 | Faster tool configuration. |
| [Microsoft 365 Copilot Tuning](https://learn.microsoft.com/en-us/microsoft-copilot-studio/microsoft-copilot-fine-tune-model) | AI Customization | Jun 2025 | Preview | TBD | Domain model fine-tuning. |
| [File groups](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-file-groups) | Knowledge | Jun 2025 (Preview) | GA | Aug 2025 | Group files with scoped instructions. |
| [Multilingual generative orchestration](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-generative-actions#multilingual-support-with-generative-orchestration) | Orchestration | Jun 2025 | Preview | TBD | Expanded planner language support. |
| [GPT‑4.1 mini experimental model](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-preview-model) | Models | Jun 2025 | Preview | TBD | Lower latency reasoning option. |
| [Power Fx regex & prompt editor enhancements](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-prompt-node#configure-and-test-a-prompt-with-the-embedded-ai-builder-prompt-editor) | Authoring | Jun 2025 | GA | Jun 2025 | Advanced validation & prompt crafting. |
| [Knowledge analysis for autonomous agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-improve-agent-effectiveness) | Analytics | Jun 2025 | GA | Jun 2025 | Attribute knowledge impact. |
| [Advanced NLU customization](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-plus-configure) | NLU | Jul 2025 | GA | Jul 2025 | Domain adaptive intents/entities. |
| [In-app global search](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-search-within-agent) | Productivity | Jul 15 2025 | GA | Jul 15 2025 | Rapid asset navigation. |
| [ROI analytics](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-cost-savings) | Analytics | Jul 2025 | GA | Jul 2025 | Quantify efficiency gains. |
| [User feedback analytics (thumbs & comments)](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-improve-agent-effectiveness) | Quality | Jun–Jul 2025 | GA | Jun/Jul 2025 | Qualitative improvement loop. |
| [MIP sensitivity label surfacing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/sensitivity-label-copilot-studio) | Security / Compliance | Jul 2025 | Preview | TBD | Prevent oversharing via labels. |
| [WhatsApp channel publishing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-whatsapp) | Channels | Jul 2025 (Ann.) | Preview | Sep 2025 (Planned) | WhatsApp reach. |
| SSO Consent Card | Auth UX | Jul 2025 | Preview | TBD | In-chat OAuth consent. |
| [Generated answer rate & quality analytics](https://learn.microsoft.com/en-us/microsoft-copilot-studio/analytics-improve-agent-effectiveness#generated-answer-rate-and-quality) | Analytics | Aug 2025 | GA | Aug 2025 | Track answer quality gaps. |
| [Code interpreter](https://learn.microsoft.com/en-us/microsoft-copilot-studio/code-interpreter-for-prompts) | AI Actions | Aug 2025 | GA | Aug 2025 | NL → Python actions. |
| [Expanded file & image upload pipeline](https://learn.microsoft.com/en-us/microsoft-copilot-studio/image-input-analysis) | Multimodal | Aug 2025 | GA | Aug 2025 | Unified multimodal ingestion. |
| [MCP server guided connection](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-add-existing-server-to-agent#add-the-mcp-server-in-copilot-studio-recommended) | Extensibility | Aug 2025 | GA | Aug 2025 | Simplified external server integration. |
| [Discover & install Microsoft-built agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-install-agent) | Catalog / Governance | Jul–Aug 2025 | Preview→GA (phased) | Jul 2025 (core) | Curated agent catalog. |

> Note: Features without an immediately available dedicated public doc are listed without a hyperlink (e.g., "Cross-prompt injection mitigation", "Tooling UX overhaul", "SSO Consent Card", "Bring Your Own Models").

| Feature | Category | Initial Release (Month) | Current Status (Sept 2025) | GA (Actual or Planned) | Purpose (Concise) |
|---------|----------|--------------------------|----------------------------|------------------------|------------------|
| Generative answers cite non‑text elements | Knowledge / Retrieval | Sep 2024 | GA | Sep 2024 | Richer citations incl. images/annotations. |
| Voice‑optimized generative responses & citations | Conversational / Voice | Oct 2024 | GA | Oct 2024 | Tailors generative output for voice agents. |
| Publish Copilot Studio agents directly to Microsoft 365 Copilot | Channels / Extensibility | Oct 2024 | GA | Oct 2024 | One-click surface of custom agents inside Microsoft 365 experiences. |
| New in-product creation experience (SharePoint / Business Chat) | Authoring UX | Oct 2024 | GA | Oct 2024 | Simplifies low‑code agent creation in user flow of work. |
| Reusable component collections | Authoring | Oct 2024 | Preview | TBD | Reuse/share structured agent assets. |
| Integrated solution explorer | ALM / Governance | Oct 2024 | GA | Oct 2024 | Manage solutions & lifecycle inside Studio. |
| GPT‑4o model updates (answers/orchestration/creation) | AI Quality | Aug–Oct 2024 | GA | Oct 2024 | Improved reasoning & multimodal response quality. |
| Autonomous agents (event-driven background workflows) | Autonomy | Nov 2024 (Preview) | GA | Mar 2025 | Long-running trigger-based task execution. |
| Azure AI Search index as knowledge source | Knowledge | Nov 11 2024 (Preview) | GA | May 15 2025 | Hybrid semantic + vector enterprise retrieval. |
| Real-time knowledge connectors (Salesforce, ServiceNow, Zendesk, etc.) | Knowledge | Nov 2024 | GA | Nov 2024 | Live data grounding with up-to-date records. |
| Multilingual voice-enabled & multilingual agents | Language / Voice | Nov 2024 | GA | Nov 2024 | Broader global language + voice support. |
| Automatic security scan | Security | Nov 2024 | GA | Nov 2024 | Detects risky patterns/components automatically. |
| Welcome message configuration (privacy/compliance) | Governance | Nov 2024 | GA | Nov 2024 | Standardizes compliance messaging to makers. |
| Image analysis in agents (initial) | Multimodal | Dec 2024 | GA (extended Aug 2025) | Dec 2024 | Let agents interpret uploaded images. |
| Arabic language support (ar‑SA) | Language | Dec 2024 | GA | Dec 2024 | Adds Arabic for conversations & generative answers. |
| Usage-based billing model | Billing | Dec 2024 | GA | Dec 2024 | Aligns cost with actual message consumption. |
| Sharing controls & limits (admin) | Governance | Dec 2024 | GA | Dec 2024 | Restrict agent sharing scope. |
| Audit logs (Purview integration) | Compliance | Jan 2025 | GA | Jan 2025 | Centralized user interaction logging. |
| Chinese (Traditional) language support (zh‑TW) | Language | Jan 2025 | GA | Jan 2025 | Additional locale coverage. |
| Default data policy soft-enable + enforcement | Data Loss Prevention | Jan–Feb 2025 | GA | Feb 2025 | Baseline DLP enforcement by default. |
| Hebrew language support | Language | Feb 2025 | GA | Feb 2025 | Expanded language coverage (text). |
| AI response generated trigger | Orchestration | Feb 2025 | GA | Feb 2025 | Intercept & modify outgoing LLM responses. |
| Publish custom agents to Microsoft 365 Copilot Chat | Channels | Feb 2025 | Preview | TBD | Direct publishing pipeline to Microsoft 365 chat surfaces. |
| Extended enterprise data via Copilot connectors | Knowledge | Feb 2025 | Preview | TBD | More structured/unstructured enterprise grounding. |
| Cross-prompt injection mitigation (XPIA) improvements | Security | Feb 2025 | GA | Feb 2025 | Hardened defense vs. prompt injection. |
| Model Context Protocol (initial integration) | Extensibility | Mar 2025 | GA (enhanced May 2025) | Mar 2025 | Standard protocol to integrate external apps/tools. |
| Generative orchestration worldwide GA | Orchestration | Mar 2025 | GA | Mar 2025 | Planner selecting actions & knowledge path. |
| Deep reasoning models | AI Models | Mar 2025 | Preview | TBD | Advanced multi-step reasoning. |
| Conversation transcripts node-level enhancement | Analytics | Mar 2025 | GA | Mar 2025 | Fine-grained traceability of dialog paths. |
| Build agent flows directly in Studio | Automation | Mar 2025 | GA | Mar 2025 | Native workflow creation inside authoring. |
| Customer Managed Keys (CMK) | Security / Encryption | Apr 7 2025 (Preview) | GA | May 20 2025 | Customer-supplied encryption keys. |
| Viva Insights ROI / agent data inclusion | Analytics | Apr 2025 | GA | Apr 2025 | Business impact & usage insights. |
| Nine new Microsoft Graph connectors | Knowledge | Apr 2025 | GA | Apr 2025 | Broader enterprise data set. |
| Connect agent to other agents | Autonomy / Composition | May 2025 | Preview | TBD | Agent-to-agent task delegation. |
| Adaptive Card designer (integrated) | Authoring UI | May 2025 | GA | May 2025 | Rich adaptive UI payload design inline. |
| SharePoint channel publishing | Channels | May 20 2025 | GA | May 20 2025 | Deploy agents on SharePoint sites. |
| VS Code Copilot Studio extension | Dev Experience | May 2025 | GA | May 2025 | Local editing & CI/CD friendly authoring. |
| Document Processor autonomous template | Templates | May 2025 | Preview | TBD | Prebuilt document-centric automation. |
| Web search for agents | Knowledge | May 2025 | GA | May 2025 | Live web grounding for broader answers. |
| Bring Your Own Models (Azure AI Foundry) | AI Extensibility | May 2025 | Preview | TBD | Plug in custom fine-tuned models. |
| Unstructured knowledge (ServiceNow, Salesforce, Confluence, Zendesk) | Knowledge | May 19 2025 | Preview | TBD | Index unstructured repos. |
| Enhanced file upload (OneDrive/SharePoint picker) | Knowledge UX | May 2025 | Preview | TBD | Easier multi-file ingestion. |
| Tabular data knowledge (Dataverse, Salesforce, ServiceNow, Azure SQL) | Knowledge | May 2025 | GA | May 2025 | Structured tabular retrieval. |
| Federated Identity Credentials (FIC) | Auth | May 2025 | GA | May 2025 | Tokenless secure auth for actions. |
| Tooling UX overhaul (grouping, IntelliSense, widgets) | Authoring Tools | Jun 2025 | GA (progressive) | Jun 2025 | Faster tool configuration & invocation. |
| Microsoft 365 Copilot Tuning (fine-tune models) | AI Customization | Jun 2025 | Preview | TBD | Domain adaptation via enterprise data. |
| File groups (knowledge organization) | Knowledge | Jun 2025 (Preview) | GA | Aug 2025 | Group related files + scoped instructions. |
| Multilingual generative orchestration expansion | Orchestration | Jun 2025 | Preview | TBD | Planner multilingual coverage. |
| GPT‑4.1 mini experimental response model | Models | Jun 2025 (US) | Preview | TBD | Lower-latency experimental option. |
| Power Fx regex & embedded prompt editor enhancements | Authoring | Jun 2025 | GA | Jun 2025 | Advanced validation & inline prompt crafting. |
| Knowledge sources analysis for autonomous agents | Analytics | Jun 2025 | GA | Jun 2025 | Attribution of knowledge impact on runs. |
| Advanced NLU customization | NLU | Jul 2025 | GA | Jul 2025 | Domain adaptive topics/entities. |
| In-app global search across agent assets | Authoring Productivity | Jul 15 2025 | GA | Jul 15 2025 | Fast navigation of topics/tools/entities. |
| ROI analytics (time & cost savings) | Analytics | Jul 2025 | GA | Jul 2025 | Quantify efficiency gains. |
| User feedback (thumbs + comments) analytics | Quality | Jun–Jul 2025 | GA | Jun/Jul 2025 | Qualitative response improvement loop. |
| MIP sensitivity label surfacing | Security / Compliance | Jul 2025 | Preview | TBD | Prevent oversharing via label awareness. |
| WhatsApp channel publishing | Channels | Jul 2025 (announced) | Preview (Planned) | Sep 2025 | Reach users via WhatsApp. |
| SSO Consent Card (inline consent) | Auth UX | Jul 2025 | Preview | TBD | Frictionless OAuth grant in chat. |
| Generated answer rate & quality analytics | Analytics | Aug 2025 | GA | Aug 2025 | Track unanswered & low-quality responses. |
| Code interpreter for prompts & workflows | AI Actions | Aug 2025 | GA | Aug 2025 | NL → Python code for dynamic actions. |
| File & image upload + downstream passing (expanded) | Multimodal | Aug 2025 | GA | Aug 2025 | Unified multimodal ingestion & routing. |
| MCP server guided connection (add existing server) | Extensibility | Aug 2025 | GA | Aug 2025 | Streamlined external capability integration. |
| Discover & install Microsoft-built agents (catalog) | Catalog / Governance | Jul–Aug 2025 | Preview→GA (phased) | Jul 2025 (core) | Curated reusable agent acquisition & governance. |

---

## Purpose Summaries

- **Generative answers cite non‑text**: Improves transparency by referencing images/annotations in answers.
- **Voice-optimized responses**: Ensures spoken output is concise and citation-friendly.
- **Direct M365 publish**: Removes deployment friction; surfaces agents inside core productivity hubs.
- **Low-code creation experience**: Empowers non-technical makers to rapidly prototype agents.
- **Reusable component collections**: Drives modular design and accelerates enterprise reuse (preview).
- **Solution explorer**: Consolidates ALM activities (versioning, packaging) within the Studio UI.
- **Model updates (GPT‑4o / 4.1 mini)**: Upgrades reasoning fidelity and performance tiers.
- **Autonomous agents**: Enables background, trigger-based operation for long-running tasks.
- **Azure AI Search knowledge**: High-quality hybrid retrieval for grounded, factual responses.
- **Real-time connectors**: Keeps knowledge fresh with live system-of-record data.
- **Multilingual & voice**: Broader global and accessibility reach.
- **Security scan / XPIA mitigation**: Proactively identifies vulnerabilities and injection vectors.
- **Audit logs & DLP enforcement**: Strengthens compliance posture out-of-the-box.
- **AI response generated trigger**: Gives makers a post-processing interception point.
- **Generative orchestration & deep reasoning (preview)**: Coordinated multi-step reasoning across tools.
- **Agent flows & tool UX overhaul**: Reduces context switching; improves author productivity.
- **Customer Managed Keys**: Customer sovereignty over encryption keys for sensitive industries.
- **Viva Insights ROI analytics**: Connects agent usage to measurable business outcomes.
- **Adaptive Card designer**: Rich, localized interactive responses without leaving Studio.
- **BYO Models & Copilot Tuning**: Domain adaptation and customized model integration.
- **Un/Structured knowledge expansion (tabular, unstructured, file groups)**: Comprehensive retrieval coverage with flexible grouping & scoping.
- **Federated Identity Credentials & SSO Consent Card**: Streamlined secure auth flows.
- **Advanced NLU customization**: Higher accuracy by leveraging customer data to shape intents/entities.
- **Global search / ROI / feedback analytics**: Faster iteration & continuous quality improvement loop.
- **MIP label surfacing & sensitivity awareness**: Data loss prevention in generative contexts.
- **WhatsApp, SharePoint, Microsoft 365 channels**: Omnichannel reach.
- **Code interpreter & multimodal uploads**: Expands action surface (data transformation, image/file reasoning).
- **MCP integration & guided server connection**: Standardized extensibility for external capability injection.
- **Catalog discovery of Microsoft-built agents**: Encourages curated reuse with governance.

## Notes & Disclaimers
- Planned GA dates may shift per official Microsoft communications; always verify in current release plans.
- Preview features should not be relied upon for production SLAs until GA unless explicitly approved.
- Some features (e.g., catalog discovery, file groups) transitioned from preview to GA during the window—table reflects initial release month plus current status.

## Source References (Representative)
- What's new in Copilot Studio: https://learn.microsoft.com/en-us/microsoft-copilot-studio/whats-new
- Power Platform Release Plan 2024 Wave 2: https://learn.microsoft.com/en-us/power-platform/release-plan/2024wave2/microsoft-copilot-studio/
- Power Platform Release Plan 2025 Wave 1: https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave1/microsoft-copilot-studio/
- Power Platform Release Plan 2025 Wave 2 (preview): https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave2/microsoft-copilot-studio/
- Individual feature docs (examples): Azure AI Search knowledge, Model Context Protocol, Code Interpreter, File Groups, Adaptive Card designer, Customer Managed Keys.

---
_Last updated: 2025-09-09_
