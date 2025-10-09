# Roadmap: Personal Exam Coach App

This roadmap converts the idea in `docs/idea.md` into a practical, phased plan (MVP → Phase 1 → Phase 2). Each phase lists acceptance criteria, success metrics, and risks.

## MVP (4 weeks) — core practice + tracking
Goals: Let a single user practice MCQs, get instant feedback (including LLM explanations for wrong answers), and store results for simple analytics.

Must-haves:
- Basic Flutter app with MCQ player screen (question, options, select answer).
- Local or lightweight backend (FastAPI) exposing: GET /question, POST /attempt, GET /stats.
- Persistent storage (SQLite/Postgres) for questions and attempts.
- LLM integration (configurable) to generate explanations on wrong answers (cache responses).
- Simple dashboard: total attempts, accuracy, topic-wise correctness (top 5 topics).
- Importer: CSV-based importer for question bank (manual + script).

Acceptance criteria:
- User can run app locally and answer a 10-question practice set.
- Wrong answers return an LLM explanation and are saved with the attempt.
- Dashboard reflects results from those attempts.

Success metrics:
- End-to-end smoke test passes (MCQ -> attempt -> explanation -> stats).

Risks:
- LLM costs / rate limits — mitigate with caching and sample explanations stored locally.

## Phase 1 (6–8 weeks) — content/UX & automation
Goals: Improve onboarding, content ingestion, and provide topic drills.

Features:
- Topic selection and timed/untimed modes.
- Importer: PDF/structured text extractor (best-effort) and CSV importer.
- Auto-tagging using an LLM (semi-automated review mode).
- Weakness drill: generate 20-question drill from weakest topics.
- Authentication (simple email or local accounts) to sync progress.

Acceptance criteria:
- Importer can ingest at least one sample CSV and tag questions.
- App can generate a 20-question drill based on topic-performance data.

Success metrics:
- Importer accuracy (manual spot-check) >= 90% for sample data.

Risks:
- PDF parsing is messy — start with CSV/JSON as canonical format.

**Developer todo:** Phase 1 is being tracked in `docs/phase1_todos.md` (keeps task statuses and implementation notes). See that file to follow current in-progress work and files created.

## Phase 2 (8–12 weeks) — personalization & advanced analytics
Goals: Make the app adaptive and introduce revision scheduling.

Features:
- Adaptive difficulty algorithm (ELO-like or Bayesian) to adjust question difficulty.
- Spaced repetition scheduler for previously-missed questions.
- Detailed dashboard: heatmaps, running averages, confidence tracking, time per question.
- Exam Simulator: full-length, timed, with exportable report.

Acceptance criteria:
- Adaptive mode shows measurable improvement on repeated runs (accuracy increase on weak topics).

Success metrics:
- Average accuracy improvement on weak topics after 2 weeks of drills >= 10%.

Risks:
- Complexity of adaptive algorithms — start with simple heuristics and iterate.

## Minimal Wireframes (text)
- Home: Start Practice | Topic Drill | Dashboard | Import Data
- Practice: Question card, Options, Timer (optional), Skip, Submit
- Feedback: Correct/Wrong badge + LLM explanation (collapsible)
- Dashboard: recent attempts chart, topic list with correctness %, weak-spot drill CTA

## Quick dev checklist for MVP
1. Create repo structure: `app/` (Flutter), `backend/` (FastAPI), `scripts/`, `docs/`.
2. Implement backend endpoints and DB models for Questions, Attempts, Topics.
3. Add CSV importer and sample dataset in `scripts/sample_data/`.
4. Scaffold Flutter MCQ screens and wire to backend (use local mock if backend not ready).
5. Add simple LLM client wrapper with caching.
6. Dashboard: basic counts and topic aggregated accuracy.

## What to deliver at MVP completion
- Running Flutter app (local) that can: import a sample CSV, run a 10-question practice, store attempts, show explanations for wrong answers, and present a simple dashboard.
