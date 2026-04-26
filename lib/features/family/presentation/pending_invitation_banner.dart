import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../providers/family_providers.dart';

/// Banner mounted above the home Scaffold body. Shows the most recent pending
/// invitation addressed to the current user (if any) with Accept / Decline
/// actions. Returns an empty [SizedBox] when there are no pending invites so
/// the banner doesn't take vertical space.
///
/// Visible from every tab — including for solo users who don't have the
/// Family tab yet (accepting the invite is what creates the Family tab).
class PendingInvitationBanner extends ConsumerWidget {
  const PendingInvitationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingInvitationsForMeProvider).valueOrNull;
    if (pending == null || pending.isEmpty) {
      return const SizedBox.shrink();
    }
    final invitation = pending.first;
    final inviter = invitation.inviterDisplayName ?? 'Someone';

    return Material(
      color: Colors.indigo.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.family_restroom, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$inviter invited you to a family.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(declineInvitationProvider.notifier)
                      .call(invitation.docId);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to decline: $e')),
                    );
                  }
                }
              },
              child:
                  const Text('Decline', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(acceptInvitationProvider.notifier)
                      .call(invitation.docId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Joined family.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to accept: $e')),
                    );
                  }
                }
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }
}
