---
title: Entity Relationships
---

# Entity Relationships

Purpose
- Manage polymorphic relationships between entities (questions, topics, quizzes, users) such as prerequisites, references and similarity links.

Entry points
- From entity pages (question/quiz/topic) or admin -> Relationships.

Layout
- Graph visualization panel and relationship list for selected entity.

Fields / Controls
- Create relation form: source type/id, target type/id, relation_type, metadata.
- Filters for relation_type, date, creator.

Primary DB tables
- `entity_relationships`

Actions & navigation
- Create -> POST /api/v1/entity_relationships
- Click node -> open corresponding detail page (question-editor, quiz-detail, topic page)

Permissions & edge cases
- Prevent duplicates and circular references for certain relation types; validate authorizations.

Notes / API endpoints
- GET /api/v1/entity_relationships?source=question:UUID
