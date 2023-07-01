// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/notification_scheduler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i14;

import 'package:flutter/material.dart' as _i15;
import 'package:google_sign_in/google_sign_in.dart' as _i12;
import 'package:http/http.dart' as _i7;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/app_state.dart' as _i6;
import 'package:taskmaster/auth.dart' as _i2;
import 'package:taskmaster/models/snooze.dart' as _i8;
import 'package:taskmaster/models/sprint.dart' as _i9;
import 'package:taskmaster/models/task_date_type.dart' as _i18;
import 'package:taskmaster/models/task_item.dart' as _i5;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i17;
import 'package:taskmaster/models/task_item_preview.dart' as _i11;
import 'package:taskmaster/models/task_recurrence.dart' as _i13;
import 'package:taskmaster/nav_helper.dart' as _i4;
import 'package:taskmaster/notification_scheduler.dart' as _i3;
import 'package:taskmaster/task_helper.dart' as _i16;
import 'package:taskmaster/task_repository.dart' as _i10;

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

class _FakeTaskMasterAuth_0 extends _i1.SmartFake
    implements _i2.TaskMasterAuth {
  _FakeTaskMasterAuth_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNotificationScheduler_1 extends _i1.SmartFake
    implements _i3.NotificationScheduler {
  _FakeNotificationScheduler_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNavHelper_2 extends _i1.SmartFake implements _i4.NavHelper {
  _FakeNavHelper_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_3 extends _i1.SmartFake implements _i5.TaskItem {
  _FakeTaskItem_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAppState_4 extends _i1.SmartFake implements _i6.AppState {
  _FakeAppState_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_5 extends _i1.SmartFake implements _i7.Client {
  _FakeClient_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_6 extends _i1.SmartFake implements Uri {
  _FakeUri_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSnooze_7 extends _i1.SmartFake implements _i8.Snooze {
  _FakeSnooze_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSprint_8 extends _i1.SmartFake implements _i9.Sprint {
  _FakeSprint_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskRepository_9 extends _i1.SmartFake
    implements _i10.TaskRepository {
  _FakeTaskRepository_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItemPreview_10 extends _i1.SmartFake
    implements _i11.TaskItemPreview {
  _FakeTaskItemPreview_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AppState].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppState extends _i1.Mock implements _i6.AppState {
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
  _i2.TaskMasterAuth get auth => (super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: _FakeTaskMasterAuth_0(
          this,
          Invocation.getter(#auth),
        ),
        returnValueForMissingStub: _FakeTaskMasterAuth_0(
          this,
          Invocation.getter(#auth),
        ),
      ) as _i2.TaskMasterAuth);
  @override
  set currentUser(_i12.GoogleSignInAccount? _currentUser) => super.noSuchMethod(
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
  _i3.NotificationScheduler get notificationScheduler => (super.noSuchMethod(
        Invocation.getter(#notificationScheduler),
        returnValue: _FakeNotificationScheduler_1(
          this,
          Invocation.getter(#notificationScheduler),
        ),
        returnValueForMissingStub: _FakeNotificationScheduler_1(
          this,
          Invocation.getter(#notificationScheduler),
        ),
      ) as _i3.NotificationScheduler);
  @override
  set notificationScheduler(
          _i3.NotificationScheduler? _notificationScheduler) =>
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
  _i4.NavHelper get navHelper => (super.noSuchMethod(
        Invocation.getter(#navHelper),
        returnValue: _FakeNavHelper_2(
          this,
          Invocation.getter(#navHelper),
        ),
        returnValueForMissingStub: _FakeNavHelper_2(
          this,
          Invocation.getter(#navHelper),
        ),
      ) as _i4.NavHelper);
  @override
  set navHelper(_i4.NavHelper? _navHelper) => super.noSuchMethod(
        Invocation.setter(
          #navHelper,
          _navHelper,
        ),
        returnValueForMissingStub: null,
      );
  @override
  List<_i5.TaskItem> get taskItems => (super.noSuchMethod(
        Invocation.getter(#taskItems),
        returnValue: <_i5.TaskItem>[],
        returnValueForMissingStub: <_i5.TaskItem>[],
      ) as List<_i5.TaskItem>);
  @override
  List<_i9.Sprint> get sprints => (super.noSuchMethod(
        Invocation.getter(#sprints),
        returnValue: <_i9.Sprint>[],
        returnValueForMissingStub: <_i9.Sprint>[],
      ) as List<_i9.Sprint>);
  @override
  void updateTasksAndSprints(
    List<_i5.TaskItem>? taskItems,
    List<_i9.Sprint>? sprints,
    List<_i13.TaskRecurrence>? taskRecurrences,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #updateTasksAndSprints,
          [
            taskItems,
            sprints,
            taskRecurrences,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void linkTasksToSprints() => super.noSuchMethod(
        Invocation.method(
          #linkTasksToSprints,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void linkTasksToRecurrences() => super.noSuchMethod(
        Invocation.method(
          #linkTasksToRecurrences,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateNavHelper(_i4.NavHelper? navHelper) => super.noSuchMethod(
        Invocation.method(
          #updateNavHelper,
          [navHelper],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i14.Future<String> getIdToken() => (super.noSuchMethod(
        Invocation.method(
          #getIdToken,
          [],
        ),
        returnValue: _i14.Future<String>.value(''),
        returnValueForMissingStub: _i14.Future<String>.value(''),
      ) as _i14.Future<String>);
  @override
  List<_i5.TaskItem> getAllTasks() => (super.noSuchMethod(
        Invocation.method(
          #getAllTasks,
          [],
        ),
        returnValue: <_i5.TaskItem>[],
        returnValueForMissingStub: <_i5.TaskItem>[],
      ) as List<_i5.TaskItem>);
  @override
  List<_i5.TaskItem> getTasksForActiveSprint() => (super.noSuchMethod(
        Invocation.method(
          #getTasksForActiveSprint,
          [],
        ),
        returnValue: <_i5.TaskItem>[],
        returnValueForMissingStub: <_i5.TaskItem>[],
      ) as List<_i5.TaskItem>);
  @override
  _i5.TaskItem? findTaskItemWithId(int? taskId) => (super.noSuchMethod(
        Invocation.method(
          #findTaskItemWithId,
          [taskId],
        ),
        returnValueForMissingStub: null,
      ) as _i5.TaskItem?);
  @override
  _i9.Sprint? findSprintWithId(int? sprintId) => (super.noSuchMethod(
        Invocation.method(
          #findSprintWithId,
          [sprintId],
        ),
        returnValueForMissingStub: null,
      ) as _i9.Sprint?);
  @override
  void updateNotificationScheduler(
    _i15.BuildContext? context,
    _i16.TaskHelper? taskHelper,
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
  _i14.Future<void> syncAllNotifications() => (super.noSuchMethod(
        Invocation.method(
          #syncAllNotifications,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
  @override
  void finishedLoading() => super.noSuchMethod(
        Invocation.method(
          #finishedLoading,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i5.TaskItem addNewTaskToList(_i5.TaskItem? taskItem) => (super.noSuchMethod(
        Invocation.method(
          #addNewTaskToList,
          [taskItem],
        ),
        returnValue: _FakeTaskItem_3(
          this,
          Invocation.method(
            #addNewTaskToList,
            [taskItem],
          ),
        ),
        returnValueForMissingStub: _FakeTaskItem_3(
          this,
          Invocation.method(
            #addNewTaskToList,
            [taskItem],
          ),
        ),
      ) as _i5.TaskItem);
  @override
  void deleteTaskFromList(_i5.TaskItem? taskItem) => super.noSuchMethod(
        Invocation.method(
          #deleteTaskFromList,
          [taskItem],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void replaceTaskItem(
    _i5.TaskItem? oldTaskItem,
    _i5.TaskItem? newTaskItem,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #replaceTaskItem,
          [
            oldTaskItem,
            newTaskItem,
          ],
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
class MockTaskRepository extends _i1.Mock implements _i10.TaskRepository {
  @override
  _i6.AppState get appState => (super.noSuchMethod(
        Invocation.getter(#appState),
        returnValue: _FakeAppState_4(
          this,
          Invocation.getter(#appState),
        ),
        returnValueForMissingStub: _FakeAppState_4(
          this,
          Invocation.getter(#appState),
        ),
      ) as _i6.AppState);
  @override
  set appState(_i6.AppState? _appState) => super.noSuchMethod(
        Invocation.setter(
          #appState,
          _appState,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i7.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_5(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_5(
          this,
          Invocation.getter(#client),
        ),
      ) as _i7.Client);
  @override
  set client(_i7.Client? _client) => super.noSuchMethod(
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
        returnValue: _FakeUri_6(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_6(
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
        returnValue: _FakeUri_6(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_6(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);
  @override
  _i14.Future<void> loadTasks(_i15.StateSetter? stateSetter) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadTasks,
          [stateSetter],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
  @override
  _i14.Future<_i5.TaskItem> addTask(_i17.TaskItemBlueprint? taskItemForm) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTask,
          [taskItemForm],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTask,
            [taskItemForm],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTask,
            [taskItemForm],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<_i5.TaskItem> addTaskIteration(
    _i11.TaskItemPreview? taskItemPreview,
    int? personId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTaskIteration,
          [
            taskItemPreview,
            personId,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTaskIteration,
            [
              taskItemPreview,
              personId,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTaskIteration,
            [
              taskItemPreview,
              personId,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<_i8.Snooze> addSnooze(_i8.Snooze? snooze) => (super.noSuchMethod(
        Invocation.method(
          #addSnooze,
          [snooze],
        ),
        returnValue: _i14.Future<_i8.Snooze>.value(_FakeSnooze_7(
          this,
          Invocation.method(
            #addSnooze,
            [snooze],
          ),
        )),
        returnValueForMissingStub: _i14.Future<_i8.Snooze>.value(_FakeSnooze_7(
          this,
          Invocation.method(
            #addSnooze,
            [snooze],
          ),
        )),
      ) as _i14.Future<_i8.Snooze>);
  @override
  _i14.Future<_i9.Sprint> addSprint(_i9.Sprint? sprint) => (super.noSuchMethod(
        Invocation.method(
          #addSprint,
          [sprint],
        ),
        returnValue: _i14.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addSprint,
            [sprint],
          ),
        )),
        returnValueForMissingStub: _i14.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addSprint,
            [sprint],
          ),
        )),
      ) as _i14.Future<_i9.Sprint>);
  @override
  _i14.Future<void> addTasksToSprint(
    List<_i5.TaskItem>? taskItems,
    _i9.Sprint? sprint,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTasksToSprint,
          [
            taskItems,
            sprint,
          ],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
  @override
  _i14.Future<_i5.TaskItem> completeTask(
    _i5.TaskItem? taskItem,
    DateTime? completionDate,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #completeTask,
          [
            taskItem,
            completionDate,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #completeTask,
            [
              taskItem,
              completionDate,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #completeTask,
            [
              taskItem,
              completionDate,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<_i5.TaskItem> updateTask(
    _i5.TaskItem? taskItem,
    _i17.TaskItemBlueprint? taskItemForm,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [
            taskItem,
            taskItemForm,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              taskItemForm,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              taskItemForm,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<void> deleteTask(_i5.TaskItem? taskItem) => (super.noSuchMethod(
        Invocation.method(
          #deleteTask,
          [taskItem],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
}

/// A class which mocks [TaskHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskHelper extends _i1.Mock implements _i16.TaskHelper {
  @override
  _i6.AppState get appState => (super.noSuchMethod(
        Invocation.getter(#appState),
        returnValue: _FakeAppState_4(
          this,
          Invocation.getter(#appState),
        ),
        returnValueForMissingStub: _FakeAppState_4(
          this,
          Invocation.getter(#appState),
        ),
      ) as _i6.AppState);
  @override
  _i10.TaskRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeTaskRepository_9(
          this,
          Invocation.getter(#repository),
        ),
        returnValueForMissingStub: _FakeTaskRepository_9(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i10.TaskRepository);
  @override
  _i2.TaskMasterAuth get auth => (super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: _FakeTaskMasterAuth_0(
          this,
          Invocation.getter(#auth),
        ),
        returnValueForMissingStub: _FakeTaskMasterAuth_0(
          this,
          Invocation.getter(#auth),
        ),
      ) as _i2.TaskMasterAuth);
  @override
  _i15.StateSetter get stateSetter => (super.noSuchMethod(
        Invocation.getter(#stateSetter),
        returnValue: (dynamic fn) {},
        returnValueForMissingStub: (dynamic fn) {},
      ) as _i15.StateSetter);
  @override
  _i4.NavHelper get navHelper => (super.noSuchMethod(
        Invocation.getter(#navHelper),
        returnValue: _FakeNavHelper_2(
          this,
          Invocation.getter(#navHelper),
        ),
        returnValueForMissingStub: _FakeNavHelper_2(
          this,
          Invocation.getter(#navHelper),
        ),
      ) as _i4.NavHelper);
  @override
  set navHelper(_i4.NavHelper? _navHelper) => super.noSuchMethod(
        Invocation.setter(
          #navHelper,
          _navHelper,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i14.Future<void> reloadTasks() => (super.noSuchMethod(
        Invocation.method(
          #reloadTasks,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
  @override
  _i14.Future<_i5.TaskItem> addTask(_i17.TaskItemBlueprint? taskItem) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTask,
          [taskItem],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTask,
            [taskItem],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTask,
            [taskItem],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<_i5.TaskItem> addTaskIteration(
    _i11.TaskItemPreview? taskItem,
    int? personId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTaskIteration,
          [
            taskItem,
            personId,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTaskIteration,
            [
              taskItem,
              personId,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTaskIteration,
            [
              taskItem,
              personId,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i5.TaskItem updateTaskList(_i5.TaskItem? committedTask) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTaskList,
          [committedTask],
        ),
        returnValue: _FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTaskList,
            [committedTask],
          ),
        ),
        returnValueForMissingStub: _FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTaskList,
            [committedTask],
          ),
        ),
      ) as _i5.TaskItem);
  @override
  _i11.TaskItemPreview? maybeCreateNextIteration(
    _i5.TaskItem? taskItem,
    bool? completed,
    DateTime? completionDate,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #maybeCreateNextIteration,
          [
            taskItem,
            completed,
            completionDate,
          ],
        ),
        returnValueForMissingStub: null,
      ) as _i11.TaskItemPreview?);
  @override
  _i11.TaskItemPreview createNextIteration(
    _i11.TaskItemPreview? taskItem,
    DateTime? completionDate,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createNextIteration,
          [
            taskItem,
            completionDate,
          ],
        ),
        returnValue: _FakeTaskItemPreview_10(
          this,
          Invocation.method(
            #createNextIteration,
            [
              taskItem,
              completionDate,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeTaskItemPreview_10(
          this,
          Invocation.method(
            #createNextIteration,
            [
              taskItem,
              completionDate,
            ],
          ),
        ),
      ) as _i11.TaskItemPreview);
  @override
  _i14.Future<_i5.TaskItem> completeTask(
    _i5.TaskItem? taskItem,
    bool? completed,
    _i15.StateSetter? stateSetter,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #completeTask,
          [
            taskItem,
            completed,
            stateSetter,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #completeTask,
            [
              taskItem,
              completed,
              stateSetter,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #completeTask,
            [
              taskItem,
              completed,
              stateSetter,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<void> deleteTask(
    _i5.TaskItem? taskItem,
    _i15.StateSetter? stateSetter,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteTask,
          [
            taskItem,
            stateSetter,
          ],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
  @override
  _i14.Future<_i5.TaskItem> updateTask(
    _i5.TaskItem? taskItem,
    _i17.TaskItemBlueprint? changes,
    _i15.StateSetter? stateSetter,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [
            taskItem,
            changes,
            stateSetter,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              changes,
              stateSetter,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              changes,
              stateSetter,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  void previewSnooze(
    _i17.TaskItemBlueprint? taskItemEdit,
    int? numUnits,
    String? unitSize,
    _i18.TaskDateType? dateType,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #previewSnooze,
          [
            taskItemEdit,
            numUnits,
            unitSize,
            dateType,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i14.Future<_i5.TaskItem> snoozeTask(
    _i5.TaskItem? taskItem,
    _i17.TaskItemBlueprint? taskItemEdit,
    int? numUnits,
    String? unitSize,
    _i18.TaskDateType? dateType,
    bool? offCycle,
    _i15.StateSetter? stateSetter,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #snoozeTask,
          [
            taskItem,
            taskItemEdit,
            numUnits,
            unitSize,
            dateType,
            offCycle,
            stateSetter,
          ],
        ),
        returnValue: _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #snoozeTask,
            [
              taskItem,
              taskItemEdit,
              numUnits,
              unitSize,
              dateType,
              offCycle,
              stateSetter,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i14.Future<_i5.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #snoozeTask,
            [
              taskItem,
              taskItemEdit,
              numUnits,
              unitSize,
              dateType,
              offCycle,
              stateSetter,
            ],
          ),
        )),
      ) as _i14.Future<_i5.TaskItem>);
  @override
  _i14.Future<_i9.Sprint> addSprintAndTasks(
    _i9.Sprint? sprint,
    List<_i5.TaskItem>? taskItems,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addSprintAndTasks,
          [
            sprint,
            taskItems,
          ],
        ),
        returnValue: _i14.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addSprintAndTasks,
            [
              sprint,
              taskItems,
            ],
          ),
        )),
        returnValueForMissingStub: _i14.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addSprintAndTasks,
            [
              sprint,
              taskItems,
            ],
          ),
        )),
      ) as _i14.Future<_i9.Sprint>);
  @override
  _i14.Future<_i9.Sprint> addTasksToSprint(
    _i9.Sprint? sprint,
    List<_i5.TaskItem>? taskItems,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTasksToSprint,
          [
            sprint,
            taskItems,
          ],
        ),
        returnValue: _i14.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addTasksToSprint,
            [
              sprint,
              taskItems,
            ],
          ),
        )),
        returnValueForMissingStub: _i14.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addTasksToSprint,
            [
              sprint,
              taskItems,
            ],
          ),
        )),
      ) as _i14.Future<_i9.Sprint>);
}
