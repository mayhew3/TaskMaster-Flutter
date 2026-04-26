import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/database/app_database.dart';

/// Thrown when the inviter looks up an email that has no `persons` doc yet.
/// Surfaced to the UI so the inviter can ask the invitee to sign in once first
/// (the current sign-in flow rejects unknown emails — see TM-335 design doc).
class InviteeNotFoundException implements Exception {
  InviteeNotFoundException(this.email);
  final String email;
  @override
  String toString() => 'InviteeNotFoundException(email: $email)';
}

/// Thrown when an invitation already exists for the same inviter+invitee+family
/// in the `pending` state. Stops accidental double-invites.
class DuplicateInvitationException implements Exception {
  DuplicateInvitationException(this.email);
  final String email;
  @override
  String toString() => 'DuplicateInvitationException(email: $email)';
}

/// Thrown when an action is rejected because the actor lacks permission
/// (e.g. a non-owner trying to remove another member).
class NotFamilyOwnerException implements Exception {
  @override
  String toString() => 'NotFamilyOwnerException';
}

/// Family operations against Firestore. Transactions guarantee that the
/// `families.members` list and `persons/{...}.familyDocId` field stay in sync,
/// even on flaky networks.
///
/// Local Drift mirrors are updated by SyncService listeners; this repository
/// does not write Drift directly except for the on-join backfill in
/// [acceptInvitation] / [createFamilyForCurrentUser].
class FamilyRepository {
  FamilyRepository({required this.firestore, required this.db});

  final FirebaseFirestore firestore;
  final AppDatabase db;

  /// Create a new family with the current user as sole member and owner.
  /// Returns the new family's docId.
  Future<String> createFamilyForCurrentUser({
    required String personDocId,
  }) async {
    final familyRef = firestore.collection('families').doc();
    final personRef = firestore.collection('persons').doc(personDocId);
    final now = DateTime.now().toUtc();

    await firestore.runTransaction((txn) async {
      final personSnap = await txn.get(personRef);
      if (personSnap.exists &&
          (personSnap.data()?['familyDocId'] as String?) != null) {
        // Already in a family — bail. UI shouldn't trigger this path, but the
        // transaction guards against double-creation if multiple devices race.
        return;
      }
      txn.set(familyRef, {
        'ownerPersonDocId': personDocId,
        'members': [personDocId],
        'dateAdded': now,
        'retired': null,
        'retiredDate': null,
      });
      txn.set(personRef, {'familyDocId': familyRef.id}, SetOptions(merge: true));
    });

    // Tasks created BEFORE the family existed stay personal — only newly
    // added tasks (stamped via AddTask while in a family) become shared.
    // This matches the user's intuition that the Family tab is what we've
    // added together, not the entire history each member brought in.

    return familyRef.id;
  }

  /// Send an invitation to [email]. The invitee must already have a `persons`
  /// doc (the current sign-in flow rejects unknown emails); throws
  /// [InviteeNotFoundException] if not. Throws [DuplicateInvitationException]
  /// if a pending invitation for the same inviter+family+email already exists.
  Future<String> inviteByEmail({
    required String inviterPersonDocId,
    required String inviterFamilyDocId,
    required String inviteeEmail,
    String? inviterDisplayName,
  }) async {
    final personsByEmail = await firestore
        .collection('persons')
        .where('email', isEqualTo: inviteeEmail)
        .limit(1)
        .get();
    if (personsByEmail.docs.isEmpty) {
      throw InviteeNotFoundException(inviteeEmail);
    }

    final existingPending = await firestore
        .collection('familyInvitations')
        .where('inviterFamilyDocId', isEqualTo: inviterFamilyDocId)
        .where('inviteeEmail', isEqualTo: inviteeEmail)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (existingPending.docs.isNotEmpty) {
      throw DuplicateInvitationException(inviteeEmail);
    }

    final invitationRef = firestore.collection('familyInvitations').doc();
    await invitationRef.set({
      'inviterPersonDocId': inviterPersonDocId,
      'inviterFamilyDocId': inviterFamilyDocId,
      'inviterDisplayName': inviterDisplayName,
      'inviteeEmail': inviteeEmail,
      'status': 'pending',
      'dateAdded': DateTime.now().toUtc(),
    });
    return invitationRef.id;
  }

  /// Accept [invitationDocId]: add me to the family, mark the invitation
  /// accepted, and backfill my existing tasks with the new familyDocId.
  Future<void> acceptInvitation({
    required String invitationDocId,
    required String myPersonDocId,
    required String myEmail,
  }) async {
    await firestore.runTransaction((txn) async {
      final invitationRef =
          firestore.collection('familyInvitations').doc(invitationDocId);
      final invitationSnap = await txn.get(invitationRef);
      if (!invitationSnap.exists) {
        throw StateError('Invitation $invitationDocId not found');
      }
      final invitation = invitationSnap.data()!;
      if (invitation['status'] != 'pending') {
        throw StateError(
            'Invitation $invitationDocId is not pending (status=${invitation['status']})');
      }
      if (invitation['inviteeEmail'] != myEmail) {
        throw StateError('Invitation is not addressed to $myEmail');
      }

      final familyDocId = invitation['inviterFamilyDocId'] as String;
      final familyRef = firestore.collection('families').doc(familyDocId);
      final personRef = firestore.collection('persons').doc(myPersonDocId);

      txn.update(familyRef, {
        'members': FieldValue.arrayUnion([myPersonDocId]),
      });
      txn.set(personRef, {'familyDocId': familyDocId}, SetOptions(merge: true));
      txn.update(invitationRef, {'status': 'accepted'});
    });

    // Tasks created BEFORE accepting the invite stay personal — only newly
    // added tasks (stamped via AddTask while in a family) become shared.
  }

  Future<void> declineInvitation(String invitationDocId) {
    return firestore
        .collection('familyInvitations')
        .doc(invitationDocId)
        .update({'status': 'declined'});
  }

  /// Remove [targetPersonDocId] from [familyDocId]. The remover must be the
  /// family owner OR the target themselves (i.e. leave). If the removed user
  /// was the owner and other members remain, ownership transfers to the first
  /// remaining member. If the family has no members left, it's hard-deleted.
  Future<void> removeMember({
    required String familyDocId,
    required String removerPersonDocId,
    required String targetPersonDocId,
  }) async {
    String? removedTasksFamilyDocId;

    await firestore.runTransaction((txn) async {
      final familyRef = firestore.collection('families').doc(familyDocId);
      final familySnap = await txn.get(familyRef);
      if (!familySnap.exists) {
        throw StateError('Family $familyDocId not found');
      }
      final family = familySnap.data()!;
      final members = (family['members'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          <String>[];
      final ownerPersonDocId = family['ownerPersonDocId'] as String;

      if (removerPersonDocId != ownerPersonDocId &&
          removerPersonDocId != targetPersonDocId) {
        throw NotFamilyOwnerException();
      }
      if (!members.contains(targetPersonDocId)) return;
      members.remove(targetPersonDocId);

      final personRef =
          firestore.collection('persons').doc(targetPersonDocId);

      if (members.isEmpty) {
        // Last member out — delete the family.
        txn.delete(familyRef);
      } else {
        final updates = <String, Object?>{'members': members};
        if (ownerPersonDocId == targetPersonDocId) {
          // Transfer ownership to the first remaining member.
          updates['ownerPersonDocId'] = members.first;
        }
        txn.update(familyRef, updates);
      }
      txn.set(personRef, {'familyDocId': null}, SetOptions(merge: true));
      removedTasksFamilyDocId = familyDocId;
    });

    if (removedTasksFamilyDocId != null) {
      // Clear familyDocId on the removed person's tasks so they no longer
      // surface to the rest of the family. The push path runs against the
      // removed person's own pending writes; if removerPersonDocId !=
      // targetPersonDocId, the target's app will pick up the persons-doc
      // change via SyncService and the cleanup runs there too — but doing it
      // on the remover's side as well keeps the data eventually consistent
      // even if the target's device is offline.
      if (removerPersonDocId == targetPersonDocId) {
        await db.taskDao
            .setFamilyDocIdForAllTasksOfPerson(targetPersonDocId, null);
      }
    }
  }

  /// Convenience: leave a family I'm a member of.
  Future<void> leaveFamily({
    required String familyDocId,
    required String myPersonDocId,
  }) {
    return removeMember(
      familyDocId: familyDocId,
      removerPersonDocId: myPersonDocId,
      targetPersonDocId: myPersonDocId,
    );
  }
}
