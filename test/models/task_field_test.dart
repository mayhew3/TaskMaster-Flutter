import 'package:test/test.dart';
import 'package:taskmaster/models/task_field.dart';

void main() {
  String addWhitespace(String str) {
    return '  ' + str + ' \r\n';
  }

  group('TaskFieldDate', () {

    final DateTime theDateTime = DateTime(2019, 7, 13, 8, 12, 55);
    final startDate = 'startDate';

    String formatDateTime(DateTime dateTime) {
      var utc = dateTime.toUtc();
      return utc.toIso8601String();
    }

    test('Should be constructed', () {
      final taskField = TaskFieldDate(startDate);
      expect(taskField.fieldName, startDate);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('Should be initialized with value', () {
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValue(theDateTime);
      expect(taskField.value, theDateTime);
      expect(taskField.originalValue, theDateTime);
    });

    test('Set value shouldn\'t update original value', () {
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      expect(taskField.value, theDateTime);
      expect(taskField.originalValue, null);
    });

    test('afterUpdate', () {
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      taskField.afterUpdate();
      expect(taskField.value, theDateTime);
      expect(taskField.originalValue, theDateTime);
    });

    test('revert', () {
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      taskField.revert();
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('isChanged', () {
      final taskField = TaskFieldDate(startDate);
      expect(taskField.isChanged(), false);
      taskField.value = theDateTime;
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('initializeValueFromString', () {
      var formatted = formatDateTime(theDateTime);
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValueFromString(formatted);
      expect(taskField.value, theDateTime);
      expect(taskField.originalValue, theDateTime);
    });

    test('initializeValueFromString extra whitespace', () {
      var formatted = formatDateTime(theDateTime);
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValueFromString(addWhitespace(formatted));
      expect(taskField.value, theDateTime);
      expect(taskField.originalValue, theDateTime);
    });

    test('initializeValueFromString null string should have null date', () {
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValueFromString(null);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('initializeValueFromString empty string should have null date', () {
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValueFromString('');
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('initializeValueFromString whitespace string should have null date', () {
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValueFromString(addWhitespace(''));
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('getInputDisplay for null should be empty string', () {
      final taskField = TaskFieldDate(startDate);
      expect(taskField.getInputDisplay(), '');
    });

    test('getInputDisplay for value should be string', () {
      var expectedDisplay = theDateTime.toString();
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      expect(taskField.getInputDisplay(), expectedDisplay);
    });

    test('setValueFromString', () {
      var formatted = formatDateTime(theDateTime);
      final taskField = TaskFieldDate(startDate);
      taskField.setValueFromString(formatted);
      expect(taskField.value, theDateTime);
      expect(taskField.originalValue, null);
    });

    test('formatForJSON', () {
      var formatted = '2019-07-13T15:12:55.000Z';
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      expect(taskField.formatForJSON(), formatted);
    });

    test('toString', () {
      var stringOutput = startDate + ': (null) -> 2019-07-13 08:12:55.000';
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      expect(taskField.toString(), stringOutput);
    });

  });

  group('TaskFieldString', () {
    final name = 'name';
    final theString = 'Cat Litter';

    test('Should be constructed', () {
      final taskField = TaskFieldString(name);
      expect(taskField.fieldName, name);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('Should be initialized with value', () {
      final taskField = TaskFieldString(name);
      taskField.initializeValue(theString);
      expect(taskField.value, theString);
      expect(taskField.originalValue, theString);
    });

    test('Set value shouldn\'t update original value', () {
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      expect(taskField.value, theString);
      expect(taskField.originalValue, null);
    });

    test('afterUpdate', () {
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      taskField.afterUpdate();
      expect(taskField.value, theString);
      expect(taskField.originalValue, theString);
    });

    test('revert', () {
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      taskField.revert();
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('isChanged from null', () {
      final taskField = TaskFieldString(name);
      expect(taskField.isChanged(), false);
      taskField.value = theString;
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('isChanged from non-null', () {
      final taskField = TaskFieldString(name);
      taskField.initializeValue(theString);
      expect(taskField.isChanged(), false);
      taskField.value = 'BLAH';
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('isChanged for empty string should be false', () {
      final taskField = TaskFieldString(name);
      taskField.value = '';
      expect(taskField.isChanged(), false);
    });

    test('isChanged should ignore whitespace only', () {
      final taskField = TaskFieldString(name);
      taskField.value = addWhitespace('');
      expect(taskField.isChanged(), false);
    });

    test('isChanged should ignore extra whitespace', () {
      final taskField = TaskFieldString(name);
      taskField.initializeValue(theString);
      taskField.value = addWhitespace(theString);
      expect(taskField.isChanged(), false);
    });

    test('initializeValueFromString', () {
      final taskField = TaskFieldString(name);
      taskField.initializeValueFromString(theString);
      expect(taskField.value, theString);
      expect(taskField.originalValue, theString);
    });

    test('getInputDisplay for null should be empty string', () {
      final taskField = TaskFieldString(name);
      expect(taskField.getInputDisplay(), '');
    });

    test('getInputDisplay for value should be string', () {
      var expectedDisplay = theString;
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      expect(taskField.getInputDisplay(), expectedDisplay);
    });

    test('setValueFromString', () {
      final taskField = TaskFieldString(name);
      taskField.setValueFromString(theString);
      expect(taskField.value, theString);
      expect(taskField.originalValue, null);
    });

    test('formatForJSON', () {
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      expect(taskField.formatForJSON(), theString);
    });

    test('formatForJSON empty string should be null', () {
      final taskField = TaskFieldString(name);
      taskField.value = '';
      expect(taskField.formatForJSON(), null);
    });

    test('formatForJSON whitespace only should be null', () {
      final taskField = TaskFieldString(name);
      taskField.value = addWhitespace('');
      expect(taskField.formatForJSON(), null);
    });

    test('formatForJSON should trim extra whitespace', () {
      final taskField = TaskFieldString(name);
      taskField.value = addWhitespace(theString);
      expect(taskField.formatForJSON(), theString);
    });

    test('toString', () {
      var stringOutput = name + ': (null) -> ' + theString;
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      expect(taskField.toString(), stringOutput);
    });

  });

  group('TaskFieldInteger', () {

    final int theInt = 6;
    final priority = 'priority';

    test('Should be constructed', () {
      final taskField = TaskFieldInteger(priority);
      expect(taskField.fieldName, priority);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('Should be initialized with value', () {
      final taskField = TaskFieldInteger(priority);
      taskField.initializeValue(theInt);
      expect(taskField.value, theInt);
      expect(taskField.originalValue, theInt);
    });

    test('Set value shouldn\'t update original value', () {
      final taskField = TaskFieldInteger(priority);
      taskField.value = theInt;
      expect(taskField.value, theInt);
      expect(taskField.originalValue, null);
    });

    test('afterUpdate', () {
      final taskField = TaskFieldInteger(priority);
      taskField.value = theInt;
      taskField.afterUpdate();
      expect(taskField.value, theInt);
      expect(taskField.originalValue, theInt);
    });

    test('revert', () {
      final taskField = TaskFieldInteger(priority);
      taskField.value = theInt;
      taskField.revert();
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('isChanged', () {
      final taskField = TaskFieldInteger(priority);
      expect(taskField.isChanged(), false);
      taskField.value = theInt;
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('initializeValueFromString', () {
      var formatted = theInt.toString();
      final taskField = TaskFieldInteger(priority);
      taskField.initializeValueFromString(formatted);
      expect(taskField.value, theInt);
      expect(taskField.originalValue, theInt);
    });

    test('initializeValueFromString extra whitespace', () {
      var formatted = theInt.toString();
      final taskField = TaskFieldInteger(priority);
      taskField.initializeValueFromString(addWhitespace(formatted));
      expect(taskField.value, theInt);
      expect(taskField.originalValue, theInt);
    });

    test('initializeValueFromString null string should have null int', () {
      final taskField = TaskFieldInteger(priority);
      taskField.initializeValueFromString(null);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('initializeValueFromString empty string should have null int', () {
      final taskField = TaskFieldInteger(priority);
      taskField.initializeValueFromString('');
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('initializeValueFromString whitespace string should have null int', () {
      final taskField = TaskFieldInteger(priority);
      taskField.initializeValueFromString(addWhitespace(''));
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('getInputDisplay for null should be empty string', () {
      final taskField = TaskFieldInteger(priority);
      expect(taskField.getInputDisplay(), '');
    });

    test('getInputDisplay for value should be string', () {
      var expectedDisplay = theInt.toString();
      final taskField = TaskFieldInteger(priority);
      taskField.value = theInt;
      expect(taskField.getInputDisplay(), expectedDisplay);
    });

    test('setValueFromString', () {
      var formatted = theInt.toString();
      final taskField = TaskFieldInteger(priority);
      taskField.setValueFromString(formatted);
      expect(taskField.value, theInt);
      expect(taskField.originalValue, null);
    });

    test('formatForJSON', () {
      final taskField = TaskFieldInteger(priority);
      taskField.value = theInt;
      expect(taskField.formatForJSON(), theInt);
    });

    test('toString', () {
      var stringOutput = priority + ': (null) -> ' + theInt.toString();
      final taskField = TaskFieldInteger(priority);
      taskField.value = theInt;
      expect(taskField.toString(), stringOutput);
    });

  });

  group('TaskFieldBoolean', () {

    final bool theBool = false;
    final recurWait = 'recur_wait';

    test('Should be constructed', () {
      final taskField = TaskFieldBoolean(recurWait);
      expect(taskField.fieldName, recurWait);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('Should be initialized with value', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.initializeValue(theBool);
      expect(taskField.value, theBool);
      expect(taskField.originalValue, theBool);
    });

    test('Set value shouldn\'t update original value', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.value = theBool;
      expect(taskField.value, theBool);
      expect(taskField.originalValue, null);
    });

    test('afterUpdate', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.value = theBool;
      taskField.afterUpdate();
      expect(taskField.value, theBool);
      expect(taskField.originalValue, theBool);
    });

    test('revert', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.value = theBool;
      taskField.revert();
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('isChanged', () {
      final taskField = TaskFieldBoolean(recurWait);
      expect(taskField.isChanged(), false);
      taskField.value = theBool;
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('initializeValueFromString', () {
      var formatted = theBool.toString();
      final taskField = TaskFieldBoolean(recurWait);
      taskField.initializeValueFromString(formatted);
      expect(taskField.value, theBool);
      expect(taskField.originalValue, theBool);
    });

    test('initializeValueFromString extra whitespace', () {
      var formatted = theBool.toString();
      final taskField = TaskFieldBoolean(recurWait);
      taskField.initializeValueFromString(addWhitespace(formatted));
      expect(taskField.value, theBool);
      expect(taskField.originalValue, theBool);
    });

    test('initializeValueFromString null string should have null bool', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.initializeValueFromString(null);
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('initializeValueFromString empty string should have null bool', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.initializeValueFromString('');
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('initializeValueFromString whitespace string should have null bool', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.initializeValueFromString(addWhitespace(''));
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('getInputDisplay for null should be empty string', () {
      final taskField = TaskFieldBoolean(recurWait);
      expect(taskField.getInputDisplay(), '');
    });

    test('getInputDisplay for value should be string', () {
      var expectedDisplay = theBool.toString();
      final taskField = TaskFieldBoolean(recurWait);
      taskField.value = theBool;
      expect(taskField.getInputDisplay(), expectedDisplay);
    });

    test('setValueFromString', () {
      var formatted = theBool.toString();
      final taskField = TaskFieldBoolean(recurWait);
      taskField.setValueFromString(formatted);
      expect(taskField.value, theBool);
      expect(taskField.originalValue, null);
    });

    test('formatForJSON', () {
      final taskField = TaskFieldBoolean(recurWait);
      taskField.value = theBool;
      expect(taskField.formatForJSON(), theBool);
    });

    test('toString', () {
      var stringOutput = recurWait + ': (null) -> ' + theBool.toString();
      final taskField = TaskFieldBoolean(recurWait);
      taskField.value = theBool;
      expect(taskField.toString(), stringOutput);
    });

  });
}