
import 'package:flutter/material.dart';

class HeadingItem extends StatelessWidget {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(128, 128, 128, 0.2),
      padding: EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
        left: 16.0,
        right: 16.0,
      ),
      child:  Text(
        heading.toUpperCase(),
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}