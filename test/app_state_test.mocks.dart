// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/app_state_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i12;

import 'package:flutter/material.dart' as _i5;
import 'package:http/http.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/app_state.dart' as _i2;
import 'package:taskmaster/models/snooze.dart' as _i8;
import 'package:taskmaster/models/sprint.dart' as _i9;
import 'package:taskmaster/models/task_item.dart' as _i7;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i13;
import 'package:taskmaster/models/task_item_preview.dart' as _i14;
import 'package:taskmaster/models/task_recurrence.dart' as _i10;
import 'package:taskmaster/models/task_recurrence_preview.dart' as _i15;
import 'package:taskmaster/nav_helper.dart' as _i11;
import 'package:taskmaster/task_helper.dart' as _i4;
import 'package:taskmaster/task_repository.dart' as _i3;

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

class _FakeClient_4 extends _i1.SmartFake implements _i6.Client {
  _FakeClient_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_5 extends _i1.SmartFake implements Uri {
  _FakeUri_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_6 extends _i1.SmartFake implements _i7.TaskItem {
  _FakeTaskItem_6(
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

class _FakeTaskRecurrence_9 extends _i1.SmartFake
    implements _i10.TaskRecurrence {
  _FakeTaskRecurrence_9(
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
class MockNavHelper extends _i1.Mock implements _i11.NavHelper {
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
  _i6.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_4(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_4(
          this,
          Invocation.getter(#client),
        ),
      ) as _i6.Client);
  @override
  set client(_i6.Client? _client) => super.noSuchMethod(
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
        returnValue: _FakeUri_5(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_5(
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
        returnValue: _FakeUri_5(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_5(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);
  @override
  _i12.Future<void> loadTasks(_i5.StateSetter? stateSetter) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadTasks,
          [stateSetter],
        ),
        returnValue: _i12.Future<void>.value(),
        returnValueForMissingStub: _i12.Future<void>.value(),
      ) as _i12.Future<void>);
  @override
  _i12.Future<_i7.TaskItem> addTask(_i13.TaskItemBlueprint? taskItemForm) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTask,
          [taskItemForm],
        ),
        returnValue: _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
          this,
          Invocation.method(
            #addTask,
            [taskItemForm],
          ),
        )),
        returnValueForMissingStub:
            _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
          this,
          Invocation.method(
            #addTask,
            [taskItemForm],
          ),
        )),
      ) as _i12.Future<_i7.TaskItem>);
  @override
  _i12.Future<_i7.TaskItem> addTaskIteration(
    _i14.TaskItemPreview? taskItemPreview,
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
        returnValue: _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
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
            _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
          this,
          Invocation.method(
            #addTaskIteration,
            [
              taskItemPreview,
              personId,
            ],
          ),
        )),
      ) as _i12.Future<_i7.TaskItem>);
  @override
  _i12.Future<_i8.Snooze> addSnooze(_i8.Snooze? snooze) => (super.noSuchMethod(
        Invocation.method(
          #addSnooze,
          [snooze],
        ),
        returnValue: _i12.Future<_i8.Snooze>.value(_FakeSnooze_7(
          this,
          Invocation.method(
            #addSnooze,
            [snooze],
          ),
        )),
        returnValueForMissingStub: _i12.Future<_i8.Snooze>.value(_FakeSnooze_7(
          this,
          Invocation.method(
            #addSnooze,
            [snooze],
          ),
        )),
      ) as _i12.Future<_i8.Snooze>);
  @override
  _i12.Future<_i9.Sprint> addSprint(_i9.Sprint? sprint) => (super.noSuchMethod(
        Invocation.method(
          #addSprint,
          [sprint],
        ),
        returnValue: _i12.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addSprint,
            [sprint],
          ),
        )),
        returnValueForMissingStub: _i12.Future<_i9.Sprint>.value(_FakeSprint_8(
          this,
          Invocation.method(
            #addSprint,
            [sprint],
          ),
        )),
      ) as _i12.Future<_i9.Sprint>);
  @override
  _i12.Future<void> addTasksToSprint(
    List<_i7.TaskItem>? taskItems,
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
        returnValue: _i12.Future<void>.value(),
        returnValueForMissingStub: _i12.Future<void>.value(),
      ) as _i12.Future<void>);
  @override
  _i12.Future<_i7.TaskItem> completeTask(
    _i7.TaskItem? taskItem,
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
        returnValue: _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
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
            _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
          this,
          Invocation.method(
            #completeTask,
            [
              taskItem,
              completionDate,
            ],
          ),
        )),
      ) as _i12.Future<_i7.TaskItem>);
  @override
  _i12.Future<_i7.TaskItem> updateTask(
    _i7.TaskItem? taskItem,
    _i13.TaskItemBlueprint? taskItemForm,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [
            taskItem,
            taskItemForm,
          ],
        ),
        returnValue: _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
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
            _i12.Future<_i7.TaskItem>.value(_FakeTaskItem_6(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              taskItemForm,
            ],
          ),
        )),
      ) as _i12.Future<_i7.TaskItem>);
  @override
  _i12.Future<_i10.TaskRecurrence> updateTaskRecurrence(
          _i15.TaskRecurrencePreview? taskRecurrencePreview) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTaskRecurrence,
          [taskRecurrencePreview],
        ),
        returnValue:
            _i12.Future<_i10.TaskRecurrence>.value(_FakeTaskRecurrence_9(
          this,
          Invocation.method(
            #updateTaskRecurrence,
            [taskRecurrencePreview],
          ),
        )),
        returnValueForMissingStub:
            _i12.Future<_i10.TaskRecurrence>.value(_FakeTaskRecurrence_9(
          this,
          Invocation.method(
            #updateTaskRecurrence,
            [taskRecurrencePreview],
          ),
        )),
      ) as _i12.Future<_i10.TaskRecurrence>);
  @override
  _i12.Future<void> deleteTask(_i7.TaskItem? taskItem) => (super.noSuchMethod(
        Invocation.method(
          #deleteTask,
          [taskItem],
        ),
        returnValue: _i12.Future<void>.value(),
        returnValueForMissingStub: _i12.Future<void>.value(),
      ) as _i12.Future<void>);
}
