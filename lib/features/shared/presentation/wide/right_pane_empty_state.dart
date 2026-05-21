import 'package:flutter/material.dart';

import '../../../../models/task_colors.dart';

/// On-brand right-pane empty state for the wide adaptive shell — what the
/// pane shows when nothing is selected (TM-383 Story 2 of Epic TM-188).
///
/// Pixel-faithful port of `RightPaneEmpty` from the Claude Design handoff
/// (`.claude/handoff/TM-188/taskmaestro-redesign/project/wide-chrome.jsx` lines
/// 511-561). Centered illustration (92dp rounded square + task-card glyph
/// + magenta-bg check badge) over a title + subtitle + a row of static
/// keyboard-hint pills. The hint pills are **visual only** in Story 2 —
/// the actual shortcut bindings land in Story 4 (TM-385).
class RightPaneEmptyState extends StatelessWidget {
  const RightPaneEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _EmptyStateIllustration(),
            const SizedBox(height: 18),
            Text(
              'Select a task',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TaskColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Click any row to edit it here — the pane stays open while '
                'you move through the list.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: TaskColors.textFaint,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _KeyboardHintRow(),
          ],
        ),
      ),
    );
  }
}

/// 92dp rounded square with a faint task-card glyph + a small magenta
/// check badge tucked into the bottom-right corner. Matches the SVG mark
/// in the prototype `RightPaneEmpty` exactly enough to read as the same
/// shape; the inner glyph uses `Icons.checklist_outlined` as a stand-in
/// for the bespoke SVG since the visual intent ("a task being checked")
/// is identical and avoids a CustomPaint maintenance cost.
class _EmptyStateIllustration extends StatelessWidget {
  const _EmptyStateIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98,
      height: 98,
      // Clip overhangs (the badge sits at bottom: -6, right: -6, so the
      // 92×92 inner square needs a 98×98 host to host the overflow).
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.checklist_outlined,
              size: 46,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: TaskColors.brandMagenta,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Static keyboard-hint row at the bottom of the empty state:
/// `[N] new task · [/] search · [J][K] next/prev`. Visual only —
/// Story 4 (TM-385) wires the actual shortcuts.
///
/// Uses [Wrap] (not [Row]) so that at narrow right-pane widths (the
/// minimum two-pane viewport gives ≈320dp inside the empty state's
/// padding, less than the natural ~419dp the three pill clusters
/// occupy) the hint groups break to a second line instead of
/// horizontally overflowing.
class _KeyboardHintRow extends StatelessWidget {
  const _KeyboardHintRow();

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      fontSize: 11,
      color: Colors.white.withValues(alpha: 0.45),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        _HintGroup(children: [
          const _Kbd('N'),
          const SizedBox(width: 4),
          Text('new task', style: muted),
        ]),
        _HintGroup(children: [
          const _Kbd('/'),
          const SizedBox(width: 4),
          Text('search', style: muted),
        ]),
        _HintGroup(children: [
          const _Kbd('J'),
          const SizedBox(width: 3),
          const _Kbd('K'),
          const SizedBox(width: 4),
          Text('next/prev', style: muted),
        ]),
      ],
    );
  }
}

/// One inseparable hint cluster (e.g. `[J][K] next/prev`). Grouped so a
/// Wrap line break never lands between a keycap and its label.
class _HintGroup extends StatelessWidget {
  final List<Widget> children;
  const _HintGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

/// Small keycap pill used by [_KeyboardHintRow]. Matches the prototype's
/// `Kbd` styling.
class _Kbd extends StatelessWidget {
  final String label;
  const _Kbd(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.75),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
