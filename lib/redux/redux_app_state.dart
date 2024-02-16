import 'package:meta/meta.dart';
import 'package:taskmaster/models/task_item.dart';

import '../models/app_tab.dart';
import '../models/sprint.dart';
import '../models/task_recurrence.dart';

@immutable
class ReduxAppState {
  final bool isLoading;
  final List<TaskItem> taskItems;
  final List<Sprint> sprints;
  final List<TaskRecurrence> taskRecurrences;
  final AppTab activeTab;

  ReduxAppState({
    this.isLoading = false,
    this.taskItems = const [],
    this.sprints = const [],
    this.taskRecurrences = const [],
    this.activeTab = AppTab.plan
  });

  factory ReduxAppState.loading() => ReduxAppState(isLoading: true);

  ReduxAppState copyWith({
    bool? isLoading,
    List<TaskItem>? todos,
    List<Sprint>? sprints,
    List<TaskRecurrence>? taskRecurrences,
    AppTab? activeTab,
  }) {
    return ReduxAppState(
      isLoading: isLoading ?? this.isLoading,
      taskItems: todos ?? this.taskItems,
      sprints: sprints ?? this.sprints,
      taskRecurrences: taskRecurrences ?? this.taskRecurrences,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^
      taskItems.hashCode ^
      activeTab.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReduxAppState &&
              runtimeType == other.runtimeType &&
              isLoading == other.isLoading &&
              taskItems == other.taskItems &&
              sprints == other.sprints &&
              taskRecurrences == other.taskRecurrences &&
              activeTab == other.activeTab;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, taskItems: $taskItems, sprints: $sprints, recurrences: $taskRecurrences, activeTab: $activeTab}';
  }
}