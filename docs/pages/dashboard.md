---
title: Dashboard
---

# Dashboard

Purpose
- User home showing progress summary, recent activity, and shortcuts to common tasks.

Entry points
- After successful sign-in; header link "Home".

Layout
- Top summary cards: total score, active quizzes, recommended practice.
- Middle: Recent attempts feed and notifications.
- Right column: shortcuts (Create quiz, Browse topics, Media manager).

Fields / Controls
- Clickable cards and lists; filter for recent activities; links to content.

Primary DB tables
- `quiz_attempts`, `quizzes`, `questions`, `users`, `topics`

Actions & navigation
- Click a quiz -> `quiz-detail`.
- Click "Continue" -> `quiz-attempt`.
- Click "Create" -> `quiz-editor`.

Permissions & edge cases
- Anonymous or limited users see sample content and CTA to sign up.

Notes / API endpoints
- GET /api/v1/dashboard/summary
