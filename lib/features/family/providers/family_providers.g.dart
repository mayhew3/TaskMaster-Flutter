// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repository wired with Firestore + the local Drift database.

@ProviderFor(familyRepository)
final familyRepositoryProvider = FamilyRepositoryProvider._();

/// Repository wired with Firestore + the local Drift database.

final class FamilyRepositoryProvider
    extends
        $FunctionalProvider<
          FamilyRepository,
          FamilyRepository,
          FamilyRepository
        >
    with $Provider<FamilyRepository> {
  /// Repository wired with Firestore + the local Drift database.
  FamilyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyRepositoryHash();

  @$internal
  @override
  $ProviderElement<FamilyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyRepository create(Ref ref) {
    return familyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyRepository>(value),
    );
  }
}

String _$familyRepositoryHash() => r'6daf913eb5da4122cc4af65596a448955fa1589d';

/// Stream of the current user's Person doc from Drift. Emits null until the
/// SyncService delivers the first persons-self snapshot.

@ProviderFor(currentPerson)
final currentPersonProvider = CurrentPersonProvider._();

/// Stream of the current user's Person doc from Drift. Emits null until the
/// SyncService delivers the first persons-self snapshot.

final class CurrentPersonProvider
    extends $FunctionalProvider<AsyncValue<Person?>, Person?, Stream<Person?>>
    with $FutureModifier<Person?>, $StreamProvider<Person?> {
  /// Stream of the current user's Person doc from Drift. Emits null until the
  /// SyncService delivers the first persons-self snapshot.
  CurrentPersonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPersonProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPersonHash();

  @$internal
  @override
  $StreamProviderElement<Person?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Person?> create(Ref ref) {
    return currentPerson(ref);
  }
}

String _$currentPersonHash() => r'5ec950160183a2836ad9182a88ef9a43b60f3689';

/// `familyDocId` of the current user (null if solo).

@ProviderFor(currentFamilyDocId)
final currentFamilyDocIdProvider = CurrentFamilyDocIdProvider._();

/// `familyDocId` of the current user (null if solo).

final class CurrentFamilyDocIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// `familyDocId` of the current user (null if solo).
  CurrentFamilyDocIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentFamilyDocIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentFamilyDocIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentFamilyDocId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentFamilyDocIdHash() =>
    r'105549b4825837eafced10a73e29985313cfe713';

/// Stream of the current user's Family doc from Drift, derived from
/// [currentPersonProvider].familyDocId.

@ProviderFor(currentFamily)
final currentFamilyProvider = CurrentFamilyProvider._();

/// Stream of the current user's Family doc from Drift, derived from
/// [currentPersonProvider].familyDocId.

final class CurrentFamilyProvider
    extends $FunctionalProvider<AsyncValue<Family?>, Family?, Stream<Family?>>
    with $FutureModifier<Family?>, $StreamProvider<Family?> {
  /// Stream of the current user's Family doc from Drift, derived from
  /// [currentPersonProvider].familyDocId.
  CurrentFamilyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentFamilyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentFamilyHash();

  @$internal
  @override
  $StreamProviderElement<Family?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Family?> create(Ref ref) {
    return currentFamily(ref);
  }
}

String _$currentFamilyHash() => r'7adb459ab340fdb7eb0dd96cf41db7e4599e075a';

/// Stream of all Person docs in the current user's family (member roster).
/// Empty list when solo.

@ProviderFor(familyMembers)
final familyMembersProvider = FamilyMembersProvider._();

/// Stream of all Person docs in the current user's family (member roster).
/// Empty list when solo.

final class FamilyMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Person>>,
          List<Person>,
          Stream<List<Person>>
        >
    with $FutureModifier<List<Person>>, $StreamProvider<List<Person>> {
  /// Stream of all Person docs in the current user's family (member roster).
  /// Empty list when solo.
  FamilyMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyMembersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyMembersHash();

  @$internal
  @override
  $StreamProviderElement<List<Person>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Person>> create(Ref ref) {
    return familyMembers(ref);
  }
}

String _$familyMembersHash() => r'32a650b070e400706a9c4df29bc7811eec4ee683';

/// Pending invitations addressed to the current user. Empty list when nothing
/// is outstanding. Powers the `PendingInvitationBanner`.

@ProviderFor(pendingInvitationsForMe)
final pendingInvitationsForMeProvider = PendingInvitationsForMeProvider._();

/// Pending invitations addressed to the current user. Empty list when nothing
/// is outstanding. Powers the `PendingInvitationBanner`.

final class PendingInvitationsForMeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FamilyInvitation>>,
          List<FamilyInvitation>,
          Stream<List<FamilyInvitation>>
        >
    with
        $FutureModifier<List<FamilyInvitation>>,
        $StreamProvider<List<FamilyInvitation>> {
  /// Pending invitations addressed to the current user. Empty list when nothing
  /// is outstanding. Powers the `PendingInvitationBanner`.
  PendingInvitationsForMeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingInvitationsForMeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingInvitationsForMeHash();

  @$internal
  @override
  $StreamProviderElement<List<FamilyInvitation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FamilyInvitation>> create(Ref ref) {
    return pendingInvitationsForMe(ref);
  }
}

String _$pendingInvitationsForMeHash() =>
    r'f16ed809dad195c6103e36217cfcb02054be0ae6';

/// Invitations sent by the current user (to render in FamilyManageScreen).

@ProviderFor(outgoingInvitations)
final outgoingInvitationsProvider = OutgoingInvitationsProvider._();

/// Invitations sent by the current user (to render in FamilyManageScreen).

final class OutgoingInvitationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FamilyInvitation>>,
          List<FamilyInvitation>,
          Stream<List<FamilyInvitation>>
        >
    with
        $FutureModifier<List<FamilyInvitation>>,
        $StreamProvider<List<FamilyInvitation>> {
  /// Invitations sent by the current user (to render in FamilyManageScreen).
  OutgoingInvitationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outgoingInvitationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outgoingInvitationsHash();

  @$internal
  @override
  $StreamProviderElement<List<FamilyInvitation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FamilyInvitation>> create(Ref ref) {
    return outgoingInvitations(ref);
  }
}

String _$outgoingInvitationsHash() =>
    r'e8acc5d88b1018286d0b0cf5025a998e63f9c568';

/// Creates a family with the current user as sole member and owner.
/// TM-368: fire-and-forget mutation — state is just the last operation's
/// AsyncValue. Auto-dispose is correct for all six family-mutation
/// notifiers below (Create / Invite / Accept / Decline / Remove / Leave).

@ProviderFor(CreateFamily)
final createFamilyProvider = CreateFamilyProvider._();

/// Creates a family with the current user as sole member and owner.
/// TM-368: fire-and-forget mutation — state is just the last operation's
/// AsyncValue. Auto-dispose is correct for all six family-mutation
/// notifiers below (Create / Invite / Accept / Decline / Remove / Leave).
final class CreateFamilyProvider
    extends $AsyncNotifierProvider<CreateFamily, void> {
  /// Creates a family with the current user as sole member and owner.
  /// TM-368: fire-and-forget mutation — state is just the last operation's
  /// AsyncValue. Auto-dispose is correct for all six family-mutation
  /// notifiers below (Create / Invite / Accept / Decline / Remove / Leave).
  CreateFamilyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createFamilyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createFamilyHash();

  @$internal
  @override
  CreateFamily create() => CreateFamily();
}

String _$createFamilyHash() => r'38ead9459f36c08509931bd3b96543198b8617e1';

/// Creates a family with the current user as sole member and owner.
/// TM-368: fire-and-forget mutation — state is just the last operation's
/// AsyncValue. Auto-dispose is correct for all six family-mutation
/// notifiers below (Create / Invite / Accept / Decline / Remove / Leave).

abstract class _$CreateFamily extends $AsyncNotifier<void> {
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

/// Send an invitation to [email] from the current user's family.
///
/// [familyDocIdOverride] lets the caller bypass [currentFamilyDocIdProvider]
/// when they've just created a family in the same flow — the Drift mirror of
/// `persons/{me}.familyDocId` may not have caught up yet (Firestore listener
/// round-trip), so reading from the provider would return null.

@ProviderFor(InviteMember)
final inviteMemberProvider = InviteMemberProvider._();

/// Send an invitation to [email] from the current user's family.
///
/// [familyDocIdOverride] lets the caller bypass [currentFamilyDocIdProvider]
/// when they've just created a family in the same flow — the Drift mirror of
/// `persons/{me}.familyDocId` may not have caught up yet (Firestore listener
/// round-trip), so reading from the provider would return null.
final class InviteMemberProvider
    extends $AsyncNotifierProvider<InviteMember, void> {
  /// Send an invitation to [email] from the current user's family.
  ///
  /// [familyDocIdOverride] lets the caller bypass [currentFamilyDocIdProvider]
  /// when they've just created a family in the same flow — the Drift mirror of
  /// `persons/{me}.familyDocId` may not have caught up yet (Firestore listener
  /// round-trip), so reading from the provider would return null.
  InviteMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteMemberHash();

  @$internal
  @override
  InviteMember create() => InviteMember();
}

String _$inviteMemberHash() => r'239123eed8e138dea16ce4df44dbe3f22f51a4e4';

/// Send an invitation to [email] from the current user's family.
///
/// [familyDocIdOverride] lets the caller bypass [currentFamilyDocIdProvider]
/// when they've just created a family in the same flow — the Drift mirror of
/// `persons/{me}.familyDocId` may not have caught up yet (Firestore listener
/// round-trip), so reading from the provider would return null.

abstract class _$InviteMember extends $AsyncNotifier<void> {
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

@ProviderFor(AcceptInvitation)
final acceptInvitationProvider = AcceptInvitationProvider._();

final class AcceptInvitationProvider
    extends $AsyncNotifierProvider<AcceptInvitation, void> {
  AcceptInvitationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'acceptInvitationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$acceptInvitationHash();

  @$internal
  @override
  AcceptInvitation create() => AcceptInvitation();
}

String _$acceptInvitationHash() => r'c8c652d3382c8830568f0858c2fdc6a807632fad';

abstract class _$AcceptInvitation extends $AsyncNotifier<void> {
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

@ProviderFor(DeclineInvitation)
final declineInvitationProvider = DeclineInvitationProvider._();

final class DeclineInvitationProvider
    extends $AsyncNotifierProvider<DeclineInvitation, void> {
  DeclineInvitationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'declineInvitationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$declineInvitationHash();

  @$internal
  @override
  DeclineInvitation create() => DeclineInvitation();
}

String _$declineInvitationHash() => r'f93e8882d7d8235696eb3b94cd7284fc29bf3237';

abstract class _$DeclineInvitation extends $AsyncNotifier<void> {
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

@ProviderFor(RemoveMember)
final removeMemberProvider = RemoveMemberProvider._();

final class RemoveMemberProvider
    extends $AsyncNotifierProvider<RemoveMember, void> {
  RemoveMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeMemberHash();

  @$internal
  @override
  RemoveMember create() => RemoveMember();
}

String _$removeMemberHash() => r'1e2ce1e07dc2f1473360e2d8b7bafa3ee22a4b8e';

abstract class _$RemoveMember extends $AsyncNotifier<void> {
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

@ProviderFor(LeaveFamily)
final leaveFamilyProvider = LeaveFamilyProvider._();

final class LeaveFamilyProvider
    extends $AsyncNotifierProvider<LeaveFamily, void> {
  LeaveFamilyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveFamilyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveFamilyHash();

  @$internal
  @override
  LeaveFamily create() => LeaveFamily();
}

String _$leaveFamilyHash() => r'9db7c087cdebfae5e031088c96d6a9b8fc625a98';

abstract class _$LeaveFamily extends $AsyncNotifier<void> {
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
