import 'package:flutter/widgets.dart';

class TaskMasterKeys {
  // Home Screens
  static final homeScreen = const Key('__homeScreen__');
  static const snackbar = Key('__snackbar__');
  static final signingIn = const Key('__signingIn__');

  // Tasks
  static final taskList = const Key('__taskItemList__');
  static final planTaskList = const Key('__planTaskList__');
  static final tasksLoading = const Key('__taskItemsLoading__');
  static final taskItem = (int id) => Key('TaskItemItem__$id');
  static final taskItemCheckbox = (int id) => Key('TaskItemItem__${id}__Checkbox');
  static final taskItemTask = (int id) => Key('TaskItemItem__${id}__Task');
  static final taskItemNote = (int id) => Key('TaskItemItem__${id}__Note');

  // Filters
  static const filterButton = Key('__filterButton__');
  static const allFilter = Key('__allFilter__');
  static const activeFilter = Key('__activeFilter__');
  static const completedFilter = Key('__completedFilter__');

  // Details Screen
  static const editTaskItemFab = Key('__editTaskItemFab__');
  static const deleteTaskItemButton = Key('__deleteTaskItemFab__');
  static const taskItemDetailsScreen = Key('__taskItemDetailsScreen__');
  static final detailsTaskItemItemCheckbox = Key('DetailsTaskItem__Checkbox');
  static final detailsTaskItemItemTask = Key('DetailsTaskItem__Task');
  static final detailsTaskItemItemNote = Key('DetailsTaskItem__Note');

  // Tabs
  static const tabs = Key('__tabs__');
  static const planTab = Key('__planTab__');
  static const taskItemTab = Key('__taskItemTab__');
  static const statsTab = Key('__statsTab__');

}