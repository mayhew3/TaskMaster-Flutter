

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/top_nav_item.dart';

import '../../models/sprint.dart';
import '../../models/task_item.dart';
import '../../models/task_recurrence.dart';
import '../app_state.dart';

part 'home_screen_viewmodel.g.dart';

abstract class HomeScreenViewModel implements Built<HomeScreenViewModel, HomeScreenViewModelBuilder> {

  TopNavItem get activeTab;

  BuiltList<TaskItem> get taskItems;
  BuiltList<Sprint> get sprints;
  BuiltList<TaskRecurrence> get taskRecurrences;

  bool get tasksLoading;
  bool get sprintsLoading;
  bool get taskRecurrencesLoading;

  HomeScreenViewModel._();

  bool isLoading() {
    return tasksLoading || sprintsLoading || taskRecurrencesLoading;
  }

  factory HomeScreenViewModel([void Function(HomeScreenViewModelBuilder) updates]) = _$HomeScreenViewModel;

  static HomeScreenViewModel fromStore(Store<AppState> store) {
    return HomeScreenViewModel((c) => c
      ..activeTab = store.state.activeTab.toBuilder()
      ..taskItems = store.state.taskItems.toBuilder()
      ..sprints = store.state.sprints.toBuilder()
      ..taskRecurrences = store.state.taskRecurrences.toBuilder()
      ..tasksLoading = store.state.tasksLoading
      ..sprintsLoading = store.state.sprintsLoading
      ..taskRecurrencesLoading = store.state.taskRecurrencesLoading
    );
  }
}
