
class VisibilityFilter {
  final bool showScheduled;
  final bool showCompleted;
  final bool showActiveSprint;

  const VisibilityFilter({
    this.showScheduled = false,
    this.showCompleted = false,
    this.showActiveSprint = false
  });

  @override
  int get hashCode =>
      showScheduled.hashCode ^
      showCompleted.hashCode ^
      showActiveSprint.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VisibilityFilter &&
              showScheduled == other.showScheduled &&
              showCompleted == other.showCompleted &&
              showActiveSprint == other.showActiveSprint;

  @override
  String toString() {
    return 'VisibilityFilter{showScheduled: $showScheduled, showCompleted: $showCompleted, showActiveSprint: $showActiveSprint}';
  }
}