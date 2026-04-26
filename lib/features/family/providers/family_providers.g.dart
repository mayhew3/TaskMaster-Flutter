// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyRepositoryHash() => r'6daf913eb5da4122cc4af65596a448955fa1589d';

/// Repository wired with Firestore + the local Drift database.
///
/// Copied from [familyRepository].
@ProviderFor(familyRepository)
final familyRepositoryProvider = Provider<FamilyRepository>.internal(
  familyRepository,
  name: r'familyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyRepositoryRef = ProviderRef<FamilyRepository>;
String _$currentPersonHash() => r'f1905b057bcb7d7d95a775aafda7209f56b482e3';

/// Stream of the current user's Person doc from Drift. Emits null until the
/// SyncService delivers the first persons-self snapshot.
///
/// Copied from [currentPerson].
@ProviderFor(currentPerson)
final currentPersonProvider = AutoDisposeStreamProvider<Person?>.internal(
  currentPerson,
  name: r'currentPersonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPersonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPersonRef = AutoDisposeStreamProviderRef<Person?>;
String _$currentFamilyDocIdHash() =>
    r'c552dda8463d908dce3bbb7ec27a5b5798955114';

/// `familyDocId` of the current user (null if solo).
///
/// Copied from [currentFamilyDocId].
@ProviderFor(currentFamilyDocId)
final currentFamilyDocIdProvider = AutoDisposeProvider<String?>.internal(
  currentFamilyDocId,
  name: r'currentFamilyDocIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentFamilyDocIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentFamilyDocIdRef = AutoDisposeProviderRef<String?>;
String _$currentFamilyHash() => r'bc77d44550ab8e840459e5e82b4a2250f12bd967';

/// Stream of the current user's Family doc from Drift, derived from
/// [currentPersonProvider].familyDocId.
///
/// Copied from [currentFamily].
@ProviderFor(currentFamily)
final currentFamilyProvider = AutoDisposeStreamProvider<Family?>.internal(
  currentFamily,
  name: r'currentFamilyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentFamilyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentFamilyRef = AutoDisposeStreamProviderRef<Family?>;
String _$familyMembersHash() => r'14806b2d8b0c7035fc1e57b8998b78d9322b6796';

/// Stream of all Person docs in the current user's family (member roster).
/// Empty list when solo.
///
/// Copied from [familyMembers].
@ProviderFor(familyMembers)
final familyMembersProvider = AutoDisposeStreamProvider<List<Person>>.internal(
  familyMembers,
  name: r'familyMembersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyMembersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyMembersRef = AutoDisposeStreamProviderRef<List<Person>>;
String _$pendingInvitationsForMeHash() =>
    r'e4ff5ebfaa59eecd0025c41ea3fb60d8ac2c0aff';

/// Pending invitations addressed to the current user. Empty list when nothing
/// is outstanding. Powers the `PendingInvitationBanner`.
///
/// Copied from [pendingInvitationsForMe].
@ProviderFor(pendingInvitationsForMe)
final pendingInvitationsForMeProvider =
    AutoDisposeStreamProvider<List<FamilyInvitation>>.internal(
      pendingInvitationsForMe,
      name: r'pendingInvitationsForMeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingInvitationsForMeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingInvitationsForMeRef =
    AutoDisposeStreamProviderRef<List<FamilyInvitation>>;
String _$outgoingInvitationsHash() =>
    r'e3347ddd33a44587c6d2b6d21a9c17354e711c10';

/// Invitations sent by the current user (to render in FamilyManageScreen).
///
/// Copied from [outgoingInvitations].
@ProviderFor(outgoingInvitations)
final outgoingInvitationsProvider =
    AutoDisposeStreamProvider<List<FamilyInvitation>>.internal(
      outgoingInvitations,
      name: r'outgoingInvitationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$outgoingInvitationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OutgoingInvitationsRef =
    AutoDisposeStreamProviderRef<List<FamilyInvitation>>;
String _$createFamilyHash() => r'38ead9459f36c08509931bd3b96543198b8617e1';

/// Creates a family with the current user as sole member and owner.
///
/// Copied from [CreateFamily].
@ProviderFor(CreateFamily)
final createFamilyProvider =
    AutoDisposeAsyncNotifierProvider<CreateFamily, void>.internal(
      CreateFamily.new,
      name: r'createFamilyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createFamilyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateFamily = AutoDisposeAsyncNotifier<void>;
String _$inviteMemberHash() => r'239123eed8e138dea16ce4df44dbe3f22f51a4e4';

/// Send an invitation to [email] from the current user's family.
///
/// [familyDocIdOverride] lets the caller bypass [currentFamilyDocIdProvider]
/// when they've just created a family in the same flow — the Drift mirror of
/// `persons/{me}.familyDocId` may not have caught up yet (Firestore listener
/// round-trip), so reading from the provider would return null.
///
/// Copied from [InviteMember].
@ProviderFor(InviteMember)
final inviteMemberProvider =
    AutoDisposeAsyncNotifierProvider<InviteMember, void>.internal(
      InviteMember.new,
      name: r'inviteMemberProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inviteMemberHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InviteMember = AutoDisposeAsyncNotifier<void>;
String _$acceptInvitationHash() => r'c8c652d3382c8830568f0858c2fdc6a807632fad';

/// See also [AcceptInvitation].
@ProviderFor(AcceptInvitation)
final acceptInvitationProvider =
    AutoDisposeAsyncNotifierProvider<AcceptInvitation, void>.internal(
      AcceptInvitation.new,
      name: r'acceptInvitationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$acceptInvitationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AcceptInvitation = AutoDisposeAsyncNotifier<void>;
String _$declineInvitationHash() => r'f93e8882d7d8235696eb3b94cd7284fc29bf3237';

/// See also [DeclineInvitation].
@ProviderFor(DeclineInvitation)
final declineInvitationProvider =
    AutoDisposeAsyncNotifierProvider<DeclineInvitation, void>.internal(
      DeclineInvitation.new,
      name: r'declineInvitationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$declineInvitationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeclineInvitation = AutoDisposeAsyncNotifier<void>;
String _$removeMemberHash() => r'1e2ce1e07dc2f1473360e2d8b7bafa3ee22a4b8e';

/// See also [RemoveMember].
@ProviderFor(RemoveMember)
final removeMemberProvider =
    AutoDisposeAsyncNotifierProvider<RemoveMember, void>.internal(
      RemoveMember.new,
      name: r'removeMemberProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$removeMemberHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RemoveMember = AutoDisposeAsyncNotifier<void>;
String _$leaveFamilyHash() => r'9db7c087cdebfae5e031088c96d6a9b8fc625a98';

/// See also [LeaveFamily].
@ProviderFor(LeaveFamily)
final leaveFamilyProvider =
    AutoDisposeAsyncNotifierProvider<LeaveFamily, void>.internal(
      LeaveFamily.new,
      name: r'leaveFamilyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leaveFamilyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeaveFamily = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
