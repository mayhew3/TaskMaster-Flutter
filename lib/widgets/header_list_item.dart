
import 'package:flutter/material.dart';

class HeadingItem extends StatelessWidget {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        heading,
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }
}