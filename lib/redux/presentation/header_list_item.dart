
import 'package:flutter/material.dart';

class HeadingItem extends StatelessWidget {
  final String heading;

  const HeadingItem(this.heading, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
      padding: EdgeInsets.only(
        top: 0.0,
        bottom: 0.0,
        left: 16.0,
        right: 16.0,
      ),
      child:  Text(
        heading.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}