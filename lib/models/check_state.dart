/// State of a checkbox in the task completion flow
enum CheckState {
  inactive,  // Task not completed
  pending,   // Task completion in progress
  checked,   // Task completed
  skipped,   // Recurring task instance skipped (stays in active list)
}

/// Callback for cycling through check states
typedef CheckCycleWaiter = CheckState? Function(CheckState startingState);
