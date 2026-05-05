// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expanded_task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expandedTaskHash() => r'8261a7359bdbcf66a20022334c26ad4432341cc1';

/// Tracks which task card (if any) is currently expanded inline.
///
/// Accordion semantics: at most one card is expanded at a time across all
/// task lists. State is session-scoped (no `keepAlive`); switching tabs
/// collapses any open card.
///
/// Copied from [ExpandedTask].
@ProviderFor(ExpandedTask)
final expandedTaskProvider =
    AutoDisposeNotifierProvider<ExpandedTask, String?>.internal(
      ExpandedTask.new,
      name: r'expandedTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expandedTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpandedTask = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
