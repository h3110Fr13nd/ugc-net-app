---
title: Question Part Editor
---

# Question Part Editor

Purpose
- Edit a single part of a question (text, image, diagram, code block, LaTeX, audio, video).

Entry points
- Inline from `question-editor` or as a modal.

Layout
- Part type selector at top; content editor area (WYSIWYG / code editor / LaTeX preview) and media attachment controls.

Fields / Controls
- Part type, content text, structured JSON content, media selector/upload, alt text and captions.

Primary DB tables
- `question_parts`, `media`

Actions & navigation
- Upload media -> opens `media-manager` or inline uploader -> returns `media_id`.
- Save -> updates `question_parts` and returns to `question-editor`.

Permissions & edge cases
- Large file uploads should be done async; show progress and allow resume.

Notes / API endpoints
- POST /api/v1/media (upload)
- POST /api/v1/question_parts
