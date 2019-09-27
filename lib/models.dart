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
  final String name;
  final int personId;
  final DateTime dateAdded;
  final DateTime completionDate;

  TaskItem({this.id, this.name, this.personId, this.dateAdded, this.completionDate});

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ personId.hashCode ^ dateAdded.hashCode ^ completionDate.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              personId == other.personId &&
              dateAdded == other.dateAdded &&
              completionDate == other.completionDate;

  TaskEntity toEntity() {
    return TaskEntity(
        id: id,
        name: name,
        personId: personId,
        dateAdded: dateAdded,
        completionDate: completionDate);
  }

  static TaskItem fromEntity(TaskEntity entity) {
    return TaskItem(
      id: entity.id,
      name: entity.name,
      personId: entity.personId,
      dateAdded: entity.dateAdded,
      completionDate: entity.completionDate
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
        name: json['name'],
        personId: json['person_id'],
        dateAdded: DateTime.parse(json['date_added']),
        completionDate: json['completion_date'] == null ? null : DateTime.parse(json['completion_date'])
    );
  }
}

class TaskEntity {
  final int id;
  final String name;
  final int personId;
  final DateTime dateAdded;
  final DateTime completionDate;

  TaskEntity({this.id, this.name, this.personId, this.dateAdded, this.completionDate});

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ personId.hashCode ^ dateAdded.hashCode ^ completionDate.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              personId == other.personId &&
              dateAdded == other.dateAdded &&
              completionDate == other.completionDate;

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
        name: json['name'],
        personId: json['person_id'],
        dateAdded: DateTime.parse(json['date_added']),
        completionDate: json['completion_date'] == null ? null : DateTime.parse(json['completion_date'])
    );
  }
}