# How to Add Questions via UI

## Quick Start

1. **Run the app**:
   ```bash
   cd net
   flutter run
   ```

2. **Navigate to Add Questions**:
   - After signing in, you'll see the **Dashboard**
   - Click the **"Add Question"** card (blue icon with plus sign)
   - This will take you to the Composite Questions page

## Three Ways to Add Questions

### Method 1: From Dashboard (Easiest)
1. Sign in to the app
2. On the dashboard, click the blue **"Add Question"** card
3. You'll see the Composite Questions Demo page
4. Click the **"+"** icon in the top-right app bar
5. This opens the Question Editor

### Method 2: Create Sample Question (Quickest)
1. Go to Dashboard → Add Question
2. Click the **"Create Sample"** floating action button at the bottom
3. A sample question will be created automatically
4. You can then edit it or create more

### Method 3: Direct Navigation (From Code)
From anywhere in your app, use:
```dart
Navigator.pushNamed(context, '/pages/composite_questions');
```

## Using the Question Editor

### Basic Information
1. **Title** (optional): Give your question a title
2. **Description** (optional): Add context or instructions
3. **Answer Type**: Choose from:
   - `options` - Multiple choice (recommended)
   - `text` - Free text answer
   - `numeric` - Number answer
   - `integer` - Whole number
   - Others (regex, file, composite)
4. **Difficulty**: 1-5 scale
5. **Estimated Time**: Time in seconds

### Adding Question Parts
Click the **"+"** button next to "Question Parts" to add:
- **Text**: Plain text content
- **Image**: Upload an image (placeholder)
- **Code**: Code snippets with syntax highlighting
- **LaTeX**: Mathematical formulas
- **Diagram**: Charts/diagrams
- **Audio/Video**: Media files (placeholder)
- **Table**: Structured data

Each part appears in the order you add them. You can add multiple parts of different types!

### Adding Answer Options (for MCQ)
1. Click **"Add Option"** in the Answer Options section
2. For each option:
   - Set the **Label** (A, B, C, D - auto-filled)
   - Check **"Correct answer"** if this is the right answer
   - Click the "+" to add parts to the option (text, image, etc.)
   - Add multiple parts if needed (e.g., text + image)

### Saving
Click the **"Save"** button in the top-right corner (currently shows a message - full save coming soon)

## Example: Creating a Simple Question

1. Navigate to Add Question
2. Leave title blank (optional)
3. Keep Answer Type as "options"
4. Set Difficulty to 2
5. In Question Parts:
   - Click "+" → select "Text"
   - Enter: "What is the capital of France?"
6. In Answer Options:
   - Click "Add Option"
   - Option A (already has a text part): Enter "Paris"
   - Check "Correct answer"
   - Click "Add Option" again
   - Option B: Enter "London"
   - Don't check correct
   - Repeat for C (Berlin) and D (Madrid)
7. Click Save

## Tips

- **Mix content types**: Combine text, images, and code in one question
- **Rich options**: Options can have images too! (e.g., identify the diagram)
- **Sample questions**: Use "Create Sample" to see how questions are structured
- **Preview**: Questions appear in the list below after creation
- **Test answers**: Click options and submit to test the question

## Troubleshooting

**Can't see the Add Question button?**
- Make sure you're signed in
- Check you're on the Dashboard screen
- Look for the blue card with a "+" icon

**Question Editor is empty?**
- The editor starts with one text part by default
- Click "Add part" to add more
- Click "Add Option" to add answer choices

**Save doesn't work?**
- Currently shows a placeholder message
- Full API integration coming soon
- Questions created with "Create Sample" work fully

## Current Limitations

- Media upload is placeholder (coming soon)
- LaTeX shows as styled text (math renderer coming soon)
- Audio/Video are placeholders (players coming soon)
- Save to database needs backend running

## Next Steps

Once the backend is running:
1. Start backend: `cd backend && uvicorn app.main:app --reload`
2. Questions will be saved to the database
3. Full CRUD operations will work
4. Media upload will be functional
