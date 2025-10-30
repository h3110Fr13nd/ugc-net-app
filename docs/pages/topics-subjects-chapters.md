---
title: Topics, Subjects & Chapters
---

# Topics / Subjects / Chapters

Purpose
- Manage hierarchical taxonomy for content: subjects -> chapters -> topics; assign questions to topics and chapters.

Entry points
- Nav "Topics", from `question-editor` or `quiz-editor` tagging panels.

Layout
- Left: tree view (subjects -> chapters -> topics).
- Right: topic detail view with metadata and list of linked questions.

Fields / Controls
- Create/edit topic, set parent, add associations (prerequisite, related), bulk assign questions.

Primary DB tables
- `subjects`, `chapters`, `topics`, `question_topics`, `topic_associations`, `question_chapters`

Actions & navigation
- Create topic -> POST /api/v1/topics.
- Assign questions -> POST /api/v1/question_topics bulk endpoint.
- View associated questions -> opens `question-editor` or question preview.

Permissions & edge cases
- Prevent circular parent assignments; validate unique (name,parent).

Notes / API endpoints
- GET /api/v1/topics/:id/tree
