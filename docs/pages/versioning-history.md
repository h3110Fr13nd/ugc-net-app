---
title: Versioning & History
---

# Versioning & History

Purpose
- Track revisions for quizzes and questions; allow viewing diffs and restoring previous versions.

Entry points
- `quiz-editor` -> History, `question-editor` -> History.

Layout
- Chronological list of versions with metadata and diff/restore actions.

Fields / Controls
- Version timestamp, author, change summary, preview diff, restore button.

Primary DB tables
- `quiz_versions`, `question_versions`, primary `quizzes` and `questions` tables.

Actions & navigation
- Restore -> creates a new version and updates canonical record, logs action to audit.

Permissions & edge cases
- Confirm destructive restores; handle conflicts when multiple users edit concurrently.

Notes / API endpoints
- GET /api/v1/questions/:id/versions
- POST /api/v1/questions/:id/versions/:version_id/restore
