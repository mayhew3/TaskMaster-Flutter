import 'package:meta/meta.dart';

import '../models/models.dart';

@immutable
class ReduxAppState {
  final bool isLoading;
  final List<TaskItem> taskItems;
  final List<Sprint> sprints;
  final List<TaskRecurrence> taskRecurrences;
  final AppTab activeTab;
  final VisibilityFilter sprintListFilter;
  final VisibilityFilter taskListFilter;

  ReduxAppState({
    this.isLoading = false,
    this.taskItems = const [],
    this.sprints = const [],
    this.taskRecurrences = const [],
    this.activeTab = AppTab.plan,
    this.sprintListFilter = const VisibilityFilter(showScheduled: true, showCompleted: true, showActiveSprint: true),
    this.taskListFilter = const VisibilityFilter(),
  });

  factory ReduxAppState.loading() => ReduxAppState(isLoading: true);

  ReduxAppState copyWith({
    bool? isLoading,
    List<TaskItem>? todos,
    List<Sprint>? sprints,
    List<TaskRecurrence>? taskRecurrences,
    AppTab? activeTab,
    VisibilityFilter? sprintListFilter,
    VisibilityFilter? taskListFilter,
  }) {
    return ReduxAppState(
      isLoading: isLoading ?? this.isLoading,
      taskItems: todos ?? this.taskItems,
      sprints: sprints ?? this.sprints,
      taskRecurrences: taskRecurrences ?? this.taskRecurrences,
      activeTab: activeTab ?? this.activeTab,
      sprintListFilter: sprintListFilter ?? this.sprintListFilter,
      taskListFilter: taskListFilter ?? this.taskListFilter,
    );
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^
      taskItems.hashCode ^
      sprints.hashCode ^
      taskRecurrences.hashCode ^
      activeTab.hashCode^
      sprintListFilter.hashCode ^
      taskListFilter.hashCode ;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReduxAppState &&
              runtimeType == other.runtimeType &&
              isLoading == other.isLoading &&
              taskItems == other.taskItems &&
              sprints == other.sprints &&
              taskRecurrences == other.taskRecurrences &&
              activeTab == other.activeTab &&
              sprintListFilter == other.sprintListFilter &&
              taskListFilter == other.taskListFilter;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, taskItems: $taskItems, sprints: $sprints, recurrences: $taskRecurrences, activeTab: $activeTab, sprintListFilter: $sprintListFilter, taskListFilter: $taskListFilter}';
  }
}