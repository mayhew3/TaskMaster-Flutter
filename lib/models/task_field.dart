

String? _cleanString(String? str) {
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

abstract class TaskField<T> {
  String fieldName;
  T? value;
  T? originalValue;

  TaskField(this.fieldName) {
    this.originalValue = this.value;
  }

  initializeValue(T? value) {
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
    T? parseValue = _parseValue(str);
    initializeValue(parseValue);
  }

  String getInputDisplay() {
    if (value == null) {
      return '';
    } else {
      return value.toString();
    }
  }

  setValueFromString(String str) {
    T? parseValue = _parseValue(str);
    value = parseValue;
  }

  Object? formatForJSON() {
    return value;
  }

  String toString() {
    String displayString =  fieldName + ': ' + ((originalValue == null) ? '(null)' : originalValue.toString());
    if (isChanged()) {
      displayString += ' -> ' + value.toString();
    }
    return displayString;
  }

  T? _parseValue(String str);
}


// DATE

class TaskFieldDate extends TaskField<DateTime> {
  TaskFieldDate(String fieldName) : super(fieldName);

  DateTime? _parseValue(String str) {
    var cleanString = _cleanString(str);
    return cleanString == null ? null : DateTime.parse(cleanString).toLocal();
  }

  bool hasPassed() {
    var now = DateTime.now();
    return value == null ? false : value!.isBefore(now);
  }

  @override
  Object? formatForJSON() {
    if (value == null) {
      return null;
    } else {
      var utc = value!.toUtc();
      return utc.toIso8601String();
    }
  }
}


// STRING

class TaskFieldString extends TaskField<String> {
  TaskFieldString(String fieldName) : super(fieldName);

  @override
  bool isChanged() {
    return super.isChanged() && (_cleanString(value) != _cleanString(originalValue));
  }

  @override
  Object? formatForJSON() {
    return _cleanString(value);
  }

  @override
  String _parseValue(String str) {
    return str;
  }
}


// INTEGER

class TaskFieldInteger extends TaskField<int> {
  TaskFieldInteger(String fieldName) : super(fieldName);

  @override
  int? _parseValue(String str) {
    var cleanString = _cleanString(str);
    return cleanString == null ? null : int.parse(str);
  }

}


// BOOL

class TaskFieldBoolean extends TaskField<bool> {
  TaskFieldBoolean(String fieldName) : super(fieldName);

  @override
  bool? _parseValue(String str) {
    var cleanString = _cleanString(str);
    return cleanString == null ? null : (str == 'true');
  }
}