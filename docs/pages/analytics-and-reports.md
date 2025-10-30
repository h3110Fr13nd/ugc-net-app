---
title: Analytics and Reports
---

# Analytics & Reports

Purpose
- Aggregated metrics and reports for instructors and admins: pass-rates, attempt counts, frequently-missed questions, per-topic performance.

Entry points
- Admin / Instructor nav -> Analytics.

Layout
- Dashboard of charts (time series of attempts, score distributions), filters and drill-down lists.

Fields / Controls
- Date selectors, cohort filters, topic/quiz filters, export controls.

Primary DB tables
- `quiz_attempts`, `question_attempts`, `questions`, `topics` and analytic materialized views or event logs.

Actions & navigation
- Click a data point -> open list of attempts -> click attempt -> `attempt-review`.
- Export CSV / schedule reports.

Permissions & edge cases
- PII controls: show aggregated data to roles without exposing user-identifiable info.

Notes / API endpoints
- GET /api/v1/analytics/quiz/:id/summary
