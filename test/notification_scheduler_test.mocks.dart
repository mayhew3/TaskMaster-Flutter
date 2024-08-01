// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/notification_scheduler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:built_collection/built_collection.dart' as _i2;
import 'package:http/http.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/models/data_payload.dart' as _i6;
import 'package:taskmaster/models/models.dart' as _i3;
import 'package:taskmaster/redux/redux_app_state.dart' as _i4;
import 'package:taskmaster/task_repository.dart' as _i7;

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

class _FakeReduxAppState_2 extends _i1.SmartFake implements _i4.ReduxAppState {
  _FakeReduxAppState_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeReduxAppStateBuilder_3 extends _i1.SmartFake
    implements _i4.ReduxAppStateBuilder {
  _FakeReduxAppStateBuilder_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_4 extends _i1.SmartFake implements _i5.Client {
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

class _FakeDataPayload_6 extends _i1.SmartFake implements _i6.DataPayload {
  _FakeDataPayload_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_7 extends _i1.SmartFake implements _i3.TaskItem {
  _FakeTaskItem_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ReduxAppState].
///
/// See the documentation for Mockito's code generation for more information.
class MockReduxAppState extends _i1.Mock implements _i4.ReduxAppState {
  @override
  bool get isLoading => (super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

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
  _i4.ReduxAppState rebuild(
          dynamic Function(_i4.ReduxAppStateBuilder)? updates) =>
      (super.noSuchMethod(
        Invocation.method(
          #rebuild,
          [updates],
        ),
        returnValue: _FakeReduxAppState_2(
          this,
          Invocation.method(
            #rebuild,
            [updates],
          ),
        ),
        returnValueForMissingStub: _FakeReduxAppState_2(
          this,
          Invocation.method(
            #rebuild,
            [updates],
          ),
        ),
      ) as _i4.ReduxAppState);

  @override
  _i4.ReduxAppStateBuilder toBuilder() => (super.noSuchMethod(
        Invocation.method(
          #toBuilder,
          [],
        ),
        returnValue: _FakeReduxAppStateBuilder_3(
          this,
          Invocation.method(
            #toBuilder,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeReduxAppStateBuilder_3(
          this,
          Invocation.method(
            #toBuilder,
            [],
          ),
        ),
      ) as _i4.ReduxAppStateBuilder);
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i7.TaskRepository {
  @override
  _i5.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_4(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_4(
          this,
          Invocation.getter(#client),
        ),
      ) as _i5.Client);

  @override
  set client(_i5.Client? _client) => super.noSuchMethod(
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
  _i8.Future<_i6.DataPayload> loadTasksRedux() => (super.noSuchMethod(
        Invocation.method(
          #loadTasksRedux,
          [],
        ),
        returnValue: _i8.Future<_i6.DataPayload>.value(_FakeDataPayload_6(
          this,
          Invocation.method(
            #loadTasksRedux,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.DataPayload>.value(_FakeDataPayload_6(
          this,
          Invocation.method(
            #loadTasksRedux,
            [],
          ),
        )),
      ) as _i8.Future<_i6.DataPayload>);

  @override
  _i8.Future<_i3.TaskItem> addTaskRedux(_i3.TaskItem? taskItem) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTaskRedux,
          [taskItem],
        ),
        returnValue: _i8.Future<_i3.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #addTaskRedux,
            [taskItem],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i3.TaskItem>.value(_FakeTaskItem_7(
          this,
          Invocation.method(
            #addTaskRedux,
            [taskItem],
          ),
        )),
      ) as _i8.Future<_i3.TaskItem>);
}
