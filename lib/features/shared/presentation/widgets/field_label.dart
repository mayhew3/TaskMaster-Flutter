import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Uppercase form-field label used by the redesigned edit-task screen.
/// Renders [label] in caps with optional [hint] (e.g. "3/5", "tap to edit")
/// and an optional trailing [action] widget aligned to the row's far end.
class FieldLabel extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget? action;

  const FieldLabel(this.label, {this.hint, this.action, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.5,
              color: TaskColors.textFaint,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Text(
              hint!,
              style: TextStyle(
                fontSize: 10.5,
                color: TaskColors.editorLabelHint,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}
