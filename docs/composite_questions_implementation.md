# Composite Questions System

This document describes the implementation of the flexible composite questions and quiz system.

## Overview

The system supports questions and options composed of multiple parts (text, images, diagrams, LaTeX, code, audio, video, tables) in any sequence and quantity. This allows for rich, multi-media quiz content.

## Backend Implementation

### Database Models (`app/db/models.py`)

Updated models with relationships:

- **Question**: Has many `parts` and `options` (cascade delete)
- **QuestionPart**: Belongs to a `question`, optionally links to `media`
- **Option**: Belongs to a `question`, has many `parts` (cascade delete)
- **OptionPart**: Belongs to an `option`, optionally links to `media`
- **Media**: Stores media files (images, videos, audio, etc.)

### API Schemas (`app/api/v1/schemas.py`)

Pydantic schemas for request/response:

- `QuestionPartCreate/Response`: For question parts with content and media
- `OptionPartCreate/Response`: For option parts
- `OptionCreate/Update/Response`: Options with their parts
- `QuestionCreate/Update/Response`: Questions with nested parts and options
- `QuestionListResponse`: Paginated list of questions

### API Endpoints (`app/api/v1/questions.py`)

RESTful CRUD operations:

- `GET /api/v1/questions` - List questions with pagination and filters
  - Query params: `page`, `page_size`, `answer_type`, `difficulty`
- `POST /api/v1/questions` - Create a new question with parts and options
- `GET /api/v1/questions/{id}` - Get a single question with all parts
- `PUT /api/v1/questions/{id}` - Update a question (replaces parts/options)
- `DELETE /api/v1/questions/{id}` - Delete a question (cascade deletes parts)

All endpoints use eager loading (`selectinload`) to fetch related parts and media.

## Frontend Implementation

### Models (`lib/src/models/composite_question.dart`)

Dart models matching the backend schema:

- **PartType** enum: text, image, diagram, latex, code, audio, video, table
- **AnswerType** enum: options, text, numeric, integer, regex, file, composite
- **Media**: Media file metadata
- **QuestionPart**: A part of a question with type, content, and optional media
- **OptionPart**: A part of an option
- **QuestionOption**: An option with label, correctness flag, weight, and parts
- **CompositeQuestion**: Main question model with parts, options, metadata

### UI Widgets

#### PartRenderer (`lib/src/widgets/part_renderer.dart`)

Renders individual parts based on type:

- **Text**: Selectable text
- **Image/Diagram**: Network image with error handling and loading
- **LaTeX**: Styled text (placeholder for math renderer like flutter_math_fork)
- **Code**: Syntax-highlighted code block
- **Audio/Video**: Placeholder with play button (needs implementation)
- **Table**: DataTable from JSON structure

#### PartsListRenderer

Renders a list of parts in sequence with configurable spacing.

#### CompositeQuestionCard (`lib/src/widgets/composite_question_card.dart`)

Full-featured question display widget:

- Shows title, difficulty, time estimate, answer type
- Renders all question parts in order
- Shows description
- Displays options with their parts
- Supports single/multi-select answers
- Submit button with callback
- Visual feedback for selected options

### Question Editor (`lib/src/pages/question_editor_page.dart`)

Interactive editor for creating/editing questions:

- **Basic Info Section**: Title, description, answer type, difficulty, time estimate
- **Question Parts Section**: Add/remove/reorder parts of different types
  - Text/LaTeX/Code: Text input
  - Image/Diagram/Audio/Video: Upload placeholder
- **Options Section** (for option-type questions):
  - Add/remove options
  - Set option label (A, B, C, D)
  - Mark correct answer(s)
  - Add/remove parts within each option
  - Visual distinction for correct options (green highlight)
- Dynamic UI that adapts to answer type

### Service Layer (`lib/src/services/composite_question_service.dart`)

API client for composite questions:

- `listQuestions()` - Fetch paginated questions with filters
- `getQuestion(id)` - Fetch single question
- `createQuestion()` - Create new question
- `updateQuestion()` - Update existing question
- `deleteQuestion()` - Delete question
- `createSimpleTextQuestion()` - Helper to create simple text-based MCQ

### Demo Page (`lib/src/pages/composite_questions_demo.dart`)

Demo page showcasing the functionality:

- Lists all questions using `CompositeQuestionCard`
- Create sample question button
- Navigate to editor for new questions
- Answer submission with instant feedback
- Error handling and loading states

## Answer Types Supported

1. **options**: Multiple choice (single or multi-select)
2. **text**: Free-text response
3. **numeric**: Numeric answer with tolerance
4. **integer**: Integer answer
5. **regex**: Pattern-matched text
6. **file**: File upload
7. **composite**: Complex multi-part answers

## Part Types Supported

- **text**: Plain or formatted text
- **image**: JPEG, PNG, WebP images
- **diagram**: SVG or other diagram formats
- **latex**: Mathematical equations (LaTeX notation)
- **code**: Syntax-highlighted code snippets
- **audio**: Audio clips
- **video**: Video files
- **table**: Structured table data (JSON format)

## Usage Examples

### Creating a Simple Text Question

```dart
final service = CompositeQuestionService(ApiClient());
await service.createSimpleTextQuestion(
  questionText: 'What is 2 + 2?',
  optionTexts: ['3', '4', '5', '6'],
  correctOptionIndex: 1,
  difficulty: 1,
);
```

### Creating a Multi-Part Question

```dart
final question = CompositeQuestion(
  id: '',
  answerType: AnswerType.options,
  parts: [
    QuestionPart(
      id: '', questionId: '', index: 0,
      partType: PartType.text,
      content: 'Consider the following code:',
    ),
    QuestionPart(
      id: '', questionId: '', index: 1,
      partType: PartType.code,
      content: 'def foo():\n    return 42',
    ),
    QuestionPart(
      id: '', questionId: '', index: 2,
      partType: PartType.text,
      content: 'What does this function return?',
    ),
  ],
  options: [
    QuestionOption(
      id: '', questionId: '', label: 'A', index: 0,
      isCorrect: true,
      parts: [
        OptionPart(
          id: '', optionId: '', index: 0,
          partType: PartType.text,
          content: '42',
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // ... more options
  ],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await service.createQuestion(question);
```

### Rendering a Question

```dart
CompositeQuestionCard(
  question: myQuestion,
  onAnswerSubmit: (selectedIds) {
    // Handle answer submission
    print('Selected options: $selectedIds');
  },
)
```

## Database Schema Notes

- All parts have an `index` field for ordering
- Options can have `weight` for partial scoring
- Media is stored separately and linked via `media_id`
- JSONB `metadata` fields allow flexible extension
- Cascade deletes ensure data integrity

## Migration

Run the migration:

```bash
cd backend
alembic upgrade head
```

## Testing

### Backend

```bash
cd backend
# Start the server
uvicorn app.main:app --reload

# Test endpoints
curl http://localhost:8000/api/v1/health
curl http://localhost:8000/api/v1/questions
```

### Frontend

```bash
cd net
flutter run
# Navigate to Composite Questions Demo
```

## Future Enhancements

1. **Media Upload**: Implement file upload to object storage (S3/MinIO)
2. **LaTeX Rendering**: Integrate flutter_math_fork for proper math rendering
3. **Audio/Video Players**: Add media playback widgets
4. **Rich Text Editor**: WYSIWYG editor for text parts
5. **Drag & Drop**: Reorder parts in the editor
6. **Templates**: Question templates for common patterns
7. **Import/Export**: Bulk import from CSV/JSON
8. **Version Control**: Track question revisions
9. **Preview Mode**: Live preview while editing
10. **Accessibility**: Screen reader support, keyboard navigation

## API Documentation

When the backend is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Notes

- The backend uses async SQLAlchemy with PostgreSQL
- Frontend uses Provider for state management
- All IDs are UUIDs for universal uniqueness
- Timestamps are UTC with timezone awareness
- Proper error handling with try/catch blocks
- Loading states and error feedback in UI
