
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/parse_helper.dart';
import 'package:taskmaster/task_helper.dart';

import 'editable_task_field.dart';
import 'nullable_dropdown.dart';

class SnoozeDialog extends StatefulWidget {

  final TaskItem taskItem;
  final TaskHelper taskHelper;

  SnoozeDialog({
    @required this.taskItem,
    @required this.taskHelper,
  });

  @override
  State<StatefulWidget> createState() => SnoozeDialogState();

}

class SnoozeDialogState extends State<SnoozeDialog> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var dateFormatThisYear = new DateFormat('EEE MMM d');
  var dateFormatOtherYear = new DateFormat('EEE MMM d yyyy');

  int numUnits = 3;
  String unitName = 'Days';
  String taskDateType;

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
    TaskDateTypes.allTypes.forEach((dateType) {
      var dateFieldOfType = dateType.dateFieldGetter(widget.taskItem);
      if (dateFieldOfType.value != null) {
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

  void onNumUnitsChanged(String value) {
    numUnits = ParseHelper.parseInt(value);
    updateTaskItemWithPreview();
  }

  void updateTaskItemWithPreview() {
    if (numUnits != null) {
      setState(() {
        widget.taskHelper.previewSnooze(widget.taskItem, numUnits, unitName, TaskDateTypes.getTypeWithLabel(taskDateType));
      });
    }
  }

  List<Widget> getWidgets() {
    if (widget.taskItem.isScheduledRecurrence()) {
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
                      if (value.isEmpty) {
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
                valueSetter: (value) => unitName = value,
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
        TaskField dateFieldOfType = dateType.dateFieldGetter(widget.taskItem);
        var dateTypeString = dateType.label;
        var actualDate = dateFieldOfType.value;
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
        widget.taskItem.revertAllChanges();
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
          FlatButton(
            onPressed: () {
              widget.taskItem.revertAllChanges();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          Visibility(
            visible: !widget.taskItem.isScheduledRecurrence(),
            child: FlatButton(
              onPressed: () async {
                final form = formKey.currentState;

                if (form.validate()) {
                  // need this to trigger valueSetters for any fields still in focus
                  form.save();
                }

                await widget.taskHelper.snoozeTask(widget.taskItem, numUnits, unitName, taskDateType);
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