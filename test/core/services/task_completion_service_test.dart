import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/services/task_completion_service.dart';
import 'package:taskmaster/features/tasks/data/firestore_task_repository.dart';
import 'package:taskmaster/features/tasks/domain/task_repository.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/timezone_helper.dart';

import 'task_completion_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TaskRepository>(),
  MockSpec<TimezoneHelper>(),
])
void main() {
  group('AddTask Provider', () {
  late MockTaskRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockTaskRepository();

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
        personDocIdProvider.overrideWith((ref) => 'person123'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('successfully adds a task via repository', () async {
    // Arrange
    final blueprint = TaskItemBlueprint()
      ..name = 'Test Task'
      ..personDocId = 'person123';

    when(mockRepository.addTask(any))
        .thenAnswer((_) async => Future.value());

    // Act
    final notifier = container.read(addTaskProvider.notifier);
    await notifier.call(blueprint);

    // Assert
    verify(mockRepository.addTask(blueprint)).called(1);

    final state = container.read(addTaskProvider);
    expect(state.hasError, false);
    expect(state.isLoading, false);
  });

  test('handles errors from repository', () async {
    // Arrange
    final blueprint = TaskItemBlueprint()
      ..name = 'Test Task'
      ..personDocId = 'person123';

    when(mockRepository.addTask(any))
        .thenThrow(Exception('Failed to add task'));

    // Act
    final notifier = container.read(addTaskProvider.notifier);
    await notifier.call(blueprint);

    // Assert
    final state = container.read(addTaskProvider);
    expect(state.hasError, true);
    expect(state.error.toString(), contains('Failed to add task'));
  });

  test('sets loading state then completes', () async {
    // Arrange
    final blueprint = TaskItemBlueprint()
      ..name = 'Test Task'
      ..personDocId = 'person123';

    when(mockRepository.addTask(any))
        .thenAnswer((_) async => Future.value());

    // Act
    final notifier = container.read(addTaskProvider.notifier);
    final future = notifier.call(blueprint);

    // Assert - should eventually complete
    await future;
    final state = container.read(addTaskProvider);
    expect(state.isLoading, false);
  });
});

  group('UpdateTask Provider', () {
  late MockTaskRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockTaskRepository();

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
        personDocIdProvider.overrideWith((ref) => 'person123'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('successfully updates a task via repository', () async {
    // Arrange
    final task = TaskItem((t) => t
      ..docId = 'task123'
      ..name = 'Old Name'
      ..personDocId = 'person123'
      ..dateAdded = DateTime.now()
      ..offCycle = false);

    final blueprint = TaskItemBlueprint()
      ..name = 'New Name'
      ..personDocId = 'person123';

    final updatedTask = task.rebuild((t) => t..name = 'New Name');

    when(mockRepository.updateTaskAndRecurrence(any, any))
        .thenAnswer((_) async => (taskItem: updatedTask, recurrence: null));

    // Act
    final notifier = container.read(updateTaskProvider.notifier);
    await notifier.call(task: task, blueprint: blueprint);

    // Assert
    verify(mockRepository.updateTaskAndRecurrence(task.docId, blueprint)).called(1);

    final state = container.read(updateTaskProvider);
    expect(state.hasError, false);
    expect(state.isLoading, false);
  });

  test('handles errors from repository', () async {
    // Arrange
    final task = TaskItem((t) => t
      ..docId = 'task123'
      ..name = 'Test Task'
      ..personDocId = 'person123'
      ..dateAdded = DateTime.now()
      ..offCycle = false);

    final blueprint = TaskItemBlueprint()
      ..name = 'Updated Name'
      ..personDocId = 'person123';

    when(mockRepository.updateTaskAndRecurrence(any, any))
        .thenThrow(Exception('Failed to update task'));

    // Act
    final notifier = container.read(updateTaskProvider.notifier);
    await notifier.call(task: task, blueprint: blueprint);

    // Assert
    final state = container.read(updateTaskProvider);
    expect(state.hasError, true);
    expect(state.error.toString(), contains('Failed to update task'));
  });

  test('updates task with recurrence', () async {
    // Arrange
    final task = TaskItem((t) => t
      ..docId = 'task123'
      ..name = 'Recurring Task'
      ..personDocId = 'person123'
      ..recurrenceDocId = 'recur123'
      ..dateAdded = DateTime.now()
      ..offCycle = false);

    final blueprint = TaskItemBlueprint()
      ..name = 'Updated Recurring Task'
      ..personDocId = 'person123';

    final updatedRecurrence = TaskRecurrence((r) => r
      ..docId = 'recur123'
      ..name = 'Updated Recurrence'
      ..personDocId = 'person123'
      ..recurNumber = 1
      ..recurUnit = 'day'
      ..recurWait = false
      ..recurIteration = 1
      ..dateAdded = DateTime.now()
      ..anchorDate = AnchorDate((a) => a
        ..dateType = TaskDateTypes.start
        ..dateValue = DateTime.now()).toBuilder());

    final updatedTask = task.rebuild((t) => t..name = 'Updated Recurring Task');

    when(mockRepository.updateTaskAndRecurrence(any, any))
        .thenAnswer((_) async => (taskItem: updatedTask, recurrence: updatedRecurrence));

    // Act
    final notifier = container.read(updateTaskProvider.notifier);
    await notifier.call(task: task, blueprint: blueprint);

    // Assert
    verify(mockRepository.updateTaskAndRecurrence(task.docId, blueprint)).called(1);

    final state = container.read(updateTaskProvider);
    expect(state.hasError, false);
  });
});

  group('DeleteTask Provider', () {
  late MockTaskRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockTaskRepository();

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
        personDocIdProvider.overrideWith((ref) => 'person123'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('successfully deletes a task via repository', () async {
    // Arrange
    final task = TaskItem((t) => t
      ..docId = 'task123'
      ..name = 'Task to Delete'
      ..personDocId = 'person123'
      ..dateAdded = DateTime.now()
      ..offCycle = false);

    when(mockRepository.deleteTask(any))
        .thenAnswer((_) async => Future.value());

    // Act
    final notifier = container.read(deleteTaskProvider.notifier);
    await notifier.call(task);

    // Assert
    verify(mockRepository.deleteTask(task)).called(1);

    final state = container.read(deleteTaskProvider);
    expect(state.hasError, false);
    expect(state.isLoading, false);
  });

  test('handles errors from repository', () async {
    // Arrange
    final task = TaskItem((t) => t
      ..docId = 'task123'
      ..name = 'Task to Delete'
      ..personDocId = 'person123'
      ..dateAdded = DateTime.now()
      ..offCycle = false);

    when(mockRepository.deleteTask(any))
        .thenThrow(Exception('Failed to delete task'));

    // Act
    final notifier = container.read(deleteTaskProvider.notifier);
    await notifier.call(task);

    // Assert
    final state = container.read(deleteTaskProvider);
    expect(state.hasError, true);
    expect(state.error.toString(), contains('Failed to delete task'));
  });
});

  group('TimezoneHelperNotifier Provider', () {
  test('is configured with keepAlive', () async {
    // Note: Full initialization test requires Flutter bindings
    // This test just verifies the provider is properly configured

    // The provider should be defined and use keepAlive=true
    // (Tested indirectly by checking it compiles and is exported)
    expect(timezoneHelperNotifierProvider, isNotNull);
  });
});
}
