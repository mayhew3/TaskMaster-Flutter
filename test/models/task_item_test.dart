import 'package:test/test.dart';
import 'package:taskmaster/models/task_item.dart';

void main() {
  group('TaskItem', () {

    test('Should be constructed', () {
      final taskItem = TaskItem();
      expect(taskItem.id == null, false);
      expect(taskItem.id.value, null);
      expect(taskItem.fields.length > 2, true);
    });

    test('revert', () {
      final taskItem = TaskItem();
      taskItem.name.value = 'Cat Litter';
      taskItem.priority.value = 4;
      taskItem.revertAllChanges();
      expect(taskItem.name.value, null);
      expect(taskItem.priority.value, null);
    });

  });
}