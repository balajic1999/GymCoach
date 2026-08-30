import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../providers/profile_providers.dart';

class PaywallSheet extends ConsumerStatefulWidget {
  const PaywallSheet({super.key});

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  String _selectedPlanId = 'gym3d_pro_annual';
  bool _isProcessing = false;

  static const _proBenefits = [
    {
      'icon': Icons.view_in_ar_rounded,
      'title': 'All 3D Exercises & Angles',
      'desc': 'Unlock full library with 360° rotation & slow-mo',
    },
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'AI Coach & Workout Generator',
      'desc': 'Personalized routines & 50 daily coaching queries',
    },
    {
      'icon': Icons.insights_rounded,
      'title': 'Advanced Analytics & PRs',
      'desc': 'Volume progression charts and personal records',
    },
    {
      'icon': Icons.cloud_download_outlined,
      'title': 'Offline 3D Model Access',
      'desc': 'Train anywhere without an internet connection',
    },
  ];

  Future<void> _handleSubscribe() async {
    setState(() => _isProcessing = true);

    try {
      await ref
          .read(proStatusProvider.notifier)
          .upgradeToPro(_selectedPlanId);

      // Invalidate profile to update UI across the app
      ref.invalidate(profileProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to Gym3D Pro! All features unlocked.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    try {
      final restored =
          await ref.read(proStatusProvider.notifier).restore();
      if (mounted) {
        if (restored) {
          ref.invalidate(profileProvider);
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active subscriptions found to restore.'),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subService = ref.watch(subscriptionServiceProvider);
    final plans = subService.getPlans();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle & close
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondaryDark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                // Header badge & title
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Unlock Gym3D Pro',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Supercharge your training with interactive 3D science',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                ),
                const SizedBox(height: 24),

                // Benefits List
                ..._proBenefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              b['icon'] as IconData,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Text(
                                  b['desc'] as String,
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
                    )),

                const SizedBox(height: 20),

                // Plan Cards
                ...plans.map((plan) {
                  final isSelected = _selectedPlanId == plan.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlanId = plan.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surfaceElevatedDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderDark,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiaryDark,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      plan.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    if (plan.discountTag != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.gradientAccent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          plan.discountTag!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  plan.period,
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
                          Text(
                            plan.priceString,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimaryDark,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // CTA Button
                GradientButton(
                  label: _isProcessing
                      ? 'Processing...'
                      : 'Start 7-Day Free Trial',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _isProcessing ? null : _handleSubscribe,
                ),
                const SizedBox(height: 12),

                // Restore & Terms
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isProcessing ? null : _handleRestore,
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                    const Text('•',
                        style: TextStyle(color: AppColors.textTertiaryDark)),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Terms & Privacy',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
