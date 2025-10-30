---
title: Settings & Tenant
---

# Settings & Tenant

Purpose
- App-level configuration (site settings, OAuth providers) and tenant management for multi-tenant deployments.

Entry points
- Admin -> Settings.

Layout
- Tabs for App settings, OAuth providers, Tenant management.

Fields / Controls
- Site title, default locale, email SMTP settings, OAuth client configs (client id, redirect URIs), tenant create/edit.

Primary DB tables
- `oauth_providers`, optional `tenants` table, and app config stored in environment/secret manager.

Actions & navigation
- Save settings -> persist to config (may require secret store); create tenant -> POST /api/v1/tenants.

Permissions & edge cases
- Editing OAuth client secrets must be done via secure channel; show warnings for breaking changes.

Notes / API endpoints
- GET/POST /api/v1/admin/settings
