import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';

/// Compact summary of a task's start/target/urgent/due dates. Renders a
/// chip per set date (with the date type's accent color) and a chevron;
/// tapping opens a date popup. Empty state shows "No dates set".
class DateSummaryRow extends StatelessWidget {
  /// Map of date type → currently-set date (or null if not set). Order
  /// follows [TaskDateTypes.allTypes].
  final Map<TaskDateType, DateTime?> dates;

  /// Called when the user taps the row to open the editor popup.
  final VoidCallback onTap;

  const DateSummaryRow({
    required this.dates,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final setEntries = TaskDateTypes.allTypes
        .where((t) => dates[t] != null)
        .toList(growable: false);
    final total = TaskDateTypes.allTypes.length;

    return Material(
      color: TaskColors.fieldSurface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TaskColors.fieldBorder, width: 1),
          ),
          child: Row(
            children: [
              if (setEntries.isEmpty)
                Expanded(
                  child: Text(
                    'No dates set',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: setEntries
                        .map((t) => _DatePill(type: t, date: dates[t]!))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${setEntries.length}/$total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.white.withValues(alpha: 0.50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final TaskDateType type;
  final DateTime date;

  const _DatePill({required this.type, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: type.textColor.withValues(alpha: 0.12),
        border: Border.all(
          color: type.textColor.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: type.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            type.label.toUpperCase(),
            style: TextStyle(
              color: type.textColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _shortDate(date),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
}
