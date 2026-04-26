import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../../shared/providers/navigation_provider.dart';
import '../providers/family_providers.dart';
import 'invite_member_dialog.dart';
import 'pending_invitation_banner.dart';

/// Drawer destination for solo users. Lets them invite their first family
/// member (which materializes a family with the inviter as owner) or wait for
/// an incoming invitation (the [PendingInvitationBanner] handles that
/// automatically).
class FamilySetupScreen extends ConsumerWidget {
  const FamilySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: Column(
        children: [
          const PendingInvitationBanner(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.family_restroom,
                        size: 64, color: Colors.white54),
                    const SizedBox(height: 16),
                    const Text(
                      "You're not in a family yet.",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Invite a family member by email to start sharing tasks. '
                      "If they've already signed in to TaskMaster, they'll "
                      'see your invite next time they open the app.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Invite a family member'),
                      onPressed: () async {
                        final success = await showDialog<bool>(
                          context: context,
                          builder: (context) => InviteMemberDialog(
                            onMissingFamily: () async {
                              return await ref
                                  .read(createFamilyProvider.notifier)
                                  .call();
                            },
                          ),
                        );
                        if (success == true && context.mounted) {
                          // Pop the setup screen so the user lands back on
                          // the bottom-nav home. Switch the active tab to
                          // index 2; once the persons-self listener delivers
                          // the new familyDocId, the Riverpod app home
                          // rebuilds its bottom-nav items with the Family tab
                          // at index 2, so the user lands on it.
                          Navigator.of(context).pop();
                          ref
                              .read(activeTabIndexProvider.notifier)
                              .setTab(2);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
