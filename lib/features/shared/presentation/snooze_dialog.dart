
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/parse_helper.dart';
import '../../../core/services/task_completion_service.dart';
import './widgets/editable_task_field.dart';
import './widgets/nullable_dropdown.dart';

/// Riverpod version of SnoozeDialog
///
/// Allows users to snooze a task by shifting its dates forward
class SnoozeDialog extends ConsumerStatefulWidget {

  final TaskItem taskItem;

  const SnoozeDialog({super.key,
    required this.taskItem,
  });

  @override
  ConsumerState<SnoozeDialog> createState() => SnoozeDialogState();

}

class SnoozeDialogState extends ConsumerState<SnoozeDialog> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var dateFormatThisYear = DateFormat('EEE MMM d');
  var dateFormatOtherYear = DateFormat('EEE MMM d yyyy');

  late TaskItemBlueprint blueprint;

  final BuiltList<String> possibleScheduledOptions = ListBuilder<String>([
    'This Task Only',
    'Change Schedule'
  ]).build();

  int? numUnits = 3;
  String unitName = 'Days';
  late String taskDateType;
  String? scheduledOption;

  final BuiltList<String> possibleRecurUnits = ListBuilder<String>([
    'Days',
    'Weeks',
    'Months',
    'Years',
  ]).build();

  late final BuiltList<String> possibleDateTypes;

  @override
  void initState() {
    super.initState();
    blueprint = widget.taskItem.createBlueprint();
    buildDateTypeList();
    taskDateType = possibleDateTypes[0];
    scheduledOption = requireScheduleOption() ?
      possibleScheduledOptions[0] :
      null;

    onNumUnitsChanged('3');
  }

  bool requireScheduleOption() {
    return blueprint.recurrenceBlueprint?.recurWait == false && !blueprint.offCycle;
  }

  void buildDateTypeList() {
    var listBuilder = ListBuilder<String>();
    for (var dateType in TaskDateTypes.allTypes) {
      var dateFieldOfType = dateType.dateFieldGetter(blueprint);
      if (dateFieldOfType != null) {
        listBuilder.add(dateType.label);
      }
    }
    if (listBuilder.isEmpty) {
      listBuilder.addAll([
        'Start',
        'Target',
        'Urgent',
        'Due'
      ]);
    }
    possibleDateTypes = listBuilder.build();
  }

  void onNumUnitsChanged(String? value) {
    try {
      numUnits = ParseHelper.parseInt(value);
      updateTaskItemWithPreview();
    } catch (e) {
      String valueStr = value ?? '';
      print('Invalid number: $valueStr');
    }
  }

  void updateTaskItemWithPreview() {
    var typeWithLabel = TaskDateTypes.getTypeWithLabel(taskDateType);
    if (numUnits != null && typeWithLabel != null) {
      setState(() {
        blueprint.offCycle = scheduledOption == possibleScheduledOptions[0];
        RecurrenceHelper.generatePreview(blueprint, numUnits!, unitName, typeWithLabel);
      });
    }
  }

  List<Widget> getWidgets() {
    final timezoneHelperAsync = ref.watch(timezoneHelperNotifierProvider);

    var widgets = [
      Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 80.0,
                child: EditableTaskField(
                  initialText: numUnits.toString(),
                  labelText: 'Num',
                  onChanged: onNumUnitsChanged,
                  fieldSetter: onNumUnitsChanged,
                  inputType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
              initialValue: unitName,
              labelText: 'Unit',
              possibleValues: possibleRecurUnits,
              onChanged: (value) => updateTaskItemWithPreview(),
              valueSetter: (value) => unitName = value ?? '',
              validator: (value) {
                return null;
              },
            ),
          ),
        ],
      ),
      NullableDropdown(
        initialValue: taskDateType,
        labelText: 'For Date',
        possibleValues: possibleDateTypes,
        onChanged: (value) => updateTaskItemWithPreview(),
        valueSetter: (value) => taskDateType = value!,
        validator: (value) {
          return null;
        },
      ),
      Visibility(
        visible: scheduledOption != null,
        child: NullableDropdown(
            initialValue: scheduledOption,
            labelText: 'Change',
            possibleValues: possibleScheduledOptions,
            valueSetter: (value) => scheduledOption = value!,
        ),
      ),
    ];

    // Add date previews
    timezoneHelperAsync.whenData((timezoneHelper) {
      for (var dateType in TaskDateTypes.allTypes) {
        DateTime? dateFieldOfType = dateType.dateFieldGetter(blueprint);
        var dateTypeString = dateType.label;
        var actualDate = dateFieldOfType;
        if (actualDate != null) {
          DateTime localDate = timezoneHelper.getLocalTime(actualDate);
          String dateFormatted = (DateTime
              .now()
              .year == localDate.year) ?
          dateFormatThisYear.format(localDate) :
          dateFormatOtherYear.format(localDate);
          Text text = Text('$dateTypeString: $dateFormatted');
          widgets.add(text);
        }
      }
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the snooze provider to keep it alive during async operations
    // (AutoDispose providers get disposed when nothing watches them)
    ref.watch(snoozeTaskProvider);

    return PopScope(
      canPop: true,
      child: AlertDialog(
        title: Text('Snooze Task'),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: getWidgets(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          Visibility(
            child: TextButton(
              onPressed: () async {
                final form = formKey.currentState;

                if (form != null && form.validate()) {
                  // need this to trigger valueSetters for any fields still in focus
                  form.save();
                }

                var typeWithLabel = TaskDateTypes.getTypeWithLabel(taskDateType);
                if (typeWithLabel != null && numUnits != null) {
                  if (blueprint.recurrenceBlueprint?.recurNumber == null) {
                    blueprint.recurrenceBlueprint = null;
                  }

                  // Use the snoozeTaskProvider to execute the snooze
                  await ref.read(snoozeTaskProvider.notifier).call(
                    taskItem: widget.taskItem,
                    blueprint: blueprint,
                    numUnits: numUnits!,
                    unitSize: unitName,
                    dateType: typeWithLabel,
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
            ),
          )
        ],
      ),
    );
  }

}
