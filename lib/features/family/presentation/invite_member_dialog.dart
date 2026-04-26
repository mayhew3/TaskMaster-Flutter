import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../data/family_repository.dart';
import '../providers/family_providers.dart';

/// Email-input dialog. On submit, calls [InviteMember.call]. Surfaces a
/// targeted error message when the invitee doesn't yet have a `persons` doc
/// (the current sign-in flow rejects unknown emails — see TM-335 design doc).
///
/// When [onMissingFamily] is non-null and the user is solo, the dialog calls
/// it before issuing the invite so the caller can spin up a family first.
/// Used by [FamilySetupScreen] to support the "first invite creates family"
/// flow.
class InviteMemberDialog extends ConsumerStatefulWidget {
  const InviteMemberDialog({super.key, this.onMissingFamily});

  /// If non-null, called when the current user has no familyDocId. Should
  /// return the new family's docId after creating it (or null on failure).
  final Future<String?> Function()? onMissingFamily;

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  // Loose email shape check — accepts any address with at least one char on
  // either side of `@` and a `.` somewhere after. Drives the Send-invite
  // button's enabled state; final validation happens server-side when we
  // look up the persons doc.
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _controller = TextEditingController();
  String? _errorText;
  bool _busy = false;
  bool _emailValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final valid = _emailPattern.hasMatch(_controller.text.trim());
    if (valid != _emailValid) {
      setState(() => _emailValid = valid);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onEmailChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _busy = true;
      _errorText = null;
    });
    try {
      // Create a family first if the user is solo and a setup callback is
      // provided. (FamilySetupScreen passes one; FamilyManageScreen does not
      // — it only opens this dialog when a family already exists.)
      String? familyDocIdOverride;
      if (ref.read(currentFamilyDocIdProvider) == null) {
        if (widget.onMissingFamily == null) {
          throw StateError('Cannot invite: not in a family');
        }
        familyDocIdOverride = await widget.onMissingFamily!();
        if (familyDocIdOverride == null) {
          if (mounted) {
            setState(() {
              _busy = false;
              _errorText = 'Could not create family. Please try again.';
            });
          }
          return;
        }
      }

      // Pass the just-created familyDocId through so InviteMember doesn't
      // race the SyncService listener round-trip back into Drift (the
      // currentFamilyDocIdProvider would still emit null).
      await ref
          .read(inviteMemberProvider.notifier)
          .call(email, familyDocIdOverride: familyDocIdOverride);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to $email.')),
        );
      }
    } on InviteeNotFoundException {
      if (mounted) {
        setState(() {
          _busy = false;
          _errorText =
              "$email hasn't signed in to TaskMaster yet. Ask them to sign in once before you invite them.";
        });
      }
    } on DuplicateInvitationException {
      if (mounted) {
        setState(() {
          _busy = false;
          _errorText = 'An invitation is already pending for $email.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _errorText = 'Failed to send invitation: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Override the dark-on-dark Material 3 defaults that pick `colorScheme.
    // primary` (TaskColors.backgroundColor — dark navy) for label, focus
    // border, and the button. Use light-on-dark instead.
    return AlertDialog(
      title: const Text('Invite a family member'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Email address',
          labelStyle: const TextStyle(color: Colors.white70),
          floatingLabelStyle: const TextStyle(color: Colors.white),
          errorText: _errorText,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
        enabled: !_busy,
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          // Disabled until the email looks valid AND we're not already in
          // flight on a previous submit.
          onPressed: (_busy || !_emailValid) ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Send invite'),
        ),
      ],
    );
  }
}
