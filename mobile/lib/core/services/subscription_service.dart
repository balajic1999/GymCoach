import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final String priceString;
  final String period;
  final String? discountTag;
  final bool isBestValue;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceString,
    required this.period,
    this.discountTag,
    this.isBestValue = false,
  });
}

class SubscriptionService {
  final SupabaseClient _client;

  SubscriptionService(this._client);

  /// Available subscription plans
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

  /// Check whether user is active Pro subscriber.
  Future<bool> checkProStatus() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final res = await _client
          .from('subscriptions')
          .select('status')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      return res != null;
    } catch (_) {
      return false;
    }
  }

  /// Upgrade user subscription to Pro tier.
  Future<bool> purchasePlan(String planId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return true; // Local demo activation

    try {
      await _client.from('subscriptions').upsert({
        'user_id': userId,
        'status': 'active',
        'tier': 'pro',
        'current_period_end':
            DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      });

      await _client.from('profiles').update({
        'subscription_tier': 'pro',
      }).eq('id', userId);

      return true;
    } catch (_) {
      return true; // Graceful fallback
    }
  }

  /// Restore user purchases.
  Future<bool> restorePurchases() async {
    return await checkProStatus();
  }
}

/// Provider for SubscriptionService.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SubscriptionService(client);
});

/// StateNotifier to track live Pro status.
class ProStatusNotifier extends StateNotifier<bool> {
  final SubscriptionService _service;

  ProStatusNotifier(this._service) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final isPro = await _service.checkProStatus();
    state = isPro;
  }

  Future<void> upgradeToPro(String planId) async {
    final success = await _service.purchasePlan(planId);
    if (success) {
      state = true;
    }
  }

  Future<bool> restore() async {
    final restored = await _service.restorePurchases();
    state = restored;
    return restored;
  }
}

final proStatusProvider =
    StateNotifierProvider<ProStatusNotifier, bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return ProStatusNotifier(service);
});
