# AI Architecture

## Overview

The AI Coach provides personalized fitness guidance using an LLM (Gemini API) with structured context injection. All AI requests are proxied through Supabase Edge Functions to keep API keys server-side.

## Architecture

```
Flutter App
    ↓ HTTPS request
Supabase Edge Function (ai-coach)
    ↓ Builds context
    ↓ Applies safety guardrails
    ↓ Calls AI provider
Gemini API
    ↓ Response
Supabase Edge Function
    ↓ Filters/validates response
    ↓ Stores in ai_messages
Flutter App
    ↓ Displays response
```

## Context Injection

Every AI request includes structured context (not free-form prompts):

```json
{
  "user_context": {
    "fitness_goal": "build_muscle",
    "experience_level": "intermediate",
    "available_equipment": ["barbell", "dumbbells", "bench"],
    "workout_frequency": 4,
    "recent_workouts": [...],
    "exercise_history": [...]
  },
  "exercise_context": {
    "current_exercise": { ... },
    "related_exercises": [...]
  },
  "conversation_history": [
    { "role": "user", "content": "..." },
    { "role": "assistant", "content": "..." }
  ]
}
```

## System Prompt

```
You are Gym3D AI Coach, a knowledgeable and supportive fitness assistant.

Rules:
1. You are NOT a doctor. Never diagnose injuries or medical conditions.
2. For injury or pain questions, always recommend consulting a healthcare professional.
3. Use the provided exercise database for exercise information. Do not invent exercises.
4. Base workout recommendations on the user's stated goal, experience, and equipment.
5. Be encouraging but honest. Do not make unrealistic promises.
6. Keep responses concise and actionable.
7. When explaining exercises, reference the 3D model: "You can view this in the 3D viewer."
8. Do not provide nutrition advice beyond general hydration and recovery tips.
9. Always prioritize safety over intensity.
```

## AI Capabilities

| Capability | Description | Input |
|------------|-------------|-------|
| Exercise Explanation | Detailed breakdown of any exercise | Exercise ID |
| Workout Generation | Personalized workout plans | User profile + preferences |
| Exercise Substitution | Alternative exercises | Exercise ID + constraints |
| Progress Analysis | Insights on training data | Workout history |
| Form Tips | Technique cues | Exercise ID |
| Training Q&A | General fitness questions | User message |

## Safety Guardrails

1. **System prompt enforcement**: Non-negotiable rules in system prompt
2. **Medical redirect**: Auto-detect injury/pain keywords → redirect to professional
3. **Content filter**: Block inappropriate or off-topic requests
4. **Rate limiting**: Free tier: 5 messages/day, Pro: 50 messages/day
5. **Token limits**: Max 2000 tokens per response (cost control)
6. **Audit log**: All conversations stored for review

## Provider Abstraction

```dart
abstract class AiProvider {
  Future<String> generateResponse({
    required String systemPrompt,
    required List<Message> conversationHistory,
    required Map<String, dynamic> context,
    int maxTokens = 2000,
  });
}

class GeminiProvider implements AiProvider { ... }
class OpenAiProvider implements AiProvider { ... }  // Future
```

## Exercise Content Generation (Admin Pipeline)

```
Admin enters: "Romanian Deadlift"
    ↓
Edge Function: generate-exercise
    ↓
AI generates draft:
  - Description
  - Instructions (step by step)
  - Breathing cues
  - Common mistakes
  - Safety notes
  - Difficulty rating
  - Equipment list
  - Primary/secondary muscles
    ↓
Content enters DRAFT status
    ↓
Human review required before PUBLISHED
```

## Cost Management

| Metric | Budget |
|--------|--------|
| Max tokens per request | 2,000 |
| Max conversation length | 20 messages |
| Free tier daily limit | 5 messages |
| Pro tier daily limit | 50 messages |
| Model | gemini-1.5-flash (cost-effective) |
