---
title: Authentication
---

# Authentication

Purpose
- Provide user sign-in/up flows, session management, OAuth account linking and token revocation UI.

Entry points
- App launch when unauthenticated.
- Header "Sign in" / footer links.

Layout
- Center column: primary forms (login / register / forgot password).
- Right column / modal: OAuth provider linking and account-completion.
- Settings > Security: sessions list and revocation controls.

Fields / Controls
- Login: email, password, remember-me, sign-in button, OAuth buttons.
- Register: email, password, display name, locale.
- Forgot password: email -> send reset link.
- Sessions: device name, last_used, ip, revoke button.

Primary DB tables
- `users`, `user_oauth_accounts`, `oauth_providers`, `refresh_tokens`, `jwt_revocations`

Actions & navigation
- Login success -> `dashboard`.
- Register -> create `users` row, send verification, go to onboarding/dashboard.
- OAuth sign-in -> create `user_oauth_accounts` and `users` as needed.
- Revoke session -> mark `refresh_tokens.revoked_at` and optionally create `jwt_revocations`.

Permissions & edge cases
- Unverified users: restrict access to sensitive settings.
- OAuth-only accounts: expose "Set password" flow.
- Rate-limit login and show friendly errors for locked accounts.

Notes / API endpoints
- POST /api/v1/auth/login {email,password}
- POST /api/v1/auth/register {email,password,...}
- POST /api/v1/auth/oauth/callback
- GET /api/v1/sessions
- POST /api/v1/sessions/:id/revoke
