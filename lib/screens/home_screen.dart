import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/task_list.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/nav_helper.dart';

import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;
  final TaskAdder taskAdder;
  final TaskCompleter taskCompleter;
  final TaskUpdater taskUpdater;

  HomeScreen({
    @required this.appState,
    @required this.navHelper,
    @required this.taskAdder,
    @required this.taskCompleter,
    @required this.taskUpdater,
    Key key,
  }) : super(key: TaskMasterKeys.homeScreen);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    widget.navHelper.updateContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appState.title),
      ),
      body: TaskListWidget(
        appState: widget.appState,
        taskCompleter: widget.taskCompleter,
        taskUpdater: widget.taskUpdater,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(taskAdder: widget.taskAdder)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

}