
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
  return dateTime == null ? null : new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

DateTime combineDateWithTime(DateTime originalDate, int hour, int minute) {
  return new DateTime(originalDate.year, originalDate.month, originalDate.day,
      hour, minute);
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    Key key,
    this.labelText,
    this.initialDate,
    this.selectedDate,
    this.selectDate,
  }) : super(key: key);

  final String labelText;
  final DateTime initialDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  TimeOfDay getSelectedTime() {
    return getTimeFromDate(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    var dateToSelect = selectedDate == null ? initialDate : selectedDate;
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: dateToSelect,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      if (selectedDate == null) {
        selectDate(picked);
      } else {
        selectDate(combineDateWithTime(picked, selectedDate.hour, selectedDate.minute));
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    var timeToSelect = getSelectedTime() == null ? getTimeFromDate(initialDate) : getSelectedTime();
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: timeToSelect,
    );
    if (picked != null && picked != getSelectedTime()) {
      var baseDate = selectedDate == null ? initialDate : selectedDate;
      var combinedDate = combineDateWithTime(baseDate, picked.hour, picked.minute);
      selectDate(combinedDate);
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
            valueText: selectedDate == null ? '' : DateFormat.yMMMd().format(selectedDate),
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
