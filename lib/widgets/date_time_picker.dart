
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed,
  }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

TimeOfDay getTimeFromDate(DateTime dateTime) {
  return dateTime == null ? null : TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

DateTime combineDateWithTime(DateTime originalDate, int hour, int minute) {
  return DateTime(originalDate.year, originalDate.month, originalDate.day,
      hour, minute);
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    Key key,
    this.labelText,
    this.defaultDate,
    this.dateGetter,
    this.dateSetter,
  }) : super(key: key);

  final String labelText;
  final DateTime defaultDate;
  final ValueGetter<DateTime> dateGetter;
  final ValueChanged<DateTime> dateSetter;

  TimeOfDay getSelectedTime() {
    return getTimeFromDate(dateGetter());
  }

  Future<void> _selectDate(BuildContext context) async {
    var dateToSelect = dateGetter() ?? defaultDate;
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: dateToSelect,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateGetter()) {
      if (dateGetter() == null) {
        dateSetter(picked);
      } else {
        dateSetter(combineDateWithTime(picked, dateGetter().hour, dateGetter().minute));
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    var timeToSelect = getSelectedTime() == null ? getTimeFromDate(defaultDate) : getSelectedTime();
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: timeToSelect,
    );
    if (picked != null && picked != getSelectedTime()) {
      var baseDate = dateGetter() == null ? defaultDate : dateGetter();
      var combinedDate = combineDateWithTime(baseDate, picked.hour, picked.minute);
      dateSetter(combinedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _InputDropdown(
            labelText: labelText,
            valueText: dateGetter() == null ? '' : DateFormat.yMMMd().format(dateGetter()),
            valueStyle: valueStyle,
            onPressed: () { _selectDate(context); },
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 3,
          child: _InputDropdown(
            valueText: getSelectedTime() == null ? '' : getSelectedTime().format(context),
            valueStyle: valueStyle,
            onPressed: () { _selectTime(context); },
          ),
        ),
      ],
    );
  }
}
