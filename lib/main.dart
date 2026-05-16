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
import 'package:taskmaestro/core/services/crash_reporter.dart';
import 'package:taskmaestro/core/services/crash_reporter_web_noop.dart';
import 'package:taskmaestro/core/services/log_storage_base.dart';
import 'package:taskmaestro/core/services/notification_web_noop.dart';
import 'package:taskmaestro/core/providers/notification_providers.dart';
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
  // Create the log storage instance (not initialized yet — needs the
  // binding first). Factory picks the native file-backed impl or the
  // web no-op at compile time so `dart:io` never reaches the web graph.
  final LogStorageBase logStorage = createLogStorage();

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
        // Skip when the engine hasn't reported a real size yet
        // (physicalSize == Size.zero pre-binding): a zero shortestSide
        // is < 600 and would wrongly portrait-lock a tablet/desktop on
        // frame one.
        if (logicalSize.shortestSide > 0 &&
            shouldLockPortrait(isWeb: kIsWeb, logicalSize: logicalSize)) {
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
      // TM-353: notifications are a no-op on web, so the local zone is
      // moot there; flutter_timezone is native-only — fall back to UTC
      // and skip the platform call. Native (TM-361): flutter_timezone
      // 5.x getLocalTimezone() returns TimezoneInfo; pull the IANA id.
      if (kIsWeb) {
        // `getLocation('UTC')` throws — the timezone package handles UTC
        // as the built-in `tz.UTC` Location, not a named DB entry.
        tz.setLocalLocation(tz.UTC);
        print('🕐 Timezone (web): UTC');
      } else {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
        print('🕐 Timezone initialized: ${tzInfo.identifier}');
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Wire up Crashlytics (only collects in release/profile, off in debug).
      // Handlers are only installed outside debug mode so:
      //   1. The `CrashReporter` debug no-op contract isn't bypassed
      //   2. Uncaught errors in debug/test aren't swallowed by `return true`
      //      — they still surface via the default Flutter error handling.
      // TM-353: firebase_crashlytics has no web support and throws on
      // web — skip the whole block there (crashReporterProvider is
      // overridden with a no-op below so app code stays unaware).
      //
      // KNOWN WEB GAP (intentional, interim — TM-374): on web there is
      // currently NO durable capture of fatal/uncaught errors at all —
      // Crashlytics is a no-op, the global FlutterError/PlatformDispatcher
      // handlers below are skipped, and LogStorageWebNoop discards the
      // print-zone output. A failed Drift→Firestore outbox push on web
      // would be invisible here. The Drift sync layer still has its own
      // user-visible connectivity/retry signaling (ConnectionStatus), so
      // this is an observability gap, not silent data loss. Web error
      // reporting (e.g. Sentry / console export) is tracked in TM-374.
      if (!kIsWeb) {
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
      }

      // Resolve emulator host before building widget tree (avoids async race in initState)
      final emulatorHost = await _resolveEmulatorHost();

      // TM-359: pre-warm SharedPreferences so the provider's future is
      // already resolved by the time the widget tree mounts. The
      // sharedPreferencesProvider returns getInstance() which is cached
      // after first call, so the provider's first read returns a
      // pre-resolved AsyncValue.data on the very next microtask.
      await SharedPreferences.getInstance();

      // Wrap app with ProviderScope for Riverpod state management.
      // TM-353: on web, swap the native plugin-backed services for
      // no-op implementations (Crashlytics / local notifications have
      // no web support; log storage has no filesystem). App code keeps
      // reading the same providers — only the bound impl changes here.
      final overrides = [
        logStorageServiceProvider.overrideWithValue(logStorage),
        if (kIsWeb) ...[
          crashReporterProvider.overrideWithValue(CrashReporterWebNoop()),
          notificationHelperProvider
              .overrideWithValue(NotificationHelperWebNoop()),
        ],
      ];
      runApp(
        ProviderScope(
          overrides: overrides,
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
        // Forward uncaught async errors to Crashlytics (no-op in debug;
        // skipped on web — firebase_crashlytics has no web support).
        if (!kDebugMode && !kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        parent.print(zone, '❌ Uncaught zone error: $error\n$stack');
      },
    ),
  );
}
