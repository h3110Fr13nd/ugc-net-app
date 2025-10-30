---
title: Quiz Detail
---

# Quiz Detail

Purpose
- Show quiz metadata, question preview, and actions to start, preview or edit the quiz.

Entry points
- From `quizzes-list`, search, dashboard or shared link.

Layout
- Header with title, author, status, tags and action buttons (Start, Preview, Edit).
- Body: question list with quick-preview and settings panel.

Fields / Controls
- Start/Preview/Edit/Export/Duplicate buttons; question list with reorder hints.

Primary DB tables
- `quizzes`, `questions`, `question_parts`, `quiz_versions`, `topics`

Actions & navigation
- Start -> `quiz-attempt` (create `quiz_attempts`).
- Edit -> `quiz-editor`.
- Publish -> create `quiz_versions` and update `quizzes.published_at`.

Permissions & edge cases
- Unpublished quizzes: restrict to owner or users with permission.

Notes / API endpoints
- GET /api/v1/quizzes/:id
- POST /api/v1/quizzes/:id/publish
