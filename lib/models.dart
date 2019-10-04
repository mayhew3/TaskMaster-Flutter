import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:flutter/foundation.dart';

class AppState {
  bool isLoading;
  List<TaskItem> taskItems;
  TaskMasterAuth auth;
  GoogleSignInAccount currentUser;
  String idToken;

  AppState({
    this.isLoading = true,
    this.taskItems = const [],
    @required userUpdater: UserUpdater,
    @required idTokenUpdater: IdTokenUpdater,
  }) {
    auth = TaskMasterAuth(
        updateCurrentUser: userUpdater,
        updateIdToken: idTokenUpdater,
    );
  }

  void finishedLoading(List<TaskItem> taskItems) {
    isLoading = false;
    this.taskItems = taskItems;
  }

  void updateTaskListWithUpdatedTask(TaskEntity taskEntity) {
    var taskItem = TaskItem.fromEntity(taskEntity);
    var existingIndex = taskItems.indexWhere((element) => element.id == taskItem.id);
    taskItems[existingIndex] = taskItem;
  }

  bool isAuthenticated() {
    return currentUser != null && idToken != null;
  }

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
  final int personId;

  final String name;
  final String description;
  final String project;
  final String context;

  final int urgency;
  final int priority;
  final int duration;

  final DateTime dateAdded;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime dueDate;
  final DateTime completionDate;
  final DateTime urgentDate;

  final int gamePoints;

  final int recurNumber;
  final String recurUnit;
  final bool recurWait;

  TaskItem({
    this.id,
    this.personId,
    this.name,
    this.description,
    this.project,
    this.context,
    this.urgency,
    this.priority,
    this.duration,
    this.dateAdded,
    this.startDate,
    this.targetDate,
    this.dueDate,
    this.completionDate,
    this.urgentDate,
    this.gamePoints,
    this.recurNumber,
    this.recurUnit,
    this.recurWait
  });

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  TaskEntity toEntity() {
    return TaskEntity(
        id: id,
        personId: personId,
        name: name,
        description: description,
        project: project,
        context: context,
        urgency: urgency,
        priority: priority,
        duration: duration,
        dateAdded: dateAdded,
        startDate: startDate,
        targetDate: targetDate,
        dueDate: dueDate,
        completionDate: completionDate,
        urgentDate: urgentDate,
        gamePoints: gamePoints,
        recurNumber: recurNumber,
        recurUnit: recurUnit,
        recurWait: recurWait
    );
  }

  static TaskItem fromEntity(TaskEntity entity) {
    return TaskItem(
        id: entity.id,
        personId: entity.personId,
        name: entity.name,
        description: entity.description,
        project: entity.project,
        context: entity.context,
        urgency: entity.urgency,
        priority: entity.priority,
        duration: entity.duration,
        dateAdded: entity.dateAdded,
        startDate: entity.startDate,
        targetDate: entity.targetDate,
        dueDate: entity.dueDate,
        completionDate: entity.completionDate,
        urgentDate: entity.urgentDate,
        gamePoints: entity.gamePoints,
        recurNumber: entity.recurNumber,
        recurUnit: entity.recurUnit,
        recurWait: entity.recurWait
    );
  }

  @override
  String toString() {
    return 'TaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'completionDate: $completionDate}';
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
        id: json['id'],
        personId: json['person_id'],
        name: json['name'],
        description: json['description'],
        project: json['project'],
        context: json['context'],
        urgency: json['urgency'],
        priority: json['priority'],
        duration: json['duration'],
        startDate: json['start_date'] == null ? null : DateTime.parse(json['start_date']),
        targetDate: json['target_date'] == null ? null : DateTime.parse(json['target_date']),
        dueDate: json['due_date'] == null ? null : DateTime.parse(json['due_date']),
        completionDate: json['completion_date'] == null ? null : DateTime.parse(json['completion_date']),
        urgentDate: json['urgent_date'] == null ? null : DateTime.parse(json['urgent_date']),
        gamePoints: json['game_points'],
        recurNumber: json['recur_number'],
        recurUnit: json['recur_unit'],
        recurWait: json['recur_wait'],
        dateAdded: DateTime.parse(json['date_added']),
    );
  }
}

class TaskEntity {
  final int id;
  final int personId;

  final String name;
  final String description;
  final String project;
  final String context;

  final int urgency;
  final int priority;
  final int duration;

  final DateTime dateAdded;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime dueDate;
  final DateTime completionDate;
  final DateTime urgentDate;

  final int gamePoints;

  final int recurNumber;
  final String recurUnit;
  final bool recurWait;

  TaskEntity({
    this.id,
    this.personId,
    this.name,
    this.description,
    this.project,
    this.context,
    this.urgency,
    this.priority,
    this.duration,
    this.dateAdded,
    this.startDate,
    this.targetDate,
    this.dueDate,
    this.completionDate,
    this.urgentDate,
    this.gamePoints,
    this.recurNumber,
    this.recurUnit,
    this.recurWait
  });

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
    return 'TaskEntity{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'completionDate: $completionDate}';
  }

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'],
      personId: json['person_id'],
      name: json['name'],
      description: json['description'],
      project: json['project'],
      context: json['context'],
      urgency: json['urgency'],
      priority: json['priority'],
      duration: json['duration'],
      startDate: json['start_date'] == null ? null : DateTime.parse(json['start_date']),
      targetDate: json['target_date'] == null ? null : DateTime.parse(json['target_date']),
      dueDate: json['due_date'] == null ? null : DateTime.parse(json['due_date']),
      completionDate: json['completion_date'] == null ? null : DateTime.parse(json['completion_date']),
      urgentDate: json['urgent_date'] == null ? null : DateTime.parse(json['urgent_date']),
      gamePoints: json['game_points'],
      recurNumber: json['recur_number'],
      recurUnit: json['recur_unit'],
      recurWait: json['recur_wait'],
      dateAdded: DateTime.parse(json['date_added']),
    );
  }
}