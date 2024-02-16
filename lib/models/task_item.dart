import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

@immutable
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItem {

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

  TaskItem({
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

  TaskItem copyWith({
    int? id,
    int? personId,
    String? name,
    String? description,
    String? project,
    String? context,
    int? urgency,
    int? priority,
    int? duration,
    int? gamePoints,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? urgentDate,
    DateTime? dueDate,
    DateTime? completionDate,
    int? recurNumber,
    String? recurUnit,
    bool? recurWait,
    int? recurrenceId,
    int? recurIteration,
    bool? offCycle,
  }) {
    return TaskItem(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      description: description ?? this.description,
      project: project ?? this.project,
      context: context ?? this.context,
      urgency: urgency ?? this.urgency,
      priority: priority ?? this.priority,
      duration: duration ?? this.duration,
      gamePoints: gamePoints ?? this.gamePoints,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      urgentDate: urgentDate ?? this.urgentDate,
      dueDate: dueDate ?? this.dueDate,
      completionDate: completionDate ?? this.completionDate,
      recurNumber: recurNumber ?? this.recurNumber,
      recurUnit: recurUnit ?? this.recurUnit,
      recurWait: recurWait ?? this.recurWait,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      recurIteration: recurIteration ?? this.recurIteration,
      offCycle: offCycle ?? this.offCycle,
    );
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskItem.fromJson(Map<String, dynamic> json) => _$TaskItemFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  String toString() {
    return 'TaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'completionDate: $completionDate}';
  }

}
