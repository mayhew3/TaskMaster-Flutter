
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';

class DetailScreen extends StatelessWidget {
  final TaskItem taskItem;

  const DetailScreen({
    Key key,
    @required this.taskItem
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                Text(
                  taskItem.name,
                  style: Theme.of(context).textTheme.headline,
                ),
                Text(
                  taskItem.dateAdded.toString(),
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            )
        )
    );
  }

}