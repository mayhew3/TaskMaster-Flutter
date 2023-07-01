
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/typedefs.dart';

enum CheckState { inactive, pending, checked }

class DelayedCheckbox extends StatelessWidget {

  final CheckCycleWaiter checkCycleWaiter;
  final CheckState initialState;
  final Color? checkedColor;
  final IconData? inactiveIcon;
  final String taskName;

  const DelayedCheckbox({
    Key? key,
    required this.checkCycleWaiter,
    required this.initialState,
    this.checkedColor,
    this.inactiveIcon,
    required this.taskName,
  }) : super(key: key);

  Color? getColor(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Map<CheckState, Color> colorMap = {
      CheckState.inactive: Color.fromARGB(0, 0, 0, 0),
      CheckState.pending: TaskColors.pendingCheckbox,
      CheckState.checked: checkedColor ?? themeData.toggleableActiveColor,
    };
    return colorMap[initialState];
  }

  IconData? getInnerIcon() {
    Map<CheckState, IconData?> iconMap = {
      CheckState.inactive: inactiveIcon,
      CheckState.pending: Icons.more_horiz,
      CheckState.checked: Icons.done_outline,
    };
    return iconMap[initialState];
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
                child: Icon(getInnerIcon(), size: 24.0),
              ),
            ),
          )
      );

  }

}
