import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

/// Thrown when a `pending` invitation already exists for the same family +
/// invitee email (regardless of which member sent it). Stops accidental
/// double-invites when multiple members try to invite the same person.
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
/// Local Drift mirrors are primarily updated by SyncService listeners. This
/// repository may still perform limited direct Drift writes for specific
/// local-cleanup flows (currently only the self-leave path of
/// [removeMember], which clears `familyDocId` on the leaver's own tasks via
/// the local pendingWrites pipeline). Callers should not assume Drift is
/// only ever updated via sync.
class FamilyRepository {
  FamilyRepository({required this.firestore, required this.db});

  final FirebaseFirestore firestore;
  final AppDatabase db;

  /// Create a new family with the current user as sole member and owner.
  /// Returns the resulting family's docId — either the freshly-created one,
  /// or the user's existing `familyDocId` if they were already in a family
  /// when this raced with another device.
  Future<String> createFamilyForCurrentUser({
    required String personDocId,
  }) async {
    final familyRef = firestore.collection('families').doc();
    final personRef = firestore.collection('persons').doc(personDocId);
    final now = DateTime.now().toUtc();
    String? existingFamilyDocId;

    await firestore.runTransaction((txn) async {
      final personSnap = await txn.get(personRef);
      if (personSnap.exists &&
          (personSnap.data()?['familyDocId'] as String?) != null) {
        // Already in a family — bail. UI shouldn't trigger this path, but
        // the transaction guards against double-creation if multiple devices
        // race. Capture the existing id so callers don't proceed with the
        // unused `familyRef.id` (which has no Firestore doc behind it).
        existingFamilyDocId = personSnap.data()!['familyDocId'] as String;
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

    return existingFamilyDocId ?? familyRef.id;
  }

  /// Send an invitation to [email]. The invitee must already have a `persons`
  /// doc (the current sign-in flow rejects unknown emails); throws
  /// [InviteeNotFoundException] if not. Throws [DuplicateInvitationException]
  /// if any pending invitation for this family + invitee email already exists
  /// (regardless of which member sent it).
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

  /// Accept [invitationDocId]: add me to the family and mark the invitation
  /// accepted. Tasks created before joining remain personal; only tasks
  /// added after joining get stamped with the new familyDocId (by AddTask).
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
      // surface to the rest of the family (the family-tasks listener is
      // keyed on familyDocId; without this, removed members' tasks linger).
      if (removerPersonDocId == targetPersonDocId) {
        // Self-leave: write through the local Drift → pendingWrites → push
        // path so the change is offline-safe and merges cleanly with any
        // local pending edits.
        await db.taskDao
            .setFamilyDocIdForAllTasksOfPerson(targetPersonDocId, null);
      } else {
        // Owner removes another member: target's tasks aren't in the
        // remover's own pending-writes pipeline, so we have to write them
        // to Firestore directly. Batched (Firestore caps at 500/batch);
        // chunk just in case a family has >500 active tasks per member.
        // Best-effort: if the batch write fails, the member is already
        // removed from the family but their tasks may still carry familyDocId
        // until the next sync or a retry. The family-tasks listener will stop
        // delivering them once the removed member's person doc loses its
        // familyDocId, so the inconsistency window is bounded by Firestore's
        // propagation latency. A server-side Function would make this atomic
        // (deferred to TM-336).
        try {
          final query = await firestore
              .collection('tasks')
              .where('familyDocId', isEqualTo: removedTasksFamilyDocId)
              .where('personDocId', isEqualTo: targetPersonDocId)
              .get();
          const batchSize = 400;
          for (var i = 0; i < query.docs.length; i += batchSize) {
            final batch = firestore.batch();
            final end = (i + batchSize < query.docs.length)
                ? i + batchSize
                : query.docs.length;
            for (final doc in query.docs.sublist(i, end)) {
              batch.update(doc.reference, {'familyDocId': null});
            }
            await batch.commit();
          }
        } catch (e, s) {
          // Log but don't rethrow — membership removal already succeeded.
          // Remaining tasks will linger in family view until the person doc
          // propagates or the next manual sync (see comment above).
          debugPrint('⚠️ [removeMember] task-cleanup batch failed: $e\n$s');
        }
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
