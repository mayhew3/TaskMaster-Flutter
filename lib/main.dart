import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:taskmaster/core/services/log_storage_service.dart';
import 'package:taskmaster/riverpod_app.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';

/// Resolve the emulator host before building the widget tree.
/// Priority: dart-define EMULATOR_HOST > assets/config/emulator_host.txt > 127.0.0.1
Future<String> _resolveEmulatorHost() async {
  const dartDefineHost = String.fromEnvironment('EMULATOR_HOST');
  if (dartDefineHost.isNotEmpty) return dartDefineHost;
  try {
    final assetHost = (await rootBundle.loadString('assets/config/emulator_host.txt')).trim();
    return assetHost.isEmpty ? '127.0.0.1' : assetHost;
  } catch (_) {
    return '127.0.0.1';
  }
}

Future<void> main() async {
  // Create the log storage instance (not initialized yet — needs the binding first)
  final logStorage = LogStorageService();

  // Capture all print() output into the log file via a custom Zone.
  // The binding MUST be initialized inside this zone so runApp() runs in the
  // same zone (otherwise Flutter throws a Zone mismatch error).
  // This preserves the full runtime output that would otherwise be lost
  // on iOS production devices where console logs aren't accessible.
  // `await` so any startup error thrown inside the zone chains back to
  // `main()` instead of becoming an unawaited future.
  await runZoned<Future<void>>(
    () async {
      // Initialize binding inside the zone so runApp uses the same zone
      WidgetsFlutterBinding.ensureInitialized();

      // Now that the binding is ready, path_provider can resolve the documents dir
      await logStorage.initialize();

      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        // The zone's print hook captures this line into the log file, so
        // we intentionally do NOT also call logStorage.writeRecord(record)
        // — that would double-write every record.
        print('${record.level.name}: ${record.time}: ${record.message}');
      });

      // Initialize timezone database for notifications
      // This is needed for flutter_local_notifications.zonedSchedule() to handle DST correctly
      tz.initializeTimeZones();
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      print('🕐 Timezone initialized: $timezoneName');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Wire up Crashlytics (only collects in release/profile, off in debug).
      // Handlers are only installed outside debug mode so:
      //   1. The `CrashReporter` debug no-op contract isn't bypassed
      //   2. Uncaught errors in debug/test aren't swallowed by `return true`
      //      — they still surface via the default Flutter error handling.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      if (!kDebugMode) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Resolve emulator host before building widget tree (avoids async race in initState)
      final emulatorHost = await _resolveEmulatorHost();

      // Wrap app with ProviderScope for Riverpod state management
      runApp(
        ProviderScope(
          overrides: [
            logStorageServiceProvider.overrideWithValue(logStorage),
          ],
          child: RiverpodTaskMasterApp(emulatorHost: emulatorHost),
        ),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, line); // Still print to console
        logStorage.writeRaw(line); // Also persist to log file
      },
      handleUncaughtError: (self, parent, zone, error, stack) {
        // Forward uncaught async errors to Crashlytics (no-op in debug)
        if (!kDebugMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        parent.print(zone, '❌ Uncaught zone error: $error\n$stack');
      },
    ),
  );
}
