---
title: User Profile
---

# User Profile

Purpose
- Allow users to view and edit personal details, manage linked OAuth accounts, and see active sessions.

Entry points
- Header avatar -> Profile.

Layout
- Profile form: display name, preferred username, locale, contact email.
- Security panel: change password, active sessions list, revoke session.
- Linked accounts panel: list and manage `user_oauth_accounts`.

Fields / Controls
- Save profile, change password, link/unlink OAuth accounts, revoke session.

Primary DB tables
- `users`, `user_oauth_accounts`, `refresh_tokens`, `jwt_revocations`

Actions & navigation
- Save -> PATCH /api/v1/users/:id
- Revoke session -> POST /api/v1/sessions/:id/revoke
- Link provider -> OAuth redirect flow.

Permissions & edge cases
- Email change requires verification; show clear state for unverified email.

Notes / API endpoints
- GET /api/v1/users/:id
- PATCH /api/v1/users/:id
