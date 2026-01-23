import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import '../../../models/task_item.dart';
import '../../../models/task_colors.dart';
import '../providers/task_providers.dart';

/// Screen showing all iterations of a recurring task.
/// Displays full history including retired/deleted tasks for debugging.
class RecurrenceDetailScreen extends ConsumerWidget {
  final String recurrenceDocId;
  final String recurrenceName;

  const RecurrenceDetailScreen({
    Key? key,
    required this.recurrenceDocId,
    required this.recurrenceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksForRecurrenceProvider(recurrenceDocId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Recurrence History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              recurrenceName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No iterations found for this recurrence.'),
                  );
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _RecurrenceIterationTile(task: tasks[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error loading iterations: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurrenceIterationTile extends StatelessWidget {
  final TaskItem task;

  const _RecurrenceIterationTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final isRetired = task.retired != null;
    final isCompleted = task.completionDate != null;
    final iteration = task.recurIteration ?? 0;

    // Get primary date with label (priority: due -> urgent -> target -> start)
    final primaryDateInfo = _getPrimaryDateInfo();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Iteration badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getBadgeColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#$iteration',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task name (with strikethrough if retired)
                  Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isRetired ? TextDecoration.lineThrough : null,
                      color: isRetired ? Colors.grey : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Primary date with label
                  if (primaryDateInfo != null)
                    Text(
                      '${primaryDateInfo.label}: ${_formatDate(primaryDateInfo.date)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryDateInfo.color,
                      ),
                    ),
                  // Completion date (if completed)
                  if (isCompleted && !isRetired)
                    Text(
                      'Completed: ${_formatDate(task.completionDate!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFD88BD0), // lighter pink
                      ),
                    ),
                  // Show retired indicator
                  if (isRetired)
                    Text(
                      'Deleted: ${_formatDate(task.retiredDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            // Status icon
            _StatusIcon(task: task),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    if (task.retired != null) return Colors.grey.shade700;
    if (task.completionDate != null) return TaskColors.completedColor;
    return TaskColors.cardColor;
  }

  _DateInfo? _getPrimaryDateInfo() {
    // Priority: due -> urgent -> target -> start
    // Use lighter versions of TaskColors for better readability
    if (task.dueDate != null) {
      return _DateInfo('Due', task.dueDate!, const Color(0xFFE091B0)); // lighter pink
    }
    if (task.urgentDate != null) {
      return _DateInfo('Urgent', task.urgentDate!, const Color(0xFFD4A89A)); // lighter orange
    }
    if (task.targetDate != null) {
      return _DateInfo('Target', task.targetDate!, const Color(0xFFB8C490)); // lighter green
    }
    if (task.startDate != null) {
      return _DateInfo('Start', task.startDate!, Colors.white70);
    }
    return null;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final localTime = dateTime.toLocal();
    final jiffy = Jiffy.parseFromDateTime(localTime);
    final isThisYear = jiffy.year == Jiffy.now().year;
    return isThisYear
        ? jiffy.format(pattern: 'MMM d')
        : jiffy.format(pattern: 'MMM d, yyyy');
  }
}

class _DateInfo {
  final String label;
  final DateTime date;
  final Color color;

  _DateInfo(this.label, this.date, this.color);
}

class _StatusIcon extends StatelessWidget {
  final TaskItem task;

  const _StatusIcon({required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.retired != null) {
      return const Icon(Icons.delete_outline, color: Colors.grey, size: 24);
    }
    if (task.completionDate != null) {
      // Lighter pink for better visibility
      return const Icon(Icons.check_circle, color: Color(0xFFD88BD0), size: 24);
    }
    return const Icon(Icons.radio_button_unchecked, color: Colors.white54, size: 24);
  }
}
