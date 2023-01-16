// Mocks generated by Mockito 5.3.2 from annotations
// in taskmaster/test/task_helper_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i17;

import 'package:flutter/material.dart' as _i5;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i14;
import 'package:google_sign_in/google_sign_in.dart' as _i16;
import 'package:http/http.dart' as _i10;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/app_state.dart' as _i2;
import 'package:taskmaster/auth.dart' as _i6;
import 'package:taskmaster/flutter_badger_wrapper.dart' as _i15;
import 'package:taskmaster/models/snooze.dart' as _i11;
import 'package:taskmaster/models/sprint.dart' as _i12;
import 'package:taskmaster/models/task_item.dart' as _i9;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i18;
import 'package:taskmaster/models/task_item_edit.dart' as _i19;
import 'package:taskmaster/nav_helper.dart' as _i8;
import 'package:taskmaster/notification_scheduler.dart' as _i7;
import 'package:taskmaster/task_helper.dart' as _i4;
import 'package:taskmaster/task_repository.dart' as _i3;
import 'package:taskmaster/timezone_helper.dart' as _i13;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeAppState_0 extends _i1.SmartFake implements _i2.AppState {
  _FakeAppState_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskRepository_1 extends _i1.SmartFake
    implements _i3.TaskRepository {
  _FakeTaskRepository_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskHelper_2 extends _i1.SmartFake implements _i4.TaskHelper {
  _FakeTaskHelper_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBuildContext_3 extends _i1.SmartFake implements _i5.BuildContext {
  _FakeBuildContext_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskMasterAuth_4 extends _i1.SmartFake
    implements _i6.TaskMasterAuth {
  _FakeTaskMasterAuth_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNotificationScheduler_5 extends _i1.SmartFake
    implements _i7.NotificationScheduler {
  _FakeNotificationScheduler_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNavHelper_6 extends _i1.SmartFake implements _i8.NavHelper {
  _FakeNavHelper_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_7 extends _i1.SmartFake implements _i9.TaskItem {
  _FakeTaskItem_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_8 extends _i1.SmartFake implements _i10.Client {
  _FakeClient_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_9 extends _i1.SmartFake implements Uri {
  _FakeUri_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSnooze_10 extends _i1.SmartFake implements _i11.Snooze {
  _FakeSnooze_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSprint_11 extends _i1.SmartFake implements _i12.Sprint {
  _FakeSprint_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTimezoneHelper_12 extends _i1.SmartFake
    implements _i13.TimezoneHelper {
  _FakeTimezoneHelper_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFlutterLocalNotificationsPlugin_13 extends _i1.SmartFake
    implements _i14.FlutterLocalNotificationsPlugin {
  _FakeFlutterLocalNotificationsPlugin_13(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFlutterBadgerWrapper_14 extends _i1.SmartFake
    implements _i15.FlutterBadgerWrapper {
  _FakeFlutterBadgerWrapper_14(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [NavHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockNavHelper extends _i1.Mock implements _i8.NavHelper {
  @override
  _i2.AppState get appState => (super.noSuchMethod(
        Invocation.getter(#appState),
        returnValue: _FakeAppState_0(
          this,
          Invocation.getter(#appState),
        ),
        returnValueForMissingStub: _FakeAppState_0(
          this,
          Invocation.getter(#appState),
        ),
      ) as _i2.AppState);
  @override
  _i3.TaskRepository get taskRepository => (super.noSuchMethod(
        Invocation.getter(#taskRepository),
        returnValue: _FakeTaskRepository_1(
          this,
          Invocation.getter(#taskRepository),
        ),
        returnValueForMissingStub: _FakeTaskRepository_1(
          this,
          Invocation.getter(#taskRepository),
        ),
      ) as _i3.TaskRepository);
  @override
  _i4.TaskHelper get taskHelper => (super.noSuchMethod(
        Invocation.getter(#taskHelper),
        returnValue: _FakeTaskHelper_2(
          this,
          Invocation.getter(#taskHelper),
        ),
        returnValueForMissingStub: _FakeTaskHelper_2(
          this,
          Invocation.getter(#taskHelper),
        ),
      ) as _i4.TaskHelper);
  @override
  _i5.BuildContext get context => (super.noSuchMethod(
        Invocation.getter(#context),
        returnValue: _FakeBuildContext_3(
          this,
          Invocation.getter(#context),
        ),
        returnValueForMissingStub: _FakeBuildContext_3(
          this,
          Invocation.getter(#context),
        ),
      ) as _i5.BuildContext);
  @override
  set context(_i5.BuildContext? _context) => super.noSuchMethod(
        Invocation.setter(
          #context,
          _context,
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateContext(_i5.BuildContext? context) => super.noSuchMethod(
        Invocation.method(
          #updateContext,
          [context],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void goToLoadingScreen(String? msg) => super.noSuchMethod(
        Invocation.method(
          #goToLoadingScreen,
          [msg],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void goToSignInScreen() => super.noSuchMethod(
        Invocation.method(
          #goToSignInScreen,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void goToHomeScreen() => super.noSuchMethod(
        Invocation.method(
          #goToHomeScreen,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [AppState].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppState extends _i1.Mock implements _i2.AppState {
  @override
  bool get isLoading => (super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  set isLoading(bool? _isLoading) => super.noSuchMethod(
        Invocation.setter(
          #isLoading,
          _isLoading,
        ),
        returnValueForMissingStub: null,
      );
  @override
  List<_i9.TaskItem> get taskItems => (super.noSuchMethod(
        Invocation.getter(#taskItems),
        returnValue: <_i9.TaskItem>[],
        returnValueForMissingStub: <_i9.TaskItem>[],
      ) as List<_i9.TaskItem>);
  @override
  set taskItems(List<_i9.TaskItem>? _taskItems) => super.noSuchMethod(
        Invocation.setter(
          #taskItems,
          _taskItems,
        ),
        returnValueForMissingStub: null,
      );
  @override
  List<_i12.Sprint> get sprints => (super.noSuchMethod(
        Invocation.getter(#sprints),
        returnValue: <_i12.Sprint>[],
        returnValueForMissingStub: <_i12.Sprint>[],
      ) as List<_i12.Sprint>);
  @override
  set sprints(List<_i12.Sprint>? _sprints) => super.noSuchMethod(
        Invocation.setter(
          #sprints,
          _sprints,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i6.TaskMasterAuth get auth => (super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: _FakeTaskMasterAuth_4(
          this,
          Invocation.getter(#auth),
        ),
        returnValueForMissingStub: _FakeTaskMasterAuth_4(
          this,
          Invocation.getter(#auth),
        ),
      ) as _i6.TaskMasterAuth);
  @override
  set currentUser(_i16.GoogleSignInAccount? _currentUser) => super.noSuchMethod(
        Invocation.setter(
          #currentUser,
          _currentUser,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get tokenRetrieved => (super.noSuchMethod(
        Invocation.getter(#tokenRetrieved),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  set tokenRetrieved(bool? _tokenRetrieved) => super.noSuchMethod(
        Invocation.setter(
          #tokenRetrieved,
          _tokenRetrieved,
        ),
        returnValueForMissingStub: null,
      );
  @override
  int get personId => (super.noSuchMethod(
        Invocation.getter(#personId),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);
  @override
  set personId(int? _personId) => super.noSuchMethod(
        Invocation.setter(
          #personId,
          _personId,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i7.NotificationScheduler get notificationScheduler => (super.noSuchMethod(
        Invocation.getter(#notificationScheduler),
        returnValue: _FakeNotificationScheduler_5(
          this,
          Invocation.getter(#notificationScheduler),
        ),
        returnValueForMissingStub: _FakeNotificationScheduler_5(
          this,
          Invocation.getter(#notificationScheduler),
        ),
      ) as _i7.NotificationScheduler);
  @override
  set notificationScheduler(
          _i7.NotificationScheduler? _notificationScheduler) =>
      super.noSuchMethod(
        Invocation.setter(
          #notificationScheduler,
          _notificationScheduler,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get title => (super.noSuchMethod(
        Invocation.getter(#title),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  set title(String? _title) => super.noSuchMethod(
        Invocation.setter(
          #title,
          _title,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i8.NavHelper get navHelper => (super.noSuchMethod(
        Invocation.getter(#navHelper),
        returnValue: _FakeNavHelper_6(
          this,
          Invocation.getter(#navHelper),
        ),
        returnValueForMissingStub: _FakeNavHelper_6(
          this,
          Invocation.getter(#navHelper),
        ),
      ) as _i8.NavHelper);
  @override
  set navHelper(_i8.NavHelper? _navHelper) => super.noSuchMethod(
        Invocation.setter(
          #navHelper,
          _navHelper,
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateNavHelper(_i8.NavHelper? navHelper) => super.noSuchMethod(
        Invocation.method(
          #updateNavHelper,
          [navHelper],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i17.Future<String> getIdToken() => (super.noSuchMethod(
        Invocation.method(
          #getIdToken,
          [],
        ),
        returnValue: _i17.Future<String>.value(''),
        returnValueForMissingStub: _i17.Future<String>.value(''),
      ) as _i17.Future<String>);
  @override
  List<_i9.TaskItem> getAllTasks() => (super.noSuchMethod(
        Invocation.method(
          #getAllTasks,
          [],
        ),
        returnValue: <_i9.TaskItem>[],
        returnValueForMissingStub: <_i9.TaskItem>[],
      ) as List<_i9.TaskItem>);
  @override
  List<_i9.TaskItem> getTasksForActiveSprint() => (super.noSuchMethod(
        Invocation.method(
          #getTasksForActiveSprint,
          [],
        ),
        returnValue: <_i9.TaskItem>[],
        returnValueForMissingStub: <_i9.TaskItem>[],
      ) as List<_i9.TaskItem>);
  @override
  _i9.TaskItem? findTaskItemWithId(int? taskId) => (super.noSuchMethod(
        Invocation.method(
          #findTaskItemWithId,
          [taskId],
        ),
        returnValueForMissingStub: null,
      ) as _i9.TaskItem?);
  @override
  _i12.Sprint? findSprintWithId(int? sprintId) => (super.noSuchMethod(
        Invocation.method(
          #findSprintWithId,
          [sprintId],
        ),
        returnValueForMissingStub: null,
      ) as _i12.Sprint?);
  @override
  void updateNotificationScheduler(
    _i5.BuildContext? context,
    _i4.TaskHelper? taskHelper,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #updateNotificationScheduler,
          [
            context,
            taskHelper,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i17.Future<void> syncAllNotifications() => (super.noSuchMethod(
        Invocation.method(
          #syncAllNotifications,
          [],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
  @override
  void finishedLoading() => super.noSuchMethod(
        Invocation.method(
          #finishedLoading,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i9.TaskItem addNewTaskToList(_i9.TaskItem? taskItem) => (super.noSuchMethod(
        Invocation.method(
          #addNewTaskToList,
          [taskItem],
        ),
        returnValue: _FakeTaskItem_7(
          this,
          Invocation.method(
            #addNewTaskToList,
            [taskItem],
          ),
        ),
        returnValueForMissingStub: _FakeTaskItem_7(
          this,
          Invocation.method(
            #addNewTaskToList,
            [taskItem],
          ),
        ),
      ) as _i9.TaskItem);
  @override
  void deleteTaskFromList(_i9.TaskItem? taskItem) => super.noSuchMethod(
        Invocation.method(
          #deleteTaskFromList,
          [taskItem],
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool isAuthenticated() => (super.noSuchMethod(
        Invocation.method(
          #isAuthenticated,
          [],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  void signOut() => super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i3.TaskRepository {
  @override
  _i2.AppState get appState => (super.noSuchMethod(
        Invocation.getter(#appState),
        returnValue: _FakeAppState_0(
          this,
          Invocation.getter(#appState),
        ),
        returnValueForMissingStub: _FakeAppState_0(
          this,
          Invocation.getter(#appState),
        ),
      ) as _i2.AppState);
  @override
  set appState(_i2.AppState? _appState) => super.noSuchMethod(
        Invocation.setter(
          #appState,
          _appState,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i10.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_8(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_8(
          this,
          Invocation.getter(#client),
        ),
      ) as _i10.Client);
  @override
  set client(_i10.Client? _client) => super.noSuchMethod(
        Invocation.setter(
          #client,
          _client,
        ),
        returnValueForMissingStub: null,
      );
  @override
  Uri getUriWithParameters(
    String? path,
    Map<String, dynamic>? queryParameters,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getUriWithParameters,
          [
            path,
            queryParameters,
          ],
        ),
        returnValue: _FakeUri_9(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_9(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
      ) as Uri);
  @override
  Uri getUri(String? path) => (super.noSuchMethod(
        Invocation.method(
          #getUri,
          [path],
        ),
        returnValue: _FakeUri_9(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_9(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);
  @override
  _i17.Future<void> loadTasks(_i5.StateSetter? stateSetter) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadTasks,
          [stateSetter],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
  @override
  _i17.Future<_i9.TaskItem> addTask(_i18.TaskItemBlueprint? taskItemForm) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTask,
          [taskItemForm],
        ),
        returnValue: _i17.Future<_i9.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #addTask,
            [taskItemForm],
          ),
        )),
        returnValueForMissingStub:
            _i17.Future<_i9.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #addTask,
            [taskItemForm],
          ),
        )),
      ) as _i17.Future<_i9.TaskItem>);
  @override
  _i17.Future<_i11.Snooze> addSnoozeSerializable(_i11.Snooze? snooze) =>
      (super.noSuchMethod(
        Invocation.method(
          #addSnoozeSerializable,
          [snooze],
        ),
        returnValue: _i17.Future<_i11.Snooze>.value(_FakeSnooze_10(
          this,
          Invocation.method(
            #addSnoozeSerializable,
            [snooze],
          ),
        )),
        returnValueForMissingStub:
            _i17.Future<_i11.Snooze>.value(_FakeSnooze_10(
          this,
          Invocation.method(
            #addSnoozeSerializable,
            [snooze],
          ),
        )),
      ) as _i17.Future<_i11.Snooze>);
  @override
  _i17.Future<_i12.Sprint> addSprint(_i12.Sprint? sprint) =>
      (super.noSuchMethod(
        Invocation.method(
          #addSprint,
          [sprint],
        ),
        returnValue: _i17.Future<_i12.Sprint>.value(_FakeSprint_11(
          this,
          Invocation.method(
            #addSprint,
            [sprint],
          ),
        )),
        returnValueForMissingStub:
            _i17.Future<_i12.Sprint>.value(_FakeSprint_11(
          this,
          Invocation.method(
            #addSprint,
            [sprint],
          ),
        )),
      ) as _i17.Future<_i12.Sprint>);
  @override
  _i17.Future<void> addTasksToSprint(
    List<_i9.TaskItem>? taskItems,
    _i12.Sprint? sprint,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTasksToSprint,
          [
            taskItems,
            sprint,
          ],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
  @override
  _i17.Future<_i9.TaskItem> completeTask(_i9.TaskItem? taskItem) =>
      (super.noSuchMethod(
        Invocation.method(
          #completeTask,
          [taskItem],
        ),
        returnValue: _i17.Future<_i9.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #completeTask,
            [taskItem],
          ),
        )),
        returnValueForMissingStub:
            _i17.Future<_i9.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #completeTask,
            [taskItem],
          ),
        )),
      ) as _i17.Future<_i9.TaskItem>);
  @override
  _i17.Future<_i9.TaskItem> updateTask(_i19.TaskItemEdit? taskItemForm) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [taskItemForm],
        ),
        returnValue: _i17.Future<_i9.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #updateTask,
            [taskItemForm],
          ),
        )),
        returnValueForMissingStub:
            _i17.Future<_i9.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #updateTask,
            [taskItemForm],
          ),
        )),
      ) as _i17.Future<_i9.TaskItem>);
  @override
  _i17.Future<void> deleteTask(_i9.TaskItem? taskItem) => (super.noSuchMethod(
        Invocation.method(
          #deleteTask,
          [taskItem],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
}

/// A class which mocks [NotificationScheduler].
///
/// See the documentation for Mockito's code generation for more information.
class MockNotificationScheduler extends _i1.Mock
    implements _i7.NotificationScheduler {
  @override
  _i2.AppState get appState => (super.noSuchMethod(
        Invocation.getter(#appState),
        returnValue: _FakeAppState_0(
          this,
          Invocation.getter(#appState),
        ),
        returnValueForMissingStub: _FakeAppState_0(
          this,
          Invocation.getter(#appState),
        ),
      ) as _i2.AppState);
  @override
  _i4.TaskHelper get taskHelper => (super.noSuchMethod(
        Invocation.getter(#taskHelper),
        returnValue: _FakeTaskHelper_2(
          this,
          Invocation.getter(#taskHelper),
        ),
        returnValueForMissingStub: _FakeTaskHelper_2(
          this,
          Invocation.getter(#taskHelper),
        ),
      ) as _i4.TaskHelper);
  @override
  _i13.TimezoneHelper get timezoneHelper => (super.noSuchMethod(
        Invocation.getter(#timezoneHelper),
        returnValue: _FakeTimezoneHelper_12(
          this,
          Invocation.getter(#timezoneHelper),
        ),
        returnValueForMissingStub: _FakeTimezoneHelper_12(
          this,
          Invocation.getter(#timezoneHelper),
        ),
      ) as _i13.TimezoneHelper);
  @override
  _i5.BuildContext get context => (super.noSuchMethod(
        Invocation.getter(#context),
        returnValue: _FakeBuildContext_3(
          this,
          Invocation.getter(#context),
        ),
        returnValueForMissingStub: _FakeBuildContext_3(
          this,
          Invocation.getter(#context),
        ),
      ) as _i5.BuildContext);
  @override
  _i5.BuildContext get homeScreenContext => (super.noSuchMethod(
        Invocation.getter(#homeScreenContext),
        returnValue: _FakeBuildContext_3(
          this,
          Invocation.getter(#homeScreenContext),
        ),
        returnValueForMissingStub: _FakeBuildContext_3(
          this,
          Invocation.getter(#homeScreenContext),
        ),
      ) as _i5.BuildContext);
  @override
  set homeScreenContext(_i5.BuildContext? _homeScreenContext) =>
      super.noSuchMethod(
        Invocation.setter(
          #homeScreenContext,
          _homeScreenContext,
        ),
        returnValueForMissingStub: null,
      );
  @override
  int get nextId => (super.noSuchMethod(
        Invocation.getter(#nextId),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);
  @override
  set nextId(int? _nextId) => super.noSuchMethod(
        Invocation.setter(
          #nextId,
          _nextId,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i14.FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      (super.noSuchMethod(
        Invocation.getter(#flutterLocalNotificationsPlugin),
        returnValue: _FakeFlutterLocalNotificationsPlugin_13(
          this,
          Invocation.getter(#flutterLocalNotificationsPlugin),
        ),
        returnValueForMissingStub: _FakeFlutterLocalNotificationsPlugin_13(
          this,
          Invocation.getter(#flutterLocalNotificationsPlugin),
        ),
      ) as _i14.FlutterLocalNotificationsPlugin);
  @override
  _i15.FlutterBadgerWrapper get flutterBadgerWrapper => (super.noSuchMethod(
        Invocation.getter(#flutterBadgerWrapper),
        returnValue: _FakeFlutterBadgerWrapper_14(
          this,
          Invocation.getter(#flutterBadgerWrapper),
        ),
        returnValueForMissingStub: _FakeFlutterBadgerWrapper_14(
          this,
          Invocation.getter(#flutterBadgerWrapper),
        ),
      ) as _i15.FlutterBadgerWrapper);
  @override
  void updateHomeScreenContext(_i5.BuildContext? context) => super.noSuchMethod(
        Invocation.method(
          #updateHomeScreenContext,
          [context],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateBadge() => super.noSuchMethod(
        Invocation.method(
          #updateBadge,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i17.Future<void> cancelAllNotifications() => (super.noSuchMethod(
        Invocation.method(
          #cancelAllNotifications,
          [],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
  @override
  _i17.Future<void> cancelNotificationsForTaskId(int? taskId) =>
      (super.noSuchMethod(
        Invocation.method(
          #cancelNotificationsForTaskId,
          [taskId],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
  @override
  _i17.Future<void> syncNotificationForTasksAndSprint(
    List<_i9.TaskItem>? taskItems,
    _i12.Sprint? sprint,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #syncNotificationForTasksAndSprint,
          [
            taskItems,
            sprint,
          ],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
  @override
  _i17.Future<void> updateNotificationForTask(_i9.TaskItem? taskItem) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateNotificationForTask,
          [taskItem],
        ),
        returnValue: _i17.Future<void>.value(),
        returnValueForMissingStub: _i17.Future<void>.value(),
      ) as _i17.Future<void>);
}
