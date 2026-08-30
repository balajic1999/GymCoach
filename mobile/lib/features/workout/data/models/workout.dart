import 'package:equatable/equatable.dart';

/// Workout template model.
class Workout extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? type;
  final String? difficulty;
  final int? estimatedDurationMin;
  final bool isAiGenerated;
  final List<WorkoutExercise> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.type,
    this.difficulty,
    this.estimatedDurationMin,
    this.isAiGenerated = false,
    this.exercises = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      difficulty: json['difficulty'] as String?,
      estimatedDurationMin: json['estimated_duration_min'] as int?,
      isAiGenerated: (json['is_ai_generated'] as bool?) ?? false,
      exercises: (json['workout_exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id];
}

/// Exercise within a workout template.
class WorkoutExercise extends Equatable {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int sortOrder;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.sortOrder,
    this.sets = 3,
    this.reps = 10,
    this.restSeconds = 60,
    this.notes,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      exerciseId: json['exercise_id'] as String,
      sortOrder: json['sort_order'] as int,
      sets: (json['sets'] as int?) ?? 3,
      reps: (json['reps'] as int?) ?? 10,
      restSeconds: (json['rest_seconds'] as int?) ?? 60,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}

/// A completed or in-progress workout session.
class WorkoutSession extends Equatable {
  final String id;
  final String userId;
  final String? workoutId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final String status;
  final String? notes;
  final List<WorkoutSet> sets;

  const WorkoutSession({
    required this.id,
    required this.userId,
    this.workoutId,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.status = 'in_progress',
    this.notes,
    this.sets = const [],
  });

  bool get isCompleted => status == 'completed';

  Duration? get duration => durationSeconds != null
      ? Duration(seconds: durationSeconds!)
      : null;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      status: (json['status'] as String?) ?? 'in_progress',
      notes: json['notes'] as String?,
      sets: (json['workout_sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id];
}

/// A single set performed during a workout session.
class WorkoutSet extends Equatable {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final double? weightKg;
  final int? repsCompleted;
  final int? durationSeconds;
  final bool isWarmup;
  final String? notes;
  final DateTime? completedAt;

  const WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    this.weightKg,
    this.repsCompleted,
    this.durationSeconds,
    this.isWarmup = false,
    this.notes,
    this.completedAt,
  });

  /// Total volume for this set (weight × reps).
  double get volume => (weightKg ?? 0) * (repsCompleted ?? 0);

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      exerciseId: json['exercise_id'] as String,
      setNumber: json['set_number'] as int,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      repsCompleted: json['reps_completed'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      isWarmup: (json['is_warmup'] as bool?) ?? false,
      notes: json['notes'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id];
}
