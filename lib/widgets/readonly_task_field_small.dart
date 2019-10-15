
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReadOnlyTaskFieldSmall extends StatelessWidget {
  final String headerName;
  final String textToShow;

  const ReadOnlyTaskFieldSmall({
    Key key,
    this.textToShow,
    this.headerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: textToShow.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(headerName,
                style: Theme.of(context).textTheme.caption,),
            Text(textToShow,
              style: Theme.of(context).textTheme.subhead,),
          ],
        ),
      ),
    );
  }

}
