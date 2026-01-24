/// State of a checkbox in the task completion flow
enum CheckState {
  inactive,  // Task not completed
  pending,   // Task completion in progress
  checked    // Task completed
}

/// Callback for cycling through check states
typedef CheckCycleWaiter = CheckState? Function(CheckState startingState);
