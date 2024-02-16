import 'package:meta/meta.dart';

@immutable
class ReduxTaskItem {

  final int id;
  final int personId;

  final String name;

  final String? description;
  final String? project;
  final String? context;

  final int? urgency;
  final int? priority;
  final int? duration;

  final int? gamePoints;

  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? dueDate;
  final DateTime? urgentDate;
  final DateTime? completionDate;

  final int? recurNumber;
  final String? recurUnit;
  final bool? recurWait;

  final int? recurrenceId;
  final int? recurIteration;

  final bool offCycle;

  ReduxTaskItem({
    required this.id,
    required this.personId,
    required this.name,
    this.description,
    this.project,
    this.context,
    this.urgency,
    this.priority,
    this.duration,
    this.gamePoints,
    this.startDate,
    this.targetDate,
    this.urgentDate,
    this.dueDate,
    this.completionDate,
    this.recurNumber,
    this.recurUnit,
    this.recurWait,
    this.recurrenceId,
    this.recurIteration,
    this.offCycle = false
  });

  bool isCompleted() {
    return completionDate != null;
  }

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReduxTaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  String toString() {
    return 'ReduxTaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'completionDate: $completionDate}';
  }

}
