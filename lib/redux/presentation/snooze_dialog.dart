
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/parse_helper.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/presentation/snooze_dialog_viewmodel.dart';

import '../app_state.dart';
import 'editable_task_field.dart';
import 'nullable_dropdown.dart';

class SnoozeDialog extends StatefulWidget {

  final TaskItem taskItem;

  const SnoozeDialog({super.key, 
    required this.taskItem,
  });

  @override
  State<StatefulWidget> createState() => SnoozeDialogState();

}

class SnoozeDialogState extends State<SnoozeDialog> {
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

  List<Widget> getWidgets(SnoozeDialogViewModel viewModel) {

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

    for (var dateType in TaskDateTypes.allTypes) {
      DateTime? dateFieldOfType = dateType.dateFieldGetter(blueprint);
      var dateTypeString = dateType.label;
      var actualDate = dateFieldOfType;
      if (actualDate != null) {
        DateTime localDate = viewModel.timezoneHelper.getLocalTime(actualDate);
        String dateFormatted = (DateTime
            .now()
            .year == localDate.year) ?
        dateFormatThisYear.format(localDate) :
        dateFormatOtherYear.format(localDate);
        Text text = Text('$dateTypeString: $dateFormatted');
        widgets.add(text);
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (context, viewModel) {
          return PopScope(
            canPop: true,
            child: AlertDialog(
              title: Text('Snooze Task'),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: getWidgets(viewModel),
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
                        StoreProvider.of<AppState>(context).dispatch(ExecuteSnooze(
                          taskItem: widget.taskItem,
                          blueprint: blueprint,
                          numUnits: numUnits!,
                          unitSize: unitName,
                          dateType: typeWithLabel,
                        ));
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Submit'),
                  ),
                )
              ],
            ),
          ) ;
        },
        converter: SnoozeDialogViewModel.fromStore
    );

  }

}