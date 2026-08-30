import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../workout/presentation/providers/workout_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedChartIndex = 0; // 0 = Volume, 1 = Frequency

  @override
  Widget build(BuildContext context) {
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

            // Interactive Charts Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Toggle Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedChartIndex == 0
                                    ? Icons.show_chart_rounded
                                    : Icons.bar_chart_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedChartIndex == 0
                                    ? 'Volume Progression'
                                    : 'Weekly Frequency',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHighDark,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _chartTab(0, 'Volume'),
                                _chartTab(1, 'Days'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Chart Canvas
                      SizedBox(
                        height: 190,
                        child: _selectedChartIndex == 0
                            ? _buildVolumeLineChart()
                            : _buildFrequencyBarChart(),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Personal Records Section
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Personal Records (PRs)'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    Row(
                      children: [
                        Expanded(
                          child: _PersonalRecordCard(
                            exerciseName: 'Barbell Squat',
                            weightKg: '120 kg',
                            date: 'Aug 24',
                            icon: Icons.fitness_center_rounded,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _PersonalRecordCard(
                            exerciseName: 'Bench Press',
                            weightKg: '95 kg',
                            date: 'Aug 26',
                            icon: Icons.fitness_center_rounded,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PersonalRecordCard(
                            exerciseName: 'Deadlift',
                            weightKg: '155 kg',
                            date: 'Aug 28',
                            icon: Icons.fitness_center_rounded,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _PersonalRecordCard(
                            exerciseName: 'Shoulder Press',
                            weightKg: '62.5 kg',
                            date: 'Aug 19',
                            icon: Icons.fitness_center_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Recent Workout Log
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Recent Sessions'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    _CompletedSessionTile(
                      title: 'Chest & Triceps Power',
                      date: 'Today',
                      duration: '48m',
                      volume: '4,280 kg',
                      setsCount: 16,
                    ),
                    SizedBox(height: 10),
                    _CompletedSessionTile(
                      title: 'Heavy Back & Pull',
                      date: '2 days ago',
                      duration: '54m',
                      volume: '5,600 kg',
                      setsCount: 18,
                    ),
                    SizedBox(height: 10),
                    _CompletedSessionTile(
                      title: 'Leg Day Hypertrophy',
                      date: '4 days ago',
                      duration: '62m',
                      volume: '6,450 kg',
                      setsCount: 20,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _chartTab(int index, String label) {
    final isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeLineChart() {
    final spots = const [
      FlSpot(0, 2400),
      FlSpot(1, 3100),
      FlSpot(2, 2800),
      FlSpot(3, 4200),
      FlSpot(4, 3900),
      FlSpot(5, 5100),
      FlSpot(6, 5600),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1500,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.borderDark.withValues(alpha: 0.5),
            strokeWidth: 0.8,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2000,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  labels[idx],
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 1000,
        maxY: 6500,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.surfaceDark,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyBarChart() {
    final values = [1, 0, 1, 1, 0, 1, 0]; // Mon - Sun
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.5,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  days[idx],
                  style: TextStyle(
                    color: values[idx] > 0
                        ? AppColors.primary
                        : AppColors.textTertiaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(7, (i) {
          final isCompleted = values[i] > 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: isCompleted ? 1.0 : 0.15,
                gradient: isCompleted ? AppColors.gradientPrimary : null,
                color: isCompleted ? null : AppColors.surfaceHighDark,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PersonalRecordCard extends StatelessWidget {
  final String exerciseName;
  final String weightKg;
  final String date;
  final IconData icon;

  const _PersonalRecordCard({
    required this.exerciseName,
    required this.weightKg,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.warning,
                  size: 18,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weightKg,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            exerciseName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _CompletedSessionTile extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  final String volume;
  final int setsCount;

  const _CompletedSessionTile({
    required this.title,
    required this.date,
    required this.duration,
    required this.volume,
    required this.setsCount,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date • $duration • $setsCount sets',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryDark,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Text(
            volume,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatVolume(double volume) {
  if (volume >= 1000) {
    final thousands = (volume / 1000).toStringAsFixed(1);
    return '${thousands}k kg';
  }
  return '${volume.toStringAsFixed(0)} kg';
}
