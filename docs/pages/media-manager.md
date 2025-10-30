---
title: Media Manager
---

# Media Manager

Purpose
- Central UI for uploading, searching, previewing, and managing media assets (images, audio, video, diagrams).

Entry points
- Global nav "Media"; upload buttons within editors (question-part, option, import wizards).

Layout
- Toolbar: upload, filter by type, search by filename/checksum.
- Grid of thumbnails with metadata overlay and actions.
- Detail panel showing usage (which entities reference it) and metadata editing.

Fields / Controls
- Upload area (drag/drop), filename, alt text, captions, tags, delete/dedup actions.

Primary DB tables
- `media`, cross-references in `question_parts`, `option_parts`, `question_attempt_parts`

Actions & navigation
- Upload -> POST /api/v1/media -> returns `media.id`.
- Attach -> select media in part editor -> returns `media_id` to client.
- Delete -> soft-delete or hard-delete if unused.

Permissions & edge cases
- Prevent deletion when referenced; offer soft-delete and orphan report.
- Large files: use direct S3 uploads with pre-signed URLs.

Notes / API endpoints
- POST /api/v1/media (multipart upload or pre-signed URL)
- GET /api/v1/media?filters
