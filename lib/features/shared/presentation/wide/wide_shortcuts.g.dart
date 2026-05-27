// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wide_shortcuts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared FocusNode owned by the wide shell so the keyboard `/`
/// shortcut can call `requestFocus()` on the sidebar search field.
/// The sidebar widget reads this provider and passes the same node
/// to its `TextField.focusNode`.

@ProviderFor(sidebarSearchFocusNode)
final sidebarSearchFocusNodeProvider = SidebarSearchFocusNodeProvider._();

/// Shared FocusNode owned by the wide shell so the keyboard `/`
/// shortcut can call `requestFocus()` on the sidebar search field.
/// The sidebar widget reads this provider and passes the same node
/// to its `TextField.focusNode`.

final class SidebarSearchFocusNodeProvider
    extends $FunctionalProvider<FocusNode, FocusNode, FocusNode>
    with $Provider<FocusNode> {
  /// Shared FocusNode owned by the wide shell so the keyboard `/`
  /// shortcut can call `requestFocus()` on the sidebar search field.
  /// The sidebar widget reads this provider and passes the same node
  /// to its `TextField.focusNode`.
  SidebarSearchFocusNodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarSearchFocusNodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarSearchFocusNodeHash();

  @$internal
  @override
  $ProviderElement<FocusNode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FocusNode create(Ref ref) {
    return sidebarSearchFocusNode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusNode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusNode>(value),
    );
  }
}

String _$sidebarSearchFocusNodeHash() =>
    r'5b8c545cc02f86ca3429852ea945b8cc0c56bcae';
