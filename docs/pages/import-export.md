---
title: Import & Export
---

# Import & Export

Purpose
- Import and export quizzes, questions, and media in JSON/CSV/zip formats for portability and backups.

Entry points
- `quiz-editor`/`question-banks` -> Export/Import actions; Admin -> Import/Export.

Layout
- Wizard-style import with file selection, field mapping, preview, and dry-run step; export modal with options.

Fields / Controls
- File selector, mapping UI, dedupe/match strategy, background job submission and job status panel.

Primary DB tables
- `quiz_versions`, `question_versions`, `media`, `questions`, `options`

Actions & navigation
- Start import -> creates background job -> show job status panel -> results and error report.
- Export -> generate archive and provide download link.

Permissions & edge cases
- Large imports should be queued; provide rollback instructions and dry-run support.

Notes / API endpoints
- POST /api/v1/import
- GET /api/v1/export/:id
