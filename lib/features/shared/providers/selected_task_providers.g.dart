// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Currently-selected task on the wide layout, by `docId`. `null` means
/// no row is selected. (TM-383 Story 2 of Epic TM-188.)
///
/// On the wide adaptive shell, tapping a task row in the center list
/// pane unconditionally sets/toggles this provider, AND — only when the
/// row `hasExpandableContent(...)` (per `EditableTaskItemWidget`'s tap
/// gate) — ALSO toggles `expandedTaskProvider`. So a wide tap on a
/// no-dates / no-notes row still selects the row (right pane stays in
/// sync) but does not flip the accordion (nothing to expand). On the
/// compact / phone path this provider is never written — taps only flip
/// the accordion (still gated by `canExpand`), same as before TM-383.
///
/// Reset on destination switch via `ActiveTabIndex.setTab` (the same
/// microtask block that clears `searchQueryProvider` /
/// `recentlyCompletedTasksProvider`), so navigating away never leaves a
/// stale selection ringing on a tab the user can no longer see. The
/// magenta selection ring (`SelectableTaskItem`) reads this provider via
/// `select` to limit rebuilds to the single row whose membership flipped.
///
/// `keepAlive` matches the other UI-state notifiers in this directory
/// (`ActiveTabIndex`, `ExpandedTask`) so reattaching consumers after a
/// rebuild see the same selection without a default-state flash.

@ProviderFor(SelectedTask)
final selectedTaskProvider = SelectedTaskProvider._();

/// Currently-selected task on the wide layout, by `docId`. `null` means
/// no row is selected. (TM-383 Story 2 of Epic TM-188.)
///
/// On the wide adaptive shell, tapping a task row in the center list
/// pane unconditionally sets/toggles this provider, AND — only when the
/// row `hasExpandableContent(...)` (per `EditableTaskItemWidget`'s tap
/// gate) — ALSO toggles `expandedTaskProvider`. So a wide tap on a
/// no-dates / no-notes row still selects the row (right pane stays in
/// sync) but does not flip the accordion (nothing to expand). On the
/// compact / phone path this provider is never written — taps only flip
/// the accordion (still gated by `canExpand`), same as before TM-383.
///
/// Reset on destination switch via `ActiveTabIndex.setTab` (the same
/// microtask block that clears `searchQueryProvider` /
/// `recentlyCompletedTasksProvider`), so navigating away never leaves a
/// stale selection ringing on a tab the user can no longer see. The
/// magenta selection ring (`SelectableTaskItem`) reads this provider via
/// `select` to limit rebuilds to the single row whose membership flipped.
///
/// `keepAlive` matches the other UI-state notifiers in this directory
/// (`ActiveTabIndex`, `ExpandedTask`) so reattaching consumers after a
/// rebuild see the same selection without a default-state flash.
final class SelectedTaskProvider
    extends $NotifierProvider<SelectedTask, String?> {
  /// Currently-selected task on the wide layout, by `docId`. `null` means
  /// no row is selected. (TM-383 Story 2 of Epic TM-188.)
  ///
  /// On the wide adaptive shell, tapping a task row in the center list
  /// pane unconditionally sets/toggles this provider, AND — only when the
  /// row `hasExpandableContent(...)` (per `EditableTaskItemWidget`'s tap
  /// gate) — ALSO toggles `expandedTaskProvider`. So a wide tap on a
  /// no-dates / no-notes row still selects the row (right pane stays in
  /// sync) but does not flip the accordion (nothing to expand). On the
  /// compact / phone path this provider is never written — taps only flip
  /// the accordion (still gated by `canExpand`), same as before TM-383.
  ///
  /// Reset on destination switch via `ActiveTabIndex.setTab` (the same
  /// microtask block that clears `searchQueryProvider` /
  /// `recentlyCompletedTasksProvider`), so navigating away never leaves a
  /// stale selection ringing on a tab the user can no longer see. The
  /// magenta selection ring (`SelectableTaskItem`) reads this provider via
  /// `select` to limit rebuilds to the single row whose membership flipped.
  ///
  /// `keepAlive` matches the other UI-state notifiers in this directory
  /// (`ActiveTabIndex`, `ExpandedTask`) so reattaching consumers after a
  /// rebuild see the same selection without a default-state flash.
  SelectedTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTaskHash();

  @$internal
  @override
  SelectedTask create() => SelectedTask();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedTaskHash() => r'1a8dad98bd223d1a52bc5d8f1f8fbe9af7bf0fd3';

/// Currently-selected task on the wide layout, by `docId`. `null` means
/// no row is selected. (TM-383 Story 2 of Epic TM-188.)
///
/// On the wide adaptive shell, tapping a task row in the center list
/// pane unconditionally sets/toggles this provider, AND — only when the
/// row `hasExpandableContent(...)` (per `EditableTaskItemWidget`'s tap
/// gate) — ALSO toggles `expandedTaskProvider`. So a wide tap on a
/// no-dates / no-notes row still selects the row (right pane stays in
/// sync) but does not flip the accordion (nothing to expand). On the
/// compact / phone path this provider is never written — taps only flip
/// the accordion (still gated by `canExpand`), same as before TM-383.
///
/// Reset on destination switch via `ActiveTabIndex.setTab` (the same
/// microtask block that clears `searchQueryProvider` /
/// `recentlyCompletedTasksProvider`), so navigating away never leaves a
/// stale selection ringing on a tab the user can no longer see. The
/// magenta selection ring (`SelectableTaskItem`) reads this provider via
/// `select` to limit rebuilds to the single row whose membership flipped.
///
/// `keepAlive` matches the other UI-state notifiers in this directory
/// (`ActiveTabIndex`, `ExpandedTask`) so reattaching consumers after a
/// rebuild see the same selection without a default-state flash.

abstract class _$SelectedTask extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Current right-pane mode for the wide adaptive shell (TM-383).
///
/// Reset to [RightPaneMode.empty] on destination switch alongside
/// [SelectedTask] so a stale `.editor` from another destination never
/// outlives the tab swap. `keepAlive` for the same reason as
/// `SelectedTask`.

@ProviderFor(RightPane)
final rightPaneProvider = RightPaneProvider._();

/// Current right-pane mode for the wide adaptive shell (TM-383).
///
/// Reset to [RightPaneMode.empty] on destination switch alongside
/// [SelectedTask] so a stale `.editor` from another destination never
/// outlives the tab swap. `keepAlive` for the same reason as
/// `SelectedTask`.
final class RightPaneProvider
    extends $NotifierProvider<RightPane, RightPaneMode> {
  /// Current right-pane mode for the wide adaptive shell (TM-383).
  ///
  /// Reset to [RightPaneMode.empty] on destination switch alongside
  /// [SelectedTask] so a stale `.editor` from another destination never
  /// outlives the tab swap. `keepAlive` for the same reason as
  /// `SelectedTask`.
  RightPaneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rightPaneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rightPaneHash();

  @$internal
  @override
  RightPane create() => RightPane();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RightPaneMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RightPaneMode>(value),
    );
  }
}

String _$rightPaneHash() => r'336dc311a391690e35e92707f6e5ee096e46b79e';

/// Current right-pane mode for the wide adaptive shell (TM-383).
///
/// Reset to [RightPaneMode.empty] on destination switch alongside
/// [SelectedTask] so a stale `.editor` from another destination never
/// outlives the tab swap. `keepAlive` for the same reason as
/// `SelectedTask`.

abstract class _$RightPane extends $Notifier<RightPaneMode> {
  RightPaneMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RightPaneMode, RightPaneMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RightPaneMode, RightPaneMode>,
              RightPaneMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
