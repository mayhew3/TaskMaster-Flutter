import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../providers/task_filter_providers.dart';

/// Riverpod version of the Stats screen
/// Displays task statistics using Riverpod providers
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = ref.watch(activeTaskCountProvider);
    final completedCountAsync = ref.watch(completedTaskCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: const [ConnectionStatusIndicator()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Completed Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: completedCountAsync.when(
                data: (count) => Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                loading: () => const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stack) {
                  print('❌ Error loading completed count: $err\n$stack');
                  return Text(
                    '?',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Active Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                '$activeCount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
