---
title: UX & QA Checklist
---

# UX & QA Checklist

This checklist covers acceptance criteria and QA tests for core pages and global concerns.

Global checks
- Responsive layouts (mobile / tablet / desktop).
- Accessibility: keyboard nav, ARIA attributes, color contrast, alt text for images.
- Authorization: verify role-restricted controls are hidden/disabled for unauthorized users.
- Error states: server errors, network failures, validation errors show friendly messages.
- Performance: pages render under acceptable budget (list pages paginate/virtualize large lists).

Page-level checks (happy path + 1-2 edge cases)

- Authentication
  - Login succeeds and redirects to dashboard.
  - OAuth sign-in links create/associate accounts.
  - Forgot password sends email and allows reset.

- Dashboard
  - Recent activity loads correctly and links navigate properly.

- Quizzes List
  - Filtering and search return expected results; bulk publish/archival works with permission checks.

- Quiz Detail
  - Start creates attempt record; preview doesn’t create attempt.

- Quiz Editor
  - Adding/reordering questions persists state; publish creates `quiz_versions` snapshot.

- Question Editor & Parts
  - Add various part types, attach media, save and preview rendering.

- Options Editor
  - Marking correct options affects preview scoring; partial scoring persisted.

- Media Manager
  - Uploads succeed (test small + large files), media is listed and attachable.

- Topics
  - Create a topic, assign questions, tree view updates; prevent circular parent.

- Question Bank
  - Import into quiz copies or links depending on the option; permissions respected.

- Quiz Attempt & Review
  - Autosave works; submit triggers grading; review shows per-question breakdown.

- Admin (Users, Roles)
  - Role changes reflected in UI; impersonation logs and revocations audited.

- Import/Export
  - Dry-run shows mapping; large imports run as background jobs with status.

Test data & automation suggestions
- Provide test fixtures for: users (admin/instructor/student), sample quizzes, topics, and media items.
- Add UI integration tests for: login -> dashboard -> start quiz -> submit -> review.

Notes
- For each issue found, capture reproduction steps, expected vs actual, and DB statement(s) for verification.
