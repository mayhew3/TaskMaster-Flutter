import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/timezone_helper.dart';

final longDateFormat = DateFormat.yMMMMd().add_jm();

DateTime daysFromNow(int days) {
  DateTime now = DateTime.now();
  DateTime atTwo = DateTime(now.year, now.month, now.day, 14);
  return atTwo.add(Duration(days: days));
}

class ClearableDateTimeField extends StatelessWidget {
  const ClearableDateTimeField({
    super.key,
    required this.labelText,
    required this.dateGetter,
    required this.dateSetter,
    required this.initialPickerGetter,
    this.firstDateGetter,
    this.currentDateGetter,
    required this.timezoneHelper
  });

  final String labelText;
  final ValueGetter<DateTime?> dateGetter;
  final ValueGetter<DateTime?> initialPickerGetter;
  final ValueGetter<DateTime?>? firstDateGetter;
  final ValueGetter<DateTime?>? currentDateGetter;
  final ValueChanged<DateTime?> dateSetter;
  final TimezoneHelper timezoneHelper;

  DateTime? getLocalDate(DateTime? dateTime) {
    return dateTime == null ? null : timezoneHelper.getLocalTime(dateTime);
  }
  
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
        initialValue: getLocalDate(dateGetter()),
        onChanged: (pickedDate) {
          print('[$labelText] onChanged called with: $pickedDate');
          dateSetter(pickedDate);
        },
        onShowPicker: (context, currentValue) async {
          DateTime? firstDateNullable = firstDateGetter == null ? null : firstDateGetter!();
          DateTime firstDate = firstDateNullable ?? DateTime(1900);

          DateTime? currentDateNullable = currentDateGetter == null ? null : currentDateGetter!();
          DateTime currentDate = currentDateNullable ?? DateTime.now();

          DateTime initialDate = currentValue ?? initialPickerGetter()!;

          final date = await showDatePicker(
              context: context,
              firstDate: firstDate,
              currentDate: currentDate,
              initialDate: initialDate,
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