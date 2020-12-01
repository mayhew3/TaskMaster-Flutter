
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/task_colors.dart';

class TaskMainMenu extends Drawer {

  final AppState appState;

  TaskMainMenu({
    Key key,
    @required this.appState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Actions'),
              decoration: BoxDecoration(
                  color: TaskColors.pendingBackground
              ),
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () async {
                await appState.notificationScheduler.cancelAllNotifications();
                await appState.auth.handleSignOut();
                appState.navHelper.goToSignInScreen();
              },
            )
          ],
        )
    );
  }

}