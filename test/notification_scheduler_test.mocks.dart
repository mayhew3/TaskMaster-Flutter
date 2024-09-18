// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/notification_scheduler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;

import 'package:built_collection/built_collection.dart' as _i2;
import 'package:google_sign_in/google_sign_in.dart' as _i5;
import 'package:http/http.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/models/data_payload.dart' as _i9;
import 'package:taskmaster/models/models.dart' as _i4;
import 'package:taskmaster/models/sprint_assignment.dart' as _i15;
import 'package:taskmaster/models/sprint_blueprint.dart' as _i13;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i12;
import 'package:taskmaster/models/task_recurrence_blueprint.dart' as _i14;
import 'package:taskmaster/models/top_nav_item.dart' as _i3;
import 'package:taskmaster/redux/app_state.dart' as _i7;
import 'package:taskmaster/task_repository.dart' as _i11;
import 'package:taskmaster/timezone_helper.dart' as _i6;

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

class _FakeBuiltList_0<E> extends _i1.SmartFake implements _i2.BuiltList<E> {
  _FakeBuiltList_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTopNavItem_1 extends _i1.SmartFake implements _i3.TopNavItem {
  _FakeTopNavItem_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeVisibilityFilter_2 extends _i1.SmartFake
    implements _i4.VisibilityFilter {
  _FakeVisibilityFilter_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoogleSignIn_3 extends _i1.SmartFake implements _i5.GoogleSignIn {
  _FakeGoogleSignIn_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTimezoneHelper_4 extends _i1.SmartFake
    implements _i6.TimezoneHelper {
  _FakeTimezoneHelper_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAppState_5 extends _i1.SmartFake implements _i7.AppState {
  _FakeAppState_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAppStateBuilder_6 extends _i1.SmartFake
    implements _i7.AppStateBuilder {
  _FakeAppStateBuilder_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_7 extends _i1.SmartFake implements _i8.Client {
  _FakeClient_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_8 extends _i1.SmartFake implements Uri {
  _FakeUri_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDataPayload_9 extends _i1.SmartFake implements _i9.DataPayload {
  _FakeDataPayload_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_10 extends _i1.SmartFake implements _i4.TaskItem {
  _FakeTaskItem_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSprint_11 extends _i1.SmartFake implements _i4.Sprint {
  _FakeSprint_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskRecurrence_12 extends _i1.SmartFake
    implements _i4.TaskRecurrence {
  _FakeTaskRecurrence_12(
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
class MockAppState extends _i1.Mock implements _i7.AppState {
  @override
  _i2.BuiltList<_i4.TaskItem> get taskItems => (super.noSuchMethod(
        Invocation.getter(#taskItems),
        returnValue: _FakeBuiltList_0<_i4.TaskItem>(
          this,
          Invocation.getter(#taskItems),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i4.TaskItem>(
          this,
          Invocation.getter(#taskItems),
        ),
      ) as _i2.BuiltList<_i4.TaskItem>);

  @override
  _i2.BuiltList<_i4.Sprint> get sprints => (super.noSuchMethod(
        Invocation.getter(#sprints),
        returnValue: _FakeBuiltList_0<_i4.Sprint>(
          this,
          Invocation.getter(#sprints),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i4.Sprint>(
          this,
          Invocation.getter(#sprints),
        ),
      ) as _i2.BuiltList<_i4.Sprint>);

  @override
  _i2.BuiltList<_i4.TaskRecurrence> get taskRecurrences => (super.noSuchMethod(
        Invocation.getter(#taskRecurrences),
        returnValue: _FakeBuiltList_0<_i4.TaskRecurrence>(
          this,
          Invocation.getter(#taskRecurrences),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i4.TaskRecurrence>(
          this,
          Invocation.getter(#taskRecurrences),
        ),
      ) as _i2.BuiltList<_i4.TaskRecurrence>);

  @override
  bool get isLoading => (super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  bool get loadFailed => (super.noSuchMethod(
        Invocation.getter(#loadFailed),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i2.BuiltList<_i4.TaskItem> get recentlyCompleted => (super.noSuchMethod(
        Invocation.getter(#recentlyCompleted),
        returnValue: _FakeBuiltList_0<_i4.TaskItem>(
          this,
          Invocation.getter(#recentlyCompleted),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i4.TaskItem>(
          this,
          Invocation.getter(#recentlyCompleted),
        ),
      ) as _i2.BuiltList<_i4.TaskItem>);

  @override
  _i3.TopNavItem get activeTab => (super.noSuchMethod(
        Invocation.getter(#activeTab),
        returnValue: _FakeTopNavItem_1(
          this,
          Invocation.getter(#activeTab),
        ),
        returnValueForMissingStub: _FakeTopNavItem_1(
          this,
          Invocation.getter(#activeTab),
        ),
      ) as _i3.TopNavItem);

  @override
  _i2.BuiltList<_i3.TopNavItem> get allNavItems => (super.noSuchMethod(
        Invocation.getter(#allNavItems),
        returnValue: _FakeBuiltList_0<_i3.TopNavItem>(
          this,
          Invocation.getter(#allNavItems),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i3.TopNavItem>(
          this,
          Invocation.getter(#allNavItems),
        ),
      ) as _i2.BuiltList<_i3.TopNavItem>);

  @override
  _i4.VisibilityFilter get sprintListFilter => (super.noSuchMethod(
        Invocation.getter(#sprintListFilter),
        returnValue: _FakeVisibilityFilter_2(
          this,
          Invocation.getter(#sprintListFilter),
        ),
        returnValueForMissingStub: _FakeVisibilityFilter_2(
          this,
          Invocation.getter(#sprintListFilter),
        ),
      ) as _i4.VisibilityFilter);

  @override
  _i4.VisibilityFilter get taskListFilter => (super.noSuchMethod(
        Invocation.getter(#taskListFilter),
        returnValue: _FakeVisibilityFilter_2(
          this,
          Invocation.getter(#taskListFilter),
        ),
        returnValueForMissingStub: _FakeVisibilityFilter_2(
          this,
          Invocation.getter(#taskListFilter),
        ),
      ) as _i4.VisibilityFilter);

  @override
  _i5.GoogleSignIn get googleSignIn => (super.noSuchMethod(
        Invocation.getter(#googleSignIn),
        returnValue: _FakeGoogleSignIn_3(
          this,
          Invocation.getter(#googleSignIn),
        ),
        returnValueForMissingStub: _FakeGoogleSignIn_3(
          this,
          Invocation.getter(#googleSignIn),
        ),
      ) as _i5.GoogleSignIn);

  @override
  bool get tokenRetrieved => (super.noSuchMethod(
        Invocation.getter(#tokenRetrieved),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i6.TimezoneHelper get timezoneHelper => (super.noSuchMethod(
        Invocation.getter(#timezoneHelper),
        returnValue: _FakeTimezoneHelper_4(
          this,
          Invocation.getter(#timezoneHelper),
        ),
        returnValueForMissingStub: _FakeTimezoneHelper_4(
          this,
          Invocation.getter(#timezoneHelper),
        ),
      ) as _i6.TimezoneHelper);

  @override
  _i10.Future<String?> getIdToken() => (super.noSuchMethod(
        Invocation.method(
          #getIdToken,
          [],
        ),
        returnValue: _i10.Future<String?>.value(),
        returnValueForMissingStub: _i10.Future<String?>.value(),
      ) as _i10.Future<String?>);

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
  bool appIsReady() => (super.noSuchMethod(
        Invocation.method(
          #appIsReady,
          [],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i7.AppState rebuild(dynamic Function(_i7.AppStateBuilder)? updates) =>
      (super.noSuchMethod(
        Invocation.method(
          #rebuild,
          [updates],
        ),
        returnValue: _FakeAppState_5(
          this,
          Invocation.method(
            #rebuild,
            [updates],
          ),
        ),
        returnValueForMissingStub: _FakeAppState_5(
          this,
          Invocation.method(
            #rebuild,
            [updates],
          ),
        ),
      ) as _i7.AppState);

  @override
  _i7.AppStateBuilder toBuilder() => (super.noSuchMethod(
        Invocation.method(
          #toBuilder,
          [],
        ),
        returnValue: _FakeAppStateBuilder_6(
          this,
          Invocation.method(
            #toBuilder,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeAppStateBuilder_6(
          this,
          Invocation.method(
            #toBuilder,
            [],
          ),
        ),
      ) as _i7.AppStateBuilder);
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i11.TaskRepository {
  @override
  _i8.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_7(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_7(
          this,
          Invocation.getter(#client),
        ),
      ) as _i8.Client);

  @override
  set client(_i8.Client? _client) => super.noSuchMethod(
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
        returnValue: _FakeUri_8(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_8(
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
        returnValue: _FakeUri_8(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_8(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);

  @override
  _i10.Future<int?> getPersonId(
    String? email,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPersonId,
          [
            email,
            idToken,
          ],
        ),
        returnValue: _i10.Future<int?>.value(),
        returnValueForMissingStub: _i10.Future<int?>.value(),
      ) as _i10.Future<int?>);

  @override
  _i10.Future<_i9.DataPayload> loadTasks(
    int? personId,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadTasks,
          [
            personId,
            idToken,
          ],
        ),
        returnValue: _i10.Future<_i9.DataPayload>.value(_FakeDataPayload_9(
          this,
          Invocation.method(
            #loadTasks,
            [
              personId,
              idToken,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i9.DataPayload>.value(_FakeDataPayload_9(
          this,
          Invocation.method(
            #loadTasks,
            [
              personId,
              idToken,
            ],
          ),
        )),
      ) as _i10.Future<_i9.DataPayload>);

  @override
  _i10.Future<
      ({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})> addTask(
    _i12.TaskItemBlueprint? blueprint,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTask,
          [
            blueprint,
            idToken,
          ],
        ),
        returnValue: _i10.Future<
            ({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})>.value((
          recurrence: null,
          taskItem: _FakeTaskItem_10(
            this,
            Invocation.method(
              #addTask,
              [
                blueprint,
                idToken,
              ],
            ),
          )
        )),
        returnValueForMissingStub: _i10.Future<
            ({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})>.value((
          recurrence: null,
          taskItem: _FakeTaskItem_10(
            this,
            Invocation.method(
              #addTask,
              [
                blueprint,
                idToken,
              ],
            ),
          )
        )),
      ) as _i10
          .Future<({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})>);

  @override
  _i10.Future<
      ({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})> updateTask(
    _i4.TaskItem? taskItem,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [
            taskItem,
            idToken,
          ],
        ),
        returnValue: _i10.Future<
            ({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})>.value((
          recurrence: null,
          taskItem: _FakeTaskItem_10(
            this,
            Invocation.method(
              #updateTask,
              [
                taskItem,
                idToken,
              ],
            ),
          )
        )),
        returnValueForMissingStub: _i10.Future<
            ({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})>.value((
          recurrence: null,
          taskItem: _FakeTaskItem_10(
            this,
            Invocation.method(
              #updateTask,
              [
                taskItem,
                idToken,
              ],
            ),
          )
        )),
      ) as _i10
          .Future<({_i4.TaskRecurrence? recurrence, _i4.TaskItem taskItem})>);

  @override
  _i10.Future<_i4.Sprint> addSprint(
    _i13.SprintBlueprint? blueprint,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addSprint,
          [
            blueprint,
            idToken,
          ],
        ),
        returnValue: _i10.Future<_i4.Sprint>.value(_FakeSprint_11(
          this,
          Invocation.method(
            #addSprint,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
        returnValueForMissingStub: _i10.Future<_i4.Sprint>.value(_FakeSprint_11(
          this,
          Invocation.method(
            #addSprint,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
      ) as _i10.Future<_i4.Sprint>);

  @override
  _i10.Future<_i4.TaskRecurrence> addTaskRecurrence(
    _i14.TaskRecurrenceBlueprint? blueprint,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTaskRecurrence,
          [
            blueprint,
            idToken,
          ],
        ),
        returnValue:
            _i10.Future<_i4.TaskRecurrence>.value(_FakeTaskRecurrence_12(
          this,
          Invocation.method(
            #addTaskRecurrence,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i4.TaskRecurrence>.value(_FakeTaskRecurrence_12(
          this,
          Invocation.method(
            #addTaskRecurrence,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
      ) as _i10.Future<_i4.TaskRecurrence>);

  @override
  _i10.Future<List<_i15.SprintAssignment>> addTasksToSprint(
    List<_i4.TaskItem>? taskItems,
    _i4.Sprint? sprint,
    String? idToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTasksToSprint,
          [
            taskItems,
            sprint,
            idToken,
          ],
        ),
        returnValue: _i10.Future<List<_i15.SprintAssignment>>.value(
            <_i15.SprintAssignment>[]),
        returnValueForMissingStub:
            _i10.Future<List<_i15.SprintAssignment>>.value(
                <_i15.SprintAssignment>[]),
      ) as _i10.Future<List<_i15.SprintAssignment>>);
}
