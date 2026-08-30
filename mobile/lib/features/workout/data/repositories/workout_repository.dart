import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// Repository for workout-related database operations.
class WorkoutRepository {
  final SupabaseClient _client;

  WorkoutRepository(this._client);

  /// Fetch all workouts for the current user.
  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('workouts')
        .select('''
          *,
          workout_exercises(
            *,
            exercise:exercises(id, name, slug, category, thumbnail_url)
          )
        ''')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Create a new workout.
  Future<Map<String, dynamic>> createWorkout({
    required String name,
    String? description,
    String? type,
    String? difficulty,
    int? estimatedDurationMin,
    bool isAiGenerated = false,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('workouts')
        .insert({
          'user_id': userId,
          'name': name,
          'description': description,
          'type': type,
          'difficulty': difficulty,
          'estimated_duration_min': estimatedDurationMin,
          'is_ai_generated': isAiGenerated,
        })
        .select()
        .single();

    return response;
  }

  /// Add exercises to a workout.
  Future<void> addExercisesToWorkout(
    String workoutId,
    List<Map<String, dynamic>> exercises,
  ) async {
    final rows = exercises.asMap().entries.map((entry) => {
          'workout_id': workoutId,
          'exercise_id': entry.value['exercise_id'],
          'sort_order': entry.key,
          'sets': entry.value['sets'] ?? 3,
          'reps': entry.value['reps'] ?? 10,
          'rest_seconds': entry.value['rest_seconds'] ?? 60,
          'notes': entry.value['notes'],
        }).toList();

    await _client.from('workout_exercises').insert(rows);
  }

  /// Delete a workout.
  Future<void> deleteWorkout(String workoutId) async {
    await _client.from('workouts').delete().eq('id', workoutId);
  }

  /// Start a new workout session.
  Future<Map<String, dynamic>> startSession(String? workoutId) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('workout_sessions')
        .insert({
          'user_id': userId,
          'workout_id': workoutId,
          'started_at': DateTime.now().toIso8601String(),
          'status': 'in_progress',
        })
        .select()
        .single();

    return response;
  }

  /// Complete a workout session.
  Future<void> completeSession(String sessionId) async {
    final now = DateTime.now();
    final session = await _client
        .from('workout_sessions')
        .select('started_at')
        .eq('id', sessionId)
        .single();

    final startedAt = DateTime.parse(session['started_at']);
    final durationSeconds = now.difference(startedAt).inSeconds;

    await _client.from('workout_sessions').update({
      'completed_at': now.toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': 'completed',
    }).eq('id', sessionId);
  }

  /// Log a set during a workout session.
  Future<Map<String, dynamic>> logSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    double? weightKg,
    int? repsCompleted,
    int? durationSeconds,
    bool isWarmup = false,
    String? notes,
  }) async {
    final response = await _client
        .from('workout_sets')
        .insert({
          'session_id': sessionId,
          'exercise_id': exerciseId,
          'set_number': setNumber,
          'weight_kg': weightKg,
          'reps_completed': repsCompleted,
          'duration_seconds': durationSeconds,
          'is_warmup': isWarmup,
          'notes': notes,
        })
        .select()
        .single();

    return response;
  }

  /// Get recent sessions with sets.
  Future<List<Map<String, dynamic>>> getRecentSessions({int limit = 10}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('workout_sessions')
        .select('''
          *,
          workout:workouts(id, name),
          workout_sets(
            *,
            exercise:exercises(id, name, slug)
          )
        ''')
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get total workout count for a user.
  Future<int> getWorkoutCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('workout_sessions')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'completed');

    return (response as List).length;
  }

  /// Get total volume (kg) for a user.
  Future<double> getTotalVolume() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('workout_sets')
        .select('weight_kg, reps_completed, session:workout_sessions!inner(user_id)')
        .eq('session.user_id', userId);

    double total = 0;
    for (final row in response) {
      final weight = (row['weight_kg'] ?? 0) as num;
      final reps = (row['reps_completed'] ?? 0) as num;
      total += weight * reps;
    }
    return total;
  }
}

/// Provider for WorkoutRepository.
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WorkoutRepository(client);
});
