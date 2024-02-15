import 'package:meta/meta.dart';
import 'package:taskmaster/models/task_item.dart';

import '../models/app_tab.dart';

@immutable
class ReduxAppState {
  final bool isLoading;
  final List<TaskItem> taskItems;
  final AppTab activeTab;

  ReduxAppState(
      {this.isLoading = false,
        this.taskItems = const [],
        this.activeTab = AppTab.plan});

  factory ReduxAppState.loading() => ReduxAppState(isLoading: true);

  ReduxAppState copyWith({
    bool? isLoading,
    List<TaskItem>? todos,
    AppTab? activeTab,
  }) {
    return ReduxAppState(
      isLoading: isLoading ?? this.isLoading,
      taskItems: todos ?? this.taskItems,
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
              activeTab == other.activeTab;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, todos: $taskItems, activeTab: $activeTab}';
  }
}