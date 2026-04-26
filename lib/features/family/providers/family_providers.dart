import 'package:flutter/foundation.dart';
// Riverpod re-exports a `Family` typedef from package:riverpod/src/framework.dart
// which collides with our `Family` model. Hide it on both Riverpod imports so
// the generated .g.dart resolves `Family` to our model.
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:riverpod_annotation/riverpod_annotation.dart' hide Family;

import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/family.dart';
import '../../../models/family_invitation.dart';
import '../../../models/person.dart';
import '../data/family_repository.dart';

part 'family_providers.g.dart';

/// Repository wired with Firestore + the local Drift database.
@Riverpod(keepAlive: true)
FamilyRepository familyRepository(Ref ref) {
  return FamilyRepository(
    firestore: ref.watch(firestoreProvider),
    db: ref.watch(databaseProvider),
  );
}

/// Stream of the current user's Person doc from Drift. Emits null until the
/// SyncService delivers the first persons-self snapshot.
@riverpod
Stream<Person?> currentPerson(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(null);
  final db = ref.watch(databaseProvider);
  return db.personDao.watchByDocId(personDocId).map((row) {
    if (row == null) return null;
    try {
      return personFromRow(row);
    } catch (e) {
      debugPrint('⚠️ [currentPersonProvider] Failed to convert row: $e');
      return null;
    }
  });
}

/// `familyDocId` of the current user (null if solo).
@riverpod
String? currentFamilyDocId(Ref ref) {
  final person = ref.watch(currentPersonProvider).valueOrNull;
  return person?.familyDocId;
}

/// Stream of the current user's Family doc from Drift, derived from
/// [currentPersonProvider].familyDocId.
@riverpod
Stream<Family?> currentFamily(Ref ref) {
  final familyDocId = ref.watch(currentFamilyDocIdProvider);
  if (familyDocId == null) return Stream.value(null);
  final db = ref.watch(databaseProvider);
  return db.familyDao.watchByDocId(familyDocId).map((row) {
    if (row == null) return null;
    try {
      return familyFromRow(row);
    } catch (e) {
      debugPrint('⚠️ [currentFamilyProvider] Failed to convert row: $e');
      return null;
    }
  });
}

/// Stream of all Person docs in the current user's family (member roster).
/// Empty list when solo.
@riverpod
Stream<List<Person>> familyMembers(Ref ref) {
  final familyDocId = ref.watch(currentFamilyDocIdProvider);
  if (familyDocId == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.personDao.watchByFamily(familyDocId).map((rows) {
    final members = <Person>[];
    for (final row in rows) {
      try {
        members.add(personFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [familyMembersProvider] Failed to convert row: $e');
      }
    }
    return members;
  });
}

/// Pending invitations addressed to the current user. Empty list when nothing
/// is outstanding. Powers the `PendingInvitationBanner`.
@riverpod
Stream<List<FamilyInvitation>> pendingInvitationsForMe(Ref ref) {
  final email = ref.watch(currentUserProvider)?.email;
  if (email == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.familyInvitationDao.watchPendingForEmail(email).map((rows) {
    final list = <FamilyInvitation>[];
    for (final row in rows) {
      try {
        list.add(familyInvitationFromRow(row));
      } catch (e) {
        debugPrint(
            '⚠️ [pendingInvitationsForMeProvider] Failed to convert row: $e');
      }
    }
    return list;
  });
}

/// Invitations sent by the current user (to render in FamilyManageScreen).
@riverpod
Stream<List<FamilyInvitation>> outgoingInvitations(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.familyInvitationDao.watchSentByPerson(personDocId).map((rows) {
    final list = <FamilyInvitation>[];
    for (final row in rows) {
      try {
        list.add(familyInvitationFromRow(row));
      } catch (e) {
        debugPrint(
            '⚠️ [outgoingInvitationsProvider] Failed to convert row: $e');
      }
    }
    return list;
  });
}

// ── Mutation controllers ────────────────────────────────────────────────────
//
// These notifiers expose imperative async methods. They intentionally do NOT
// mutate `state` (the `build()` return is the only state consumers observe).
// Mutating `state` from inside `call()` while `build()` returned synchronously
// triggers "Bad state: Future already completed" because the AsyncNotifier's
// internal completer has already settled. Callers that need loading state
// should manage it locally (e.g. via a `bool _busy` field in their widget).

/// Creates a family with the current user as sole member and owner.
@riverpod
class CreateFamily extends _$CreateFamily {
  @override
  FutureOr<void> build() {}

  Future<String?> call() async {
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      throw StateError('Cannot create family: not signed in');
    }
    final familyDocId = await ref
        .read(familyRepositoryProvider)
        .createFamilyForCurrentUser(personDocId: personDocId);
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'CreateFamily')
        .ignore();
    return familyDocId;
  }
}

/// Send an invitation to [email] from the current user's family.
///
/// [familyDocIdOverride] lets the caller bypass [currentFamilyDocIdProvider]
/// when they've just created a family in the same flow — the Drift mirror of
/// `persons/{me}.familyDocId` may not have caught up yet (Firestore listener
/// round-trip), so reading from the provider would return null.
@riverpod
class InviteMember extends _$InviteMember {
  @override
  FutureOr<void> build() {}

  Future<void> call(String email, {String? familyDocIdOverride}) async {
    final personDocId = ref.read(personDocIdProvider);
    final familyDocId =
        familyDocIdOverride ?? ref.read(currentFamilyDocIdProvider);
    final displayName = ref.read(currentUserProvider)?.displayName;
    if (personDocId == null || familyDocId == null) {
      throw StateError('Cannot invite: not in a family');
    }
    await ref.read(familyRepositoryProvider).inviteByEmail(
          inviterPersonDocId: personDocId,
          inviterFamilyDocId: familyDocId,
          inviteeEmail: email.trim(),
          inviterDisplayName: displayName,
        );
  }
}

@riverpod
class AcceptInvitation extends _$AcceptInvitation {
  @override
  FutureOr<void> build() {}

  Future<void> call(String invitationDocId) async {
    final personDocId = ref.read(personDocIdProvider);
    final email = ref.read(currentUserProvider)?.email;
    if (personDocId == null || email == null) {
      throw StateError('Cannot accept invitation: not signed in');
    }
    await ref.read(familyRepositoryProvider).acceptInvitation(
          invitationDocId: invitationDocId,
          myPersonDocId: personDocId,
          myEmail: email,
        );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'AcceptInvitation')
        .ignore();
  }
}

@riverpod
class DeclineInvitation extends _$DeclineInvitation {
  @override
  FutureOr<void> build() {}

  Future<void> call(String invitationDocId) async {
    await ref
        .read(familyRepositoryProvider)
        .declineInvitation(invitationDocId);
  }
}

@riverpod
class RemoveMember extends _$RemoveMember {
  @override
  FutureOr<void> build() {}

  Future<void> call(String targetPersonDocId) async {
    final personDocId = ref.read(personDocIdProvider);
    final familyDocId = ref.read(currentFamilyDocIdProvider);
    if (personDocId == null || familyDocId == null) {
      throw StateError('Cannot remove: not in a family');
    }
    await ref.read(familyRepositoryProvider).removeMember(
          familyDocId: familyDocId,
          removerPersonDocId: personDocId,
          targetPersonDocId: targetPersonDocId,
        );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'RemoveMember')
        .ignore();
  }
}

@riverpod
class LeaveFamily extends _$LeaveFamily {
  @override
  FutureOr<void> build() {}

  Future<void> call() async {
    final personDocId = ref.read(personDocIdProvider);
    final familyDocId = ref.read(currentFamilyDocIdProvider);
    if (personDocId == null || familyDocId == null) {
      throw StateError('Cannot leave: not in a family');
    }
    await ref.read(familyRepositoryProvider).leaveFamily(
          familyDocId: familyDocId,
          myPersonDocId: personDocId,
        );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'LeaveFamily')
        .ignore();
  }
}
