
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/typedefs.dart';

enum CheckState { inactive, pending, checked }

class MyCheckbox extends StatefulWidget {

  final CheckCycleWaiter checkCycleWaiter;
  final CheckState initialState;

  const MyCheckbox({
    Key key,
    this.checkCycleWaiter,
    this.initialState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyCheckboxState();
}

class MyCheckboxState extends State<MyCheckbox> {

  CheckState currentState;

  @override
  void initState() {
    super.initState();
    currentState = widget.initialState;
  }

  void handleClick() {
    CheckState originalState = currentState;
    setState(() {
      currentState = CheckState.pending;
    });

    widget.checkCycleWaiter(originalState).then((resultingState) {
      setState(() {
        currentState = resultingState;
      });
    });
  }

  Color getColor(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Map<CheckState, Color> colorMap = {
      CheckState.inactive: themeData.unselectedWidgetColor,
      CheckState.pending: TaskColors.pendingCheckbox,
      CheckState.checked: themeData.toggleableActiveColor,
    };
    return colorMap[currentState];
  }

  IconData getInnerIcon() {
    Map<CheckState, IconData> iconMap = {
      CheckState.inactive: null,
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
            top: 3.0,
            bottom: 3.0,
            right: 3.0,
            left: 3.0,
          ),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                /*side: BorderSide(
                            color: checkOutline,
                            width: 2.0,
                          ),*/
              ),
              color: getColor(context),
              child: Icon(getInnerIcon(), size: 24.0),
            ),
          ),
        )
    );

  }

}