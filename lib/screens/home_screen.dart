import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/widgets/task_list.dart';
import 'package:taskmaster/keys.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final String title;

  HomeScreen({
    @required this.appState,
    @required this.title,
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
      taskItems: widget.appState.taskItems,
      loading: widget.appState.isLoading,
    );
  }

  Widget buildBody(BuildContext context) {
    if (widget.appState.isAuthenticated()) {
      return buildTaskList(context);
    } else {
      return buildSignInScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildBody(context),
    );
  }

}