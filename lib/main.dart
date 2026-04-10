import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
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

  // Resolve emulator host before building widget tree (avoids async race in initState)
  final emulatorHost = await _resolveEmulatorHost();

  // Wrap app with ProviderScope for Riverpod state management
  runApp(
    ProviderScope(
      child: RiverpodTaskMasterApp(emulatorHost: emulatorHost),
    ),
  );
}
