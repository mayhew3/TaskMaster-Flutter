import 'package:test/test.dart';
import 'package:taskmaster/models/task_field.dart';

void main() {
  group('TaskFieldDate', () {

    final DateTime _theDateTime = DateTime(2019, 7, 13, 8, 12, 55);
    final startDate = 'startDate';

    String _formatDateTime(DateTime dateTime) {
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
      taskField.initializeValue(_theDateTime);
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, _theDateTime);
    });

    test('Set value shouldn\'t update original value', () {
      final taskField = TaskFieldDate(startDate);
      taskField.value = _theDateTime;
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, null);
    });

    test('afterUpdate', () {
      final taskField = TaskFieldDate(startDate);
      taskField.value = _theDateTime;
      taskField.afterUpdate();
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, _theDateTime);
    });

    test('revert', () {
      final taskField = TaskFieldDate(startDate);
      taskField.value = _theDateTime;
      taskField.revert();
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('isChanged', () {
      final taskField = TaskFieldDate(startDate);
      expect(taskField.isChanged(), false);
      taskField.value = _theDateTime;
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('initializeValueFromString', () {
      var formatted = _formatDateTime(_theDateTime);
      final taskField = TaskFieldDate(startDate);
      taskField.initializeValueFromString(formatted);
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, _theDateTime);
    });

    test('getInputDisplay for null should be empty string', () {
      final taskField = TaskFieldDate(startDate);
      expect(taskField.getInputDisplay(), '');
    });

    test('getInputDisplay for value should be string', () {
      var expectedDisplay = _theDateTime.toString();
      final taskField = TaskFieldDate(startDate);
      taskField.value = _theDateTime;
      expect(taskField.getInputDisplay(), expectedDisplay);
    });

    test('setValueFromString', () {
      var formatted = _formatDateTime(_theDateTime);
      final taskField = TaskFieldDate(startDate);
      taskField.setValueFromString(formatted);
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, null);
    });

    test('formatForJSON', () {
      var formatted = '2019-07-13 15:12:55';
      final taskField = TaskFieldDate(startDate);
      taskField.value = _theDateTime;
      expect(taskField.formatForJSON(), formatted);
    });

    test('toString', () {
      var stringOutput = startDate + ': 2019-07-13 08:12:55.000';
      final taskField = TaskFieldDate(startDate);
      taskField.value = _theDateTime;
      expect(taskField.toString(), stringOutput);
    });

  });

}