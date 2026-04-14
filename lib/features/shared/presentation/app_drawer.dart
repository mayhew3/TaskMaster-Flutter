import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/crash_reporter.dart';
import '../../../core/services/log_storage_service.dart';
import '../../../models/task_colors.dart';

/// Riverpod-based navigation drawer
/// Replaces Redux TaskMainMenu widget
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: TaskColors.pendingBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (authState.user != null) ...[
                  Text(
                    authState.user!.displayName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.user!.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ] else
                  const Text(
                    'TaskMaster',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Logs'),
            onTap: () async {
              Navigator.of(context).pop(); // Close drawer first
              final logStorage = ref.read(logStorageServiceProvider);
              final path = logStorage.getLogFilePath();
              if (path == null) return;
              final timestamp = DateTime.now()
                  .toIso8601String()
                  .replaceAll(':', '-')
                  .split('.')
                  .first;
              final exportName = 'taskmaster-$timestamp.log';
              await SharePlus.instance.share(
                ShareParams(
                  files: [XFile(path)],
                  fileNameOverrides: [exportName],
                  subject: exportName,
                ),
              );
            },
          ),
          // Debug-only: expose crash-testing actions so end users in release
          // builds can't trigger fatal crashes from the drawer.
          if (kDebugMode) ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('Test Crash Reporting'),
            subtitle: const Text('Fatal crash, non-fatal error, and log breadcrumb'),
            onTap: () async {
              Navigator.of(context).pop();
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Test Crash Reporting'),
                  content: const Text(
                    'Pick a test to send to Crashlytics. '
                    'Reports only fire in release/profile mode.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Non-fatal: logged via wrapper, does not crash
                        ref.read(crashReporterProvider).logError(
                              Exception('Manual non-fatal test'),
                              StackTrace.current,
                              context: 'Test Crash Reporting button',
                            );
                      },
                      child: const Text('Non-fatal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Throws unhandled — picked up by FlutterError.onError
                        throw StateError('Manual unhandled test crash');
                      },
                      child: const Text('Unhandled throw'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Forces a native crash (Firebase recommended test)
                        FirebaseCrashlytics.instance.crash();
                      },
                      child: const Text('Native crash'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer first
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}
