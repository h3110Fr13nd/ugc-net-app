---
title: Admin - Roles & Permissions
---

# Admin — Roles & Permissions

Purpose
- Manage roles, permissions and role assignments (RBAC) for the application.

Entry points
- Admin nav -> Roles & Permissions.

Layout
- Roles list with permission matrix; role detail view showing assigned users and role metadata.

Fields / Controls
- Create/edit role, assign/remove permissions, view users with role, delete role.

Primary DB tables
- `roles`, `permissions`, `role_permissions`, `user_roles`

Actions & navigation
- Create role -> POST /api/v1/roles
- Assign permission -> POST /api/v1/role_permissions

Permissions & edge cases
- Changing a role should be immediate; consider session refresh requirements for users with changed roles.

Notes / API endpoints
- GET /api/v1/roles
- GET /api/v1/permissions
