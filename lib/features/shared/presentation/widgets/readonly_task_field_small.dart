
import 'package:flutter/material.dart';

class ReadOnlyTaskFieldSmall extends StatelessWidget {
  final String headerName;
  final String textToShow;

  const ReadOnlyTaskFieldSmall({
    super.key,
    required this.textToShow,
    required this.headerName,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: textToShow.isNotEmpty,
      child: Expanded(
        child: Card(
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
