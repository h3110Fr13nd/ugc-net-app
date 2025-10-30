# Database schema design (living document)

This file captures an extensible database design for the quiz/assessment product and related authentication needs. It is intended to be a living document — add new requirements and examples below and keep iterating.

## Assumptions and high-level decisions
- Primary DB: PostgreSQL (recommended) for relational integrity + JSONB flexibility.
- Use UUIDs for primary keys (universally unique and safe across services).
- All entities have audit fields: `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_at` (soft-delete).
- Use JSONB `metadata` columns for entity-specific flexible attributes.
- Store media (images/diagrams/audio/video) in an object storage (S3/compatible). Keep canonical metadata in a `media` table.
- Use hashed & salted passwords (Argon2id or bcrypt). Do not store raw JWTs; store refresh token hashes and JWT `jti` revocation entries.

----

## Auth / Users

Tables:

- users
  - id UUID PK
  - email TEXT UNIQUE NOT NULL
  - email_verified BOOLEAN DEFAULT FALSE
  - password_hash TEXT NULL
  - password_algo TEXT NULL (e.g., argon2id)
  - preferred_username TEXT NULL
  - display_name TEXT NULL
  - locale TEXT NULL
  - metadata JSONB DEFAULT '{}'  -- app-specific data
  - created_at, updated_at, deleted_at, created_by, updated_by

- user_roles (many-to-many)
  - id UUID PK
  - user_id FK -> users(id)
  - role_id FK -> roles(id)
  - assigned_by UUID (FK user)
  - assigned_at TIMESTAMP

- roles
  - id UUID PK
  - name TEXT UNIQUE
  - description TEXT
  - metadata JSONB

- permissions
  - id UUID PK
  - name TEXT UNIQUE
  - description TEXT

- role_permissions (many-to-many)
  - role_id FK -> roles(id)
  - permission_id FK -> permissions(id)

- oauth_providers
  - id UUID PK
  - provider_name TEXT (google, github, etc.) UNIQUE
  - client_id TEXT (encrypted in config) or managed in app config
  - metadata JSONB

- user_oauth_accounts
  - id UUID PK
  - user_id FK -> users(id)
  - provider_id FK -> oauth_providers(id)
  - provider_account_id TEXT NOT NULL
  - provider_account_email TEXT
  - access_token_encrypted TEXT NULL
  - refresh_token_encrypted TEXT NULL
  - scope TEXT
  - raw_profile JSONB
  - created_at, updated_at
  - UNIQUE(provider_id, provider_account_id)

- jwt_revocations
  - jti TEXT PRIMARY KEY (JWT ID)
  - user_id FK -> users(id)
  - expires_at TIMESTAMP
  - revoked_at TIMESTAMP
  - reason TEXT
  - metadata JSONB
  - Index on expires_at for periodic cleanup

- refresh_tokens
  - id UUID PK
  - user_id FK -> users(id)
  - refresh_token_hash TEXT NOT NULL
  - device_info TEXT NULL
  - created_at, last_used_at, revoked_at
  - expires_at TIMESTAMP
  - metadata JSONB
  - rotate_on_use BOOLEAN DEFAULT TRUE

Security notes:
- Hash refresh tokens before storing (use HMAC or bcrypt). Keep rotation and one-time use semantics.
- For OAuth, store provider tokens encrypted and keep minimal token lifetime server-side.

----

## Content: Quizzes, Questions, Parts, Options, Media

Design goals:
- Questions are composable: a question is a container of ordered parts (text, image, diagram, code block, etc.).
- Options (for MCQ) can also be composite (each option can have text/image/diagram parts).
- Questions may accept different answer types (multiple choice, multi-select, text, numeric with tolerance, regex-match, file-upload, code-runner, etc.).
- Support multi-correct options, partial scoring, and per-option weights.
- Support tagging and hierarchical topics (subjects/chapters/topics) with many-to-many assignment.

Tables and explanation (key columns shown):

- quizzes
  - id UUID PK
  - title TEXT
  - description TEXT
  - metadata JSONB (timing rules, passing_score, shuffle_parts, shuffle_options)
  - created_by, created_at, updated_at, published_at, status (draft/published/archived)

- quiz_versions (optional)
  - id UUID PK
  - quiz_id FK -> quizzes(id)
  - version_number INT
  - snapshot JSONB (full snapshot of quiz at that version)
  - created_at, created_by

- questions
  - id UUID PK
  - canonical_id UUID (if multiple versions; canonical groups versions)
  - title TEXT
  - description TEXT
  - answer_type TEXT ENUM ('options', 'text', 'numeric', 'integer', 'regex', 'file', 'composite')
  - scoring JSONB (default scoring rules, e.g., partial scoring rules)
  - difficulty SMALLINT
  - estimated_time_seconds INT
  - metadata JSONB
  - created_by, created_at, updated_at

- question_versions
  - similar to quiz_versions; snapshot for revision control

- question_parts
  - id UUID PK
  - question_id FK -> questions(id)
  - index INT NOT NULL  -- ordering of parts (1,2,3...)
  - part_type TEXT ENUM ('text','image','diagram','latex','code','audio','video','table')
  - content TEXT NULL -- for small text content
  - content_json JSONB NULL -- structured content (e.g., richtext blocks)
  - media_id UUID FK -> media(id) NULL (optional, used when part_type requires media)
  - metadata JSONB
  - UNIQUE(question_id, index)

- media
  - id UUID PK
  - url TEXT NOT NULL
  - storage_key TEXT UNIQUE NOT NULL
  - mime_type TEXT
  - width INT, height INT, size_bytes BIGINT
  - checksum TEXT
  - uploaded_by UUID FK -> users(id)
  - metadata JSONB
  - created_at, updated_at
  - Index on checksum for dedup

- options
  - id UUID PK
  - question_id FK -> questions(id)
  - label TEXT NULL -- e.g., "A", "B" (auto-generated by UX)
  - index INT NULL -- ordering if options are ordered (UI chooses)
  - is_correct BOOLEAN DEFAULT FALSE
  - weight NUMERIC DEFAULT 1.0 -- for partial scoring
  - metadata JSONB -- e.g., explanation, rationale
  - created_at, updated_at

- option_parts (composite options)
  - id UUID PK
  - option_id FK -> options(id)
  - index INT
  - part_type ENUM('text','image','diagram',...)
  - content TEXT
  - media_id FK -> media(id)

Notes on options and multi-part: options are linked to a question but can be independently composed of parts. For non-option answer types (text/numeric), options table is unused.

----

## Answers and Attempts (student responses)

Design to record attempts at question and quiz level with detailed per-part responses.

- quiz_attempts
  - id UUID PK
  - quiz_id FK -> quizzes(id)
  - user_id FK -> users(id) (nullable for anonymous)
  - started_at, submitted_at, duration_seconds
  - score NUMERIC, max_score NUMERIC
  - status ENUM('in_progress','submitted','graded')
  - metadata JSONB

- question_attempts
  - id UUID PK
  - quiz_attempt_id FK -> quiz_attempts(id) NULL
  - question_id FK -> questions(id)
  - attempt_index INT (order in quiz)
  - started_at, submitted_at, scored_at
  - score NUMERIC
  - grading JSONB (per-part scores, feedback)
  - metadata JSONB

- question_attempt_parts
  - id UUID PK
  - question_attempt_id FK -> question_attempts(id)
  - question_part_id FK -> question_parts(id) NULL
  - selected_option_ids UUID[] NULL  -- helpful for MCQ multi-select (store option ids)
  - text_response TEXT NULL
  - numeric_response NUMERIC NULL
  - file_media_id FK -> media(id) NULL
  - raw_response JSONB NULL  -- extensible
  - created_at

Normalization tip: If you need full audit of every option selected (one row per selection) create question_attempt_option_responses with attempt_part_id and option_id and score.

----

## Topics / Subjects / Chapters and hierarchical tagging

Requirements: topics and subtopics are topics with parents; questions can belong to many topics; chapters and subjects also assigned to questions; topics may be associated with topics arbitrarily; almost every entity may have dynamic relationships.

Suggested unified approach:

- subjects
  - id UUID PK
  - name TEXT
  - metadata JSONB

- chapters
  - id UUID PK
  - subject_id FK -> subjects(id)  -- optional
  - name TEXT
  - metadata JSONB

- topics
  - id UUID PK
  - name TEXT
  - parent_id UUID NULL FK -> topics(id)
  - path LTREE or text[] materialized path (if using pg_ltree extension) for fast hierarchy queries
  - metadata JSONB
  - UNIQUE (name, parent_id) optional

- question_topics (many-to-many)
  - id UUID PK
  - question_id FK -> questions(id)
  - topic_id FK -> topics(id)
  - confidence_score or relevance_score numeric optional

- question_chapters (many-to-many)
  - question_id, chapter_id

- topic_associations (free-form associations between topics)
  - id UUID PK
  - from_topic_id FK -> topics(id)
  - to_topic_id FK -> topics(id)
  - association_type TEXT (related, prerequisite, alternative, alias)
  - metadata JSONB

This approach lets topics be hierarchical (parent_id) and also have many-to-many associations between topics.

----

## Modeling dynamic relationships between arbitrary entities

To support "almost every entity may have their dynamic relationships", create a polymorphic relationships table that can link any two rows from any tables and carry relationship metadata and versioning.

- entity_relationships
  - id UUID PK
  - source_type TEXT NOT NULL  -- e.g., 'question','topic','user','quiz' (application-level name)
  - source_id UUID NOT NULL
  - target_type TEXT NOT NULL
  - target_id UUID NOT NULL
  - relation_type TEXT NOT NULL -- e.g., 'references','depends_on','similar_to'
  - metadata JSONB
  - created_by UUID, created_at
  - UNIQUE(source_type, source_id, target_type, target_id, relation_type) optional

Indexing: partial indexes on (source_type, source_id) and (target_type, target_id) for fast lookups.

This gives a flexible graph-of-entities model without altering the schema every time a new relationship is required.

----

## Indexing and performance suggestions
- Add indexes on frequently queried columns: users.email, quizzes.status, questions.answer_type, question_parts.question_id, options.question_id.
- Use GIN indexes on JSONB columns for queries on metadata: CREATE INDEX ON table USING GIN (metadata);
- Use pg_trgm + GIN for full-text fuzzy search on question text and titles.
- Add partial indexes for active (deleted_at IS NULL) rows to speed up normal use-case queries.
- If hierarchical queries are common, enable `pg_ltree` extension and store topic paths for fast subtree retrieval.

----

## Example DDL snippets (Postgres flavor)

-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  password_hash TEXT,
  password_algo TEXT,
  preferred_username TEXT,
  display_name TEXT,
  locale TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Topics (with ltree path)
CREATE EXTENSION IF NOT EXISTS ltree;
CREATE TABLE topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  parent_id UUID NULL REFERENCES topics(id) ON DELETE SET NULL,
  path LTREE,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Polymorphic relationship example
CREATE TABLE entity_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type TEXT NOT NULL,
  source_id UUID NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID NOT NULL,
  relation_type TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
CREATE INDEX ON entity_relationships (source_type, source_id);
CREATE INDEX ON entity_relationships (target_type, target_id);

----

## Versioning, auditing, and migration strategy
- Keep immutable snapshots for published questions/quizzes in *_versions tables.
- Keep small `delta` JSONB when possible for lightweight versioning (store only changed fields).
- Use application-level events for heavy operations (e.g., bulk topic reassignment) and write idempotent migrations.

----

## Extensibility / Next requirements to capture
- Support translations for question parts and options (i18n): add `language` and `translation_of` references for parts.
- Adaptive quizzes: model prerequisite logic between questions (use entity_relationships with relation_type='prerequisite').
- Content owners and access control (ACL): add ACL tables or integrate with RBAC for question visibility.
- Question banks and sharing across organizations (multi-tenant considerations): tenant_id on top-level tables.
- Analytics events table to capture activity streams and aggregated counters for popular questions/topics.

----

## How to continue adding requirements in this file
1. Add a short header with date and the new requirement.
2. Describe the functional need and expected queries (read-heavy / write-heavy).
3. Propose where in the schema it fits or if a new table/pattern is needed.
4. If behavior spans multiple entities, add a short migration plan and expected downtime or data transformations.

----

## Open design questions (to decide)
- Should we use strict normalized tables for all attempt responses (one row per response) or allow JSONB blobs for quick storage? (Trade-offs: relational queries vs flexibility)
- How to model adaptive item selection rules (rule engine external vs stored in DB as JSON)?
- Multi-tenancy: single DB with tenant_id column vs separate DBs per tenant.

----

If you want, I can convert the above DDL to migration files for your chosen migration system (Alembic, Django migrations, Knex, Flyway) or generate an ER diagram (PlantUML) next.
