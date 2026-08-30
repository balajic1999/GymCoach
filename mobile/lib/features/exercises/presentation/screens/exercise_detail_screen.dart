import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/exercise_providers.dart';
import '../widgets/exercise_3d_viewer.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  bool _isPlaying = true;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    final exerciseAsync = ref.watch(exerciseDetailProvider(widget.exerciseId));
    final favorites = ref.watch(favoritesProvider);

    return exerciseAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.textTertiaryDark),
              const SizedBox(height: 16),
              Text('Could not load exercise',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      )),
            ],
          ),
        ),
      ),
      data: (exercise) {
        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: AppColors.textTertiaryDark),
                  const SizedBox(height: 16),
                  Text('Exercise not found',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textSecondaryDark,
                              )),
                ],
              ),
            ),
          );
        }

        final isFavorited = favorites.contains(exercise.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 3D Model Viewer in SliverAppBar
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.surfaceDark,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderDark,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        isFavorited
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 20,
                        color: isFavorited ? AppColors.error : null,
                      ),
                    ),
                    onPressed: () =>
                        ref.read(favoritesProvider.notifier).toggle(exercise.id),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Exercise3DViewer(
                    modelSrc: exercise.animationAssetUrl ??
                        exercise.characterAssetUrl,
                    exerciseName: exercise.name,
                    category: exercise.category,
                    muscles: exercise.muscles,
                    height: 380,
                    isPlaying: _isPlaying,
                    playbackSpeed: _playbackSpeed,
                    onPlayPauseToggle: () =>
                        setState(() => _isPlaying = !_isPlaying),
                    onSpeedChanged: (speed) =>
                        setState(() => _playbackSpeed = speed),
                  ),
                ),
              ),

              // Playback Controls Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderDark,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Replay / Reset
                      IconButton(
                        icon: const Icon(Icons.replay_rounded),
                        tooltip: 'Reset Animation',
                        onPressed: () {
                          setState(() {
                            _isPlaying = true;
                          });
                        },
                        color: AppColors.textSecondaryDark,
                      ),

                      // Central Play/Pause Button
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isPlaying = !_isPlaying),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      // Speed Selector
                      PopupMenuButton<double>(
                        tooltip: 'Playback Speed',
                        icon: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.borderDark,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.speed_rounded,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_playbackSpeed}x',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        onSelected: (speed) =>
                            setState(() => _playbackSpeed = speed),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 0.25, child: Text('0.25x Slow')),
                          PopupMenuItem(value: 0.5, child: Text('0.5x Half')),
                          PopupMenuItem(value: 1.0, child: Text('1.0x Normal')),
                          PopupMenuItem(value: 1.5, child: Text('1.5x Fast')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Exercise Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _DetailTag(
                            label: _capitalizeFirst(exercise.difficulty),
                            icon: Icons.signal_cellular_alt_rounded,
                            color: _difficultyColor(exercise.difficulty),
                          ),
                          ...exercise.equipment.map((eq) => _DetailTag(
                                label: eq.equipment?.name ?? 'Equipment',
                                icon: Icons.fitness_center_rounded,
                                color: AppColors.accent,
                              )),
                          _DetailTag(
                            label:
                                '${exercise.defaultSets} × ${exercise.defaultReps}',
                            icon: Icons.repeat_rounded,
                            color: AppColors.primary,
                          ),
                          _DetailTag(
                            label: '${exercise.defaultRestSeconds}s rest',
                            icon: Icons.timer_rounded,
                            color: AppColors.textSecondaryDark,
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    ],
                  ),
                ),
              ),

              // Description
              if (exercise.description != null &&
                  exercise.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'About',
                    icon: Icons.info_outline_rounded,
                    child: Text(
                      exercise.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ),

              // Target Muscles
              if (exercise.muscles.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Target Muscles',
                    icon: Icons.accessibility_new_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercise.muscles
                          .map((em) => _MuscleRow(
                                name: em.muscle?.name ?? 'Unknown',
                                role: _capitalizeFirst(em.role),
                                color: _muscleColor(
                                    em.muscle?.bodyRegion ?? 'upper'),
                              ))
                          .toList(),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                ),

              // Instructions
              if (exercise.instructions.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Instructions',
                    icon: Icons.list_alt_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercise.instructions
                          .asMap()
                          .entries
                          .map((e) => _InstructionStep(
                                number: e.key + 1,
                                text: e.value,
                              ))
                          .toList(),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ),

              // Breathing
              if (exercise.breathing != null &&
                  exercise.breathing!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Breathing',
                    icon: Icons.air_rounded,
                    child: Text(
                      exercise.breathing!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                ),

              // Common Mistakes
              if (exercise.commonMistakes.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Common Mistakes',
                    icon: Icons.warning_amber_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercise.commonMistakes
                          .map((m) => _MistakeItem(text: m))
                          .toList(),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                ),

              // Safety Notes
              if (exercise.safetyNotes.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Safety Notes',
                    icon: Icons.health_and_safety_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercise.safetyNotes
                          .map((s) => _SafetyItem(text: s))
                          .toList(),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                ),

              // Add to Workout button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GradientButton(
                    label: 'Add to Workout',
                    icon: Icons.add_rounded,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Workout system coming in Phase 6')),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

String _capitalizeFirst(String s) {
  if (s.isEmpty) return s;
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

Color _difficultyColor(String difficulty) {
  return switch (difficulty.toLowerCase()) {
    'beginner' => AppColors.success,
    'intermediate' => AppColors.warning,
    'advanced' => AppColors.error,
    _ => AppColors.textSecondaryDark,
  };
}

Color _muscleColor(String bodyRegion) {
  return switch (bodyRegion.toLowerCase()) {
    'upper' => AppColors.muscleChest,
    'core' => AppColors.muscleCore,
    'lower' => AppColors.muscleLegs,
    _ => AppColors.primary,
  };
}

// ── Widgets ─────────────────────────────────────────────────────────────

class _DetailTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _DetailTag(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  final String name;
  final String role;
  final Color color;

  const _MuscleRow(
      {required this.name, required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(name, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: role == 'Primary'
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceHighDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: role == 'Primary'
                        ? AppColors.primary
                        : AppColors.textSecondaryDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeItem extends StatelessWidget {
  final String text;

  const _MistakeItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyItem extends StatelessWidget {
  final String text;

  const _SafetyItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined,
              size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
