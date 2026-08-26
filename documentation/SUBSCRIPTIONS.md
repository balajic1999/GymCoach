# Subscriptions

## Overview

Gym3D uses a freemium model with a Pro subscription tier. Subscriptions are managed by RevenueCat, which handles both Google Play Billing and Apple StoreKit.

## Tiers

### Free Tier

| Feature | Limit |
|---------|-------|
| Exercise library | 8 curated exercises |
| 3D viewer | Basic (play/pause/rotate) |
| Saved workouts | 2 maximum |
| AI Coach | 5 messages/day |
| Progress tracking | Basic history only |
| Offline downloads | ❌ |
| Muscle highlighting | ❌ |
| Custom workouts | ❌ |
| Slow motion playback | ❌ |

### Pro Tier

| Feature | Access |
|---------|--------|
| Exercise library | All exercises (20+ and growing) |
| 3D viewer | Full controls (slow-mo, zoom, angles) |
| Saved workouts | Unlimited |
| AI Coach | 50 messages/day |
| Progress tracking | Full charts, PRs, volume analysis |
| Offline downloads | ✅ |
| Muscle highlighting | ✅ |
| Custom workouts | ✅ |
| AI workout generation | ✅ |

## Pricing

| Plan | Price | Savings |
|------|-------|---------|
| Monthly | $9.99/month | — |
| Annual | $79.99/year | ~33% off |
| Free trial | 7 days | Pro features |

## Implementation — RevenueCat

### Flutter SDK

Package: `purchases_flutter`

```dart
// Initialize
await Purchases.configure(
  PurchasesConfiguration('revenuecat_api_key')
    ..appUserID = supabaseUserId,
);

// Check entitlements
final customerInfo = await Purchases.getCustomerInfo();
final isPro = customerInfo.entitlements.all['pro']?.isActive ?? false;

// Show paywall
final offerings = await Purchases.getOfferings();
final currentOffering = offerings.current;
```

### Entitlement Checking

```dart
class SubscriptionService {
  Future<bool> isPro();
  Future<List<Package>> getPackages();
  Future<void> purchase(Package package);
  Future<void> restorePurchases();
  Stream<bool> proStatusStream();
}
```

### Server-Side Validation

RevenueCat webhooks → Supabase Edge Function → Update `subscriptions` table.

This ensures subscription status is validated server-side, not just client-side.

## Paywall UX Design

### When to Show Paywall

1. User tries to access a Pro-only exercise → Soft paywall
2. User tries to create a 3rd workout → Soft paywall
3. User exceeds daily AI limit → Soft paywall
4. Profile settings → "Upgrade to Pro" option (always accessible)
5. After 3 workout completions → Non-blocking upgrade suggestion

### Paywall Screen Content

- Clear feature comparison (Free vs Pro)
- Price with savings highlighted for annual
- "Start Free Trial" primary CTA
- Monthly option as secondary
- Restore purchases link
- Terms and privacy links
- Close/dismiss button (never trap the user)

### Anti-Patterns to Avoid

- ❌ Blocking app launch with paywall
- ❌ Hiding the close button
- ❌ Dark patterns (pre-selected expensive plan)
- ❌ Aggressive interruptions during workouts
- ❌ Misleading "limited time" claims

## Store Compliance

### Google Play

- Use Google Play Billing Library (via RevenueCat)
- Provide subscription management deep link
- Display price in local currency
- Honor cancellation grace period

### Apple App Store

- Use StoreKit (via RevenueCat)
- Provide restore purchases option
- Display subscription terms
- Support family sharing if applicable
- Comply with auto-renewable subscription guidelines

## Revenue Analytics

RevenueCat provides:
- MRR / ARR
- Trial conversion rate
- Churn rate
- LTV per subscriber
- Revenue per platform
