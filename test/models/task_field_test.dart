import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:taskmaster/models/task_field.dart';

void main() {
  group('TaskFieldDate', () {

    DateTime _theDateTime = DateTime(2019, 7, 13, 8, 12, 55);

    String formattedRight = '2019-09-27T04:34:48.460Z';

    String _formatDateTime(DateTime dateTime) {
      var utc = dateTime.toUtc();
      return utc.toIso8601String();
    }

    test('Should be constructed', () {
      final taskField = TaskFieldDate('startDate');
      expect(taskField.fieldName, 'startDate');
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('Should be initialized with value', () {
      final taskField = TaskFieldDate('startDate');
      taskField.initializeValue(_theDateTime);
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, _theDateTime);
    });

    test('Set value shouldn\'t update original value', () {
      final taskField = TaskFieldDate('startDate');
      taskField.value = _theDateTime;
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, null);
    });

    test('afterUpdate', () {
      final taskField = TaskFieldDate('startDate');
      taskField.value = _theDateTime;
      taskField.afterUpdate();
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, _theDateTime);
    });

    test('revert', () {
      final taskField = TaskFieldDate('startDate');
      taskField.value = _theDateTime;
      taskField.revert();
      expect(taskField.value, null);
      expect(taskField.originalValue, null);
    });

    test('isChanged', () {
      final taskField = TaskFieldDate('startDate');
      expect(taskField.isChanged(), false);
      taskField.value = _theDateTime;
      expect(taskField.isChanged(), true);
      taskField.afterUpdate();
      expect(taskField.isChanged(), false);
    });

    test('initializeValueFromString', () {
      var formatted = _formatDateTime(_theDateTime);
      final taskField = TaskFieldDate('startDate');
      taskField.initializeValueFromString(formatted);
      expect(taskField.value, _theDateTime);
      expect(taskField.originalValue, _theDateTime);
    });

  });

}