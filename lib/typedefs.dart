import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/containers/tab_selector.dart';
import 'package:taskmaster/models/check_state.dart';

import 'models/task_item_blueprint.dart';


typedef UserUpdater = Function(GoogleSignInAccount? account);

typedef EndLoadingCallback = Function(BuildContext context);

typedef TaskItemRefresher = Function(TaskItem taskItem);

typedef StateCallback = void Function();
typedef MyStateSetter = void Function(StateCallback stateCallback);

typedef BottomNavigationBarGetter = TabSelector Function();

typedef TaskListGetter = List<TaskItem> Function();

typedef DateFieldGetter = DateTime? Function(DateHolder dateHolder);
typedef DateFieldSetter = void Function(TaskItemBlueprint blueprint, DateTime? newDate);

typedef WidgetGetter = Widget Function();
typedef TaskItemFilter = bool Function(SprintDisplayTask sprintDisplayTask);
typedef TaskItemOrdering = int Function(SprintDisplayTask a, SprintDisplayTask b);

typedef GetApiOperation = Future<Response> Function(Uri uri, {Map<String, String>? headers});
typedef BodyApiOperation = Future<Response> Function(Uri uri, {Map<String, String>? headers, Object? body, Encoding? encoding});