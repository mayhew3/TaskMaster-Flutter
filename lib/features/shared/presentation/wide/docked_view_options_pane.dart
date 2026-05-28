import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/form_factor.dart';
import '../../../../models/task_colors.dart';
import '../../../../models/task_list_view.dart';
import '../../providers/right_pane_width_provider.dart';
import '../../providers/task_list_view_providers.dart';
import '../view_options_sheet.dart' show ViewOptionsPanelContent;

/// The wide-layout View Options side panel (TM-385 Story 4 of Epic
/// TM-188). Hosts the same [ViewOptionsPanelContent] body the phone
/// bottom sheet uses, wrapped in pane-specific chrome.
///
/// Two render modes based on the active surface's
/// `viewOptionsCollapsed` flag (per-surface, persisted via
/// `taskListViewStateProvider`):
///
///   - **Expanded**: a [_ResizeDivider] at the left edge (drag to
///     resize within `[kViewOptionsExpandedMin, kViewOptionsExpandedMax]`;
///     drag below `kViewOptionsCollapseSnapThreshold` collapses) +
///     the panel content (header, scrollable controls, Cancel/Apply).
///   - **Collapsed**: a [_ViewOptionsHandle] (44dp vertical strip with
///     sliders icon + rotated "VIEW OPTIONS" label). Tap the icon to
///     expand.
///
/// The pane's external width is computed by `rightPaneWidthProvider`
/// (read by `_buildWideShell`); this widget reads the same surface
/// state to decide what to render inside that width.
class DockedViewOptionsPane extends ConsumerWidget {
  const DockedViewOptionsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = ref.watch(activeSurfaceProvider);
    if (surface == null) {
      // Defensive: Stats has no list surface. The pane shouldn't be
      // routed here from `.viewOptions` mode on Stats (the button
      // isn't shown), but render a transparent placeholder if it is.
      return const SizedBox.shrink();
    }
    final collapsed = ref.watch(
      taskListViewStateProvider(surface)
          .select((v) => v.viewOptionsCollapsed),
    );

    return Material(
      color: TaskColors.bgDeep,
      child: collapsed
          ? _ViewOptionsHandle(surface: surface)
          : _ExpandedPanel(surface: surface),
    );
  }
}

/// Collapsed-state vertical handle (44dp). Tapping the sliders icon
/// flips `viewOptionsCollapsed` back to false. Renders the rotated
/// "VIEW OPTIONS" label per the prototype's `ViewOptionsHandle`.
class _ViewOptionsHandle extends ConsumerWidget {
  final TaskListSurface surface;

  const _ViewOptionsHandle({required this.surface});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.black.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: 'Expand View Options',
            child: Material(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => ref
                    .read(taskListViewStateProvider(surface).notifier)
                    .setViewOptionsCollapsed(false),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              'VIEW OPTIONS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expanded-state body: [_ResizeDivider] on the left edge + the
/// shared [ViewOptionsPanelContent]. The panel's `onClose` callback
/// collapses the panel (rather than dismissing — there's nothing to
/// dismiss; the pane is structural in the wide shell).
class _ExpandedPanel extends ConsumerWidget {
  final TaskListSurface surface;

  const _ExpandedPanel({required this.surface});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _ResizeDivider(surface: surface),
        Expanded(
          child: ViewOptionsPanelContent(
            surface: surface,
            onClose: () => ref
                .read(taskListViewStateProvider(surface).notifier)
                .setViewOptionsCollapsed(true),
          ),
        ),
      ],
    );
  }
}

/// 6dp draggable divider at the left edge of the expanded panel.
/// Drag updates the surface's `viewOptionsExpandedRatio`; drag past
/// the snap threshold collapses the panel (a tactile "drag to close"
/// affordance that mirrors common desktop panel UIs).
///
/// Stateful: captures the pane width at drag-start and accumulates
/// the total delta across `onHorizontalDragUpdate` events. Reading
/// `rightPaneWidthProvider` once per update would race with
/// Riverpod's recompute scheduling — under rapid-fire drag events,
/// each callback could see the same stale width and only the last
/// update's effect would persist.
class _ResizeDivider extends ConsumerStatefulWidget {
  final TaskListSurface surface;

  const _ResizeDivider({required this.surface});

  @override
  ConsumerState<_ResizeDivider> createState() => _ResizeDividerState();
}

class _ResizeDividerState extends ConsumerState<_ResizeDivider> {
  double? _startWidth;
  double _accumulatedDx = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _startWidth = ref.read(rightPaneWidthProvider);
          _accumulatedDx = 0;
        },
        onHorizontalDragUpdate: _handleDrag,
        onHorizontalDragEnd: (_) {
          _startWidth = null;
          _accumulatedDx = 0;
        },
        onHorizontalDragCancel: () {
          _startWidth = null;
          _accumulatedDx = 0;
        },
        child: Container(
          width: 6,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: SizedBox(
            width: 1,
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDrag(DragUpdateDetails details) {
    final startWidth = _startWidth;
    if (startWidth == null) return;
    _accumulatedDx += details.delta.dx;
    // Divider is at the LEFT EDGE of the pane, so drag-right
    // (positive dx) shrinks the pane and drag-left widens it.
    final nextWidth = startWidth - _accumulatedDx;
    final notifier = ref.read(taskListViewStateProvider(widget.surface).notifier);
    if (nextWidth < kViewOptionsCollapseSnapThreshold) {
      notifier.setViewOptionsCollapsed(true);
      _startWidth = null;
      _accumulatedDx = 0;
      return;
    }
    final clamped = nextWidth.clamp(
      kViewOptionsExpandedMin,
      kViewOptionsExpandedMax,
    );
    final ratio = (clamped - kViewOptionsExpandedMin) /
        (kViewOptionsExpandedMax - kViewOptionsExpandedMin);
    notifier.setViewOptionsExpandedRatio(ratio);
  }
}
