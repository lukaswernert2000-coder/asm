import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const hasSeenOnboardingPrefsKey = 'has_seen_onboarding';

final hasSeenOnboardingProvider = Provider<bool>((ref) {
  return ref
          .watch(sharedPreferencesProvider)
          .getBool(hasSeenOnboardingPrefsKey) ??
      false;
});

Future<void> markOnboardingSeen(WidgetRef ref) async {
  await ref
      .read(sharedPreferencesProvider)
      .setBool(hasSeenOnboardingPrefsKey, true);
  ref.invalidate(hasSeenOnboardingProvider);
}
