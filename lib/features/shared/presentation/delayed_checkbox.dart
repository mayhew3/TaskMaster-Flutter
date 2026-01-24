
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/check_state.dart';

class DelayedCheckbox extends StatefulWidget {

  final CheckCycleWaiter checkCycleWaiter;
  final CheckState initialState;
  final Color? checkedColor;
  final IconData? inactiveIcon;
  final String taskName;

  const DelayedCheckbox({
    super.key,
    required this.checkCycleWaiter,
    required this.initialState,
    this.checkedColor,
    this.inactiveIcon,
    required this.taskName,
  });

  @override
  State<DelayedCheckbox> createState() => _DelayedCheckboxState();
}

class _DelayedCheckboxState extends State<DelayedCheckbox> {
  late CheckState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  @override
  void didUpdateWidget(DelayedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when parent provides new state
    // This handles when the task is completed/uncompleted from Firestore
    if (widget.initialState != oldWidget.initialState) {
      _currentState = widget.initialState;
    }
  }

  Color? getColor(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final checkedColor = widget.checkedColor ??
        themeData.checkboxTheme.fillColor?.resolve({WidgetState.selected}) ??
        TaskColors.cardColor;
    Map<CheckState, Color> colorMap = {
      CheckState.inactive: Color.fromARGB(0, 0, 0, 0),
      CheckState.pending: TaskColors.pendingCheckbox,
      CheckState.checked: checkedColor,
    };
    return colorMap[_currentState];
  }

  IconData? getInnerIcon() {
    Map<CheckState, IconData?> iconMap = {
      CheckState.inactive: widget.inactiveIcon,
      CheckState.pending: Icons.more_horiz,
      CheckState.checked: Icons.done_outline,
    };
    return iconMap[_currentState];
  }

  void _onTap() {
    // Don't process taps while already pending
    if (_currentState == CheckState.pending) {
      return;
    }

    // Immediately show pending state (TM-323)
    setState(() {
      _currentState = CheckState.pending;
    });

    // Trigger the parent callback
    widget.checkCycleWaiter(widget.initialState);
  }

  @override
  Widget build(BuildContext context) {

    return
      GestureDetector(
          onTap: _onTap,
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
