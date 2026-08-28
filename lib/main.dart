import 'package:asm/app.dart';
import 'package:asm/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
    appRunner: () => runApp(const ProviderScope(child: AsmApp())),
  );
}
