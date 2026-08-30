import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../../data/repositories/workout_repository.dart';
import '../providers/workout_providers.dart';

class _ActiveSetState {
  final int setNumber;
  double weightKg;
  int reps;
  bool isCompleted = false;

  _ActiveSetState({
    required this.setNumber,
    this.weightKg = 0.0,
    this.reps = 10,
  });
}

class _ActiveExerciseState {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final int restSeconds;
  final List<_ActiveSetState> sets;

  _ActiveExerciseState({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    this.restSeconds = 60,
    required this.sets,
  });
}

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String? workoutId;
  final String workoutTitle;

  const ActiveWorkoutScreen({
    super.key,
    this.workoutId,
    this.workoutTitle = 'Workout Session',
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _stopwatchTimer;
  int _elapsedSeconds = 0;
  String? _sessionId;
  bool _isLoading = true;

  int _currentExerciseIndex = 0;
  List<_ActiveExerciseState> _exercises = [];

  // Rest Timer State
  Timer? _restCountdownTimer;
  int _restRemainingSeconds = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _startStopwatch();
    _initializeSession();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _restCountdownTimer?.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  Future<void> _initializeSession() async {
    try {
      final repo = ref.read(workoutRepositoryProvider);
      final sessionData = await repo.startSession(widget.workoutId);
      _sessionId = sessionData['id'] as String;

      // Load exercises for workout or fallback to default exercises
      if (widget.workoutId != null) {
        final workouts = await repo.getWorkouts();
        final workout = workouts.firstWhere(
          (w) => w['id'] == widget.workoutId,
          orElse: () => <String, dynamic>{},
        );

        final rawExercises = workout['workout_exercises'] as List<dynamic>?;
        if (rawExercises != null && rawExercises.isNotEmpty) {
          _exercises = rawExercises.map((re) {
            final ex = re['exercise'] as Map<String, dynamic>?;
            final setsCount = (re['sets'] as int?) ?? 3;
            final targetReps = (re['reps'] as int?) ?? 10;
            final rest = (re['rest_seconds'] as int?) ?? 60;

            return _ActiveExerciseState(
              exerciseId: re['exercise_id'] as String,
              exerciseName: ex?['name'] as String? ?? 'Exercise',
              category: ex?['category'] as String? ?? 'chest',
              restSeconds: rest,
              sets: List.generate(
                setsCount,
                (i) => _ActiveSetState(setNumber: i + 1, reps: targetReps),
              ),
            );
          }).toList();
        }
      }

      // Default Quick Start exercises if list is empty
      if (_exercises.isEmpty) {
        final exerciseList =
            await ref.read(exerciseListProvider(const ExerciseFilterParams()).future);
        final defaultPicks = exerciseList.take(3).toList();

        _exercises = defaultPicks.map((ex) {
          return _ActiveExerciseState(
            exerciseId: ex.id,
            exerciseName: ex.name,
            category: ex.category,
            restSeconds: ex.defaultRestSeconds,
            sets: List.generate(
              ex.defaultSets,
              (i) => _ActiveSetState(
                  setNumber: i + 1, reps: ex.defaultReps, weightKg: 20.0),
            ),
          );
        }).toList();
      }
    } catch (_) {
      // Offline fallback state
      _exercises = [
        _ActiveExerciseState(
          exerciseId: 'demo-1',
          exerciseName: 'Barbell Squat',
          category: 'legs',
          restSeconds: 90,
          sets: List.generate(
            3,
            (i) => _ActiveSetState(
                setNumber: i + 1, reps: 10, weightKg: 60.0),
          ),
        ),
      ];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startRestTimer(int seconds) {
    _restCountdownTimer?.cancel();
    setState(() {
      _isResting = true;
      _restRemainingSeconds = seconds;
    });

    _restCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restRemainingSeconds > 0) {
        setState(() => _restRemainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _isResting = false);
      }
    });
  }

  void _addRestSeconds(int extra) {
    setState(() => _restRemainingSeconds += extra);
  }

  void _skipRest() {
    _restCountdownTimer?.cancel();
    setState(() => _isResting = false);
  }

  Future<void> _logSetComplete(_ActiveExerciseState exercise, _ActiveSetState set) async {
    setState(() {
      set.isCompleted = true;
    });

    // Start rest timer
    _startRestTimer(exercise.restSeconds);

    // Persist set to Supabase if session active
    if (_sessionId != null) {
      try {
        final repo = ref.read(workoutRepositoryProvider);
        await repo.logSet(
          sessionId: _sessionId!,
          exerciseId: exercise.exerciseId,
          setNumber: set.setNumber,
          weightKg: set.weightKg,
          repsCompleted: set.reps,
        );
      } catch (_) {}
    }
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _finishWorkout() async {
    final totalSets = _exercises.fold<int>(
        0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
    final totalVol = _exercises.fold<double>(
      0,
      (sum, ex) =>
          sum +
          ex.sets
              .where((s) => s.isCompleted)
              .fold<double>(0, (sVol, s) => sVol + (s.weightKg * s.reps)),
    );

    if (_sessionId != null) {
      try {
        final repo = ref.read(workoutRepositoryProvider);
        await repo.completeSession(_sessionId!);
      } catch (_) {}
    }

    // Refresh providers
    ref.invalidate(workoutCountProvider);
    ref.invalidate(totalVolumeProvider);
    ref.invalidate(workoutStreakProvider);
    ref.invalidate(weeklyWorkoutCountProvider);
    ref.invalidate(recentSessionsProvider);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _WorkoutSummaryDialog(
          duration: _formatTime(_elapsedSeconds),
          totalVolume: totalVol,
          totalSets: totalSets,
          onClose: () {
            Navigator.of(ctx).pop();
            context.pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentExercise = _exercises.isNotEmpty
        ? _exercises[_currentExerciseIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.workoutTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_elapsedSeconds),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _finishWorkout,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Exercise switcher banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppColors.surfaceDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _currentExerciseIndex > 0
                        ? () => setState(() => _currentExerciseIndex--)
                        : null,
                  ),
                  Text(
                    'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: _currentExerciseIndex < _exercises.length - 1
                        ? () => setState(() => _currentExerciseIndex++)
                        : null,
                  ),
                ],
              ),
            ),

            if (currentExercise != null) ...[
              // Current Exercise Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentExercise.exerciseName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Target Rest: ${currentExercise.restSeconds}s',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textTertiaryDark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Set Logging Table
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Table Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 40,
                            child: Text('SET',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textTertiaryDark)),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text('KG',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textTertiaryDark)),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text('REPS',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textTertiaryDark)),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                            child: Center(
                              child: Text('DONE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textTertiaryDark)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Set Rows
                    ...currentExercise.sets.map((set) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              // Set Number
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '${set.setNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ),

                              // Weight Input
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: TextFormField(
                                    initialValue: set.weightKg > 0
                                        ? set.weightKg.toStringAsFixed(1)
                                        : '',
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 8),
                                    ),
                                    onChanged: (v) {
                                      set.weightKg =
                                          double.tryParse(v) ?? set.weightKg;
                                    },
                                  ),
                                ),
                              ),

                              // Reps Input
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: TextFormField(
                                    initialValue: '${set.reps}',
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 8),
                                    ),
                                    onChanged: (v) {
                                      set.reps = int.tryParse(v) ?? set.reps;
                                    },
                                  ),
                                ),
                              ),

                              // Checkmark Button
                              SizedBox(
                                width: 50,
                                child: IconButton(
                                  icon: Icon(
                                    set.isCompleted
                                        ? Icons.check_circle_rounded
                                        : Icons.check_circle_outline_rounded,
                                    color: set.isCompleted
                                        ? AppColors.success
                                        : AppColors.textTertiaryDark,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    if (!set.isCompleted) {
                                      _logSetComplete(currentExercise, set);
                                    } else {
                                      setState(() => set.isCompleted = false);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Add Set Button
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          currentExercise.sets.add(_ActiveSetState(
                            setNumber: currentExercise.sets.length + 1,
                            weightKg: currentExercise.sets.isNotEmpty
                                ? currentExercise.sets.last.weightKg
                                : 0.0,
                            reps: currentExercise.sets.isNotEmpty
                                ? currentExercise.sets.last.reps
                                : 10,
                          ));
                        });
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Set'),
                    ),
                  ],
                ),
              ),
            ],

            // Rest Timer Popup Overlay
            if (_isResting)
              Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REST TIMER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            _formatTime(_restRemainingSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _addRestSeconds(30),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      child: const Text('+30s',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded,
                          color: Colors.white),
                      tooltip: 'Skip Rest',
                      onPressed: _skipRest,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutSummaryDialog extends StatelessWidget {
  final String duration;
  final double totalVolume;
  final int totalSets;
  final VoidCallback onClose;

  const _WorkoutSummaryDialog({
    required this.duration,
    required this.totalVolume,
    required this.totalSets,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Workout Completed! 🎉',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job pushing your limits today.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Duration',
                  value: duration,
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Total Vol',
                  value: '${totalVolume.toStringAsFixed(0)} kg',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatCard(
            label: 'Sets Logged',
            value: '$totalSets sets',
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Back to Workouts',
            icon: Icons.arrow_forward_rounded,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
