
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/check_state.dart';

class DelayedCheckbox extends StatelessWidget {

  final CheckCycleWaiter checkCycleWaiter;
  final CheckState initialState;
  final Color? checkedColor;
  final IconData? inactiveIcon;
  final Color? inactiveIconColor;
  final String taskName;

  const DelayedCheckbox({
    super.key,
    required this.checkCycleWaiter,
    required this.initialState,
    this.checkedColor,
    this.inactiveIcon,
    this.inactiveIconColor,
    required this.taskName,
  });

  Color? getColor(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Map<CheckState, Color> colorMap = {
      CheckState.inactive: const Color.fromARGB(0, 0, 0, 0),
      CheckState.pending: TaskColors.pendingCheckbox,
      CheckState.checked: checkedColor ?? themeData.checkboxTheme.fillColor!.resolve({WidgetState.selected}) ?? TaskColors.cardColor,
      CheckState.skipped: Colors.red.withValues(alpha: 0.3),
    };
    return colorMap[initialState];
  }

  IconData? getInnerIcon() {
    Map<CheckState, IconData?> iconMap = {
      CheckState.inactive: inactiveIcon,
      CheckState.pending: Icons.more_horiz,
      CheckState.checked: Icons.done_outline,
      CheckState.skipped: Icons.close,
    };
    return iconMap[initialState];
  }

  Color? getIconColor() {
    if (initialState == CheckState.inactive) return inactiveIconColor;
    return null;
  }

  @override
  Widget build(BuildContext context) {

    return
      GestureDetector(
          onTap: () => checkCycleWaiter(initialState),
          child: Container(
            padding: EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
            ),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.white70,
                    width: 2.0,
                  ),
                ),
                color: getColor(context),
                child: Icon(getInnerIcon(), size: 24.0, color: getIconColor()),
              ),
            ),
          )
      );

  }

}
