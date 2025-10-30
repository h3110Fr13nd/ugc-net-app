---
title: Options Editor
---

# Options Editor

Purpose
- Manage options for multiple-choice and composite options: labels, correctness, weights, explanations.

Entry points
- Visible in `question-editor` when `answer_type` is `options`.

Layout
- Ordered list of options with drag/drop ordering and per-option editors (parts, explanation, weight).

Fields / Controls
- Label, is_correct toggle, weight numeric, explanation text, add/remove option.

Primary DB tables
- `options`, `option_parts`, `media`

Actions & navigation
- Add option -> creates `options` and optional `option_parts`.
- Mark correct -> toggles `options.is_correct` and updates preview scoring.

Permissions & edge cases
- Enforce single-correct vs multi-correct constraints according to question settings.

Notes / API endpoints
- POST /api/v1/questions/:id/options
