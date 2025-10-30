---
title: Quiz Editor
---

# Quiz Editor

Purpose
- Full composer for creating and editing quizzes: metadata, ordering, timing, versioning.

Entry points
- From `quizzes-list` Create/Edit, or duplicate action in `quiz-detail`.

Layout
- Left: quiz metadata form (title, description, duration, pass score).
- Center: ordered question list (drag/drop) with inline previews.
- Right: question inspector (settings) and version history.

Fields / Controls
- Add question (new or from bank), reorder, save draft, publish.

Primary DB tables
- `quizzes`, `quiz_versions`, `questions`, `question_topics`

Actions & navigation
- Add question -> `question-editor` modal.
- Save -> PATCH /api/v1/quizzes/:id
- Publish -> POST /api/v1/quizzes/:id/publish (creates snapshot)

Permissions & edge cases
- Warn on concurrent edits; provide version conflict resolution.

Notes / API endpoints
- POST /api/v1/quizzes/:id/questions (insert)
