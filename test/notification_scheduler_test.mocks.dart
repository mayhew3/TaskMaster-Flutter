// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/notification_scheduler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;

import 'package:built_collection/built_collection.dart' as _i2;
import 'package:google_sign_in/google_sign_in.dart' as _i4;
import 'package:http/http.dart' as _i7;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/models/data_payload.dart' as _i8;
import 'package:taskmaster/models/models.dart' as _i3;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i11;
import 'package:taskmaster/redux/app_state.dart' as _i6;
import 'package:taskmaster/task_repository.dart' as _i10;
import 'package:taskmaster/timezone_helper.dart' as _i5;

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

class _FakeVisibilityFilter_1 extends _i1.SmartFake
    implements _i3.VisibilityFilter {
  _FakeVisibilityFilter_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoogleSignIn_2 extends _i1.SmartFake implements _i4.GoogleSignIn {
  _FakeGoogleSignIn_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTimezoneHelper_3 extends _i1.SmartFake
    implements _i5.TimezoneHelper {
  _FakeTimezoneHelper_3(
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

class _FakeAppStateBuilder_5 extends _i1.SmartFake
    implements _i6.AppStateBuilder {
  _FakeAppStateBuilder_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_6 extends _i1.SmartFake implements _i7.Client {
  _FakeClient_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_7 extends _i1.SmartFake implements Uri {
  _FakeUri_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDataPayload_8 extends _i1.SmartFake implements _i8.DataPayload {
  _FakeDataPayload_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_9 extends _i1.SmartFake implements _i3.TaskItem {
  _FakeTaskItem_9(
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
  _i2.BuiltList<_i3.TaskItem> get taskItems => (super.noSuchMethod(
        Invocation.getter(#taskItems),
        returnValue: _FakeBuiltList_0<_i3.TaskItem>(
          this,
          Invocation.getter(#taskItems),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i3.TaskItem>(
          this,
          Invocation.getter(#taskItems),
        ),
      ) as _i2.BuiltList<_i3.TaskItem>);

  @override
  _i2.BuiltList<_i3.Sprint> get sprints => (super.noSuchMethod(
        Invocation.getter(#sprints),
        returnValue: _FakeBuiltList_0<_i3.Sprint>(
          this,
          Invocation.getter(#sprints),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i3.Sprint>(
          this,
          Invocation.getter(#sprints),
        ),
      ) as _i2.BuiltList<_i3.Sprint>);

  @override
  _i2.BuiltList<_i3.TaskRecurrence> get taskRecurrences => (super.noSuchMethod(
        Invocation.getter(#taskRecurrences),
        returnValue: _FakeBuiltList_0<_i3.TaskRecurrence>(
          this,
          Invocation.getter(#taskRecurrences),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i3.TaskRecurrence>(
          this,
          Invocation.getter(#taskRecurrences),
        ),
      ) as _i2.BuiltList<_i3.TaskRecurrence>);

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
  _i2.BuiltList<_i3.TaskItem> get recentlyCompleted => (super.noSuchMethod(
        Invocation.getter(#recentlyCompleted),
        returnValue: _FakeBuiltList_0<_i3.TaskItem>(
          this,
          Invocation.getter(#recentlyCompleted),
        ),
        returnValueForMissingStub: _FakeBuiltList_0<_i3.TaskItem>(
          this,
          Invocation.getter(#recentlyCompleted),
        ),
      ) as _i2.BuiltList<_i3.TaskItem>);

  @override
  _i3.AppTab get activeTab => (super.noSuchMethod(
        Invocation.getter(#activeTab),
        returnValue: _i3.AppTab.plan,
        returnValueForMissingStub: _i3.AppTab.plan,
      ) as _i3.AppTab);

  @override
  _i3.VisibilityFilter get sprintListFilter => (super.noSuchMethod(
        Invocation.getter(#sprintListFilter),
        returnValue: _FakeVisibilityFilter_1(
          this,
          Invocation.getter(#sprintListFilter),
        ),
        returnValueForMissingStub: _FakeVisibilityFilter_1(
          this,
          Invocation.getter(#sprintListFilter),
        ),
      ) as _i3.VisibilityFilter);

  @override
  _i3.VisibilityFilter get taskListFilter => (super.noSuchMethod(
        Invocation.getter(#taskListFilter),
        returnValue: _FakeVisibilityFilter_1(
          this,
          Invocation.getter(#taskListFilter),
        ),
        returnValueForMissingStub: _FakeVisibilityFilter_1(
          this,
          Invocation.getter(#taskListFilter),
        ),
      ) as _i3.VisibilityFilter);

  @override
  _i4.GoogleSignIn get googleSignIn => (super.noSuchMethod(
        Invocation.getter(#googleSignIn),
        returnValue: _FakeGoogleSignIn_2(
          this,
          Invocation.getter(#googleSignIn),
        ),
        returnValueForMissingStub: _FakeGoogleSignIn_2(
          this,
          Invocation.getter(#googleSignIn),
        ),
      ) as _i4.GoogleSignIn);

  @override
  bool get tokenRetrieved => (super.noSuchMethod(
        Invocation.getter(#tokenRetrieved),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i5.TimezoneHelper get timezoneHelper => (super.noSuchMethod(
        Invocation.getter(#timezoneHelper),
        returnValue: _FakeTimezoneHelper_3(
          this,
          Invocation.getter(#timezoneHelper),
        ),
        returnValueForMissingStub: _FakeTimezoneHelper_3(
          this,
          Invocation.getter(#timezoneHelper),
        ),
      ) as _i5.TimezoneHelper);

  @override
  _i9.Future<String?> getIdToken() => (super.noSuchMethod(
        Invocation.method(
          #getIdToken,
          [],
        ),
        returnValue: _i9.Future<String?>.value(),
        returnValueForMissingStub: _i9.Future<String?>.value(),
      ) as _i9.Future<String?>);

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
  _i6.AppState rebuild(dynamic Function(_i6.AppStateBuilder)? updates) =>
      (super.noSuchMethod(
        Invocation.method(
          #rebuild,
          [updates],
        ),
        returnValue: _FakeAppState_4(
          this,
          Invocation.method(
            #rebuild,
            [updates],
          ),
        ),
        returnValueForMissingStub: _FakeAppState_4(
          this,
          Invocation.method(
            #rebuild,
            [updates],
          ),
        ),
      ) as _i6.AppState);

  @override
  _i6.AppStateBuilder toBuilder() => (super.noSuchMethod(
        Invocation.method(
          #toBuilder,
          [],
        ),
        returnValue: _FakeAppStateBuilder_5(
          this,
          Invocation.method(
            #toBuilder,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeAppStateBuilder_5(
          this,
          Invocation.method(
            #toBuilder,
            [],
          ),
        ),
      ) as _i6.AppStateBuilder);
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i10.TaskRepository {
  @override
  _i7.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_6(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_6(
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
        returnValue: _FakeUri_7(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_7(
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
        returnValue: _FakeUri_7(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_7(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);

  @override
  _i9.Future<int?> getPersonId(
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
        returnValue: _i9.Future<int?>.value(),
        returnValueForMissingStub: _i9.Future<int?>.value(),
      ) as _i9.Future<int?>);

  @override
  _i9.Future<_i8.DataPayload> loadTasks(
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
        returnValue: _i9.Future<_i8.DataPayload>.value(_FakeDataPayload_8(
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
            _i9.Future<_i8.DataPayload>.value(_FakeDataPayload_8(
          this,
          Invocation.method(
            #loadTasks,
            [
              personId,
              idToken,
            ],
          ),
        )),
      ) as _i9.Future<_i8.DataPayload>);

  @override
  _i9.Future<_i3.TaskItem> addTask(
    _i11.TaskItemBlueprint? blueprint,
    String? idToken,
    int? personId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTask,
          [
            blueprint,
            idToken,
            personId,
          ],
        ),
        returnValue: _i9.Future<_i3.TaskItem>.value(_FakeTaskItem_9(
          this,
          Invocation.method(
            #addTask,
            [
              blueprint,
              idToken,
              personId,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i9.Future<_i3.TaskItem>.value(_FakeTaskItem_9(
          this,
          Invocation.method(
            #addTask,
            [
              blueprint,
              idToken,
              personId,
            ],
          ),
        )),
      ) as _i9.Future<_i3.TaskItem>);

  @override
  _i9.Future<_i3.TaskItem> updateTask(
    _i3.TaskItem? taskItem,
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
        returnValue: _i9.Future<_i3.TaskItem>.value(_FakeTaskItem_9(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              idToken,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i9.Future<_i3.TaskItem>.value(_FakeTaskItem_9(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              idToken,
            ],
          ),
        )),
      ) as _i9.Future<_i3.TaskItem>);
}
