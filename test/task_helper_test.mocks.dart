// Mocks generated by Mockito 5.4.2 from annotations
// in taskmaster/test/task_helper_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/models/data_payload.dart' as _i3;
import 'package:taskmaster/models/sprint.dart' as _i5;
import 'package:taskmaster/models/sprint_blueprint.dart' as _i9;
import 'package:taskmaster/models/task_item.dart' as _i4;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i8;
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

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_1 extends _i1.SmartFake implements Uri {
  _FakeUri_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDataPayload_2 extends _i1.SmartFake implements _i3.DataPayload {
  _FakeDataPayload_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTaskItem_3 extends _i1.SmartFake implements _i4.TaskItem {
  _FakeTaskItem_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSprint_4 extends _i1.SmartFake implements _i5.Sprint {
  _FakeSprint_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i6.TaskRepository {
  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
      ) as _i2.Client);

  @override
  set client(_i2.Client? _client) => super.noSuchMethod(
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
        returnValue: _FakeUri_1(
          this,
          Invocation.method(
            #getUriWithParameters,
            [
              path,
              queryParameters,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeUri_1(
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
        returnValue: _FakeUri_1(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
        returnValueForMissingStub: _FakeUri_1(
          this,
          Invocation.method(
            #getUri,
            [path],
          ),
        ),
      ) as Uri);

  @override
  _i7.Future<int?> getPersonId(
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
        returnValue: _i7.Future<int?>.value(),
        returnValueForMissingStub: _i7.Future<int?>.value(),
      ) as _i7.Future<int?>);

  @override
  _i7.Future<_i3.DataPayload> loadTasks(
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
        returnValue: _i7.Future<_i3.DataPayload>.value(_FakeDataPayload_2(
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
            _i7.Future<_i3.DataPayload>.value(_FakeDataPayload_2(
          this,
          Invocation.method(
            #loadTasks,
            [
              personId,
              idToken,
            ],
          ),
        )),
      ) as _i7.Future<_i3.DataPayload>);

  @override
  _i7.Future<_i4.TaskItem> addTask(
    _i8.TaskItemBlueprint? blueprint,
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
        returnValue: _i7.Future<_i4.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTask,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i4.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #addTask,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
      ) as _i7.Future<_i4.TaskItem>);

  @override
  _i7.Future<_i4.TaskItem> updateTask(
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
        returnValue: _i7.Future<_i4.TaskItem>.value(_FakeTaskItem_3(
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
            _i7.Future<_i4.TaskItem>.value(_FakeTaskItem_3(
          this,
          Invocation.method(
            #updateTask,
            [
              taskItem,
              idToken,
            ],
          ),
        )),
      ) as _i7.Future<_i4.TaskItem>);

  @override
  _i7.Future<_i5.Sprint> addSprint(
    _i9.SprintBlueprint? blueprint,
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
        returnValue: _i7.Future<_i5.Sprint>.value(_FakeSprint_4(
          this,
          Invocation.method(
            #addSprint,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
        returnValueForMissingStub: _i7.Future<_i5.Sprint>.value(_FakeSprint_4(
          this,
          Invocation.method(
            #addSprint,
            [
              blueprint,
              idToken,
            ],
          ),
        )),
      ) as _i7.Future<_i5.Sprint>);
}
