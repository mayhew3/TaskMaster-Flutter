import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final longDateFormat = DateFormat.yMMMMd().add_jm();

DateTime daysFromNow(int days) {
  DateTime now = DateTime.now();
  DateTime atSeven = new DateTime(now.year, now.month, now.day, 19);
  return atSeven.add(new Duration(days: days));
}

class ClearableDateTimeField extends StatelessWidget {
  const ClearableDateTimeField({
    Key key,
    this.labelText,
    this.dateGetter,
    this.dateSetter,
  }) : super(key: key);

  final String labelText;
  final ValueGetter<DateTime> dateGetter;
  final ValueChanged<DateTime> dateSetter;

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
        decoration: InputDecoration(
          labelText: labelText,
          filled: false,
          border: OutlineInputBorder(),
        ),
        format: longDateFormat,
        initialValue: dateGetter(),
        onChanged: (pickedDate) => dateSetter(pickedDate),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? daysFromNow(7),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? daysFromNow(7)),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
    );
  }
}