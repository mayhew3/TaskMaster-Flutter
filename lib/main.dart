import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/core/services/log_storage_service.dart';
import 'package:taskmaestro/riverpod_app.dart';
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

      // TM-371: lock phones (iPhone + Android) to portrait before the
      // first frame so there's no landscape flash if launched rotated.
      // Tablets and web are excluded (web landscape is a deliberate
      // future feature — TM-354). Done here, first thing post-binding:
      // setPreferredOrientations needs the binding, it doesn't print so
      // it's safe inside the log-capturing zone, and applying it before
      // any UI work guarantees the constraint holds for frame one.
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        final view = views.first;
        final logicalSize = view.physicalSize / view.devicePixelRatio;
        if (shouldLockPortrait(isWeb: kIsWeb, logicalSize: logicalSize)) {
          await SystemChrome.setPreferredOrientations(
            const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
          );
        }
      }

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
      // TM-361: flutter_timezone 5.x — getLocalTimezone() now returns
      // TimezoneInfo; pull the IANA identifier off it.
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      print('🕐 Timezone initialized: ${tzInfo.identifier}');

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

      // TM-359: pre-warm SharedPreferences so the provider's future is
      // already resolved by the time the widget tree mounts. The
      // sharedPreferencesProvider returns getInstance() which is cached
      // after first call, so the provider's first read returns a
      // pre-resolved AsyncValue.data on the very next microtask.
      await SharedPreferences.getInstance();

      // Wrap app with ProviderScope for Riverpod state management
      runApp(
        ProviderScope(
          overrides: [
            logStorageServiceProvider.overrideWithValue(logStorage),
          ],
          child: RiverpodTaskMaestroApp(emulatorHost: emulatorHost),
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
