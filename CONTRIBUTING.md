## Contributing Guidelines

Follow repository authoring standards in `.github/copilot-instructions.md`.

### Workflow
1. Open an issue describing change (feature addition, status update, automation improvement).
2. Reference authoritative public sources (Microsoft Learn, Release Plan) for any date/status changes.
3. Run local validation scripts:
   - `./scripts/link-check.ps1 -IncludeArchive`
   - `./scripts/update-metrics.ps1`
   - `./scripts/update-delta.ps1`
4. Commit with conventional prefix (e.g., `docs:`, `chore:`, `feat:` for script tooling only).
5. Open PR; CI will re-run link check.

### Adding / Updating Features
1. Update `features.json` with new record (fields: name, currentStatus, initialRelease or plannedGA, category, purpose).
2. Insert row in appropriate archive or future file table. Keep cell width ≤110 chars.
3. Do not remove historical rows; move to archive as they age past window.

### Automated Sections
Markers (do not edit inside unless intentional):
- `AT_A_GLANCE`
- `LAST30_TABLE`
- `FUTURE_SUMMARY`
- `DELTA`

### Quality Checklist
- Status formatting consistent (GA | Preview | Planned GA | TBD)
- Dates ISO or Month YYYY
- No confidential / internal code names
- Action verbs used in Recommended Action / Prep columns
- Security-impacting items classified in Security & Compliance Focus section

### Releasing Structural Changes
Update `CHANGELOG.md` and bump `version` front matter in `README.md`.

---
_Last updated: 2025-09-10_