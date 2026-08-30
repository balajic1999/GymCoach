import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';

/// Provides the list of user's workouts.
final workoutListProvider = FutureProvider<List<Workout>>((ref) async {
  try {
    final repo = ref.watch(workoutRepositoryProvider);
    final data = await repo.getWorkouts();
    return data.map((json) => Workout.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

/// Provides the total completed workout count.
final workoutCountProvider = FutureProvider<int>((ref) async {
  try {
    final repo = ref.watch(workoutRepositoryProvider);
    return await repo.getWorkoutCount();
  } catch (_) {
    return 0;
  }
});

/// Provides the total volume lifted (kg).
final totalVolumeProvider = FutureProvider<double>((ref) async {
  try {
    final repo = ref.watch(workoutRepositoryProvider);
    return await repo.getTotalVolume();
  } catch (_) {
    return 0;
  }
});

/// Provides recent completed sessions.
final recentSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  try {
    final repo = ref.watch(workoutRepositoryProvider);
    final data = await repo.getRecentSessions(limit: 20);
    return data.map((json) => WorkoutSession.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

/// Calculates the current workout streak (consecutive days).
final workoutStreakProvider = FutureProvider<int>((ref) async {
  try {
    final sessions = await ref.watch(recentSessionsProvider.future);
    if (sessions.isEmpty) return 0;

    // Build a set of dates when workouts were completed
    final workoutDates = <DateTime>{};
    for (final session in sessions) {
      if (session.completedAt != null) {
        final date = DateTime(
          session.completedAt!.year,
          session.completedAt!.month,
          session.completedAt!.day,
        );
        workoutDates.add(date);
      }
    }

    if (workoutDates.isEmpty) return 0;

    // Count consecutive days from today backwards
    int streak = 0;
    var checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    // If no workout today, start from yesterday
    if (!workoutDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (workoutDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  } catch (_) {
    return 0;
  }
});

/// Provides the number of workouts completed this week.
final weeklyWorkoutCountProvider = FutureProvider<int>((ref) async {
  try {
    final sessions = await ref.watch(recentSessionsProvider.future);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return sessions.where((s) {
      return s.completedAt != null && s.completedAt!.isAfter(weekStart);
    }).length;
  } catch (_) {
    return 0;
  }
});
