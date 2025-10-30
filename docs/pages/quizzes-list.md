---
title: Quizzes List
---

# Quizzes — List

Purpose
- Browse, search, filter and perform bulk actions on quizzes.

Entry points
- Sidebar "Quizzes", dashboard shortcuts.

Layout
- Toolbar: search, filters (status, topic, author), create button.
- Main: list or grid of quizzes with status badges and quick actions.

Fields / Controls
- Create quiz, publish/unpublish, duplicate, delete, bulk operations.

Primary DB tables
- `quizzes`, `quiz_versions`, `topics`, `users`

Actions & navigation
- Open quiz -> `quiz-detail`.
- Create -> `quiz-editor`.

Permissions & edge cases
- Publish only for users with role permission; show controls disabled otherwise.

Notes / API endpoints
- GET /api/v1/quizzes?filters...
- POST /api/v1/quizzes (create)
