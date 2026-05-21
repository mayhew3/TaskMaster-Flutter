import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/form_factor.dart';
import '../../../../models/task_colors.dart';
import '../../providers/selected_task_providers.dart';

/// Wraps a list-bearing body in a Stack with a **parent-level** aura
/// underlay (TM-383 Story 2 of Epic TM-188).
///
/// ## Why this exists
///
/// The naive per-row aura ([SelectableTaskItem]'s previous implementation
/// painted a [BoxShadow] inside each row) suffers from a fundamental
/// paint-order problem in a [ListView]: each row paints AFTER the row
/// above it, so any shadow that overflows the selected row's bounds
/// upward paints **over** the previous row's content. The row above
/// ends up visibly tinted magenta where the aura overflows into it.
///
/// The fix is to paint the aura at the **list body level**, BELOW the
/// rows in z-order:
///   - `Stack[AuraLayer, listChild]` — `AuraLayer` paints first.
///   - The list's rows paint on top. Each row's opaque card body
///     occludes the aura's interior; the aura is naturally visible only
///     in the per-row margin gaps where rows don't paint.
///   - No row paints over the aura, no matter which row is selected.
///
/// ## Wiring
///
/// Each row's [SelectableTaskItem] attaches a [GlobalObjectKey] keyed by
/// its docId WHEN selected, so this widget's aura layer can look up its
/// [RenderBox] via that key and paint the aura at the row's current
/// screen position. A [NotificationListener] catches
/// [ScrollUpdateNotification]s from the descendant ListView and
/// triggers a rebuild so the aura tracks the row through scroll.
///
/// On compact layouts this widget returns its child unchanged — phones
/// never render a selection aura.
class AuraStack extends ConsumerStatefulWidget {
  final Widget child;
  const AuraStack({super.key, required this.child});

  @override
  ConsumerState<AuraStack> createState() => _AuraStackState();
}

class _AuraStackState extends ConsumerState<AuraStack> {
  // Bump on each scroll event so AuraLayer rebuilds and recomputes the
  // selected row's position. Keep on the State so the rebuild is local
  // to this subtree, not the whole screen.
  int _scrollTick = 0;

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(MediaQuery.sizeOf(context))) return widget.child;

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (_) {
        // Don't consume — let any other listeners (e.g. the framework's
        // own scroll machinery) keep seeing the notification.
        if (mounted) setState(() => _scrollTick++);
        return false;
      },
      child: Stack(
        children: [
          // Aura paints FIRST → underneath the list. The list's row
          // cards paint on top and occlude the aura's interior; only
          // the halo extending into per-row margin space stays visible.
          //
          // _AuraLayer is a direct Stack child (not wrapped in another
          // Positioned) because the layer itself returns Positioned
          // .fromRect when it has a rect — nesting two Positioneds
          // would conflict on the same StackParentData.
          _AuraLayer(scrollTick: _scrollTick),
          widget.child,
        ],
      ),
    );
  }
}

/// Internal: finds the selected row's [RenderBox] via [GlobalObjectKey]
/// and paints the aura at its bounds. [scrollTick] is bumped by the
/// parent on every scroll event to force a re-position.
///
/// **Why stateful + post-frame:** parents build before children in a
/// frame, so on the build that follows a selection change, the
/// SelectableTaskItem holding the row's GlobalObjectKey hasn't mounted
/// yet — its `currentContext` is null. Doing the row lookup in a
/// post-frame callback defers it past the child build pass, then a
/// `setState` rebuilds this layer with the now-attached RenderBox.
class _AuraLayer extends ConsumerStatefulWidget {
  final int scrollTick;
  const _AuraLayer({required this.scrollTick});

  @override
  ConsumerState<_AuraLayer> createState() => _AuraLayerState();
}

class _AuraLayerState extends ConsumerState<_AuraLayer> {
  Rect? _auraRect;
  bool _updateScheduled = false;

  @override
  void initState() {
    super.initState();
    // Initial mount: lookup may need a post-frame because the
    // SelectableTaskItem children haven't built yet on this frame.
    _scheduleUpdate();
    // Reschedule on every selection change for the lifetime of this
    // widget. Using listenManual (not ref.listen in build) keeps the
    // listener wired exactly once and avoids re-arming on every build.
    ref.listenManual(selectedTaskProvider, (_, __) => _scheduleUpdate());
  }

  @override
  void didUpdateWidget(_AuraLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollTick != widget.scrollTick) _scheduleUpdate();
  }

  void _scheduleUpdate() {
    if (_updateScheduled) return;
    _updateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      if (!mounted) return;
      _recomputeRect();
    });
  }

  void _recomputeRect() {
    final docId = ref.read(selectedTaskProvider);
    Rect? newRect;
    if (docId != null) {
      final rb = SelectableTaskItemKey.of(docId).currentContext
          ?.findRenderObject() as RenderBox?;
      final myRb = context.findRenderObject() as RenderBox?;
      if (rb != null &&
          rb.attached &&
          myRb != null &&
          myRb.attached) {
        final rowGlobal = rb.localToGlobal(Offset.zero);
        final rowLocal = myRb.globalToLocal(rowGlobal);
        newRect = Rect.fromLTWH(
          rowLocal.dx,
          rowLocal.dy,
          rb.size.width,
          rb.size.height,
        );
      }
    }
    if (newRect != _auraRect) {
      setState(() => _auraRect = newRect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rect = _auraRect;
    if (rect == null) return const SizedBox.shrink();
    return Positioned.fromRect(
      rect: rect,
      child: const IgnorePointer(child: _AuraDecoration()),
    );
  }
}

/// The aura's visual: inset to match the card's outer margin, opaque
/// fill (occluded by the actual card on top, but ensures the shadow's
/// interior is occluded by *something*), and a brand-magenta [BoxShadow]
/// extending outward.
class _AuraDecoration extends StatelessWidget {
  const _AuraDecoration();

  /// Must match the `Card.margin` on the V9 card body in
  /// `editable_task_item.dart` (currently line 202) so the aura's
  /// silhouette lines up with the card's silhouette.
  static const EdgeInsets _kCardOuterMargin =
      EdgeInsets.symmetric(horizontal: 8, vertical: 3);
  static const double _kAuraRadius = 7;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _kCardOuterMargin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kAuraRadius),
          color: TaskColors.cardColor,
          boxShadow: [
            BoxShadow(
              color: TaskColors.brandMagenta.withValues(alpha: 0.40),
              blurRadius: 22,
            ),
          ],
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Marker type for the row's [GlobalObjectKey]. Using a typed marker
/// (not a raw String) keeps the key namespace distinct from any other
/// code that might create `GlobalObjectKey(someString)` for an
/// unrelated purpose.
class _AuraRowKey {
  final String docId;
  const _AuraRowKey(this.docId);

  @override
  bool operator ==(Object other) =>
      other is _AuraRowKey && other.docId == docId;

  @override
  int get hashCode => docId.hashCode;
}

/// Shared key namespace between [SelectableTaskItem] (which attaches the
/// key when selected) and [_AuraLayer] (which looks it up to find the
/// row's RenderBox).
///
/// **Why the marker cache:** [GlobalObjectKey] compares `value` by
/// `identical()` (NOT `==`), so two `GlobalObjectKey(_AuraRowKey('docA'))`
/// calls produce NON-EQUAL keys because each call allocates a fresh
/// `_AuraRowKey` instance. Caching the marker per docId guarantees
/// `SelectableTaskItemKey.of('docA')` returns the SAME logical key
/// across the SelectableTaskItem (which attaches it) and the
/// `_AuraLayer` (which looks it up).
class SelectableTaskItemKey {
  const SelectableTaskItemKey._();

  static final Map<String, _AuraRowKey> _markers = {};

  /// Returns the [GlobalObjectKey] for [docId]'s row. Stable across
  /// calls — multiple invocations return keys that compare equal via
  /// [GlobalObjectKey]'s identity-based `==`.
  static GlobalObjectKey of(String docId) {
    final marker = _markers.putIfAbsent(docId, () => _AuraRowKey(docId));
    return GlobalObjectKey(marker);
  }
}
