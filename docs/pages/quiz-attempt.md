---
title: Quiz Attempt
---

# Quiz Attempt

Purpose
- The student-facing interface for taking a quiz: present questions, capture answers, autosave and submit.

Entry points
- From `quiz-detail` Start or resume an in-progress attempt.

Layout
- Left: question navigation/TOC with status (answered/flagged).
- Top: timer, save status, submit button.
- Main: current question view rendering `question_parts` and answer controls.

Fields / Controls
- Answer inputs (options, text, numeric), file upload, flag, previous/next navigation.

Primary DB tables
- `quiz_attempts`, `question_attempts`, `question_attempt_parts`, `media` (for file uploads)

Actions & navigation
- Autosave -> writes `question_attempt_parts` at intervals.
- Submit -> PATCH quiz_attempt status to `submitted`, server-side grading starts.

Permissions & edge cases
- Enforce time limits; auto-submit when timer expires.
- Support intermittent connectivity with local cache sync.

Notes / API endpoints
- POST /api/v1/quiz_attempts (start)
- PATCH /api/v1/quiz_attempts/:id/submit
