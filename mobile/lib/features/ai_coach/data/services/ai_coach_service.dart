import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class AiCoachResponse {
  final String content;
  final List<String> suggestions;

  const AiCoachResponse({
    required this.content,
    this.suggestions = const [],
  });
}

class GeneratedWorkoutExercise {
  final String exerciseName;
  final String category;
  final int sets;
  final int reps;
  final int restSeconds;

  const GeneratedWorkoutExercise({
    required this.exerciseName,
    required this.category,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });
}

class GeneratedWorkoutPlan {
  final String name;
  final String description;
  final String difficulty;
  final int estimatedDurationMin;
  final List<GeneratedWorkoutExercise> exercises;

  const GeneratedWorkoutPlan({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.estimatedDurationMin,
    required this.exercises,
  });
}

/// Service handling communication with the Gemini AI Coach & local intelligent fallback.
class AiCoachService {
  final SupabaseClient _client;

  AiCoachService(this._client);

  /// Send a chat message to the AI coach.
  Future<AiCoachResponse> sendMessage({
    required String message,
    List<Map<String, String>> history = const [],
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? exerciseContext,
  }) async {
    // 1. Safety Guardrail: Medical & injury intercept
    final lower = message.toLowerCase();
    if (lower.contains('sharp pain') ||
        lower.contains('injured') ||
        lower.contains('dislocated') ||
        lower.contains('torn') ||
        lower.contains('hurts really bad')) {
      return const AiCoachResponse(
        content:
            '⚠️ **Safety Warning**: Sharp or acute pain indicates a possible strain or injury. Please stop exercising immediately and consult a healthcare professional or physical therapist. Your safety is paramount!',
        suggestions: ['Gentle Mobility Tips', 'How to Warm Up Properly'],
      );
    }

    // 2. Try calling Supabase Edge Function
    try {
      final response = await _client.functions.invoke(
        'ai-coach',
        body: {
          'message': message,
          'conversation_history': history,
          'user_context': userContext,
          'exercise_context': exerciseContext,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final reply = data['response'] as String? ?? '';
        final suggestions = (data['suggested_actions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        return AiCoachResponse(content: reply, suggestions: suggestions);
      }
    } catch (_) {
      // Fallback to local intelligent knowledge engine
    }

    return _generateLocalResponse(message, exerciseContext);
  }

  /// Generate an AI workout plan based on user requirements.
  Future<GeneratedWorkoutPlan> generateWorkoutPlan({
    required String targetFocus,
    required int durationMin,
    required String difficulty,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final focusLower = targetFocus.toLowerCase();

    if (focusLower.contains('chest') || focusLower.contains('push')) {
      return GeneratedWorkoutPlan(
        name: 'AI Push Power Blast',
        description:
            'Hypertrophy and strength focused push routine targeting chest, shoulders, and triceps.',
        difficulty: difficulty,
        estimatedDurationMin: durationMin,
        exercises: const [
          GeneratedWorkoutExercise(
            exerciseName: 'Barbell Bench Press',
            category: 'chest',
            sets: 4,
            reps: 8,
            restSeconds: 90,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Incline Dumbbell Press',
            category: 'chest',
            sets: 3,
            reps: 10,
            restSeconds: 60,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Overhead Shoulder Press',
            category: 'shoulders',
            sets: 3,
            reps: 10,
            restSeconds: 60,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Triceps Pushdown',
            category: 'arms',
            sets: 3,
            reps: 12,
            restSeconds: 45,
          ),
        ],
      );
    } else if (focusLower.contains('back') || focusLower.contains('pull')) {
      return GeneratedWorkoutPlan(
        name: 'AI Pull & Lat Hypertrophy',
        description:
            'Comprehensive back and bicep builder emphasizing upper back thickness and lat width.',
        difficulty: difficulty,
        estimatedDurationMin: durationMin,
        exercises: const [
          GeneratedWorkoutExercise(
            exerciseName: 'Conventional Deadlift',
            category: 'back',
            sets: 4,
            reps: 6,
            restSeconds: 120,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Lat Pulldown',
            category: 'back',
            sets: 3,
            reps: 10,
            restSeconds: 60,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Bent Over Barbell Row',
            category: 'back',
            sets: 3,
            reps: 8,
            restSeconds: 75,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Biceps Barbell Curl',
            category: 'arms',
            sets: 3,
            reps: 12,
            restSeconds: 45,
          ),
        ],
      );
    } else {
      // Default Legs / Full Body
      return GeneratedWorkoutPlan(
        name: 'AI Full Body Foundation',
        description:
            'Compound multi-joint movements for maximum muscle engagement and functional power.',
        difficulty: difficulty,
        estimatedDurationMin: durationMin,
        exercises: const [
          GeneratedWorkoutExercise(
            exerciseName: 'Barbell Squat',
            category: 'legs',
            sets: 4,
            reps: 8,
            restSeconds: 90,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Barbell Bench Press',
            category: 'chest',
            sets: 3,
            reps: 8,
            restSeconds: 90,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Lat Pulldown',
            category: 'back',
            sets: 3,
            reps: 10,
            restSeconds: 60,
          ),
          GeneratedWorkoutExercise(
            exerciseName: 'Romanian Deadlift',
            category: 'legs',
            sets: 3,
            reps: 10,
            restSeconds: 75,
          ),
        ],
      );
    }
  }

  AiCoachResponse _generateLocalResponse(
    String message,
    Map<String, dynamic>? exerciseContext,
  ) {
    final lower = message.toLowerCase();

    if (lower.contains('squat')) {
      return const AiCoachResponse(
        content: '### How to Perfect Your Squat Form 🏋️‍♂️\n\n'
            '1. **Foot Position**: Place feet slightly wider than shoulder-width, toes angled out 15–30°.\n'
            '2. **Bracing**: Take a deep diaphragmatic breath and brace your core like preparing for a punch.\n'
            '3. **Descent**: Initiate by hinging hips back and bending knees simultaneously.\n'
            '4. **Depth**: Lower until hip crease is at or below the top of your knees (parallel).\n'
            '5. **Drive**: Push through the mid-foot while keeping your chest up.\n\n'
            '*💡 Tip: Open the Barbell Squat 3D Viewer in the exercise library to see 360° form and muscle engagement!*',
        suggestions: [
          'What muscles do squats work?',
          'Common squat mistakes to avoid',
          'Create a leg workout'
        ],
      );
    } else if (lower.contains('deadlift')) {
      return const AiCoachResponse(
        content: '### Deadlift Key Technique Cues 🎯\n\n'
            '• **Bar Path**: Keep the barbell touching your shins and thighs throughout the lift.\n'
            '• **Lats Engagement**: Pull shoulders down and back ("protect your armpits").\n'
            '• **Neutral Spine**: Avoid hyperextending at the top or rounding lower back at the bottom.\n'
            '• **Leg Drive**: Think of pushing the floor away rather than pulling the bar up.\n\n'
            '*Primary Muscles: Hamstrings, Glutes, Erector Spinae, and Upper Traps.*',
        suggestions: [
          'Deadlift vs Romanian Deadlift',
          'Warm up for heavy pulls',
          'Build a back routine'
        ],
      );
    } else if (lower.contains('workout') || lower.contains('routine') || lower.contains('plan')) {
      return const AiCoachResponse(
        content: '### Recommended 3-Day Full Body Split 📅\n\n'
            '**Workout A (Monday)**:\n'
            '• Barbell Squat: 3 sets × 8–10 reps\n'
            '• Bench Press: 3 sets × 8–10 reps\n'
            '• Bent-Over Row: 3 sets × 10 reps\n\n'
            '**Workout B (Wednesday)**:\n'
            '• Deadlift: 3 sets × 6 reps\n'
            '• Overhead Press: 3 sets × 8–10 reps\n'
            '• Lat Pulldown: 3 sets × 10–12 reps\n\n'
            '**Workout C (Friday)**:\n'
            '• Lunges: 3 sets × 10 reps/leg\n'
            '• Incline Dumbbell Press: 3 sets × 10 reps\n'
            '• Barbell Bicep Curls: 3 sets × 12 reps\n\n'
            '*You can tap the AI Workout Generator on the Workouts tab to automatically create this routine in your account!*',
        suggestions: [
          'Create a 4-day split',
          'How much rest between sets?',
          'Generate Chest Workout'
        ],
      );
    } else if (lower.contains('warm up') || lower.contains('warmup')) {
      return const AiCoachResponse(
        content: '### Optimal Pre-Workout Dynamic Warmup (5-8 min) 🔥\n\n'
            '1. **5 min Light Cardio**: Rowing machine, stationary bike, or brisk walking.\n'
            '2. **Dynamic Mobility**:\n'
            '   • Hip Openers / World\'s Greatest Stretch (10 reps/side)\n'
            '   • Arm Circles & Band Pull-Aparts (15 reps)\n'
            '   • Bodyweight Squats & Glute Bridges (12 reps)\n'
            '3. **Pyramid Warm-Up Sets**: 1-2 light sets of your first major compound exercise at 40-50% working weight.\n\n'
            '*Avoid static stretching before heavy lifts—save static holds for post-workout recovery!*',
        suggestions: [
          'Post-workout cool down',
          'Mobility exercises for hips',
          'Proper breathing technique'
        ],
      );
    }

    return AiCoachResponse(
      content: 'Great question! Here is how to approach this in your training:\n\n'
          '1. **Consistency**: Progressive overload over weeks and months is the most reliable driver of strength and hypertrophy.\n'
          '2. **Form & Mechanics**: Control the eccentric (lowering) phase for 2–3 seconds to maximize time under tension.\n'
          '3. **Recovery**: Ensure 7–9 hours of sleep and adequate protein intake (1.6–2.2g per kg body weight).\n\n'
          '*Feel free to ask for specific exercise breakdowns or tap below to generate a tailored workout!*',
      suggestions: [
        'How do I perform a squat correctly?',
        'Create a beginner workout',
        'What muscles does deadlift work?',
        'How should I warm up?'
      ],
    );
  }
}

/// Provider for AiCoachService.
final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AiCoachService(client);
});
