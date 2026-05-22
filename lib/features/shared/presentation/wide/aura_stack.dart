import 'package:flutter/rendering.dart' show RenderStack;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/form_factor.dart';
import '../../../../models/task_colors.dart';
import '../../../../models/task_list_view.dart' show TaskListSurface;
import '../../providers/selected_task_providers.dart';
import '../editable_task_item.dart' show kV9CardOuterMargin;

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
/// ([surface], docId) WHEN selected, so this widget's aura layer can
/// look up its [RenderBox] via that key and paint the aura at the row's
/// current screen position. A [NotificationListener] catches
/// [ScrollUpdateNotification]s from the descendant ListView and
/// triggers a rebuild so the aura tracks the row through scroll.
///
/// ## Surface scoping
///
/// The wide shell uses `IndexedStack` to keep all destination bodies
/// mounted simultaneously. A family-shared task that's also in the
/// active sprint appears in BOTH the Family list AND the Plan tab's
/// sprint view at the same time. Without surface scoping, both
/// [SelectableTaskItem] instances would attach the same global key →
/// "Duplicate GlobalKey" runtime throw. Each [AuraStack] passes its own
/// [surface] into the key namespace so the lookups stay independent.
///
/// On compact layouts this widget returns its child unchanged — phones
/// never render a selection aura.
class AuraStack extends ConsumerStatefulWidget {
  /// Which list surface this aura layer is for. Must match the surface
  /// passed to the [SelectableTaskItem]s rendered inside [child].
  final TaskListSurface surface;
  final Widget child;
  const AuraStack({
    super.key,
    required this.surface,
    required this.child,
  });

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
        // No selection = nothing to reposition. Skip the setState (and
        // the AuraLayer rebuild it triggers) on every scroll frame
        // during the common no-selection case.
        // Don't consume — let any other listeners (e.g. the framework's
        // own scroll machinery) keep seeing the notification.
        if (mounted && ref.read(selectedTaskProvider) != null) {
          setState(() => _scrollTick++);
        }
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
          _AuraLayer(surface: widget.surface, scrollTick: _scrollTick),
          widget.child,
        ],
      ),
    );
  }
}

/// Internal: finds the selected row's [RenderBox] via [GlobalObjectKey]
/// (scoped by [surface]) and paints the aura at its bounds. [scrollTick]
/// is bumped by the parent on every scroll event to force a re-position.
///
/// **Why stateful + post-frame:** parents build before children in a
/// frame, so on the build that follows a selection change, the
/// SelectableTaskItem holding the row's GlobalObjectKey hasn't mounted
/// yet — its `currentContext` is null. Doing the row lookup in a
/// post-frame callback defers it past the child build pass, then a
/// `setState` rebuilds this layer with the now-attached RenderBox.
class _AuraLayer extends ConsumerStatefulWidget {
  final TaskListSurface surface;
  final int scrollTick;
  const _AuraLayer({required this.surface, required this.scrollTick});

  @override
  ConsumerState<_AuraLayer> createState() => _AuraLayerState();
}

class _AuraLayerState extends ConsumerState<_AuraLayer> {
  Rect? _auraRect;
  bool _updateScheduled = false;
  // Held so dispose() can close it explicitly. Riverpod's ConsumerState
  // ref-disposal should auto-clean listenManual subscriptions, but the
  // explicit close removes any doubt + keeps the listener-lifetime
  // story local to this widget rather than relying on the framework's
  // implicit cleanup semantics.
  ProviderSubscription<String?>? _selectionSub;

  @override
  void initState() {
    super.initState();
    // Initial mount: lookup may need a post-frame because the
    // SelectableTaskItem children haven't built yet on this frame.
    _scheduleUpdate();
    // Reschedule on every selection change for the lifetime of this
    // widget. Using listenManual (not ref.listen in build) keeps the
    // listener wired exactly once and avoids re-arming on every build.
    _selectionSub = ref.listenManual(
      selectedTaskProvider,
      (_, __) => _scheduleUpdate(),
    );
  }

  @override
  void dispose() {
    _selectionSub?.close();
    _selectionSub = null;
    super.dispose();
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
      final rb = SelectableTaskItemKey.of(widget.surface, docId)
          .currentContext
          ?.findRenderObject() as RenderBox?;
      // Anchor to the ancestor Stack's coordinate space, NOT this
      // widget's own RenderObject. `context.findRenderObject()` here
      // would resolve to the Positioned child's RenderObject (the
      // previously-painted aura's position) — using `globalToLocal` on
      // that yields offsets relative to where the aura WAS, not where
      // the Stack IS. Result: each recompute would drift by the
      // previous aura's local offset (visible when switching selection
      // between two rows at different vertical positions, or when the
      // list scrolls).
      final stackBox = context.findAncestorRenderObjectOfType<RenderStack>();
      if (rb != null &&
          rb.attached &&
          stackBox != null &&
          stackBox.attached) {
        final rowGlobal = rb.localToGlobal(Offset.zero);
        final rowLocal = stackBox.globalToLocal(rowGlobal);
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

  /// Corner radius of the aura's RRect.
  static const double _kAuraRadius = 7;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kV9CardOuterMargin,
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

/// Marker type for the row's [GlobalObjectKey]. Includes the surface so
/// the same docId rendered on multiple surfaces (e.g. a family-shared
/// task that's also in the active sprint, visible on both the Family
/// tab and the Plan tab's sprint view simultaneously) gets distinct
/// keys per surface.
class _AuraRowKey {
  final TaskListSurface surface;
  final String docId;
  const _AuraRowKey(this.surface, this.docId);

  @override
  bool operator ==(Object other) =>
      other is _AuraRowKey &&
      other.surface == surface &&
      other.docId == docId;

  @override
  int get hashCode => Object.hash(surface, docId);
}

/// Shared key namespace between [SelectableTaskItem] (which attaches the
/// key when selected) and [_AuraLayer] (which looks it up to find the
/// row's RenderBox).
///
/// **Why a marker:** [GlobalObjectKey] compares `value` by `identical()`
/// (NOT `==`), so two `GlobalObjectKey(_AuraRowKey(surface, 'docA'))`
/// calls produce NON-EQUAL keys because each call allocates a fresh
/// `_AuraRowKey` instance. The cache below guarantees
/// `SelectableTaskItemKey.of(surface, 'docA')` returns the SAME logical
/// key across the SelectableTaskItem (which attaches it) and the
/// `_AuraLayer` (which looks it up).
///
/// **Why per-surface scope:** see [SelectableTaskItem]'s docstring —
/// the wide shell's `IndexedStack` keeps multiple surfaces mounted, and
/// a single docId can appear on more than one surface at once (e.g.
/// family-shared sprint tasks). Without surface scoping, both surfaces
/// would attach the same global key → duplicate-key throw.
///
/// **Why bounded to the current selection per surface:** only one row
/// per surface is ever selected at a time, so each surface needs at
/// most one marker alive. Bounding the cache to one entry per surface
/// avoids the unbounded growth a naive `Map<(surface, docId), _AuraRowKey>`
/// would suffer over a long session.
class SelectableTaskItemKey {
  const SelectableTaskItemKey._();

  static final Map<TaskListSurface, _CachedMarker> _cache = {};

  /// Returns the [GlobalObjectKey] for the row in [surface] with
  /// [docId]. Stable across calls for the SAME (surface, docId) pair —
  /// multiple invocations return keys that compare equal via
  /// [GlobalObjectKey]'s identity-based `==`.
  ///
  /// Switching the surface's selection to a different docId evicts the
  /// previous cache entry for that surface (one marker per surface).
  static GlobalObjectKey of(TaskListSurface surface, String docId) {
    final cached = _cache[surface];
    if (cached?.docId != docId) {
      _cache[surface] = _CachedMarker(docId, _AuraRowKey(surface, docId));
    }
    return GlobalObjectKey(_cache[surface]!.marker);
  }
}

/// Internal: one cached `(docId, marker)` pair per surface in
/// [SelectableTaskItemKey._cache]. Top-level so the cache entries are
/// strongly typed without exposing the marker.
class _CachedMarker {
  final String docId;
  final _AuraRowKey marker;
  const _CachedMarker(this.docId, this.marker);
}
