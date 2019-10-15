
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReadOnlyTaskField extends StatelessWidget {
  final String textToShow;

  const ReadOnlyTaskField({
    Key key,
    this.textToShow,
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
                  child: Text('Notes',
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
