---
title: Question Banks
---

# Question Banks

Purpose
- Reusable repository of questions that can be searched, previewed, and imported into quizzes.

Entry points
- Global nav "Question Bank", from `quiz-editor` -> Insert from bank.

Layout
- Search/filter panel, list of results, multi-select import actions and preview pane.

Fields / Controls
- Search by topic/difficulty/answer type, select multiple, preview question parts, import copy/link options.

Primary DB tables
- `questions`, `question_versions`, `question_topics`, `question_chapters`

Actions & navigation
- Import copy -> duplicates `questions` into quiz context.
- Link -> references canonical question id.
- Edit -> opens `question-editor` (edits canonical or copied instance depending on policy).

Permissions & edge cases
- ACL: display only questions the user can access; obey ownership rules.

Notes / API endpoints
- GET /api/v1/question_bank?filters
- POST /api/v1/question_bank/import
