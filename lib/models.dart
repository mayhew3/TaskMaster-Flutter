class AppState {
  bool isLoading;
  List<TaskItem> taskItems;

  AppState({
    this.isLoading = false,
    this.taskItems = const [],
  });

  factory AppState.loading() => AppState(isLoading: true);

  @override
  int get hashCode => taskItems.hashCode ^ isLoading.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              taskItems == other.taskItems &&
              isLoading == other.isLoading;

  @override
  String toString() {
    return 'AppState{taskItems: $taskItems, isLoading: $isLoading}';
  }
}


class TaskItem {
  final int id;
  final String name;
  final int personId;
  final DateTime dateAdded;
  final DateTime dateCompleted;

  TaskItem({this.id, this.name, this.personId, this.dateAdded, this.dateCompleted});

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ personId.hashCode ^ dateAdded.hashCode ^ dateCompleted.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              personId == other.personId &&
              dateAdded == other.dateAdded &&
              dateCompleted == other.dateCompleted;

  TaskEntity toEntity() {
    return TaskEntity(
        id: id,
        name: name,
        personId: personId,
        dateAdded: dateAdded,
        dateCompleted: dateCompleted);
  }

  static TaskItem fromEntity(TaskEntity entity) {
    return TaskItem(
      id: entity.id,
      name: entity.name,
      personId: entity.personId,
      dateAdded: entity.dateAdded,
      dateCompleted: entity.dateCompleted
    );
  }

  @override
  String toString() {
    return 'TaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'dateCompleted: $dateCompleted}';
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
        id: json['id'],
        name: json['name'],
        personId: json['person_id'],
        dateAdded: DateTime.parse(json['date_added']),
        dateCompleted: json['date_completed'] == null ? null : DateTime.parse(json['date_completed'])
    );
  }
}

class TaskEntity {
  final int id;
  final String name;
  final int personId;
  final DateTime dateAdded;
  final DateTime dateCompleted;

  TaskEntity({this.id, this.name, this.personId, this.dateAdded, this.dateCompleted});

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ personId.hashCode ^ dateAdded.hashCode ^ dateCompleted.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              personId == other.personId &&
              dateAdded == other.dateAdded &&
              dateCompleted == other.dateCompleted;

  @override
  String toString() {
    return 'TaskEntity{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'dateCompleted: $dateCompleted}';
  }

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
        id: json['id'],
        name: json['name'],
        personId: json['person_id'],
        dateAdded: DateTime.parse(json['date_added']),
        dateCompleted: json['date_completed'] == null ? null : DateTime.parse(json['date_completed'])
    );
  }
}