import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:taskmaster/app.dart';
import 'package:taskmaster/core/feature_flags.dart';
import 'package:taskmaster/riverpod_app.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Print feature flags for debugging
  FeatureFlags.printStatus();

  // Initialize timezone database for notifications
  // This is needed for flutter_local_notifications.zonedSchedule() to handle DST correctly
  tz.initializeTimeZones();
  final String timezoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezoneName));
  print('🕐 Timezone initialized: $timezoneName');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Wrap app with ProviderScope for Riverpod state management
  // Choose between Riverpod-first or Redux-first app based on feature flag
  runApp(
    ProviderScope(
      child: FeatureFlags.useRiverpodForAuth
          ? const RiverpodTaskMasterApp()  // New Riverpod auth flow
          : TaskMasterApp(),               // Legacy Redux auth flow
    ),
  );
}
