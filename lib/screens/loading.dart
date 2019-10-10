import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/typedefs.dart';

class LoadingScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;
  final LoadListStarter loadListStarter;

  LoadingScreen({
    Key key,
    @required this.appState,
    @required this.navHelper,
    @required this.loadListStarter,
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
    maybeKickOffSignIn(context);
  }

  void maybeKickOffSignIn(BuildContext context) {
    if (!widget.appState.isAuthenticated()) {
      widget.navHelper.updateContext(context);
      widget.appState.auth.addGoogleListener().then((value) {
        if (value == null) {
          widget.navHelper.goToSignInScreen();
        } else {
          widget.loadListStarter();
        }
        widget.appState.updateNotificationScheduler(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appState.title),
      ),
      body: Container(
        child: Center(
            child: CircularProgressIndicator(
              key: TaskMasterKeys.tasksLoading,
            )
        ),
      ),
    );
  }

}