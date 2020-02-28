
import 'package:intl/intl.dart';

abstract class TaskField<T> {
  String fieldName;
  T value;
  T originalValue;

  TaskField(this.fieldName) {
    this.originalValue = this.value;
  }

  TaskField.withValues(this.fieldName, this.value) {
    this.originalValue = this.value;
  }

  initializeValue(T value) {
    this.value = value;
    this.originalValue = value;
  }

  afterUpdate() {
    this.originalValue = this.value;
  }

  revert() {
    this.value = this.originalValue;
  }

  bool isChanged() {
    return value != originalValue;
  }

  initializeValueFromString(String str) {
    T parseValue = _parseValue(str);
    initializeValue(parseValue);
  }

  setValueFromString(String str) {
    T parseValue = _parseValue(str);
    value = parseValue;
  }

  Object formatForJSON() {
    return value;
  }

  String toString() {
    return value.toString();
  }

  T _parseValue(String str);
}

class TaskFieldDate extends TaskField<DateTime> {
  TaskFieldDate(String fieldName) : super(fieldName);

  TaskFieldDate.withValues(String fieldName, DateTime value) : super.withValues(fieldName, value);

  DateTime _parseValue(String str) {
    return DateTime.parse(str).toLocal();
  }

  @override
  Object formatForJSON() {
    if (value == null) {
      return null;
    } else {
      var utc = value.toUtc();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(utc);
    }
  }
}

class TaskFieldString extends TaskField<String> {
  TaskFieldString(String fieldName) : super(fieldName);

  TaskFieldString.withValues(String fieldName, String value) : super.withValues(fieldName, value);

  @override
  initializeValueFromString(String str) {
    value = str;
    originalValue = str;
  }

  @override
  Object formatForJSON() {
    return value == null || value.isEmpty ? null : value.trim();
  }

  @override
  String _parseValue(String str) {
    return str;
  }
}

class TaskFieldInteger extends TaskField<int> {
  TaskFieldInteger(String fieldName) : super(fieldName);

  TaskFieldInteger.withValues(String fieldName, int value) : super.withValues(fieldName, value);

  @override
  int _parseValue(String str) {
    return int.parse(str);
  }

}

class TaskFieldBoolean extends TaskField<bool> {
  TaskFieldBoolean(String fieldName) : super(fieldName);

  TaskFieldBoolean.withValues(String fieldName, bool value) : super.withValues(fieldName, value);

  @override
  bool _parseValue(String str) {
    return (str == 'true');
  }
}