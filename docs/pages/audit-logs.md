---
title: Audit Logs
---

# Audit Logs

Purpose
- Centralized event log for security-relevant and administrative actions (revocations, publishes, imports, impersonations).

Entry points
- Admin nav -> Audit / from user/admin actions that link into log entries.

Layout
- Timeline view with filters (event type, user, date range), and event detail panel showing metadata JSON.

Fields / Controls
- Search, export, retention controls (admin-only), link-to-entity actions.

Primary DB tables
- `jwt_revocations`, `refresh_tokens` (revoked), application event log table (if implemented), `quiz_versions`

Actions & navigation
- Click event -> open full JSON detail and link to affected entity.
- Export -> CSV/JSON of selected timeframe.

Permissions & edge cases
- Access restricted to audit roles; PII redaction for exported data may be required.

Notes / API endpoints
- GET /api/v1/admin/audit?filters
