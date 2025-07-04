// Mocks generated by Mockito 5.4.6 from annotations
// in taskmaster/test/recurrence_helper_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:built_collection/built_collection.dart' as _i6;
import 'package:built_value/serializer.dart' as _i10;
import 'package:cloud_firestore/cloud_firestore.dart' as _i2;
import 'package:logging/logging.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:taskmaster/models/snooze_blueprint.dart' as _i16;
import 'package:taskmaster/models/sprint.dart' as _i7;
import 'package:taskmaster/models/sprint_assignment.dart' as _i13;
import 'package:taskmaster/models/sprint_blueprint.dart' as _i14;
import 'package:taskmaster/models/task_item.dart' as _i5;
import 'package:taskmaster/models/task_item_blueprint.dart' as _i11;
import 'package:taskmaster/models/task_item_recur_preview.dart' as _i12;
import 'package:taskmaster/models/task_recurrence.dart' as _i8;
import 'package:taskmaster/models/task_recurrence_blueprint.dart' as _i15;
import 'package:taskmaster/task_repository.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFirebaseFirestore_0 extends _i1.SmartFake
    implements _i2.FirebaseFirestore {
  _FakeFirebaseFirestore_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeLogger_1 extends _i1.SmartFake implements _i3.Logger {
  _FakeLogger_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeStreamSubscription_2<T1> extends _i1.SmartFake
    implements _i4.StreamSubscription<T1> {
  _FakeStreamSubscription_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeTaskItem_3 extends _i1.SmartFake implements _i5.TaskItem {
  _FakeTaskItem_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBuiltList_4<E> extends _i1.SmartFake implements _i6.BuiltList<E> {
  _FakeBuiltList_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeSprint_5 extends _i1.SmartFake implements _i7.Sprint {
  _FakeSprint_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeTaskRecurrence_6 extends _i1.SmartFake
    implements _i8.TaskRecurrence {
  _FakeTaskRecurrence_6(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [TaskRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskRepository extends _i1.Mock implements _i9.TaskRepository {
  @override
  _i2.FirebaseFirestore get firestore =>
      (super.noSuchMethod(
            Invocation.getter(#firestore),
            returnValue: _FakeFirebaseFirestore_0(
              this,
              Invocation.getter(#firestore),
            ),
            returnValueForMissingStub: _FakeFirebaseFirestore_0(
              this,
              Invocation.getter(#firestore),
            ),
          )
          as _i2.FirebaseFirestore);

  @override
  _i3.Logger get log =>
      (super.noSuchMethod(
            Invocation.getter(#log),
            returnValue: _FakeLogger_1(this, Invocation.getter(#log)),
            returnValueForMissingStub: _FakeLogger_1(
              this,
              Invocation.getter(#log),
            ),
          )
          as _i3.Logger);

  @override
  _i4.Future<String?> getPersonIdFromFirestore(String? email) =>
      (super.noSuchMethod(
            Invocation.method(#getPersonIdFromFirestore, [email]),
            returnValue: _i4.Future<String?>.value(),
            returnValueForMissingStub: _i4.Future<String?>.value(),
          )
          as _i4.Future<String?>);

  @override
  void goOffline() => super.noSuchMethod(
    Invocation.method(#goOffline, []),
    returnValueForMissingStub: null,
  );

  @override
  void goOnline() => super.noSuchMethod(
    Invocation.method(#goOnline, []),
    returnValueForMissingStub: null,
  );

  @override
  ({
    _i4.StreamSubscription<_i2.QuerySnapshot<Map<String, dynamic>>>
    mainListener,
    Map<String, _i4.StreamSubscription<_i2.QuerySnapshot<Map<String, dynamic>>>>
    sprintAssignmentListeners,
  })
  createListener<T, S>({
    required String? collectionName,
    required String? personDocId,
    required dynamic Function(Iterable<T>)? addCallback,
    dynamic Function(Iterable<T>)? modifyCallback,
    dynamic Function(Iterable<T>)? deleteCallback,
    required _i10.Serializer<T>? serializer,
    int? limit,
    DateTime? completionFilter,
    String? subCollectionName,
    dynamic Function(Iterable<S>)? subAddCallback,
    _i10.Serializer<S>? subSerializer,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#createListener, [], {
              #collectionName: collectionName,
              #personDocId: personDocId,
              #addCallback: addCallback,
              #modifyCallback: modifyCallback,
              #deleteCallback: deleteCallback,
              #serializer: serializer,
              #limit: limit,
              #completionFilter: completionFilter,
              #subCollectionName: subCollectionName,
              #subAddCallback: subAddCallback,
              #subSerializer: subSerializer,
            }),
            returnValue: (
              mainListener:
                  _FakeStreamSubscription_2<
                    _i2.QuerySnapshot<Map<String, dynamic>>
                  >(
                    this,
                    Invocation.method(#createListener, [], {
                      #collectionName: collectionName,
                      #personDocId: personDocId,
                      #addCallback: addCallback,
                      #modifyCallback: modifyCallback,
                      #deleteCallback: deleteCallback,
                      #serializer: serializer,
                      #limit: limit,
                      #completionFilter: completionFilter,
                      #subCollectionName: subCollectionName,
                      #subAddCallback: subAddCallback,
                      #subSerializer: subSerializer,
                    }),
                  ),
              sprintAssignmentListeners:
                  <
                    String,
                    _i4.StreamSubscription<
                      _i2.QuerySnapshot<Map<String, dynamic>>
                    >
                  >{},
            ),
            returnValueForMissingStub: (
              mainListener:
                  _FakeStreamSubscription_2<
                    _i2.QuerySnapshot<Map<String, dynamic>>
                  >(
                    this,
                    Invocation.method(#createListener, [], {
                      #collectionName: collectionName,
                      #personDocId: personDocId,
                      #addCallback: addCallback,
                      #modifyCallback: modifyCallback,
                      #deleteCallback: deleteCallback,
                      #serializer: serializer,
                      #limit: limit,
                      #completionFilter: completionFilter,
                      #subCollectionName: subCollectionName,
                      #subAddCallback: subAddCallback,
                      #subSerializer: subSerializer,
                    }),
                  ),
              sprintAssignmentListeners:
                  <
                    String,
                    _i4.StreamSubscription<
                      _i2.QuerySnapshot<Map<String, dynamic>>
                    >
                  >{},
            ),
          )
          as ({
            _i4.StreamSubscription<_i2.QuerySnapshot<Map<String, dynamic>>>
            mainListener,
            Map<
              String,
              _i4.StreamSubscription<_i2.QuerySnapshot<Map<String, dynamic>>>
            >
            sprintAssignmentListeners,
          }));

  @override
  void addTask(_i11.TaskItemBlueprint? blueprint) => super.noSuchMethod(
    Invocation.method(#addTask, [blueprint]),
    returnValueForMissingStub: null,
  );

  @override
  _i5.TaskItem addRecurTask(_i12.TaskItemRecurPreview? blueprint) =>
      (super.noSuchMethod(
            Invocation.method(#addRecurTask, [blueprint]),
            returnValue: _FakeTaskItem_3(
              this,
              Invocation.method(#addRecurTask, [blueprint]),
            ),
            returnValueForMissingStub: _FakeTaskItem_3(
              this,
              Invocation.method(#addRecurTask, [blueprint]),
            ),
          )
          as _i5.TaskItem);

  @override
  _i4.Future<({_i8.TaskRecurrence? recurrence, _i5.TaskItem taskItem})>
  updateTaskAndRecurrence(
    String? taskItemDocId,
    _i11.TaskItemBlueprint? blueprint,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateTaskAndRecurrence, [
              taskItemDocId,
              blueprint,
            ]),
            returnValue:
                _i4.Future<
                  ({_i8.TaskRecurrence? recurrence, _i5.TaskItem taskItem})
                >.value((
                  recurrence: null,
                  taskItem: _FakeTaskItem_3(
                    this,
                    Invocation.method(#updateTaskAndRecurrence, [
                      taskItemDocId,
                      blueprint,
                    ]),
                  ),
                )),
            returnValueForMissingStub:
                _i4.Future<
                  ({_i8.TaskRecurrence? recurrence, _i5.TaskItem taskItem})
                >.value((
                  recurrence: null,
                  taskItem: _FakeTaskItem_3(
                    this,
                    Invocation.method(#updateTaskAndRecurrence, [
                      taskItemDocId,
                      blueprint,
                    ]),
                  ),
                )),
          )
          as _i4.Future<
            ({_i8.TaskRecurrence? recurrence, _i5.TaskItem taskItem})
          >);

  @override
  _i4.Future<_i8.TaskRecurrence?> updateRecurrence(
    _i2.DocumentReference<Map<String, dynamic>>? recurrenceDoc,
    Map<String, dynamic>? recurrenceJson,
    String? recurrenceDocId,
    _i8.TaskRecurrence? updatedRecurrence,
    Map<String, dynamic>? blueprintJson,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateRecurrence, [
              recurrenceDoc,
              recurrenceJson,
              recurrenceDocId,
              updatedRecurrence,
              blueprintJson,
            ]),
            returnValue: _i4.Future<_i8.TaskRecurrence?>.value(),
            returnValueForMissingStub: _i4.Future<_i8.TaskRecurrence?>.value(),
          )
          as _i4.Future<_i8.TaskRecurrence?>);

  @override
  _i4.Future<
    ({
      _i6.BuiltList<_i5.TaskItem> addedTasks,
      _i7.Sprint sprint,
      _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
    })
  >
  addSprintWithTaskItems(
    _i14.SprintBlueprint? blueprint,
    _i6.BuiltList<_i5.TaskItem>? existingItems,
    _i6.BuiltList<_i12.TaskItemRecurPreview>? newItems,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#addSprintWithTaskItems, [
              blueprint,
              existingItems,
              newItems,
            ]),
            returnValue:
                _i4.Future<
                  ({
                    _i6.BuiltList<_i5.TaskItem> addedTasks,
                    _i7.Sprint sprint,
                    _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
                  })
                >.value((
                  addedTasks: _FakeBuiltList_4<_i5.TaskItem>(
                    this,
                    Invocation.method(#addSprintWithTaskItems, [
                      blueprint,
                      existingItems,
                      newItems,
                    ]),
                  ),
                  sprint: _FakeSprint_5(
                    this,
                    Invocation.method(#addSprintWithTaskItems, [
                      blueprint,
                      existingItems,
                      newItems,
                    ]),
                  ),
                  sprintAssignments: _FakeBuiltList_4<_i13.SprintAssignment>(
                    this,
                    Invocation.method(#addSprintWithTaskItems, [
                      blueprint,
                      existingItems,
                      newItems,
                    ]),
                  ),
                )),
            returnValueForMissingStub:
                _i4.Future<
                  ({
                    _i6.BuiltList<_i5.TaskItem> addedTasks,
                    _i7.Sprint sprint,
                    _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
                  })
                >.value((
                  addedTasks: _FakeBuiltList_4<_i5.TaskItem>(
                    this,
                    Invocation.method(#addSprintWithTaskItems, [
                      blueprint,
                      existingItems,
                      newItems,
                    ]),
                  ),
                  sprint: _FakeSprint_5(
                    this,
                    Invocation.method(#addSprintWithTaskItems, [
                      blueprint,
                      existingItems,
                      newItems,
                    ]),
                  ),
                  sprintAssignments: _FakeBuiltList_4<_i13.SprintAssignment>(
                    this,
                    Invocation.method(#addSprintWithTaskItems, [
                      blueprint,
                      existingItems,
                      newItems,
                    ]),
                  ),
                )),
          )
          as _i4.Future<
            ({
              _i6.BuiltList<_i5.TaskItem> addedTasks,
              _i7.Sprint sprint,
              _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
            })
          >);

  @override
  _i4.Future<_i8.TaskRecurrence> updateTaskRecurrence(
    String? taskRecurrenceDocId,
    _i15.TaskRecurrenceBlueprint? blueprint,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateTaskRecurrence, [
              taskRecurrenceDocId,
              blueprint,
            ]),
            returnValue: _i4.Future<_i8.TaskRecurrence>.value(
              _FakeTaskRecurrence_6(
                this,
                Invocation.method(#updateTaskRecurrence, [
                  taskRecurrenceDocId,
                  blueprint,
                ]),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i8.TaskRecurrence>.value(
              _FakeTaskRecurrence_6(
                this,
                Invocation.method(#updateTaskRecurrence, [
                  taskRecurrenceDocId,
                  blueprint,
                ]),
              ),
            ),
          )
          as _i4.Future<_i8.TaskRecurrence>);

  @override
  _i4.Future<
    ({
      _i6.BuiltList<_i5.TaskItem> addedTasks,
      _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
    })
  >
  addTasksToSprint(
    _i6.BuiltList<_i5.TaskItem>? existingItems,
    _i6.BuiltList<_i12.TaskItemRecurPreview>? newItems,
    _i7.Sprint? sprint,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#addTasksToSprint, [
              existingItems,
              newItems,
              sprint,
            ]),
            returnValue:
                _i4.Future<
                  ({
                    _i6.BuiltList<_i5.TaskItem> addedTasks,
                    _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
                  })
                >.value((
                  addedTasks: _FakeBuiltList_4<_i5.TaskItem>(
                    this,
                    Invocation.method(#addTasksToSprint, [
                      existingItems,
                      newItems,
                      sprint,
                    ]),
                  ),
                  sprintAssignments: _FakeBuiltList_4<_i13.SprintAssignment>(
                    this,
                    Invocation.method(#addTasksToSprint, [
                      existingItems,
                      newItems,
                      sprint,
                    ]),
                  ),
                )),
            returnValueForMissingStub:
                _i4.Future<
                  ({
                    _i6.BuiltList<_i5.TaskItem> addedTasks,
                    _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
                  })
                >.value((
                  addedTasks: _FakeBuiltList_4<_i5.TaskItem>(
                    this,
                    Invocation.method(#addTasksToSprint, [
                      existingItems,
                      newItems,
                      sprint,
                    ]),
                  ),
                  sprintAssignments: _FakeBuiltList_4<_i13.SprintAssignment>(
                    this,
                    Invocation.method(#addTasksToSprint, [
                      existingItems,
                      newItems,
                      sprint,
                    ]),
                  ),
                )),
          )
          as _i4.Future<
            ({
              _i6.BuiltList<_i5.TaskItem> addedTasks,
              _i6.BuiltList<_i13.SprintAssignment> sprintAssignments,
            })
          >);

  @override
  void deleteTask(_i5.TaskItem? taskItem) => super.noSuchMethod(
    Invocation.method(#deleteTask, [taskItem]),
    returnValueForMissingStub: null,
  );

  @override
  void addSnooze(_i16.SnoozeBlueprint? snooze) => super.noSuchMethod(
    Invocation.method(#addSnooze, [snooze]),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Future<void> dataFixAll() =>
      (super.noSuchMethod(
            Invocation.method(#dataFixAll, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> dataFixCollection({
    required String? collectionName,
    String? subCollectionName,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#dataFixCollection, [], {
              #collectionName: collectionName,
              #subCollectionName: subCollectionName,
            }),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
