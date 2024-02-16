import 'package:flutter/widgets.dart';

class TaskMasterKeys {
  // Home Screens
  static final homeScreen = const Key('__homeScreen__');

  // Tasks
  static final taskList = const Key('__todoList__');
  static final planTaskList = const Key('__planTaskList__');
  static final tasksLoading = const Key('__todosLoading__');
  static final taskItem = (String id) => Key('TodoItem__$id');

  // Filters
  static const filterButton = Key('__filterButton__');
  static const allFilter = Key('__allFilter__');
  static const activeFilter = Key('__activeFilter__');
  static const completedFilter = Key('__completedFilter__');

}