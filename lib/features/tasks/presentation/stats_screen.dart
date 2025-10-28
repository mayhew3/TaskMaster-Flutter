import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../redux/containers/tab_selector.dart';
import '../../../redux/presentation/task_main_menu.dart';
import '../providers/task_filter_providers.dart';

/// Riverpod version of the Stats screen
/// Displays task statistics using Riverpod providers
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = ref.watch(activeTaskCountProvider);
    final completedCount = ref.watch(completedTaskCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatCard(
              label: 'Active Tasks',
              count: activeCount,
              color: Colors.blue,
              icon: Icons.check_box_outline_blank,
            ),
            const SizedBox(height: 16),
            _StatCard(
              label: 'Completed Tasks',
              count: completedCount,
              color: Colors.green,
              icon: Icons.check_box,
            ),
          ],
        ),
      ),
      drawer: TaskMainMenu(),
      bottomNavigationBar: TabSelector(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
