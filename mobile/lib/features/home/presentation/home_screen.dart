import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../exercises/data/models/exercise.dart';
import '../../exercises/presentation/providers/exercise_providers.dart';
import '../../workout/presentation/providers/workout_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularExercises = ref.watch(
      exerciseListProvider(const ExerciseFilterParams()),
    );
    final workoutCount = ref.watch(workoutCountProvider);
    final streak = ref.watch(workoutStreakProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back 👋',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to train?',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                    // AI Coach shortcut
                    GestureDetector(
                      onTap: () => context.push('/ai-coach'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Start Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  onTap: () => context.go('/workouts'),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'QUICK START',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start Your\nWorkout',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose from your saved workouts or let AI create one for you',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Stats Row — wired to providers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Workouts',
                        value: workoutCount.when(
                          data: (v) => '$v',
                          loading: () => '–',
                          error: (error, stackTrace) => '0',
                        ),
                        icon: Icons.fitness_center_rounded,
                        iconColor: AppColors.accent,
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
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Popular Exercises — wired to provider
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Popular Exercises',
                actionLabel: 'See All',
                onAction: () => context.go('/exercises'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: popularExercises.when(
                  loading: () => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, _) =>
                        const ShimmerBox(width: 162, height: 180),
                  ),
                  error: (error, stackTrace) => const Center(
                    child: Text('Could not load exercises'),
                  ),
                  data: (exercises) {
                    // Show first 8 or all if fewer
                    final displayList = exercises.take(8).toList();
                    if (displayList.isEmpty) {
                      return Center(
                        child: Text(
                          'No exercises available',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppColors.textTertiaryDark),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayList.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final exercise = displayList[index];
                        return _PopularExerciseCard(exercise: exercise);
                      },
                    );
                  },
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // AI Coach Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  onTap: () => context.push('/ai-coach'),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Coach',
                              style:
                                  Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ask me anything about exercises, form, or training',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textTertiaryDark,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Card for the horizontal popular exercises carousel.
class _PopularExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _PopularExerciseCard({required this.exercise});

  Color get _categoryColor {
    return switch (exercise.category.toLowerCase()) {
      'chest' => AppColors.muscleChest,
      'back' => AppColors.muscleBack,
      'legs' => AppColors.muscleLegs,
      'shoulders' => AppColors.muscleShoulders,
      'arms' => AppColors.muscleArms,
      'core' => AppColors.muscleCore,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/exercises/${exercise.slug}'),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.fitness_center_rounded,
                  color: _categoryColor, size: 22),
            ),
            const Spacer(),
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${exercise.category[0].toUpperCase()}${exercise.category.substring(1)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: _categoryColor),
            ),
          ],
        ),
      ),
    );
  }
}
