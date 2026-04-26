import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../../../core/providers/auth_providers.dart';
import '../../../models/family_invitation.dart';
import '../../../models/person.dart';
import '../providers/family_providers.dart';
import 'invite_member_dialog.dart';

/// Pushed route accessed from the Family tab's action row. Shows the member
/// roster, lets the owner remove members, lets any member leave, and lets
/// the user issue new invitations. Outstanding invitations sent by the
/// current user are listed below the roster.
class FamilyManageScreen extends ConsumerWidget {
  const FamilyManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(currentFamilyProvider).valueOrNull;
    final members = ref.watch(familyMembersProvider).valueOrNull ?? const [];
    // The provider returns every invite the user has sent (incl. accepted /
    // declined). The "Pending invitations" section is for outstanding ones
    // only, so filter here.
    final outgoing = (ref.watch(outgoingInvitationsProvider).valueOrNull ??
            const <FamilyInvitation>[])
        .where((i) => i.status == FamilyInvitation.statusPending)
        .toList();
    final myPersonDocId = ref.watch(personDocIdProvider);
    final isOwner =
        family != null && family.ownerPersonDocId == myPersonDocId;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage family')),
      body: ListView(
        children: [
          if (family == null)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text("You're not in a family.")),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Members',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            for (final member in members)
              _MemberTile(
                member: member,
                isOwner: family.ownerPersonDocId == member.docId,
                isMe: member.docId == myPersonDocId,
                canRemoveOthers: isOwner,
                onRemove: member.docId == myPersonDocId
                    ? () => _confirmAndLeave(context, ref)
                    : (isOwner
                        ? () => _confirmAndRemove(context, ref, member)
                        : null),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Invite a family member'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => const InviteMemberDialog(),
                ),
              ),
            ),
            if (outgoing.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Pending invitations',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              for (final invitation in outgoing)
                ListTile(
                  leading: const Icon(Icons.outgoing_mail),
                  title: Text(invitation.inviteeEmail),
                  subtitle: Text(invitation.status),
                ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                label: const Text('Leave family',
                    style: TextStyle(color: Colors.redAccent)),
                onPressed: () => _confirmAndLeave(context, ref),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave family?'),
        content: const Text(
            "You'll stop seeing other members' tasks, and they'll stop seeing yours. You can be re-invited later."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(leaveFamilyProvider.notifier).call();
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave: $e')),
        );
      }
    }
  }

  Future<void> _confirmAndRemove(
      BuildContext context, WidgetRef ref, Person member) async {
    final name = (member.displayName != null && member.displayName!.isNotEmpty)
        ? member.displayName!
        : 'this member';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove $name?'),
        content: Text(
            "$name will stop seeing the family's tasks, and the family will stop seeing theirs."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(removeMemberProvider.notifier).call(member.docId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isOwner,
    required this.isMe,
    required this.canRemoveOthers,
    required this.onRemove,
  });

  final Person member;
  final bool isOwner;
  final bool isMe;
  final bool canRemoveOthers;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final name = (member.displayName != null && member.displayName!.isNotEmpty)
        ? member.displayName!
        : 'Family member';
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Row(
        children: [
          Flexible(child: Text(name)),
          if (isMe) const SizedBox(width: 6),
          if (isMe)
            const Chip(
                label: Text('You', style: TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact),
          if (isOwner) const SizedBox(width: 6),
          if (isOwner)
            const Chip(
                label: Text('Owner', style: TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact),
        ],
      ),
      // Email is never surfaced in the UI (TM-335 follow-up). The persons
      // doc keeps email only for sign-in lookup.
      trailing: onRemove != null
          ? IconButton(
              icon: Icon(isMe ? Icons.exit_to_app : Icons.person_remove,
                  color: Colors.redAccent),
              tooltip: isMe ? 'Leave' : 'Remove',
              onPressed: onRemove,
            )
          : null,
    );
  }
}
