import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/sync_status_provider.dart';

/// AppBar-embedded indicator that reflects offline / sync-failed / syncing state
/// without shifting page layout.
///
/// Priority (highest wins): offline > sync error > syncing > idle.
/// - **Idle + online:** renders nothing.
/// - **Syncing:** subtle animated three-dot indicator with one dot cycling
///   at full opacity while the others stay at 30%.
/// - **Sync error:** red pill with "Sync failed".
/// - **Offline:** orange pill with "Offline".
///
/// Replaces the old OfflineBanner which was rendered in the main scaffold
/// Column and shifted all screen content down when visible (TM-340).
class ConnectionStatusIndicator extends ConsumerStatefulWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  ConsumerState<ConnectionStatusIndicator> createState() =>
      _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState
    extends ConsumerState<ConnectionStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final syncStatus = ref.watch(syncStatusControllerProvider);

    final online = connectivityAsync.valueOrNull ?? true;

    // Priority: offline > error > syncing > idle
    if (!online) {
      _stopAnimation();
      return const _StatusPill(
        color: Color(0xFFE65100), // Colors.orange.shade700
        icon: Icons.cloud_off,
        label: 'Offline',
      );
    }
    if (syncStatus == SyncStatus.error) {
      _stopAnimation();
      return const _StatusPill(
        color: Color(0xFFC62828), // Colors.red.shade700
        icon: Icons.error_outline,
        label: 'Sync failed',
      );
    }
    if (syncStatus == SyncStatus.syncing) {
      _startAnimation();
      return _SyncingEllipsis(controller: _controller);
    }

    _stopAnimation();
    return const SizedBox.shrink();
  }

  void _startAnimation() {
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _stopAnimation() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncingEllipsis extends StatelessWidget {
  const _SyncingEllipsis({required this.controller});

  final AnimationController controller;

  static const double _dotSize = 6;
  static const double _dotGap = 3;
  static const int _dotCount = 3;

  @override
  Widget build(BuildContext context) {
    final foreground =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onPrimary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: _dotCount * _dotSize + (_dotCount - 1) * _dotGap,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final active = (controller.value * _dotCount).floor() % _dotCount;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_dotCount, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i == _dotCount - 1 ? 0 : _dotGap),
                    child: Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: i == active ? 1.0 : 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
