import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/task_date_type.dart';
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
  late AnchorDate anchorDate;
  late AnchorDate? nextIterationDate;

  MockTaskRecurrenceBuilder();

  TaskRecurrence create() {
    var taskRecurrenceMap = {
      'docId': docId,
      'dateAdded': DateTime.now().toUtc(),
      'name': name,
      'personDocId': MockTaskItemBuilder.me,
      'recurNumber': recurNumber,
      'recurUnit': recurUnit,
      'recurWait': recurWait,
      'recurIteration': recurIteration,
      'anchorDate': {
        'dateValue': anchorDate.dateValue,
        'dateType': anchorDate.dateType.label,
      },
      'nextIterationDate': nextIterationDate == null ? null : {
        'dateValue': nextIterationDate!.dateValue,
        'dateType': nextIterationDate!.dateType.label,
      },
    };
    return serializers.deserializeWith(TaskRecurrence.serializer, taskRecurrenceMap)!;
  }

  factory MockTaskRecurrenceBuilder.asPreCommit() {
    var anchorDateBuilder = AnchorDateBuilder()
      ..dateValue = DateTime.now().toUtc()
      ..dateType = TaskDateTypes.target;
    var nextIterationBuilder = AnchorDateBuilder()
      ..dateValue = DateTime.now().toUtc().add(Duration(days: 42))
      ..dateType = TaskDateTypes.target;
    return MockTaskRecurrenceBuilder()
      ..name = 'Test Recurrence'
      ..recurNumber = 6
      ..recurIteration = 1
      ..recurUnit = 'Weeks'
      ..recurWait = false
      ..anchorDate = anchorDateBuilder.build()
      ..nextIterationDate = nextIterationBuilder.build()
    ;
  }

  factory MockTaskRecurrenceBuilder.asDefault() {
    return MockTaskRecurrenceBuilder.asPreCommit()
        ..docId = MockTaskItemBuilder.me;
  }
}