import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/serializers.dart';

import 'mock_data_builder.dart';

class MockTaskRecurrenceBuilder {
  String? docId;
  late String name;
  late int recurNumber;
  late String recurUnit;
  late bool recurWait;
  late int recurIteration;
  late DateTime anchorDate;
  late String anchorType;

  MockTaskRecurrenceBuilder();

  TaskRecurrence create() {
    var taskRecurrence = {
      docId: docId,
      name: name,
      recurNumber: recurNumber,
      recurUnit: recurUnit,
      recurWait: recurWait,
      recurIteration: recurIteration,
      anchorDate: anchorDate,
      anchorType: anchorType
    };
    return serializers.deserializeWith(TaskRecurrence.serializer, taskRecurrence)!;
  }

  factory MockTaskRecurrenceBuilder.asPreCommit() {
    return MockTaskRecurrenceBuilder()
      ..name = 'Test Recurrence'
      ..recurNumber = 6
      ..recurIteration = 1
      ..recurUnit = 'Weeks'
      ..recurWait = false
      ..anchorDate = DateTime.now()
      ..anchorType = 'target'
    ;
  }

  factory MockTaskRecurrenceBuilder.asDefault() {
    return MockTaskRecurrenceBuilder.asPreCommit()
        ..docId = MockTaskItemBuilder.me;
  }
}