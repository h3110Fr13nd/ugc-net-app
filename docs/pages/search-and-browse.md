---
title: Search and Browse
---

# Search & Browse

Purpose
- Provide global search across quizzes, questions, topics and users with advanced filters and saved searches.

Entry points
- Top nav search input, dashboard quick search box.

Layout
- Search input with instant suggestions; results tabbed by resource type; advanced filter pane.

Fields / Controls
- Filters: date range, topic, difficulty, author, status; sort options and save search.

Primary DB tables
- `questions`, `quizzes`, `topics`, `users` and any search index (PG trigram / external search service)

Actions & navigation
- Click result -> navigate to resource detail page.
- Advanced search -> modal to construct complex queries and save presets.

Permissions & edge cases
- Respect ACLs; hide private or tenant-restricted content from results.

Notes / API endpoints
- GET /api/v1/search?q=...&type=questions
