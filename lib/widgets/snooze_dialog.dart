
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_edit.dart';
import 'package:taskmaster/parse_helper.dart';
import 'package:taskmaster/task_helper.dart';

import 'editable_task_field.dart';
import 'nullable_dropdown.dart';

class SnoozeDialog extends StatefulWidget {

  final TaskItem taskItem;
  final TaskHelper taskHelper;

  SnoozeDialog({
    required this.taskItem,
    required this.taskHelper,
  });

  @override
  State<StatefulWidget> createState() => SnoozeDialogState();

}

class SnoozeDialogState extends State<SnoozeDialog> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var dateFormatThisYear = new DateFormat('EEE MMM d');
  var dateFormatOtherYear = new DateFormat('EEE MMM d yyyy');

  late TaskItemEdit taskItemEdit;

  int? numUnits = 3;
  String unitName = 'Days';
  String? taskDateType;

  List<String> possibleRecurUnits = [
    'Days',
    'Weeks',
    'Months',
    'Years',
  ];

  List<String> possibleDateTypes = [];

  @override
  void initState() {
    super.initState();
    taskItemEdit = widget.taskItem.createEditTemplate();
    TaskDateTypes.allTypes.forEach((dateType) {
      var dateFieldOfType = dateType.dateFieldGetter(taskItemEdit);
      if (dateFieldOfType != null) {
        possibleDateTypes.add(dateType.label);
      }
    });
    if (possibleDateTypes.isEmpty) {
      possibleDateTypes = [
        'Start',
        'Target',
        'Urgent',
        'Due'
      ];
    }
    taskDateType = possibleDateTypes[0];

    onNumUnitsChanged('3');
  }

  void onNumUnitsChanged(String? value) {
    numUnits = ParseHelper.parseInt(value);
    updateTaskItemWithPreview();
  }

  void updateTaskItemWithPreview() {
    var typeWithLabel = TaskDateTypes.getTypeWithLabel(taskDateType);
    if (numUnits != null && typeWithLabel != null) {
      setState(() {
        widget.taskHelper.previewSnooze(taskItemEdit, numUnits!, unitName, typeWithLabel);
      });
    }
  }

  List<Widget> getWidgets() {
    if (taskItemEdit.isScheduledRecurrence()) {
      return [
        Text('Snooze doesn''t yet support Scheduled Dates recurrences.')
      ];
    } else {
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
          valueSetter: (value) => taskDateType = value,
          validator: (value) {
            return null;
          },
        ),
      ];

      TaskDateTypes.allTypes.forEach((dateType) {
        DateTime? dateFieldOfType = dateType.dateFieldGetter(taskItemEdit);
        var dateTypeString = dateType.label;
        var actualDate = dateFieldOfType;
        if (actualDate != null) {
          String dateFormatted = (DateTime
              .now()
              .year == actualDate.year) ?
          dateFormatThisYear.format(actualDate) :
          dateFormatOtherYear.format(actualDate);
          Text text = Text(dateTypeString + ': ' + dateFormatted);
          widgets.add(text);
        }
      });

      return widgets;
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
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
            visible: !taskItemEdit.isScheduledRecurrence(),
            child: TextButton(
              onPressed: () async {
                final form = formKey.currentState;

                if (form != null && form.validate()) {
                  // need this to trigger valueSetters for any fields still in focus
                  form.save();
                }

                var typeWithLabel = TaskDateTypes.getTypeWithLabel(taskDateType);
                if (typeWithLabel != null && numUnits != null) {
                  await widget.taskHelper.snoozeTask(widget.taskItem,
                      taskItemEdit, numUnits!, unitName, typeWithLabel);
                }
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          )
        ],
      ),
    ) ;

  }

}