---
title: Question Editor
---

# Question Editor

Purpose
- Create and edit questions: parts, answer type, scoring, topics and metadata.

Entry points
- From `quiz-editor`, `question-banks`, or search results.

Layout
- Header: title and answer type selector.
- Main: ordered list of `question_parts` with add/edit controls.
- Sidebar: scoring settings, options (when MCQ), topics assignment and metadata.

Fields / Controls
- Add Part, Add Option, Set answer_type, Difficulty, Estimated time, Tags.

Primary DB tables
- `questions`, `question_parts`, `options`, `option_parts`, `question_topics`, `question_chapters`

Actions & navigation
- Add part -> `question-part-editor` modal.
- Save -> POST/PATCH /api/v1/questions/:id
- Version -> create `question_versions` snapshot.

Permissions & edge cases
- Changing answer_type may invalidate options; warn user and require confirmation.

Notes / API endpoints
- GET /api/v1/questions/:id
- POST /api/v1/questions
