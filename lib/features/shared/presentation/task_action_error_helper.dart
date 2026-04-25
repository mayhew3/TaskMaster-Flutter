import 'package:flutter/material.dart';

import '../../../core/services/task_completion_service.dart';

/// Surfaces errors from CompleteTask / SkipTask actions in a SnackBar.
/// Pass the BuildContext that owns the action's UI; checks `mounted` before
/// showing.
void showTaskActionError(BuildContext context, Object error) {
  if (!context.mounted) return;
  final String message;
  if (error is RecurrenceNotFoundException) {
    message =
        "Couldn't update task — recurrence data isn't loaded yet. Pull to refresh and try again.";
  } else {
    // Log the underlying error for diagnostics; show a generic message to
    // avoid leaking raw exception text (e.g. "Instance of ...") to users.
    debugPrint('Error updating task: $error');
    message = "Couldn't update task. Please try again.";
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
