---
title: Admin - Users
---

# Admin — Users

Purpose
- Admin interface for listing and managing users, roles, impersonation, and account status.

Entry points
- Admin nav -> Users.

Layout
- Searchable user table, filters (active, role), user detail panel with roles and recent activity.

Fields / Controls
- Assign/unassign roles, deactivate/reactivate accounts, view attempts and audit logs, impersonate user.

Primary DB tables
- `users`, `user_roles`, `roles`, `quiz_attempts`, `jwt_revocations`

Actions & navigation
- Assign role -> POST /api/v1/user_roles
- Deactivate -> PATCH /api/v1/users/:id (set deleted_at)
- Impersonate -> POST /api/v1/admin/impersonate -> returns ephemeral token.

Permissions & edge cases
- Only super-admin roles should access; impersonation must be logged.

Notes / API endpoints
- GET /api/v1/admin/users
