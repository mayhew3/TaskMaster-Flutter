import 'package:flutter/material.dart';

class CheckboxInPopupMenu extends StatelessWidget {
  final ValueGetter<bool> scheduledGetter;
  final ValueGetter<bool> completedGetter;

  final ValueSetter<bool> scheduledSetter;
  final ValueSetter<bool> completedSetter;

  const CheckboxInPopupMenu({Key key,
    this.scheduledGetter,
    this.completedGetter,
    this.scheduledSetter,
    this.completedSetter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.filter_list),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          checked: true,
          child: Text("Show Scheduled"),
        ),
        CheckedPopupMenuItem(
          child: Text("Show Completed"),
        ),
      ],
    );
  }
}