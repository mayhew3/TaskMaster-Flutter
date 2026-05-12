// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskCompletionService)
final taskCompletionServiceProvider = TaskCompletionServiceProvider._();

final class TaskCompletionServiceProvider
    extends
        $FunctionalProvider<
          TaskCompletionService,
          TaskCompletionService,
          TaskCompletionService
        >
    with $Provider<TaskCompletionService> {
  TaskCompletionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskCompletionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskCompletionServiceHash();

  @$internal
  @override
  $ProviderElement<TaskCompletionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaskCompletionService create(Ref ref) {
    return taskCompletionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskCompletionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskCompletionService>(value),
    );
  }
}

String _$taskCompletionServiceHash() =>
    r'd8165489e9937c88a1919383230bd3dab18567e4';

/// Controller for completing tasks.
/// TM-368: fire-and-forget mutation notifier — state is just the latest
/// invocation's AsyncValue<void>. Auto-dispose is correct.

@ProviderFor(CompleteTask)
final completeTaskProvider = CompleteTaskProvider._();

/// Controller for completing tasks.
/// TM-368: fire-and-forget mutation notifier — state is just the latest
/// invocation's AsyncValue<void>. Auto-dispose is correct.
final class CompleteTaskProvider
    extends $AsyncNotifierProvider<CompleteTask, void> {
  /// Controller for completing tasks.
  /// TM-368: fire-and-forget mutation notifier — state is just the latest
  /// invocation's AsyncValue<void>. Auto-dispose is correct.
  CompleteTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeTaskHash();

  @$internal
  @override
  CompleteTask create() => CompleteTask();
}

String _$completeTaskHash() => r'cce9e58cfdc8c8c417707ab2b7a9c4ffd81c44df';

/// Controller for completing tasks.
/// TM-368: fire-and-forget mutation notifier — state is just the latest
/// invocation's AsyncValue<void>. Auto-dispose is correct.

abstract class _$CompleteTask extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for skipping a recurring task instance
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

@ProviderFor(SkipTask)
final skipTaskProvider = SkipTaskProvider._();

/// Controller for skipping a recurring task instance
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
final class SkipTaskProvider extends $AsyncNotifierProvider<SkipTask, void> {
  /// Controller for skipping a recurring task instance
  /// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
  SkipTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skipTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skipTaskHash();

  @$internal
  @override
  SkipTask create() => SkipTask();
}

String _$skipTaskHash() => r'0aaa83e64b81003c518422c56b3142bdb4688b86';

/// Controller for skipping a recurring task instance
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

abstract class _$SkipTask extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

@ProviderFor(DeleteTask)
final deleteTaskProvider = DeleteTaskProvider._();

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
final class DeleteTaskProvider
    extends $AsyncNotifierProvider<DeleteTask, void> {
  /// Controller for deleting tasks.
  ///
  /// Notifier `state` is intentionally NOT mutated from `call`. With a sync
  /// `FutureOr<void> build()` the AsyncNotifier's internal future completer
  /// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
  /// re-completes it and throws "Bad state: Future already completed". UI
  /// loading state is handled locally by callers (e.g. `_busy` flags).
  /// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
  DeleteTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteTaskHash();

  @$internal
  @override
  DeleteTask create() => DeleteTask();
}

String _$deleteTaskHash() => r'75b5d13720fc5386dfd53999721eda028959ab36';

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

abstract class _$DeleteTask extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for adding new tasks.
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

@ProviderFor(AddTask)
final addTaskProvider = AddTaskProvider._();

/// Controller for adding new tasks.
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
final class AddTaskProvider extends $AsyncNotifierProvider<AddTask, void> {
  /// Controller for adding new tasks.
  /// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
  AddTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTaskHash();

  @$internal
  @override
  AddTask create() => AddTask();
}

String _$addTaskHash() => r'0f96b22cf04235abe274be4d8869d6fca3010a9a';

/// Controller for adding new tasks.
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

abstract class _$AddTask extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for updating tasks.
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

@ProviderFor(UpdateTask)
final updateTaskProvider = UpdateTaskProvider._();

/// Controller for updating tasks.
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
final class UpdateTaskProvider
    extends $AsyncNotifierProvider<UpdateTask, void> {
  /// Controller for updating tasks.
  /// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
  UpdateTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTaskHash();

  @$internal
  @override
  UpdateTask create() => UpdateTask();
}

String _$updateTaskHash() => r'8bb8c502dd05d7a2830670163db55a44686aed94';

/// Controller for updating tasks.
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

abstract class _$UpdateTask extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for snoozing tasks
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

@ProviderFor(SnoozeTask)
final snoozeTaskProvider = SnoozeTaskProvider._();

/// Controller for snoozing tasks
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
final class SnoozeTaskProvider
    extends $AsyncNotifierProvider<SnoozeTask, void> {
  /// Controller for snoozing tasks
  /// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.
  SnoozeTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snoozeTaskProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snoozeTaskHash();

  @$internal
  @override
  SnoozeTask create() => SnoozeTask();
}

String _$snoozeTaskHash() => r'7fc6c953aa372c8d82d62fdc567d699324f57a09';

/// Controller for snoozing tasks
/// TM-368: fire-and-forget mutation notifier — see `CompleteTask`.

abstract class _$SnoozeTask extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for legacy TaskRepository (for snooze functionality)

@ProviderFor(legacyTaskRepository)
final legacyTaskRepositoryProvider = LegacyTaskRepositoryProvider._();

/// Provider for legacy TaskRepository (for snooze functionality)

final class LegacyTaskRepositoryProvider
    extends
        $FunctionalProvider<
          legacy.TaskRepository,
          legacy.TaskRepository,
          legacy.TaskRepository
        >
    with $Provider<legacy.TaskRepository> {
  /// Provider for legacy TaskRepository (for snooze functionality)
  LegacyTaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legacyTaskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legacyTaskRepositoryHash();

  @$internal
  @override
  $ProviderElement<legacy.TaskRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  legacy.TaskRepository create(Ref ref) {
    return legacyTaskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(legacy.TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<legacy.TaskRepository>(value),
    );
  }
}

String _$legacyTaskRepositoryHash() =>
    r'736796d2f328e43cc027ff968fc453ada26d05d4';

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first

@ProviderFor(TimezoneHelperNotifier)
final timezoneHelperProvider = TimezoneHelperNotifierProvider._();

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first
final class TimezoneHelperNotifierProvider
    extends $AsyncNotifierProvider<TimezoneHelperNotifier, TimezoneHelper> {
  /// Provider for TimezoneHelper
  /// Must be initialized before use - call configureLocalTimeZone() first
  TimezoneHelperNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timezoneHelperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timezoneHelperNotifierHash();

  @$internal
  @override
  TimezoneHelperNotifier create() => TimezoneHelperNotifier();
}

String _$timezoneHelperNotifierHash() =>
    r'38eced5cb9614d50d30a7b1c818fbc59981d6b30';

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first

abstract class _$TimezoneHelperNotifier extends $AsyncNotifier<TimezoneHelper> {
  FutureOr<TimezoneHelper> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TimezoneHelper>, TimezoneHelper>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TimezoneHelper>, TimezoneHelper>,
              AsyncValue<TimezoneHelper>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
