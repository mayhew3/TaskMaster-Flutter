import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/models/models.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_item_blueprint.dart';
import 'package:taskmaestro/models/task_recurrence_blueprint.dart';
import 'package:taskmaestro/features/areas/presentation/area_picker.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_summary_row.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_timeline_popup.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/field_label.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/length_bucket_picker.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/points_picker.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/repeat_editor_card.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/tm_bottom_action_bar.dart';
import 'package:taskmaestro/helpers/task_selectors.dart';
import 'package:taskmaestro/timezone_helper.dart';
import '../../../core/services/task_completion_service.dart';
import '../../family/providers/family_providers.dart';
import '../providers/task_providers.dart';

/// Riverpod version of the Add/Edit Task screen
/// Handles creating new tasks and editing existing tasks
class TaskAddEditScreen extends ConsumerStatefulWidget {
  final String? taskItemId;

  /// When `true` and adding a new task (no [taskItemId]), pre-stamp the
  /// blueprint with the current user's `familyDocId` so the task becomes
  /// family-shared. Set by the Family-tab FAB; the Tasks-tab FAB leaves
  /// this `false` so additions stay personal even while in a family.
  final bool defaultFamilyShared;

  const TaskAddEditScreen({
    super.key,
    this.taskItemId,
    this.defaultFamilyShared = false,
  });

  @override
  ConsumerState<TaskAddEditScreen> createState() => _TaskAddEditScreenState();
}

class _TaskAddEditScreenState extends ConsumerState<TaskAddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late BuiltList<String> possibleContexts;

  bool _repeatOn = false;
  late bool _initialRepeatOn;

  late TaskItemBlueprint taskItemBlueprint;
  TaskItem? taskItem;

  TaskItemBlueprint blankBlueprint = TaskItemBlueprint();
  late TaskRecurrenceBlueprint taskRecurrenceBlueprint;

  bool popped = false;
  int? _initialTaskCount;
  bool _submitting = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    possibleContexts = ListBuilder<String>([
      'Computer',
      'Home',
      'Office',
      'E-Mail',
      'Phone',
      'Outside',
      'Reading',
      'Planning',
    ]).build();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    if (task == null && widget.defaultFamilyShared) {
      taskItemBlueprint.familyDocId = ref.read(currentFamilyDocIdProvider);
    }
    var existingRecurrence = task?.recurrence;
    taskRecurrenceBlueprint = (existingRecurrence == null)
        ? TaskRecurrenceBlueprint()
        : existingRecurrence.createBlueprint();

    _initialRepeatOn = task?.recurrenceDocId != null;
    _repeatOn = _initialRepeatOn;
  }

  bool get isEditing => widget.taskItemId != null;
  bool editMode() => taskItem != null;

  bool hasDate() => taskItemBlueprint.getAnchorDate() != null;

  bool? _anchorLabelToRecurWait(String? label) {
    if (label == null) return null;
    return label == 'Completed Date';
  }

  String? _recurWaitToAnchorLabel(bool? recurWait) {
    if (recurWait == null) return null;
    return recurWait ? 'Completed Date' : 'Schedule Dates';
  }

  void _clearRepeatOn() {
    _repeatOn = false;
  }

  void _clearRecurrenceFieldsFromTask() {
    taskItemBlueprint.recurUnit = null;
    taskItemBlueprint.recurNumber = null;
    taskItemBlueprint.recurWait = null;
    taskItemBlueprint.recurIteration = null;
    taskItemBlueprint.recurrenceBlueprint = null;
    taskItemBlueprint.recurrenceDocId = null;
  }

  void _updateRecurrenceBlueprint() {
    taskRecurrenceBlueprint.recurIteration = taskItemBlueprint.recurIteration;
    taskRecurrenceBlueprint.recurNumber = taskItemBlueprint.recurNumber;
    taskRecurrenceBlueprint.recurWait = taskItemBlueprint.recurWait;
    taskRecurrenceBlueprint.recurUnit = taskItemBlueprint.recurUnit;
    taskRecurrenceBlueprint.name = taskItemBlueprint.name;
    taskRecurrenceBlueprint.anchorDate = taskItemBlueprint.getAnchorDate();
    taskItemBlueprint.recurrenceBlueprint = taskRecurrenceBlueprint;
    taskItemBlueprint.recurrenceDocId = taskItem?.recurrence?.docId;
  }

  bool _hasChanges() {
    if (_repeatOn != _initialRepeatOn) return true;
    if (editMode()) {
      return taskItemBlueprint.hasChanges(taskItem!);
    } else {
      return taskItemBlueprint.hasChangesBlueprint(blankBlueprint);
    }
  }

  void _checkForAutoClose() {
    if (!_submitting) return;

    final tasksAsync = ref.read(tasksWithRecurrencesProvider);
    final recurrencesAsync = ref.read(taskRecurrencesProvider);

    tasksAsync.whenData((tasks) {
      recurrencesAsync.whenData((recurrences) {
        if (popped) return;
        if (editMode()) {
          final builtTasks = BuiltList<TaskItem>(tasks);
          final builtRecurrences = BuiltList<TaskRecurrence>(recurrences);

          var latestTask = taskItemSelector(builtTasks, taskItem!.docId);
          var latestRecurrence = taskRecurrenceSelector(
            builtRecurrences,
            taskItem!.recurrence?.docId,
          );
          var hasTaskChanges =
              latestTask != null && latestTask.hasChanges(taskItem!);
          var hasRecurrenceChanges = latestRecurrence != null &&
              latestRecurrence.hasChanges(taskItem!.recurrence);
          if (hasTaskChanges || hasRecurrenceChanges) {
            popped = true;
            _scheduleAutoClose();
          }
        } else {
          if (_initialTaskCount != null && tasks.length > _initialTaskCount!) {
            popped = true;
            _scheduleAutoClose();
          }
        }
      });
    });
  }

  /// Defer the Navigator.pop until after the current notification cycle
  /// completes. Multiple ref.watch / ref.listen subscribers depend on the
  /// same providers; popping synchronously would dispose the element mid-
  /// cycle (TM-348).
  void _scheduleAutoClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pop(context);
    });
  }

  void _onSavePressed() {
    final form = formKey.currentState;

    if (!_repeatOn) {
      _clearRecurrenceFieldsFromTask();
    }

    if (form != null && form.validate()) {
      form.save();

      if (_repeatOn) {
        if (!_initialRepeatOn) {
          taskItemBlueprint.recurIteration = 1;
        }
        _updateRecurrenceBlueprint();
      }

      setState(() {
        _submitting = true;
      });

      if (editMode()) {
        ref
            .read(updateTaskProvider.notifier)
            .call(task: taskItem!, blueprint: taskItemBlueprint);
      } else {
        ref.read(addTaskProvider.notifier).call(taskItemBlueprint);
      }
    }
  }

  Future<void> _onDeletePressed() async {
    if (!editMode()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TaskColors.popupBg,
        title: const Text(
          'Delete this task?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently remove "${taskItem?.name ?? 'this task'}". You cannot undo this.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await ref.read(deleteTaskProvider.notifier).call(taskItem!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

    ref.listen<AsyncValue<List<TaskItem>>>(
      tasksWithRecurrencesProvider,
      (prev, next) => _checkForAutoClose(),
    );

    ref.listen<AsyncValue<List<TaskRecurrence>>>(
      taskRecurrencesProvider,
      (prev, next) => _checkForAutoClose(),
    );

    return tasksAsync.when(
      data: (tasks) {
        _initialTaskCount ??= tasks.length;

        final timezoneHelperAsync = ref.watch(timezoneHelperNotifierProvider);
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
      backgroundColor: TaskColors.cardColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0, -0.34), // ~280px on a typical phone height
            colors: [TaskColors.editorBgTop, TaskColors.cardColor],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _TopNav(
                    title: editMode() ? 'Edit task' : 'New task',
                    onBack: () => Navigator.of(context).pop(),
                    onDelete: editMode() ? _onDeletePressed : null,
                  ),
                  Expanded(
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: () => setState(() {}),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                        child: _buildBody(timezoneHelper),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TmBottomActionBar(
                  saveLabel: editMode() ? 'Save changes' : 'Add task',
                  cancelLabel: 'Cancel',
                  saveEnabled: !isEditing || _hasChanges(),
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _onSavePressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(TimezoneHelper timezoneHelper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NameField(
          initialText: taskItemBlueprint.name,
          onChanged: (value) {
            setState(() {
              taskItemBlueprint.name = value;
            });
          },
          onSaved: (value) => taskItemBlueprint.name = value,
        ),
        const SizedBox(height: 22),

        const FieldLabel('Area'),
        AreaPicker(
          initialValue: taskItemBlueprint.area,
          valueSetter: (value) => taskItemBlueprint.area = value,
        ),
        const SizedBox(height: 16),

        const FieldLabel('Context'),
        _ContextPickerButton(
          value: taskItemBlueprint.context,
          options: possibleContexts,
          onChanged: (value) {
            setState(() {
              taskItemBlueprint.context = value;
            });
          },
        ),
        const SizedBox(height: 16),

        FieldLabel(
          'Priority',
          hint: taskItemBlueprint.priority == null
              ? null
              : '${taskItemBlueprint.priority}/5',
        ),
        SegmentedBar(
          value: taskItemBlueprint.priority,
          segments: 5,
          accent: SegmentedBarAccent.priority,
          onChanged: (v) {
            setState(() {
              taskItemBlueprint.priority = v;
            });
          },
        ),
        const SizedBox(height: 16),

        FieldLabel(
          'Points',
          hint: taskItemBlueprint.gamePoints == null
              ? null
              : '${taskItemBlueprint.gamePoints} pts',
        ),
        PointsPicker(
          value: taskItemBlueprint.gamePoints,
          onChanged: (v) {
            setState(() {
              taskItemBlueprint.gamePoints = v;
            });
          },
        ),
        const SizedBox(height: 16),

        FieldLabel(
          'Length',
          hint: taskItemBlueprint.duration == null
              ? null
              : '${taskItemBlueprint.duration} min',
        ),
        LengthBucketPicker(
          minutes: taskItemBlueprint.duration,
          onChanged: (m) {
            setState(() {
              taskItemBlueprint.duration = m;
            });
          },
        ),
        const SizedBox(height: 16),

        const FieldLabel('Dates', hint: 'Tap to edit · all optional'),
        DateSummaryRow(
          dates: _datesMap(),
          onTap: () => _openDatesPopup(timezoneHelper),
        ),
        const SizedBox(height: 16),

        const FieldLabel('Repeat'),
        _buildRepeatSection(),
        const SizedBox(height: 16),

        const FieldLabel('Notes'),
        _NotesField(
          initialText: taskItemBlueprint.description,
          onChanged: (value) {
            setState(() {
              taskItemBlueprint.description =
                  (value == null || value.isEmpty) ? null : value;
            });
          },
          onSaved: (value) => taskItemBlueprint.description =
              (value == null || value.isEmpty) ? null : value,
        ),
      ],
    );
  }

  Map<TaskDateType, DateTime?> _datesMap() {
    return {
      for (final t in TaskDateTypes.allTypes)
        t: t.dateFieldGetter(taskItemBlueprint),
    };
  }

  void _openDatesPopup(TimezoneHelper timezoneHelper) {
    DateTimelinePopup.show(
      context: context,
      dates: _datesMap(),
      onChanged: (type, value) {
        setState(() {
          type.dateFieldSetter(taskItemBlueprint, value);
          if (!hasDate()) _clearRepeatOn();
        });
      },
    );
  }

  Widget _buildRepeatSection() {
    if (!hasDate()) {
      return _DisabledRepeatHint(
        message: 'Add a date above to enable repeats.',
      );
    }
    final willBeFamilyShared = taskItemBlueprint.familyDocId != null;
    final alreadyRecurring = _initialRepeatOn;
    final disabledReason = (willBeFamilyShared && !alreadyRecurring)
        ? "Repeating tasks aren't supported in family view yet."
        : null;
    return RepeatEditorCard(
      enabled: _repeatOn,
      number: taskItemBlueprint.recurNumber,
      unit: taskItemBlueprint.recurUnit,
      anchor: _recurWaitToAnchorLabel(taskItemBlueprint.recurWait),
      disabledReason: disabledReason,
      onEnabledChanged: (v) {
        setState(() {
          _repeatOn = v;
        });
      },
      onNumberChanged: (v) {
        setState(() {
          taskItemBlueprint.recurNumber = v;
        });
      },
      onUnitChanged: (v) {
        setState(() {
          taskItemBlueprint.recurUnit = v;
        });
      },
      onAnchorChanged: (v) {
        setState(() {
          taskItemBlueprint.recurWait = _anchorLabelToRecurWait(v);
        });
      },
    );
  }
}

class _TopNav extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDelete;

  const _TopNav({
    required this.title,
    required this.onBack,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                size: 22,
                color: const Color(0xFFFFB4B4).withValues(alpha: 0.85),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final String? initialText;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String?> onSaved;

  const _NameField({
    required this.initialText,
    required this.onChanged,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('task_name_field'),
      initialValue: initialText,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Name is required' : null,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
      decoration: InputDecoration(
        hintText: 'Task name',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.40),
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.only(bottom: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.50),
          ),
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final String? initialText;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String?> onSaved;

  const _NotesField({
    required this.initialText,
    required this.onChanged,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialText,
      onChanged: onChanged,
      onSaved: onSaved,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 3,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Add notes...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.40)),
        filled: true,
        fillColor: TaskColors.fieldSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: TaskColors.fieldBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: TaskColors.fieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
      ),
    );
  }
}

/// Single-select Context picker button — opens a modal bottom sheet listing
/// the options. Single-select for now; will become multi-select pills when
/// the `String? context → List<String> contexts` migration lands (TM-362).
class _ContextPickerButton extends StatelessWidget {
  final String? value;
  final BuiltList<String> options;
  final ValueChanged<String?> onChanged;

  const _ContextPickerButton({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TaskColors.fieldSurface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TaskColors.fieldBorder, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? 'None',
                  style: TextStyle(
                    color: value == null
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.white.withValues(alpha: 0.40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: TaskColors.popupBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Select context',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _ContextOption(
                  label: 'None',
                  selected: value == null,
                  italic: true,
                  onTap: () {
                    onChanged(null);
                    Navigator.of(ctx).pop();
                  },
                ),
                ...options.map(
                  (o) => _ContextOption(
                    label: o,
                    selected: value == o,
                    onTap: () {
                      onChanged(o);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContextOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool italic;
  final VoidCallback onTap;

  const _ContextOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: italic
                        ? Colors.white.withValues(alpha: 0.65)
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check,
                  size: 18,
                  color: Color.fromRGBO(143, 184, 255, 0.95),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisabledRepeatHint extends StatelessWidget {
  final String message;

  const _DisabledRepeatHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: TaskColors.fieldBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: TaskColors.textFaint,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: TaskColors.textDim,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Suppress an unused-import warning for SystemChannels — keeps the import
// path stable in case future iterations need keyboard control on the
// number input.
// ignore: unused_element
void _silenceUnusedSystemChannels() => SystemChannels.textInput;
