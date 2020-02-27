
abstract class TaskField<T> {
  String fieldName;
  T fieldValue;

  TaskField(this.fieldName);

  TaskField.withValues(this.fieldName, this.fieldValue);
}

class TaskFieldDate extends TaskField<DateTime> {
  TaskFieldDate(String fieldName) : super(fieldName);

  TaskFieldDate.withValues(String fieldName, DateTime value) : super.withValues(fieldName, value);

  setValuefromJSON(String jsonStr) {
    DateTime local = DateTime.parse(jsonStr).toLocal();
    fieldValue = local;
  }
}

class TaskFieldString extends TaskField<String> {
  TaskFieldString(String fieldName) : super(fieldName);

  TaskFieldString.withValues(String fieldName, String value) : super.withValues(fieldName, value);
}

class TaskFieldInteger extends TaskField<int> {
  TaskFieldInteger(String fieldName) : super(fieldName);

  TaskFieldInteger.withValues(String fieldName, int value) : super.withValues(fieldName, value);
}

class TaskFieldBoolean extends TaskField<bool> {
  TaskFieldBoolean(String fieldName) : super(fieldName);

  TaskFieldBoolean.withValues(String fieldName, bool value) : super.withValues(fieldName, value);
}