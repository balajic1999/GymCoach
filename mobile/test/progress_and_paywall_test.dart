import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym3d/core/services/subscription_service.dart';
import 'package:gym3d/features/profile/presentation/widgets/paywall_sheet.dart';
import 'package:gym3d/features/progress/presentation/screens/progress_screen.dart';
import 'package:gym3d/features/workout/presentation/providers/workout_providers.dart';

class _FakeSubscriptionService implements SubscriptionService {
  @override
  List<SubscriptionPlan> getPlans() {
    return const [
      SubscriptionPlan(
        id: 'gym3d_pro_annual',
        title: 'Annual Plan',
        priceString: '\$79.99 / year',
        period: '\$6.67 / month',
        discountTag: 'SAVE 33%',
        isBestValue: true,
      ),
      SubscriptionPlan(
        id: 'gym3d_pro_monthly',
        title: 'Monthly Plan',
        priceString: '\$9.99 / month',
        period: '\$9.99 / month',
        discountTag: null,
        isBestValue: false,
      ),
    ];
  }

  @override
  Future<bool> checkProStatus() async => false;

  @override
  Future<bool> purchasePlan(String planId) async => true;

  @override
  Future<bool> restorePurchases() async => true;
}

void main() {
  group('Progress Analytics and Paywall Tests', () {
    testWidgets('ProgressScreen renders stats, chart toggles, and charts',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutCountProvider.overrideWith((ref) => 12),
            weeklyWorkoutCountProvider.overrideWith((ref) => 3),
            totalVolumeProvider.overrideWith((ref) => 18500.0),
            workoutStreakProvider.overrideWith((ref) => 5),
          ],
          child: const MaterialApp(
            home: ProgressScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Total Workouts'), findsOneWidget);
      expect(find.text('Total Volume'), findsOneWidget);
      expect(find.text('Volume Progression'), findsOneWidget);
      expect(find.text('Personal Records (PRs)'), findsOneWidget);
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Recent Sessions'), findsOneWidget);

      // Tap 'Days' tab to toggle to bar chart
      await tester.tap(find.text('Days'));
      await tester.pumpAndSettle();
      expect(find.text('Weekly Frequency'), findsOneWidget);
    });

    testWidgets('PaywallSheet renders Pro benefits, Annual/Monthly plans, and trial CTA',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionServiceProvider
                .overrideWithValue(_FakeSubscriptionService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PaywallSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlock Gym3D Pro'), findsOneWidget);
      expect(find.text('All 3D Exercises & Angles'), findsOneWidget);
      expect(find.text('Annual Plan'), findsOneWidget);
      expect(find.text('Monthly Plan'), findsOneWidget);
      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
    });
  });
}
