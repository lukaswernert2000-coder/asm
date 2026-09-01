import 'package:asm/app.dart';
import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/onboarding/presentation/onboarding_providers.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  AppConfig.assertValid();

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = AppConfig.sentryDsn
        ..sendDefaultPii = false
        ..environment = AppConfig.environment
        ..tracesSampleRate = AppConfig.isProd ? 0.2 : 1.0;
    },
    appRunner: () async {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {
            hasSeenOnboardingPrefsKey,
            listingViewModePrefsKey,
            searchHistoryPrefsKey,
            createListingDraftPrefsKey,
            hiddenConversationsPrefsKey,
          },
        ),
      );
      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const AsmApp(),
        ),
      );
    },
  );
}
