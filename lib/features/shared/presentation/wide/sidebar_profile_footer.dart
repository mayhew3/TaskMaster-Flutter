import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../models/task_colors.dart';

/// Pinned profile footer of the wide-layout sidebar (TM-382). Shows the
/// signed-in identity (mirrors [AppDrawer]'s `authProvider` read) and, on
/// tap, opens the existing [AppDrawer] of the enclosing wide Scaffold —
/// verbatim reuse, no new account/settings UI in Story 1.
class SidebarProfileFooter extends ConsumerWidget {
  const SidebarProfileFooter({super.key});

  String _initials(String? displayName, String? email) {
    final name = (displayName ?? '').trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      final first = parts.first.characters.first;
      final last = parts.length > 1 ? parts.last.characters.first : '';
      return (first + last).toUpperCase();
    }
    final mail = (email ?? '').trim();
    if (mail.isNotEmpty) return mail.characters.first.toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: TaskColors.hairline)),
      ),
      // Builder so onTap's context is a descendant of the wide Scaffold
      // and Scaffold.of resolves to it (not any inner-screen Scaffold).
      child: Builder(
        builder: (context) => InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TaskColors.brandMagenta,
                        TaskColors.brandMagentaMuted,
                      ],
                    ),
                  ),
                  child: Text(
                    _initials(user?.displayName, email),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TaskColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: TaskColors.textFaint,
                            fontSize: 10.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
