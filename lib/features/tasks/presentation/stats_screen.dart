import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../redux/containers/tab_selector.dart';
import '../../../redux/presentation/task_main_menu.dart';
import '../providers/task_providers.dart';

/// Riverpod version of the Stats screen
/// Displays task statistics using Riverpod providers
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final activeCount = tasks
              .where((t) => t.completionDate == null && t.retired == null)
              .length;
          final completedCount =
              tasks.where((t) => t.completionDate != null).length;

          return Center(
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
                  child: Text(
                    '$completedCount',
                    style: Theme.of(context).textTheme.titleMedium,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading stats: $err'),
        ),
      ),
      drawer: TaskMainMenu(),
      bottomNavigationBar: TabSelector(),
    );
  }
}
