import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/exercise.dart';

/// Overlay widget displaying target muscle groups and intensity levels.
class MuscleEngagementOverlay extends StatelessWidget {
  final List<ExerciseMuscle> muscles;
  final VoidCallback? onClose;

  const MuscleEngagementOverlay({
    super.key,
    required this.muscles,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (muscles.isEmpty) return const SizedBox.shrink();

    final primaryMuscles =
        muscles.where((m) => m.role.toLowerCase() == 'primary').toList();
    final secondaryMuscles =
        muscles.where((m) => m.role.toLowerCase() == 'secondary').toList();

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Muscle Activation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Primary Muscles
          if (primaryMuscles.isNotEmpty) ...[
            Text(
              'PRIMARY (100% ACTIVATION)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: primaryMuscles.map((em) {
                final name = em.muscle?.name ?? 'Muscle';
                return _MuscleBadge(
                  name: name,
                  color: AppColors.error,
                  isPrimary: true,
                );
              }).toList(),
            ),
          ],

          // Secondary Muscles
          if (secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'SECONDARY (SUPPORTING)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: secondaryMuscles.map((em) {
                final name = em.muscle?.name ?? 'Muscle';
                return _MuscleBadge(
                  name: name,
                  color: AppColors.warning,
                  isPrimary: false,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MuscleBadge extends StatelessWidget {
  final String name;
  final Color color;
  final bool isPrimary;

  const _MuscleBadge({
    required this.name,
    required this.color,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPrimary ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isPrimary ? 0.4 : 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrimary ? Icons.local_fire_department_rounded : Icons.offline_bolt_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
