import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/check_state.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/services/task_completion_service.dart';
import '../providers/task_providers.dart';
import 'task_add_edit_screen.dart';
import 'recurrence_detail_screen.dart';
import '../../shared/presentation/delayed_checkbox.dart';
import '../../shared/presentation/widgets/readonly_task_field.dart';
import '../../shared/presentation/widgets/readonly_task_field_small.dart';

/// Riverpod version of the Task Details screen
/// Displays full task information with edit and delete actions
class TaskDetailsScreen extends ConsumerWidget {
  final String taskItemId;

  const TaskDetailsScreen({
    Key? key,
    required this.taskItemId,
  }) : super(key: key ?? TaskMasterKeys.taskItemDetailsScreen);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskProvider(taskItemId));
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (_) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Not Found')),
            body: const Center(child: Text('Task not found')),
          );
        }
        return _TaskDetailsBody(task: task);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Task Item Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading tasks: $err')),
      ),
    );
  }
}

class _TaskDetailsBody extends ConsumerWidget {
  final TaskItem task;

  const _TaskDetailsBody({
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Item Details'),
        actions: [
          IconButton(
            tooltip: 'Delete Task Item',
            key: TaskMasterKeys.deleteTaskItemButton,
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await ref.read(deleteTaskProvider.notifier).call(task);
              if (context.mounted) {
                Navigator.pop(context, task);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      task.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: DelayedCheckbox(
                    taskName: task.name,
                    initialState: task.isCompleted()
                        ? CheckState.checked
                        : task.pendingCompletion
                            ? CheckState.pending
                            : CheckState.inactive,
                    checkCycleWaiter: (checkState) {
                      ref.read(completeTaskProvider.notifier).call(
                        task,
                        complete: CheckState.inactive == checkState,
                      );
                      return null;
                    },
                  ),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Project',
              textToShow: task.project,
            ),
            ReadOnlyTaskField(
              headerName: 'Context',
              textToShow: task.context,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ReadOnlyTaskFieldSmall(
                  headerName: 'Priority',
                  textToShow: _formatNumber(task.priority),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Points',
                  textToShow: _formatNumber(task.gamePoints),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Length',
                  textToShow: _formatNumber(task.duration),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Start',
              textToShow: _formatDateTime(task.startDate),
              optionalSubText: _getFormattedAgo(task.startDate),
              optionalTextColor: _getStartTextColor(task),
              optionalOutlineColor: _getStartOutlineColor(task),
              optionalBackgroundColor: _getStartBackgroundColor(task),
              hasShadow: false,
            ),
            ReadOnlyTaskField(
              headerName: 'Target',
              textToShow: _formatDateTime(task.targetDate),
              optionalSubText: _getFormattedAgo(task.targetDate),
              optionalTextColor: TaskDateTypes.target.textColor,
              optionalBackgroundColor: _getTargetBackgroundColor(task),
            ),
            ReadOnlyTaskField(
              headerName: 'Urgent',
              textToShow: _formatDateTime(task.urgentDate),
              optionalSubText: _getFormattedAgo(task.urgentDate),
              optionalTextColor: TaskDateTypes.urgent.textColor,
              optionalBackgroundColor: _getUrgentBackgroundColor(task),
            ),
            ReadOnlyTaskField(
              headerName: 'Due',
              textToShow: _formatDateTime(task.dueDate),
              optionalSubText: _getFormattedAgo(task.dueDate),
              optionalTextColor: TaskDateTypes.due.textColor,
              optionalBackgroundColor: _getDueBackgroundColor(task),
            ),
            ReadOnlyTaskField(
              headerName: 'Completed',
              textToShow: _formatDateTime(task.getFinishedCompletionDate()),
              optionalSubText: _getFormattedAgo(task.getFinishedCompletionDate()),
              optionalBackgroundColor: _getCompletedBackgroundColor(task),
            ),
            _RecurrenceField(task: task),
            ReadOnlyTaskField(
              headerName: 'Notes',
              textToShow: task.description,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: TaskMasterKeys.editTaskItemFab,
        tooltip: 'Edit Task Item',
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskAddEditScreen(taskItemId: task.docId),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    var localTime = dateTime.toLocal();
    var jiffy = Jiffy.parseFromDateTime(localTime);
    var isToday = jiffy.yMMMd == Jiffy.now().yMMMd;
    var isThisYear = jiffy.year == Jiffy.now().year;
    var jiffyTime = jiffy.format(pattern: 'h:mm a');
    var jiffyDate = isThisYear
        ? jiffy.format(pattern: 'MMMM do')
        : jiffy.format(pattern: 'MMMM do, yyyy');
    var formattedDate = isToday ? '$jiffyTime today' : jiffyDate;
    return formattedDate;
  }

  String? _getFormattedAgo(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return '(${timeago.format(dateTime, allowFromNow: true)})';
  }

  String _formatNumber(num? number) {
    return number == null ? '' : number.toString();
  }

  bool _hasPassed(DateTime? dateTime) {
    return dateTime != null && dateTime.isBefore(DateTime.timestamp());
  }

  Color _getStartTextColor(TaskItem task) {
    var start = _hasPassed(task.startDate);
    return start ? Colors.white : TaskColors.scheduledText;
  }

  Color? _getStartOutlineColor(TaskItem task) {
    var start = _hasPassed(task.startDate);
    return start ? null : TaskColors.scheduledOutline;
  }

  Color _getStartBackgroundColor(TaskItem task) {
    var start = _hasPassed(task.startDate);
    return start ? TaskColors.cardColor : TaskColors.scheduledColor;
  }

  Color _getTargetBackgroundColor(TaskItem task) {
    var target = _hasPassed(task.targetDate);
    return target ? TaskColors.targetColor : TaskColors.cardColor;
  }

  Color _getUrgentBackgroundColor(TaskItem task) {
    var urgent = _hasPassed(task.urgentDate);
    return urgent ? TaskColors.urgentColor : TaskColors.cardColor;
  }

  Color _getDueBackgroundColor(TaskItem task) {
    var due = _hasPassed(task.dueDate);
    return due ? TaskColors.dueColor : TaskColors.cardColor;
  }

  Color _getCompletedBackgroundColor(TaskItem task) {
    var completed = _hasPassed(task.completionDate);
    return completed ? TaskColors.completedColor : TaskColors.cardColor;
  }

}

/// Displays recurrence info as a tappable card that navigates to RecurrenceDetailScreen.
/// Shows "No recurrence." for non-recurring tasks, and a tappable row for recurring tasks.
class _RecurrenceField extends StatelessWidget {
  final TaskItem task;

  const _RecurrenceField({required this.task});

  @override
  Widget build(BuildContext context) {
    final recurrence = task.recurrence;
    final hasRecurrence = recurrence != null;
    final recurrenceText = hasRecurrence
        ? _getFormattedRecurrence(recurrence)
        : 'No recurrence.';

    return Card(
      elevation: 3.0,
      color: TaskColors.cardColor,
      child: InkWell(
        onTap: hasRecurrence ? () => _navigateToRecurrenceDetail(context) : null,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 70.0,
                child: Text(
                  'Repeat',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  recurrenceText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
              if (hasRecurrence)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRecurrenceDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecurrenceDetailScreen(
          recurrenceDocId: task.recurrenceDocId!,
          recurrenceName: task.name,
        ),
      ),
    );
  }

  String _getFormattedRecurrence(TaskRecurrence recurrence) {
    final recurNumber = recurrence.recurNumber;
    final recurWait = recurrence.recurWait;
    return 'Every $recurNumber ${_getFormattedRecurUnit(recurrence)}${recurWait ? ' (after completion)' : ''}';
  }

  String _getFormattedRecurUnit(TaskRecurrence taskRecurrence) {
    String unit = taskRecurrence.recurUnit;
    if (taskRecurrence.recurNumber == 1) {
      unit = unit.substring(0, unit.length - 1);
    }
    return unit.toLowerCase();
  }
}
