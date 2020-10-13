
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/typedefs.dart';

enum CheckState { inactive, pending, checked }

class DelayedCheckbox extends StatefulWidget {

  final CheckCycleWaiter checkCycleWaiter;
  final CheckState initialState;
  final Color checkedColor;
  final IconData inactiveIcon;
  final MyStateSetter stateSetter;

  const DelayedCheckbox({
    Key key,
    this.checkCycleWaiter,
    this.initialState,
    this.checkedColor,
    this.inactiveIcon,
    @required this.stateSetter,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DelayedCheckboxState();
}

class DelayedCheckboxState extends State<DelayedCheckbox> {

  CheckState currentState;

  @override
  void initState() {
    super.initState();
    currentState = widget.initialState;
  }

  void handleClick() {
    CheckState originalState = currentState;
    widget.stateSetter(() {
      currentState = CheckState.pending;
    });

    widget.checkCycleWaiter(originalState).then((resultingState) {
      widget.stateSetter(() {
        currentState = resultingState;
      });
    });
  }

  Color getColor(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Map<CheckState, Color> colorMap = {
      CheckState.inactive: Color.fromARGB(0, 0, 0, 0),
      CheckState.pending: TaskColors.pendingCheckbox,
      CheckState.checked: widget.checkedColor ?? themeData.toggleableActiveColor,
    };
    return colorMap[currentState];
  }

  IconData getInnerIcon() {
    Map<CheckState, IconData> iconMap = {
      CheckState.inactive: widget.inactiveIcon,
      CheckState.pending: Icons.more_horiz,
      CheckState.checked: Icons.done_outline,
    };
    return iconMap[currentState];
  }

  @override
  Widget build(BuildContext context) {

    return
    GestureDetector(
      onTap: handleClick,
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