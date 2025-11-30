import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/task_providers.dart';
import '../../sprints/providers/sprint_providers.dart';

/// Riverpod version of RefreshButton
///
/// Invalidates task and sprint providers to trigger a refresh from Firestore
class RefreshButton extends ConsumerWidget {
  const RefreshButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        // Invalidate providers to trigger refresh
        // Note: Invalidating tasksProvider will also invalidate tasksWithRecurrencesProvider
        ref.invalidate(tasksProvider);
        ref.invalidate(taskRecurrencesProvider);
        ref.invalidate(sprintsProvider);
      },
    );
  }
}
