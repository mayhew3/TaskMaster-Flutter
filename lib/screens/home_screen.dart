import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/task_list.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/screens/detail_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final String title;
  final TaskAdder taskAdder;
  final TaskCompleter taskCompleter;
  final TaskUpdater taskUpdater;

  HomeScreen({
    @required this.appState,
    @required this.title,
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
    widget.appState.auth.addGoogleListener();
  }

  Widget buildSignInScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: widget.appState.auth.handleSignIn,
          ),
        ],
      ),
    );
  }

  Widget buildTaskList(BuildContext context) {
    return TaskListWidget(
      appState: widget.appState,
      taskCompleter: widget.taskCompleter,
      taskUpdater: widget.taskUpdater,
    );
  }

  Widget buildBody(BuildContext context) {
    if (widget.appState.isAuthenticated()) {
      return buildTaskList(context);
    } else {
      return buildSignInScreen(context);
    }
  }

  Widget buildActionButton(BuildContext context) {
    if (widget.appState.isLoading) {
      return null;
    } else {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(taskAdder: widget.taskAdder)),
          );
        },
        child: Icon(Icons.add),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildBody(context),
      floatingActionButton: buildActionButton(context),
    );
  }

}