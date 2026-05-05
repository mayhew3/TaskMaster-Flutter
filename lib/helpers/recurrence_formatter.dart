/// Formats a TaskItem's recurrence rule as a human-readable string for the
/// expanded card detail row (e.g. "Every 2 weeks (after completion)").
class RecurrenceFormatter {
  RecurrenceFormatter._();

  /// Returns null when the rule is incomplete or invalid; the card should
  /// hide the row in those cases. Non-positive intervals are treated as
  /// invalid — "Every 0 weeks" is meaningless and the rest of the codebase
  /// assumes a positive interval.
  static String? format({
    int? recurNumber,
    String? recurUnit,
    bool? recurWait,
  }) {
    if (recurNumber == null ||
        recurNumber <= 0 ||
        recurUnit == null ||
        recurUnit.isEmpty) {
      return null;
    }

    final unit = _singularUnit(recurUnit);
    if (unit == null) return null;

    final body = recurNumber == 1
        ? 'Every $unit'
        : 'Every $recurNumber ${unit}s';
    return recurWait == true ? '$body (after completion)' : body;
  }

  static String? _singularUnit(String recurUnit) {
    switch (recurUnit.toLowerCase()) {
      case 'day':
      case 'days':
        return 'day';
      case 'week':
      case 'weeks':
        return 'week';
      case 'month':
      case 'months':
        return 'month';
      case 'year':
      case 'years':
        return 'year';
    }
    return null;
  }
}
