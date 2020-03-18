
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';

class PendingCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          color: TaskColors.pendingCheckbox,
        ),
      ),
    );
  }

}