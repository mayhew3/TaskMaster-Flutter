
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';
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

  var dateFormat = new DateFormat('EEE MMM d');

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
    TaskDateType.values.forEach((dateType) {
      var dateFieldOfType = widget.taskItem.getDateFieldOfType(dateType);
      if (dateFieldOfType.value != null) {
        possibleDateTypes.add(TaskItem.getDateTypeString(dateType));
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
  }

  List<Widget> getWidgets() {
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
                  onChanged: (value) => numUnits = _parseValue(value),
                  fieldSetter: (value) => numUnits = _parseValue(value),
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
        valueSetter: (value) => taskDateType = value,
        validator: (value) {
          return null;
        },
      ),
    ];

    TaskDateType.values.forEach((dateType) {
      TaskField dateFieldOfType = widget.taskItem.getDateFieldOfType(dateType);
      var dateTypeString = TaskItem.getDateTypeString(dateType);
      if (dateFieldOfType.value != null) {
        // TODO: Calculate dates based on inputs, maybe in new TaskHelper method?
        Text text = Text(dateTypeString + ': ' + dateFormat.format(dateFieldOfType.value));
        widgets.add(text);
      }
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
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
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FlatButton(
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
      ],
    );
  }

  int _parseValue(String str) {
    var cleanString = _cleanString(str);
    return cleanString == null ? null : int.parse(str);
  }

  String _cleanString(String str) {
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

}