import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final longDateFormat = DateFormat.yMMMMd().add_jm();

DateTime daysFromNow(int days) {
  DateTime now = DateTime.now();
  DateTime atTwo = DateTime(now.year, now.month, now.day, 14);
  return atTwo.add(Duration(days: days));
}

class ClearableDateTimeField extends StatelessWidget {
  const ClearableDateTimeField({
    Key key,
    required this.labelText,
    required this.dateGetter,
    required this.dateSetter,
    required this.initialPickerGetter,
    this.firstDateGetter,
    this.currentDateGetter,
  }) : super(key: key);

  final String labelText;
  final ValueGetter<DateTime> dateGetter;
  final ValueGetter<DateTime> initialPickerGetter;
  final ValueGetter<DateTime> firstDateGetter;
  final ValueGetter<DateTime> currentDateGetter;
  final ValueChanged<DateTime> dateSetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: DateTimeField(
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
              firstDate: firstDateGetter == null || firstDateGetter() == null ?
                            DateTime(1900) :
                            firstDateGetter(),
              currentDate: currentDateGetter == null || currentDateGetter() == null ?
                            DateTime.now() :
                            currentDateGetter(),
              initialDate: currentValue ?? initialPickerGetter(),
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
      ),
    );
  }
}