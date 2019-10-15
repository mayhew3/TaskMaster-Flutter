
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/widgets/readonly_task_field.dart';

class DetailScreen extends StatelessWidget {
  final TaskItem taskItem;
  final TaskAdder taskAdder;
  final TaskUpdater taskUpdater;

  const DetailScreen({
    Key key,
    this.taskItem,
    this.taskAdder,
    this.taskUpdater,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(taskItem.name,
                      style: Theme.of(context).textTheme.headline,
                    )
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Checkbox(
                    value: (taskItem.completionDate != null),
                    onChanged: (value) => {},
                  ),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Notes',
              textToShow: taskItem.description,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Edit',
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AddEditScreen(
                  taskUpdater: taskUpdater,
                  taskAdder: taskAdder,
                  taskItem: taskItem,
                );
              },
            ),
          );
        },
      ),
    );
  }

}
