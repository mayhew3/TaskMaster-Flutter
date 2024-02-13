
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';

class ReadOnlyTaskFieldSmall extends StatelessWidget {
  final String headerName;
  final String textToShow;

  const ReadOnlyTaskFieldSmall({
    Key? key,
    required this.textToShow,
    required this.headerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: textToShow.isNotEmpty,
      child: Expanded(
        child: Card(
          elevation: 3.0,
          color: TaskColors.cardColor,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: <Widget>[
                Text(headerName,
                  style: Theme.of(context).textTheme.bodySmall,),
                Text(textToShow,
                  style: Theme.of(context).textTheme.titleMedium,),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
