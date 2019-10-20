
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReadOnlyTaskField extends StatelessWidget {
  final String headerName;
  final String textToShow;
  final Color optionalBackgroundColor;

  const ReadOnlyTaskField({
    Key key,
    this.textToShow,
    this.headerName,
    this.optionalBackgroundColor,
  }) : super(key: key);

  Color getBackgroundColor() {
    return this.optionalBackgroundColor ?? Color.fromRGBO(76, 77, 105, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: textToShow != null && textToShow.isNotEmpty,
      child: Card(
        elevation: 3.0,
        color: getBackgroundColor(),
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
              Text(textToShow ?? '',
                style: Theme.of(context).textTheme.subhead,),
            ],
          ),
        ),
      ),
    );
  }

}
