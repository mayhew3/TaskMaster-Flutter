import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/nav_helper.dart';

class LoadingScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;
  final String msg;

  LoadingScreen({
    Key key,
    @required this.appState,
    @required this.navHelper,
    @required this.msg,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadingScreenState();
  }
}

class LoadingScreenState extends State<LoadingScreen> {

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
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CircularProgressIndicator(
                key: TaskMasterKeys.tasksLoading,
              ),
              Text(widget.msg),
            ],
          )
        ),
      ),
    );
  }

}