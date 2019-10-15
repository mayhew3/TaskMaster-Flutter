
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReadOnlyTaskField extends StatelessWidget {
  final String headerName;
  final String textToShow;

  const ReadOnlyTaskField({
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
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 80.0,
                  child: Text(headerName,
                    style: Theme.of(context).textTheme.caption,),
                ),
              ],
            ),
            Text(textToShow,
              style: Theme.of(context).textTheme.subhead,),
          ],
        ),
      ),
    );
  }

}
