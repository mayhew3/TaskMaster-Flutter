import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/redux/presentation/clearable_date_time_field.dart';
import 'package:taskmaster/redux/presentation/editable_task_field.dart';
import 'package:taskmaster/redux/presentation/nullable_dropdown.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/timezone_helper.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/task_completion_service.dart';
import '../providers/task_providers.dart';

/// Riverpod version of the Add/Edit Task screen
/// Handles creating new tasks and editing existing tasks
class TaskAddEditScreen extends ConsumerStatefulWidget {
  final String? taskItemId;

  const TaskAddEditScreen({
    super.key,
    this.taskItemId,
  });

  @override
  ConsumerState<TaskAddEditScreen> createState() => _TaskAddEditScreenState();
}

class _TaskAddEditScreenState extends ConsumerState<TaskAddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late BuiltList<String> possibleProjects;
  late BuiltList<String> possibleContexts;
  late BuiltList<String> possibleAnchorDates;
  late BuiltList<String> possibleRecurUnits;

  bool _repeatOn = false;
  late bool _initialRepeatOn;

  late TaskItemBlueprint taskItemBlueprint;
  TaskItem? taskItem;

  TaskItemBlueprint blankBlueprint = TaskItemBlueprint();
  late TaskRecurrenceBlueprint taskRecurrenceBlueprint;

  bool popped = false;
  int? _initialTaskCount; // Track initial task count for new task detection
  bool _submitting = false; // Track if submit was pressed
  bool _initialized = false; // Track if task has been initialized to prevent re-init on rebuild

  @override
  void initState() {
    super.initState();

    // Initialize dropdown options
    possibleProjects = ListBuilder<String>([
      '(none)',
      'Career',
      'Hobby',
      'Friends',
      'Family',
      'Health',
      'Maintenance',
      'Organization',
      'Shopping',
      'Entertainment',
      'WIG Mentorship',
      'Writing',
      'Bugs',
      'Projects',
    ]).build();

    possibleContexts = ListBuilder<String>([
      '(none)',
      'Computer',
      'Home',
      'Office',
      'E-Mail',
      'Phone',
      'Outside',
      'Reading',
      'Planning',
    ]).build();

    possibleAnchorDates = ListBuilder<String>([
      '(none)',
      'Schedule Dates',
      'Completed Date',
    ]).build();

    possibleRecurUnits = ListBuilder<String>([
      '(none)',
      'Days',
      'Weeks',
      'Months',
      'Years',
    ]).build();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize task only once when dependencies are first available
    if (!_initialized) {
      final task = widget.taskItemId != null
          ? ref.read(taskProvider(widget.taskItemId!))
          : null;
      _initializeTask(task);
      _initialized = true;
    }
  }

  void _initializeTask(TaskItem? task) {
    taskItem = task;
    taskItemBlueprint =
        task == null ? TaskItemBlueprint() : task.createBlueprint();
    var existingRecurrence = task?.recurrence;
    taskRecurrenceBlueprint = (existingRecurrence == null)
        ? TaskRecurrenceBlueprint()
        : existingRecurrence.createBlueprint();

    _initialRepeatOn = task?.recurrenceDocId != null;
    _repeatOn = _initialRepeatOn;
  }

  bool get isEditing {
    return widget.taskItemId != null;
  }

  bool hasDate() {
    return taskItemBlueprint.getAnchorDate() != null;
  }

  bool? anchorDateToRecurWait(String anchorDate) {
    if (anchorDate == '(none)') {
      return null;
    } else {
      return anchorDate == 'Completed Date';
    }
  }

  String recurWaitToAnchorDate(bool? recurWait) {
    return (recurWait == null)
        ? '(none)'
        : !recurWait
            ? 'Schedule Dates'
            : 'Completed Date';
  }

  void clearRepeatOn() {
    _repeatOn = false;
  }

  DateTime? getLastDateBefore(TaskDateType taskDateType) {
    var typesPreceding = TaskDateTypes.getTypesPreceding(taskDateType);
    var allDates = typesPreceding
        .map((type) => type.dateFieldGetter(taskItemBlueprint))
        .whereType<DateTime>();

    return allDates.isEmpty ? null : DateUtil.maxDate(allDates);
  }

  DateTime _getPreviousDateOrNow(TaskDateType taskDateType) {
    var lastDate = getLastDateBefore(taskDateType);
    return lastDate ?? DateTime.now();
  }

  DateTime _getOnePastPreviousDateOrNow(TaskDateType taskDateType) {
    var lastDate = getLastDateBefore(taskDateType);
    return lastDate == null ? DateTime.now() : lastDate.add(Duration(days: 1));
  }

  String _getInputDisplay(dynamic value) {
    if (value == null) {
      return '';
    } else {
      return value.toString();
    }
  }

  void clearRecurrenceFieldsFromTask() {
    taskItemBlueprint.recurUnit = null;
    taskItemBlueprint.recurNumber = null;
    taskItemBlueprint.recurWait = null;
    taskItemBlueprint.recurIteration = null;
    taskItemBlueprint.recurrenceBlueprint = null;
    taskItemBlueprint.recurrenceDocId = null;
  }

  void updateRecurrenceBlueprint() {
    taskRecurrenceBlueprint.recurIteration = taskItemBlueprint.recurIteration;
    taskRecurrenceBlueprint.recurNumber = taskItemBlueprint.recurNumber;
    taskRecurrenceBlueprint.recurWait = taskItemBlueprint.recurWait;
    taskRecurrenceBlueprint.recurUnit = taskItemBlueprint.recurUnit;
    taskRecurrenceBlueprint.name = taskItemBlueprint.name;
    taskRecurrenceBlueprint.anchorDate = taskItemBlueprint.getAnchorDate();
    taskItemBlueprint.recurrenceBlueprint = taskRecurrenceBlueprint;
    taskItemBlueprint.recurrenceDocId = taskItem?.recurrence?.docId;
  }

  bool hasChanges() {
    // Check if recurrence toggle state has changed
    if (_repeatOn != _initialRepeatOn) {
      return true;
    }

    if (editMode()) {
      return taskItemBlueprint.hasChanges(taskItem!);
    } else {
      return taskItemBlueprint.hasChangesBlueprint(blankBlueprint);
    }
  }

  bool editMode() {
    return taskItem != null;
  }

  String? _cleanString(String? str) {
    if (str == null) {
      return null;
    } else {
      var trimmed = str.trim();
      if (trimmed.isEmpty) {
        return null;
      } else {
        return trimmed;
      }
    }
  }

  int? _parseInt(String? str) {
    if (str == null) {
      return null;
    }
    var cleanString = _cleanString(str);
    return cleanString == null ? null : int.parse(str);
  }

  void _checkForAutoClose() {
    // Only check for auto-close if user has submitted the form
    if (!_submitting) {
      return;
    }

    final tasksAsync = ref.read(tasksWithRecurrencesProvider);
    final recurrencesAsync = ref.read(taskRecurrencesProvider);

    tasksAsync.whenData((tasks) {
      recurrencesAsync.whenData((recurrences) {
        if (!popped) {
          if (editMode()) {
            // Convert List to BuiltList for selectors
            final builtTasks = BuiltList<TaskItem>(tasks);
            final builtRecurrences = BuiltList<TaskRecurrence>(recurrences);

            var latestTask = taskItemSelector(builtTasks, taskItem!.docId);
            var latestRecurrence = taskRecurrenceSelector(
                builtRecurrences, taskItem!.recurrence?.docId);
            var hasTaskChanges =
                latestTask != null && latestTask.hasChanges(taskItem!);
            var hasRecurrenceChanges = latestRecurrence != null &&
                latestRecurrence.hasChanges(taskItem!.recurrence);
            if (hasTaskChanges || hasRecurrenceChanges) {
              popped = true;
              Navigator.pop(context);
            }
          } else {
            // For new tasks, check if count increased after submitting
            if (_initialTaskCount != null && tasks.length > _initialTaskCount!) {
              popped = true;
              Navigator.pop(context);
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

    // Listen for changes to auto-close
    ref.listen<AsyncValue<List<TaskItem>>>(tasksWithRecurrencesProvider, (prev, next) {
      _checkForAutoClose();
    });

    ref.listen<AsyncValue<List<TaskRecurrence>>>(taskRecurrencesProvider,
        (prev, next) {
      _checkForAutoClose();
    });

    return tasksAsync.when(
      data: (tasks) {
        // Store initial task count for new task detection (first time only)
        _initialTaskCount ??= tasks.length;

        // Get timezoneHelper from Riverpod provider
        final timezoneHelperAsync = ref.watch(timezoneHelperNotifierProvider);

        // Get timezone helper value or show loading
        final timezoneHelper = timezoneHelperAsync.value;
        if (timezoneHelper == null) {
          return const Scaffold(
            appBar: null,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildForm(context, timezoneHelper);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading tasks: $err')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, TimezoneHelper timezoneHelper) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: () {
                setState(() {});
              },
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    EditableTaskField(
                      key: const Key('task_name_field'),
                      initialText: taskItemBlueprint.name,
                      labelText: 'Name',
                      onChanged: (value) {
                        taskItemBlueprint.name = value;
                        setState(() {}); // Trigger rebuild to update FAB visibility
                      },
                      fieldSetter: (value) => taskItemBlueprint.name = value,
                      inputType: TextInputType.multiline,
                      isRequired: true,
                      wordCaps: true,
                    ),
                    NullableDropdown(
                      initialValue: taskItemBlueprint.project,
                      labelText: 'Project',
                      possibleValues: possibleProjects,
                      valueSetter: (value) => taskItemBlueprint.project = value,
                    ),
                    NullableDropdown(
                      initialValue: taskItemBlueprint.context,
                      labelText: 'Context',
                      possibleValues: possibleContexts,
                      valueSetter: (value) => taskItemBlueprint.context = value,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: EditableTaskField(
                            initialText:
                                _getInputDisplay(taskItemBlueprint.priority),
                            labelText: 'Priority',
                            onChanged: (value) {
                              setState(() {
                                taskItemBlueprint.priority = _parseInt(value);
                              });
                            },
                            fieldSetter: (value) =>
                                taskItemBlueprint.priority = _parseInt(value),
                            inputType: TextInputType.number,
                          ),
                        ),
                        Expanded(
                          child: EditableTaskField(
                            initialText:
                                _getInputDisplay(taskItemBlueprint.gamePoints),
                            labelText: 'Points',
                            onChanged: (value) {
                              setState(() {
                                taskItemBlueprint.gamePoints = _parseInt(value);
                              });
                            },
                            fieldSetter: (value) =>
                                taskItemBlueprint.gamePoints = _parseInt(value),
                            inputType: TextInputType.number,
                          ),
                        ),
                        Expanded(
                          child: EditableTaskField(
                            initialText:
                                _getInputDisplay(taskItemBlueprint.duration),
                            labelText: 'Length',
                            onChanged: (value) {
                              setState(() {
                                taskItemBlueprint.duration = _parseInt(value);
                              });
                            },
                            fieldSetter: (value) =>
                                taskItemBlueprint.duration = _parseInt(value),
                            inputType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    ClearableDateTimeField(
                      labelText: 'Start Date',
                      dateGetter: () {
                        return taskItemBlueprint.startDate;
                      },
                      initialPickerGetter: () {
                        return DateTime.now();
                      },
                      dateSetter: (DateTime? pickedDate) {
                        print('[TM-300 DEBUG] Start Date dateSetter called with: $pickedDate');
                        print('[TM-300 DEBUG] hasDate() before: ${hasDate()}');
                        setState(() {
                          taskItemBlueprint.startDate = pickedDate;
                          print('[TM-300 DEBUG] blueprint.startDate now: ${taskItemBlueprint.startDate}');
                          print('[TM-300 DEBUG] hasDate() after: ${hasDate()}');
                          if (!hasDate()) {
                            clearRepeatOn();
                          }
                        });
                      },
                      timezoneHelper: timezoneHelper,
                    ),
                    ClearableDateTimeField(
                      labelText: 'Target Date',
                      dateGetter: () {
                        return taskItemBlueprint.targetDate;
                      },
                      initialPickerGetter: () {
                        return _getOnePastPreviousDateOrNow(
                            TaskDateTypes.target);
                      },
                      firstDateGetter: () {
                        return taskItemBlueprint.startDate;
                      },
                      currentDateGetter: () {
                        return _getPreviousDateOrNow(TaskDateTypes.target);
                      },
                      dateSetter: (DateTime? pickedDate) {
                        print('[TM-300 DEBUG] Target Date dateSetter called with: $pickedDate');
                        print('[TM-300 DEBUG] hasDate() before: ${hasDate()}');
                        setState(() {
                          taskItemBlueprint.targetDate = pickedDate;
                          print('[TM-300 DEBUG] blueprint.targetDate now: ${taskItemBlueprint.targetDate}');
                          print('[TM-300 DEBUG] hasDate() after: ${hasDate()}');
                          if (!hasDate()) {
                            clearRepeatOn();
                          }
                        });
                      },
                      timezoneHelper: timezoneHelper,
                    ),
                    ClearableDateTimeField(
                      labelText: 'Urgent Date',
                      dateGetter: () {
                        return taskItemBlueprint.urgentDate;
                      },
                      initialPickerGetter: () {
                        return _getOnePastPreviousDateOrNow(
                            TaskDateTypes.urgent);
                      },
                      firstDateGetter: () {
                        return taskItemBlueprint.startDate;
                      },
                      currentDateGetter: () {
                        return _getPreviousDateOrNow(TaskDateTypes.urgent);
                      },
                      dateSetter: (DateTime? pickedDate) {
                        setState(() {
                          taskItemBlueprint.urgentDate = pickedDate;
                          if (!hasDate()) {
                            clearRepeatOn();
                          }
                        });
                      },
                      timezoneHelper: timezoneHelper,
                    ),
                    ClearableDateTimeField(
                      labelText: 'Due Date',
                      dateGetter: () {
                        return taskItemBlueprint.dueDate;
                      },
                      initialPickerGetter: () {
                        return _getOnePastPreviousDateOrNow(TaskDateTypes.due);
                      },
                      firstDateGetter: () {
                        return taskItemBlueprint.startDate;
                      },
                      currentDateGetter: () {
                        return _getPreviousDateOrNow(TaskDateTypes.due);
                      },
                      dateSetter: (DateTime? pickedDate) {
                        setState(() {
                          taskItemBlueprint.dueDate = pickedDate;
                          if (!hasDate()) {
                            clearRepeatOn();
                          }
                        });
                      },
                      timezoneHelper: timezoneHelper,
                    ),
                    Visibility(
                      visible: hasDate(),
                      child: Card(
                        elevation: 3.0,
                        color: TaskColors.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 8.0),
                                      child: Text(
                                        'Repeat',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Switch(
                                        value: _repeatOn,
                                        onChanged: (value) {
                                          setState(() {
                                            _repeatOn = value;
                                          });
                                        },
                                        activeTrackColor: Colors.pinkAccent,
                                        activeColor: Colors.pink,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: _repeatOn,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 80.0,
                                              child: EditableTaskField(
                                                initialText: _getInputDisplay(
                                                    taskItemBlueprint
                                                        .recurNumber),
                                                labelText: 'Num',
                                                fieldSetter: (value) =>
                                                    taskItemBlueprint
                                                            .recurNumber =
                                                        _parseInt(value),
                                                inputType: TextInputType.number,
                                                validator: (value) {
                                                  if (_repeatOn &&
                                                      value != null &&
                                                      value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: NullableDropdown(
                                            initialValue:
                                                taskItemBlueprint.recurUnit,
                                            labelText: 'Unit',
                                            possibleValues: possibleRecurUnits,
                                            valueSetter: (value) =>
                                                taskItemBlueprint.recurUnit =
                                                    value,
                                            validator: (value) {
                                              if (_repeatOn &&
                                                  value == '(none)') {
                                                return 'Unit is required for repeat.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    NullableDropdown(
                                      initialValue: recurWaitToAnchorDate(
                                          taskItemBlueprint.recurWait),
                                      labelText: 'Anchor',
                                      possibleValues: possibleAnchorDates,
                                      valueSetter: (value) =>
                                          taskItemBlueprint.recurWait =
                                              anchorDateToRecurWait(value!),
                                      validator: (value) {
                                        if (_repeatOn && value == '(none)') {
                                          return 'Anchor Date is required for repeat.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    EditableTaskField(
                      initialText: taskItemBlueprint.description,
                      labelText: 'Notes',
                      onChanged: (value) {
                        setState(() {
                          taskItemBlueprint.description =
                              value == null || value.isEmpty ? null : value;
                        });
                      },
                      fieldSetter: (value) => taskItemBlueprint.description =
                          value == null || value.isEmpty ? null : value,
                      inputType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Visibility(
            visible: !isEditing || hasChanges(),
            child: FloatingActionButton(
              child: Icon(isEditing ? Icons.check : Icons.add),
              onPressed: () {
              final form = formKey.currentState;

              if (!_repeatOn) {
                clearRecurrenceFieldsFromTask();
              }

              if (form != null && form.validate()) {
                form.save();

                if (_repeatOn) {
                  if (!_initialRepeatOn) {
                    taskItemBlueprint.recurIteration = 1;
                  }
                  updateRecurrenceBlueprint();
                }

                // Mark as submitting for auto-close detection (new tasks)
                setState(() {
                  _submitting = true;
                });

                // Debug logging before save
                print('[TM-300 DEBUG] About to save task:');
                print('  startDate: ${taskItemBlueprint.startDate}');
                print('  targetDate: ${taskItemBlueprint.targetDate}');
                print('  dueDate: ${taskItemBlueprint.dueDate}');
                print('  urgentDate: ${taskItemBlueprint.urgentDate}');
                print('  hasDate(): ${hasDate()}');

                // Use Riverpod providers for task operations
                // Don't await - let the auto-close mechanism handle closing via stream updates
                if (editMode()) {
                  ref.read(updateTaskProvider.notifier).call(
                    task: taskItem!,
                    blueprint: taskItemBlueprint,
                  );
                } else {
                  // add mode
                  ref.read(addTaskProvider.notifier).call(
                    taskItemBlueprint,
                  );
                }
              }
            },
            ),
          ),
        );
  }
}
