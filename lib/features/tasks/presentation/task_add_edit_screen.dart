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
import 'package:taskmaestro/features/contexts/presentation/context_picker.dart';
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

  bool _repeatOn = false;
  late bool _initialRepeatOn;

  /// Set to true the first time the user taps Save while Repeat is on but
  /// some required field (every-N / unit / anchor) is missing. Drives the
  /// inline error highlight on the RepeatEditorCard. Cleared when Repeat
  /// is toggled off (no recurrence to validate) or when a successful save
  /// reaches the providers.
  bool _repeatValidationFailed = false;

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
    // TM-181: contexts now come from the per-user catalog. The legacy
    // hardcoded list was removed; the catalog is read inside ContextPicker
    // via contextsWithDefaultsProvider, which lazily seeds the same eight
    // names on first read for a brand-new user.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // For new tasks (no ID), initialize immediately with a blank
    // blueprint. For edits, defer initialization to build() — a
    // ref.read here returns null during the brief startup window
    // between screen mount and Drift hydration, which silently
    // flipped the screen into "new task / blank" mode for the rest
    // of its lifetime even after the task became available.
    if (!_initialized && widget.taskItemId == null) {
      _initializeTask(null);
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

    // Per-task priority scale migration (TM-358). Legacy rows (scale
    // version 1) stored priority on a 1–10 scale; the redesigned bar
    // works on a 1–5 scale (version 2). On opening a legacy task we
    // (a) mirror the scale-aware value into the blueprint so the bar
    // renders the right fills, (b) persist the migration silently via
    // updateTask, and (c) update the local change-detection baseline
    // (`taskItem`) so the silent migration doesn't show up as a
    // pending edit (Save Changes stays disabled until the user makes
    // a real edit). New tasks always start at version 2.
    if (task == null) {
      taskItemBlueprint.priorityScaleVersion = 2;
    } else if (task.priorityScaleVersion < 2) {
      // Always bump the blueprint's scale version in memory so the bar
      // renders on the new scale and hasChanges() compares correctly.
      taskItemBlueprint.priorityScaleVersion = 2;

      if (task.priority != null) {
        // Real priority value to migrate — mirror it into the blueprint
        // and persist silently (auto-close is gated on `_submitting`,
        // which is false here, so the resulting stream re-emit won't
        // pop the screen).
        final migratedPriority = task.displayPriority;
        taskItemBlueprint.priority = migratedPriority;
        // Schedule the persistence write for after the current frame so
        // it doesn't fire a provider mutation while we're still inside
        // build() — `_initializeTask` is called from build() on the
        // edit-mode loading path, and writing through the provider mid-
        // build risks setState-during-build errors. Mounted check
        // covers the race where the screen pops before the post-frame
        // callback fires.
        final blueprintAtMigration = taskItemBlueprint;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(updateTaskProvider.notifier).call(
                task: task,
                blueprint: blueprintAtMigration,
              );
        });
        taskItem = task.rebuild((b) => b
          ..priority = migratedPriority
          ..priorityScaleVersion = 2);
      } else {
        // No priority value → no migration to persist. Still update the
        // local change-detection baseline so the in-memory scale bump
        // doesn't show up as a pending edit (Save Changes stays
        // disabled until the user makes a real edit).
        taskItem = task.rebuild((b) => b..priorityScaleVersion = 2);
      }
    }
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

  // ---- Per-field change detection (TM-358 "what's changed" indicator) ----
  // For new tasks (`taskItem == null`) every field is "fresh" — there is
  // nothing to compare against — so all of these getters return false and
  // no green-border highlight renders.

  bool _diff(bool Function(TaskItem original) isDifferent) =>
      taskItem != null && isDifferent(taskItem!);

  bool get _nameChanged =>
      _diff((t) => t.name != (taskItemBlueprint.name ?? ''));
  bool get _areaChanged => _diff((t) => t.area != taskItemBlueprint.area);
  bool get _contextChanged => _diff((t) {
        // Compare BOTH name and value per element, in order. Tier 1 only
        // surfaces the name in the picker, but `value` is part of the
        // persisted schema (Tier 2 numeric contexts) and the model's
        // hasChangesBlueprint treats it as significant — keeping the
        // change-highlight in sync with that contract.
        final taskList = t.contexts.toList();
        final blueprintList = taskItemBlueprint.contexts;
        if (taskList.length != blueprintList.length) return true;
        for (var i = 0; i < taskList.length; i++) {
          if (taskList[i].name != blueprintList[i].name) return true;
          if (taskList[i].value != blueprintList[i].value) return true;
        }
        return false;
      });
  bool get _priorityChanged =>
      _diff((t) => t.priority != taskItemBlueprint.priority);
  bool get _pointsChanged =>
      _diff((t) => t.gamePoints != taskItemBlueprint.gamePoints);
  bool get _lengthChanged =>
      _diff((t) => t.duration != taskItemBlueprint.duration);
  bool get _datesChanged => _diff((t) =>
      t.startDate != taskItemBlueprint.startDate ||
      t.targetDate != taskItemBlueprint.targetDate ||
      t.urgentDate != taskItemBlueprint.urgentDate ||
      t.dueDate != taskItemBlueprint.dueDate);
  bool get _repeatChanged {
    if (taskItem == null) return false;
    if (_repeatOn != _initialRepeatOn) return true;
    return taskItem!.recurNumber != taskItemBlueprint.recurNumber ||
        taskItem!.recurUnit != taskItemBlueprint.recurUnit ||
        taskItem!.recurWait != taskItemBlueprint.recurWait;
  }

  bool get _notesChanged =>
      _diff((t) => t.description != taskItemBlueprint.description);

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
      // Recurrence requires `every`, `unit`, and `anchor` when toggled
      // on. The legacy screen enforced this via per-field FormField
      // validators; the redesigned RepeatEditorCard uses raw segmented
      // bars + a TextField (no FormField wrappers), so we validate at
      // the screen level and surface inline error highlights on the
      // missing fields by flipping a flag the card watches.
      if (_repeatOn) {
        final missingNumber = taskItemBlueprint.recurNumber == null ||
            taskItemBlueprint.recurNumber! <= 0;
        final missingUnit = taskItemBlueprint.recurUnit == null;
        final missingAnchor = taskItemBlueprint.recurWait == null;
        if (missingNumber || missingUnit || missingAnchor) {
          setState(() => _repeatValidationFailed = true);
          return;
        }
      }

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
    // Edit mode: wait for the task to materialize in the provider before
    // initializing the form. ref.watch (not read) so a startup-race null
    // recovers as soon as Drift / Firestore / family / completed-batches
    // populate it. _initialized is the latch — once we've populated the
    // blueprint, subsequent provider emits won't clobber the user's
    // in-flight edits.
    if (widget.taskItemId != null && !_initialized) {
      final task = ref.watch(taskProvider(widget.taskItemId!));
      if (task == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Task Details')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      _initializeTask(task);
      _initialized = true;
    }

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

        final timezoneHelperAsync = ref.watch(timezoneHelperProvider);
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
    // BorderRadius reused across most field wrappers — slightly larger
    // than the inner field's own corner so the green ring frames it.
    const fieldRadius = BorderRadius.all(Radius.circular(12));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NameField(
          initialText: taskItemBlueprint.name,
          changed: _nameChanged,
          onChanged: (value) {
            setState(() {
              taskItemBlueprint.name = value;
            });
          },
          onSaved: (value) => taskItemBlueprint.name = value,
        ),
        const SizedBox(height: 22),

        const FieldLabel('Area'),
        _ChangedFieldHighlight(
          changed: _areaChanged,
          borderRadius: fieldRadius,
          child: AreaPicker(
            initialValue: taskItemBlueprint.area,
            // Wrap the setter in setState so the green changed-border and
            // the bottom Save bar update immediately. AreaPicker is no
            // longer a FormField (it's a custom chevron-button + sheet
            // since TM-358), so the parent Form's onChanged hook doesn't
            // fire on selection — we have to push the rebuild ourselves.
            valueSetter: (value) {
              setState(() {
                taskItemBlueprint.area = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        const FieldLabel('Context'),
        _ChangedFieldHighlight(
          changed: _contextChanged,
          borderRadius: fieldRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ContextPicker(
              selected: taskItemBlueprint.contexts,
              onChanged: (next) {
                setState(() {
                  taskItemBlueprint.contexts = next;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        FieldLabel(
          'Priority',
          hint: taskItemBlueprint.priority == null
              ? null
              : '${taskItemBlueprint.priority}/5',
        ),
        _ChangedFieldHighlight(
          changed: _priorityChanged,
          borderRadius: fieldRadius,
          child: SegmentedBar(
            value: taskItemBlueprint.priority,
            segments: 5,
            accent: SegmentedBarAccent.priority,
            fillUpTo: true,
            onChanged: (v) {
              setState(() {
                taskItemBlueprint.priority = v;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        FieldLabel(
          'Points',
          hint: taskItemBlueprint.gamePoints == null
              ? null
              : '${taskItemBlueprint.gamePoints} pts',
        ),
        _ChangedFieldHighlight(
          changed: _pointsChanged,
          borderRadius: fieldRadius,
          child: PointsPicker(
            value: taskItemBlueprint.gamePoints,
            onChanged: (v) {
              setState(() {
                taskItemBlueprint.gamePoints = v;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        FieldLabel(
          'Length',
          hint: taskItemBlueprint.duration == null
              ? null
              : '${taskItemBlueprint.duration} min',
        ),
        _ChangedFieldHighlight(
          changed: _lengthChanged,
          borderRadius: fieldRadius,
          child: LengthBucketPicker(
            minutes: taskItemBlueprint.duration,
            onChanged: (m) {
              setState(() {
                taskItemBlueprint.duration = m;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        const FieldLabel('Dates', hint: 'Tap to edit · all optional'),
        _ChangedFieldHighlight(
          changed: _datesChanged,
          borderRadius: fieldRadius,
          child: DateSummaryRow(
            dates: _datesMap(timezoneHelper),
            onTap: () => _openDatesPopup(timezoneHelper),
          ),
        ),
        const SizedBox(height: 16),

        const FieldLabel('Repeat'),
        _ChangedFieldHighlight(
          changed: _repeatChanged,
          borderRadius: fieldRadius,
          child: _buildRepeatSection(),
        ),
        const SizedBox(height: 16),

        const FieldLabel('Notes'),
        _ChangedFieldHighlight(
          changed: _notesChanged,
          borderRadius: fieldRadius,
          child: _NotesField(
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
        ),
      ],
    );
  }

  /// Returns each date field as a *local* DateTime, since blueprint values
  /// hydrated from Firestore are UTC. Mirrors the legacy
  /// `ClearableDateTimeField` pattern: convert UTC → local for display, and
  /// the storage layer round-trips back to UTC on save.
  Map<TaskDateType, DateTime?> _datesMap(TimezoneHelper tz) {
    return {
      for (final t in TaskDateTypes.allTypes)
        t: () {
          final raw = t.dateFieldGetter(taskItemBlueprint);
          return raw == null ? null : tz.getLocalTime(raw);
        }(),
    };
  }

  void _openDatesPopup(TimezoneHelper timezoneHelper) {
    DateTimelinePopup.show(
      context: context,
      dates: _datesMap(timezoneHelper),
      onChanged: (type, value) {
        // The popup hands us a local-time value (or null). Pass it through
        // to the setter as-is — the storage layer converts to UTC on save.
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
      showValidationErrors: _repeatValidationFailed,
      onEnabledChanged: (v) {
        setState(() {
          _repeatOn = v;
          // Toggling off clears the validation state — there's no
          // recurrence to validate anymore. Toggling on doesn't preempt
          // validation; errors only render after the user attempts Save.
          if (!v) _repeatValidationFailed = false;
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

/// Wraps a field with a soft 2-px green ring when [changed] is true. The
/// padding is preserved when not changed (transparent border occupies the
/// same space) so toggling doesn't shift layout.
class _ChangedFieldHighlight extends StatelessWidget {
  final bool changed;
  final BorderRadius borderRadius;
  final Widget child;

  /// Light green that reads against the brand-blue card surface.
  static const Color _accent = Color(0xFF8FE5A1);
  static const Duration _animDuration = Duration(milliseconds: 180);
  static const double _borderWidth = 2;
  static const double _innerGap = 2;

  const _ChangedFieldHighlight({
    required this.changed,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animDuration,
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(_innerGap),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: changed ? _accent : Colors.transparent,
          width: _borderWidth,
        ),
      ),
      child: child,
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
  final bool changed;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String?> onSaved;

  const _NameField({
    required this.initialText,
    required this.changed,
    required this.onChanged,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    // Underline-only field, so the "changed" indicator recolors the
    // underline (using the same accent green as wrapped fields) instead
    // of adding a ring around the input.
    final underlineColor = changed
        ? _ChangedFieldHighlight._accent
        : Colors.white.withValues(alpha: 0.18);
    final focusedColor = changed
        ? _ChangedFieldHighlight._accent
        : Colors.white.withValues(alpha: 0.50);
    final width = changed ? 2.0 : 1.0;
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
          borderSide: BorderSide(color: underlineColor, width: width),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: underlineColor, width: width),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: focusedColor, width: width),
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
      // The default 20-px scrollPadding leaves the focused field flush with
      // the bottom of the scroll viewport — but the sticky action bar
      // overlays that region, so the field ends up hidden by the bar (and
      // by the keyboard above the bar). 120 px clears the action bar with
      // a comfortable visual buffer.
      scrollPadding: const EdgeInsets.only(bottom: 120),
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
