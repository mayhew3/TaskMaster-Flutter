import 'package:flutter/widgets.dart';

class TaskMasterKeys {
  // Home Screens
  static final homeScreen = const Key('__homeScreen__');

  // Todos
  static final todoList = const Key('__todoList__');
  static final todosLoading = const Key('__todosLoading__');
  static final todoItem = (String id) => Key('TodoItem__${id}');
}