import 'package:flutter/material.dart';

import '../../../../core/platform/form_factor.dart';

/// Constrains [child] to a centered ~720dp max-width column on the wide
/// adaptive shell; returns the child unchanged on compact (TM-383 Story
/// 2 of Epic TM-188).
///
/// Pixel-faithful port of the prototype `TaskListPane`'s `maxWidth: 720`
/// Direction-1 treatment
/// (`.claude/handoff/TM-188/taskmaestro-redesign/project/wide-screens
/// .jsx` line 91). Use from any **list-bearing** destination's
/// `Scaffold.body` (Tasks, Family, Sprint) so the calm centered column
/// renders consistently across them. Plan (form-shaped) and Stats
/// (charts read wider) intentionally skip this wrap.
///
/// Wrapping happens INSIDE each `Scaffold.body` rather than at the shell
/// level so each screen's `AppBar` still spans the full available width
/// — only the body content gets centered.
class WideCenteredColumn extends StatelessWidget {
  /// Max width of the centered column on wide layouts.
  static const double maxWidth = 720.0;

  final Widget child;
  const WideCenteredColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(MediaQuery.sizeOf(context))) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
