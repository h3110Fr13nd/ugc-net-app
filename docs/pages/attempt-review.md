---
title: Attempt Review
---

# Attempt Review

Purpose
- Present graded results for a quiz attempt with per-question breakdown, feedback and regrade request flow.

Entry points
- After grading completes, from `dashboard` notifications or attempts history.

Layout
- Summary header with score, pass/fail, time taken.
- Accordion per question showing student response, correct answer, grading details and feedback.

Fields / Controls
- Request regrade button, download report, retake button (if allowed).

Primary DB tables
- `quiz_attempts`, `question_attempts`, `question_attempt_parts`, `questions`

Actions & navigation
- Request regrade -> creates a ticket and flags audit logs.
- Retake -> starts a new `quiz_attempt` (if allowed by quiz settings).

Permissions & edge cases
- Hiding answers until grading window expiration is supported via quiz metadata; UI must obey that.

Notes / API endpoints
- GET /api/v1/quiz_attempts/:id
- POST /api/v1/quiz_attempts/:id/regrade
