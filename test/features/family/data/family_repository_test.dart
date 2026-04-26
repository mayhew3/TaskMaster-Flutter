import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/features/family/data/family_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeFirebaseFirestore firestore;
  late FamilyRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    repo = FamilyRepository(firestore: firestore, db: db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedPerson({
    required String docId,
    required String email,
    String? displayName,
    String? familyDocId,
  }) async {
    await firestore.collection('persons').doc(docId).set({
      'email': email,
      'displayName': displayName,
      'familyDocId': familyDocId,
      'dateAdded': DateTime.utc(2024, 1, 1),
    });
  }

  group('createFamilyForCurrentUser', () {
    test('creates family with current user as sole owner', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');

      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');

      final familyDoc =
          await firestore.collection('families').doc(familyDocId).get();
      expect(familyDoc.exists, true);
      expect(familyDoc.data()!['ownerPersonDocId'], 'pA');
      expect(familyDoc.data()!['members'], ['pA']);

      final personDoc = await firestore.collection('persons').doc('pA').get();
      expect(personDoc.data()!['familyDocId'], familyDocId);
    });

    test('is a no-op when the user is already in a family', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com', familyDocId: 'existing');

      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');

      // The transaction sees the existing familyDocId and bails before
      // creating a new family. The returned ID is stale but no doc exists.
      final familyDoc =
          await firestore.collection('families').doc(familyDocId).get();
      expect(familyDoc.exists, false);
      final personDoc = await firestore.collection('persons').doc('pA').get();
      expect(personDoc.data()!['familyDocId'], 'existing');
    });
  });

  group('inviteByEmail', () {
    test('writes a pending invitation when invitee exists', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');

      final invitationDocId = await repo.inviteByEmail(
        inviterPersonDocId: 'pA',
        inviterFamilyDocId: familyDocId,
        inviteeEmail: 'b@x.com',
        inviterDisplayName: 'Alice',
      );

      final invitation = await firestore
          .collection('familyInvitations')
          .doc(invitationDocId)
          .get();
      expect(invitation.exists, true);
      expect(invitation.data()!['status'], 'pending');
      expect(invitation.data()!['inviteeEmail'], 'b@x.com');
      expect(invitation.data()!['inviterFamilyDocId'], familyDocId);
      expect(invitation.data()!['inviterDisplayName'], 'Alice');
    });

    test('throws InviteeNotFoundException when no person matches email',
        () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');

      expect(
        () => repo.inviteByEmail(
          inviterPersonDocId: 'pA',
          inviterFamilyDocId: familyDocId,
          inviteeEmail: 'unknown@x.com',
        ),
        throwsA(isA<InviteeNotFoundException>()),
      );
    });

    test('throws DuplicateInvitationException on repeated invite', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      await repo.inviteByEmail(
        inviterPersonDocId: 'pA',
        inviterFamilyDocId: familyDocId,
        inviteeEmail: 'b@x.com',
      );

      expect(
        () => repo.inviteByEmail(
          inviterPersonDocId: 'pA',
          inviterFamilyDocId: familyDocId,
          inviteeEmail: 'b@x.com',
        ),
        throwsA(isA<DuplicateInvitationException>()),
      );
    });
  });

  group('acceptInvitation', () {
    test('adds invitee to family.members and updates persons.familyDocId',
        () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      final invitationDocId = await repo.inviteByEmail(
        inviterPersonDocId: 'pA',
        inviterFamilyDocId: familyDocId,
        inviteeEmail: 'b@x.com',
      );

      await repo.acceptInvitation(
        invitationDocId: invitationDocId,
        myPersonDocId: 'pB',
        myEmail: 'b@x.com',
      );

      final family =
          await firestore.collection('families').doc(familyDocId).get();
      expect(family.data()!['members'], containsAll(['pA', 'pB']));

      final personB = await firestore.collection('persons').doc('pB').get();
      expect(personB.data()!['familyDocId'], familyDocId);

      final invitation = await firestore
          .collection('familyInvitations')
          .doc(invitationDocId)
          .get();
      expect(invitation.data()!['status'], 'accepted');
    });

    test('rejects mismatched email', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      final invitationDocId = await repo.inviteByEmail(
        inviterPersonDocId: 'pA',
        inviterFamilyDocId: familyDocId,
        inviteeEmail: 'b@x.com',
      );

      expect(
        () => repo.acceptInvitation(
          invitationDocId: invitationDocId,
          myPersonDocId: 'pC',
          myEmail: 'c@x.com',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('declineInvitation', () {
    test('marks invitation declined', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      final invitationDocId = await repo.inviteByEmail(
        inviterPersonDocId: 'pA',
        inviterFamilyDocId: familyDocId,
        inviteeEmail: 'b@x.com',
      );

      await repo.declineInvitation(invitationDocId);

      final invitation = await firestore
          .collection('familyInvitations')
          .doc(invitationDocId)
          .get();
      expect(invitation.data()!['status'], 'declined');
    });
  });

  group('removeMember', () {
    test('owner removes another member', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      final invitationDocId = await repo.inviteByEmail(
        inviterPersonDocId: 'pA',
        inviterFamilyDocId: familyDocId,
        inviteeEmail: 'b@x.com',
      );
      await repo.acceptInvitation(
        invitationDocId: invitationDocId,
        myPersonDocId: 'pB',
        myEmail: 'b@x.com',
      );

      await repo.removeMember(
        familyDocId: familyDocId,
        removerPersonDocId: 'pA',
        targetPersonDocId: 'pB',
      );

      final family =
          await firestore.collection('families').doc(familyDocId).get();
      expect(family.data()!['members'], ['pA']);
      final personB = await firestore.collection('persons').doc('pB').get();
      expect(personB.data()!['familyDocId'], null);
    });

    test('non-owner cannot remove a different member', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      await seedPerson(docId: 'pC', email: 'c@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      // Add pB and pC manually to skip the invitation dance.
      await firestore.collection('families').doc(familyDocId).update({
        'members': ['pA', 'pB', 'pC'],
      });

      expect(
        () => repo.removeMember(
          familyDocId: familyDocId,
          removerPersonDocId: 'pB',
          targetPersonDocId: 'pC',
        ),
        throwsA(isA<NotFamilyOwnerException>()),
      );
    });

    test('member can remove themselves (leave)', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      await firestore.collection('families').doc(familyDocId).update({
        'members': ['pA', 'pB'],
      });
      await firestore
          .collection('persons')
          .doc('pB')
          .set({'familyDocId': familyDocId}, SetOptions(merge: true));

      await repo.removeMember(
        familyDocId: familyDocId,
        removerPersonDocId: 'pB',
        targetPersonDocId: 'pB',
      );

      final family =
          await firestore.collection('families').doc(familyDocId).get();
      expect(family.data()!['members'], ['pA']);
      final personB = await firestore.collection('persons').doc('pB').get();
      expect(personB.data()!['familyDocId'], null);
    });

    test('owner leaving transfers ownership to first remaining member',
        () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      await seedPerson(docId: 'pB', email: 'b@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');
      await firestore.collection('families').doc(familyDocId).update({
        'members': ['pA', 'pB'],
      });

      await repo.leaveFamily(
          familyDocId: familyDocId, myPersonDocId: 'pA');

      final family =
          await firestore.collection('families').doc(familyDocId).get();
      expect(family.data()!['ownerPersonDocId'], 'pB');
      expect(family.data()!['members'], ['pB']);
    });

    test('last member leaving deletes the family', () async {
      await seedPerson(docId: 'pA', email: 'a@x.com');
      final familyDocId =
          await repo.createFamilyForCurrentUser(personDocId: 'pA');

      await repo.leaveFamily(
          familyDocId: familyDocId, myPersonDocId: 'pA');

      final family =
          await firestore.collection('families').doc(familyDocId).get();
      expect(family.exists, false);
      final personA = await firestore.collection('persons').doc('pA').get();
      expect(personA.data()!['familyDocId'], null);
    });
  });
}
