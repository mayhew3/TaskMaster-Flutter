// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/notification_scheduler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:http/http.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/models/data_payload.dart' as _i5;
import 'package:taskmaster/models/models.dart' as _i2;
import 'package:taskmaster/redux/redux_app_state.dart' as _i3;
import 'package:taskmaster/task_repository.dart' as _i6;

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

class _FakeVisibilityFilter_0 extends _i1.SmartFake
    implements _i2.VisibilityFilter {
  _FakeVisibilityFilter_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeReduxAppState_1 extends _i1.SmartFake implements _i3.ReduxAppState {
  _FakeReduxAppState_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_2 extends _i1.SmartFake implements _i4.Client {
  _FakeClient_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_3 extends _i1.SmartFake implements Uri {
  _FakeUri_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDataPayload_4 extends _i1.SmartFake implements _i5.DataPayload {
  _FakeDataPayload_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_5 extends _i1.SmartFake implements _i2.TaskItem {
  _FakeTaskItem_5(
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
// ignore: must_be_immutable
class MockReduxAppState extends _i1.Mock implements _i3.ReduxAppState {
  @override
  bool get isLoading => (super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  List<_i2.TaskItem> get taskItems => (super.noSuchMethod(
        Invocation.getter(#taskItems),
        returnValue: <_i2.TaskItem>[],
        returnValueForMissingStub: <_i2.TaskItem>[],
      ) as List<_i2.TaskItem>);

  @override
  List<_i2.Sprint> get sprints => (super.noSuchMethod(
        Invocation.getter(#sprints),
        returnValue: <_i2.Sprint>[],
        returnValueForMissingStub: <_i2.Sprint>[],
      ) as List<_i2.Sprint>);

  @override
  List<_i2.TaskRecurrence> get taskRecurrences => (super.noSuchMethod(
        Invocation.getter(#taskRecurrences),
        returnValue: <_i2.TaskRecurrence>[],
        returnValueForMissingStub: <_i2.TaskRecurrence>[],
      ) as List<_i2.TaskRecurrence>);

  @override
  _i2.AppTab get activeTab => (super.noSuchMethod(
        Invocation.getter(#activeTab),
        returnValue: _i2.AppTab.plan,
        returnValueForMissingStub: _i2.AppTab.plan,
      ) as _i2.AppTab);

  @override
  _i2.VisibilityFilter get sprintListFilter => (super.noSuchMethod(
        Invocation.getter(#sprintListFilter),
        returnValue: _FakeVisibilityFilter_0(
          this,
          Invocation.getter(#sprintListFilter),
        ),
        returnValueForMissingStub: _FakeVisibilityFilter_0(
          this,
          Invocation.getter(#sprintListFilter),
        ),
      ) as _i2.VisibilityFilter);

  @override
  _i2.VisibilityFilter get taskListFilter => (super.noSuchMethod(
        Invocation.getter(#taskListFilter),
        returnValue: _FakeVisibilityFilter_0(
          this,
          Invocation.getter(#taskListFilter),
        ),
        returnValueForMissingStub: _FakeVisibilityFilter_0(
          this,
          Invocation.getter(#taskListFilter),
        ),
      ) as _i2.VisibilityFilter);

  @override
  _i3.ReduxAppState copyWith({
    bool? isLoading,
    List<_i2.TaskItem>? todos,
    List<_i2.Sprint>? sprints,
    List<_i2.TaskRecurrence>? taskRecurrences,
    _i2.AppTab? activeTab,
    _i2.VisibilityFilter? sprintListFilter,
    _i2.VisibilityFilter? taskListFilter,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #copyWith,
          [],
          {
            #isLoading: isLoading,
            #todos: todos,
            #sprints: sprints,
            #taskRecurrences: taskRecurrences,
            #activeTab: activeTab,
            #sprintListFilter: sprintListFilter,
            #taskListFilter: taskListFilter,
          },
        ),
        returnValue: _FakeReduxAppState_1(
          this,
          Invocation.method(
            #copyWith,
            [],
            {
              #isLoading: isLoading,
              #todos: todos,
              #sprints: sprints,
              #taskRecurrences: taskRecurrences,
              #activeTab: activeTab,
              #sprintListFilter: sprintListFilter,
              #taskListFilter: taskListFilter,
            },
          ),
        ),
        returnValueForMissingStub: _FakeReduxAppState_1(
          this,
          Invocation.method(
            #copyWith,
            [],
            {
              #isLoading: isLoading,
              #todos: todos,
              #sprints: sprints,
              #taskRecurrences: taskRecurrences,
              #activeTab: activeTab,
              #sprintListFilter: sprintListFilter,
              #taskListFilter: taskListFilter,
            },
          ),
        ),
      ) as _i3.ReduxAppState);
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i6.TaskRepository {
  @override
  _i4.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_2(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_2(
          this,
          Invocation.getter(#client),
        ),
      ) as _i4.Client);

  @override
  set client(_i4.Client? _client) => super.noSuchMethod(
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
        returnValue: _FakeUri_3(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_3(
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
        returnValue: _FakeUri_3(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_3(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);

  @override
  _i7.Future<_i5.DataPayload> loadTasksRedux() => (super.noSuchMethod(
        Invocation.method(
          #loadTasksRedux,
          [],
        ),
        returnValue: _i7.Future<_i5.DataPayload>.value(_FakeDataPayload_4(
          this,
          Invocation.method(
            #loadTasksRedux,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i5.DataPayload>.value(_FakeDataPayload_4(
          this,
          Invocation.method(
            #loadTasksRedux,
            [],
          ),
        )),
      ) as _i7.Future<_i5.DataPayload>);

  @override
  _i7.Future<_i2.TaskItem> addTaskRedux(_i2.TaskItem? taskItem) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTaskRedux,
          [taskItem],
        ),
        returnValue: _i7.Future<_i2.TaskItem>.value(_FakeTaskItem_5(
          this,
          Invocation.method(
            #addTaskRedux,
            [taskItem],
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.TaskItem>.value(_FakeTaskItem_5(
          this,
          Invocation.method(
            #addTaskRedux,
            [taskItem],
          ),
        )),
      ) as _i7.Future<_i2.TaskItem>);
}
