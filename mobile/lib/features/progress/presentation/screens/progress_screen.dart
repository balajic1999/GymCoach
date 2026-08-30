import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../workout/presentation/providers/workout_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWorkouts = ref.watch(workoutCountProvider);
    final weeklyCount = ref.watch(weeklyWorkoutCountProvider);
    final totalVolume = ref.watch(totalVolumeProvider);
    final streak = ref.watch(workoutStreakProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Progress',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Stats overview — wired to providers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Workouts',
                        value: totalWorkouts.when(
                          data: (v) => '$v',
                          loading: () => '–',
                          error: (error, stackTrace) => '0',
                        ),
                        icon: Icons.fitness_center_rounded,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'This Week',
                        value: weeklyCount.when(
                          data: (v) => '$v',
                          loading: () => '–',
                          error: (error, stackTrace) => '0',
                        ),
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Volume',
                        value: totalVolume.when(
                          data: (v) => _formatVolume(v),
                          loading: () => '–',
                          error: (error, stackTrace) => '0 kg',
                        ),
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Streak',
                        value: streak.when(
                          data: (v) => '$v day${v != 1 ? 's' : ''}',
                          loading: () => '–',
                          error: (error, stackTrace) => '0 days',
                        ),
                        icon: Icons.local_fire_department_rounded,
                        iconColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Workout chart placeholder
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Workout Frequency',
                              style:
                                  Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Chart placeholder — will use fl_chart in Phase 8
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighDark
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.insert_chart_outlined_rounded,
                                size: 48,
                                color: AppColors.textTertiaryDark,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Charts will appear after\nyou complete workouts',
                                textAlign: TextAlign.center,
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
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Personal Records
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Personal Records'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          size: 48,
                          color: AppColors.textTertiaryDark,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No records yet',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your personal bests will show up here',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiaryDark,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Formats volume for display (e.g., 12345 → "12,345 kg").
String _formatVolume(double volume) {
  if (volume >= 1000) {
    final thousands = (volume / 1000).toStringAsFixed(1);
    return '${thousands}k kg';
  }
  return '${volume.toStringAsFixed(0)} kg';
}
