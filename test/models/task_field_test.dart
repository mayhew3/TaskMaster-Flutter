import 'package:test/test.dart';
import 'package:taskmaster/models/task_field.dart';

void main() {
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
      var formatted = '2019-07-13 15:12:55';
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      expect(taskField.formatForJSON(), formatted);
    });

    test('toString', () {
      var stringOutput = startDate + ': 2019-07-13 08:12:55.000';
      final taskField = TaskFieldDate(startDate);
      taskField.value = theDateTime;
      expect(taskField.toString(), stringOutput);
    });

  });

  group('TaskFieldString', () {
    final name = 'name';
    final theString = 'Cat Litter';

    String addWhitespace(String str) {
      return '  ' + str + ' \r\n';
    }

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
      var stringOutput = name + ': ' + theString;
      final taskField = TaskFieldString(name);
      taskField.value = theString;
      expect(taskField.toString(), stringOutput);
    });

  });
}