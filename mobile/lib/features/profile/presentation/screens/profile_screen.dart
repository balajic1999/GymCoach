import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/auth/auth_service.dart';
import '../providers/profile_providers.dart';
import '../widgets/paywall_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    // Extract display values from profile
    final displayName = profileAsync.when(
      data: (p) => p?.fullName ?? 'Gym3D User',
      loading: () => 'Loading...',
      error: (error, stackTrace) => 'Gym3D User',
    );
    final subscriptionTier = profileAsync.when(
      data: (p) => p?.subscriptionTier ?? 'free',
      loading: () => 'free',
      error: (error, stackTrace) => 'free',
    );
    final isPro = subscriptionTier == 'pro';

    final fitnessGoal = profileAsync.when(
      data: (p) => p?.fitnessGoal ?? 'Not set',
      loading: () => '–',
      error: (error, stackTrace) => 'Not set',
    );
    final experienceLevel = profileAsync.when(
      data: (p) => p?.experienceLevel ?? 'Not set',
      loading: () => '–',
      error: (error, stackTrace) => 'Not set',
    );
    final equipment = profileAsync.when(
      data: (p) =>
          p != null && p.availableEquipment.isNotEmpty
              ? p.availableEquipment.join(', ')
              : 'Not set',
      loading: () => '–',
      error: (error, stackTrace) => 'Not set',
    );
    final workoutFrequency = profileAsync.when(
      data: (p) =>
          p?.workoutFrequency != null ? '${p!.workoutFrequency}x/week' : 'Not set',
      loading: () => '–',
      error: (error, stackTrace) => 'Not set',
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Profile card — wired to provider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPro
                                    ? AppColors.primary
                                        .withValues(alpha: 0.15)
                                    : AppColors.surfaceHighDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPro ? 'Pro Plan' : 'Free Plan',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isPro
                                          ? AppColors.primary
                                          : AppColors.textSecondaryDark,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () {},
                        color: AppColors.textSecondaryDark,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Upgrade banner — only show for free users
            if (!isPro)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => const PaywallSheet(),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Colors.white,
                                  size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upgrade to Pro',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Unlock all exercises, AI coach, and more',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Fitness Profile — wired to provider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FITNESS PROFILE',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppColors.textTertiaryDark,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsItem(
                              icon: Icons.flag_outlined,
                              title: 'Fitness Goal',
                              value: _capitalizeFirst(fitnessGoal)),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.signal_cellular_alt_rounded,
                              title: 'Experience Level',
                              value: _capitalizeFirst(experienceLevel)),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.fitness_center_outlined,
                              title: 'Equipment',
                              value: equipment),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.schedule_outlined,
                              title: 'Workout Frequency',
                              value: workoutFrequency),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // App Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APP SETTINGS',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppColors.textTertiaryDark,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsItem(
                              icon: Icons.dark_mode_outlined,
                              title: 'Theme',
                              value: 'Dark'),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              value: 'On'),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.language_outlined,
                              title: 'Language',
                              value: 'English'),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.straighten_outlined,
                              title: 'Units',
                              value: 'Metric'),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Support
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUPPORT',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppColors.textTertiaryDark,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsItem(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy'),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.description_outlined,
                              title: 'Terms of Service'),
                          const _SettingsDivider(),
                          _SettingsItem(
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support'),
                          const _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.logout_rounded,
                            title: 'Sign Out',
                            titleColor: AppColors.error,
                            onTap: () async {
                              final authService =
                                  ref.read(authServiceProvider);
                              try {
                                await authService.signOut();
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Not currently signed in')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'Gym3D v0.1.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

String _capitalizeFirst(String s) {
  if (s.isEmpty || s == 'Not set') return s;
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.value,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 22,
                  color:
                      titleColor ?? AppColors.textSecondaryDark),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: titleColor),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 52),
      child: Divider(height: 0.5, thickness: 0.5),
    );
  }
}
