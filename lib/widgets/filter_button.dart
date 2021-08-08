import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final ValueGetter<bool> scheduledGetter;
  final ValueGetter<bool> completedGetter;

  final Function toggleScheduled;
  final Function toggleCompleted;

  const FilterButton({Key key,
    required this.scheduledGetter,
    required this.completedGetter,
    required this.toggleScheduled,
    required this.toggleCompleted
  }) : super(key: key);

  void toggleFilter(String key) {
    if (key == 'scheduled') {
      toggleScheduled();
    } else if (key == 'completed') {
      toggleCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: toggleFilter,
      itemBuilder: (context) => [
        CheckedPopupMenuItem<String>(
          checked: scheduledGetter(),
          value: 'scheduled',
          child: Text("Show Scheduled"),
        ),
        CheckedPopupMenuItem<String>(
          checked: completedGetter(),
          value: 'completed',
          child: Text("Show Completed"),
        ),
      ],
    );
  }
}