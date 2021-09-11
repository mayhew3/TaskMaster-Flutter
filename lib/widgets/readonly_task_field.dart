
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReadOnlyTaskField extends StatelessWidget {
  final String headerName;
  final String? textToShow;
  final String? optionalSubText;
  final Color? optionalTextColor;
  final Color? optionalBackgroundColor;
  final Color? optionalOutlineColor;
  final bool hasShadow;

  const ReadOnlyTaskField({
    Key? key,
    required this.textToShow,
    required this.headerName,
    this.optionalSubText,
    this.optionalTextColor,
    this.optionalBackgroundColor,
    this.optionalOutlineColor,
    this.hasShadow = true,
  }) : super(key: key);

  Color getBackgroundColor() {
    return this.optionalBackgroundColor ?? Color.fromRGBO(76, 77, 105, 1.0);
  }

  ShapeBorder _getBorder() {
    if (optionalOutlineColor != null) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
        side: BorderSide(
          color: optionalOutlineColor!,
          width: 1.0,
        ),
      );
    } else {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      );
    }
  }

  List<Widget> _getDateTexts() {
    List<Widget> texts = [];
    texts.add(Text(textToShow ?? '',
        style: TextStyle(
            color: optionalTextColor ?? Colors.white,
            fontSize: 16.0
        )));

    if (optionalSubText != null) {
      texts.add(Text(optionalSubText ?? '',
          style: TextStyle(
              color: optionalTextColor ?? Colors.white,
              fontSize: 12.0
          )));
    }

    return texts;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: textToShow != null && textToShow!.isNotEmpty,
      child: Card(
        shadowColor: hasShadow ? Colors.black : Color.fromRGBO(0, 0, 0, 0.0),
        elevation: 3.0,
        shape: _getBorder(),
        color: getBackgroundColor(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 70.0,
                child: Text(headerName,
                  style: Theme.of(context).textTheme.caption,),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getDateTexts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
