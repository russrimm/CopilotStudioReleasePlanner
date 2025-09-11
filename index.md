---
layout: default
title: Copilot Studio – Rolling Updates Hub
---
<link rel="stylesheet" href="/CopilotStudioReleasePlanner/assets/css/custom.css" />

<div class="intro">
  <h1>Copilot Studio – Rolling Updates Hub</h1>
  <p>Ultra‑condensed view of what just changed and what is coming next. Scroll only if you need deeper analytics, governance, or risk context.</p>
</div>

<div class="content markdown-body">
{% capture readme %}{% include_relative README.md %}{% endcapture %}
{{ readme | markdownify }}
</div>

<div class="footer-updated">Site generated with Modernist theme. Content sourced from README.md.</div>
