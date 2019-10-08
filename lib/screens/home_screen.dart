import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/typedefs.dart';
import 'dart:typed_data';
import 'package:taskmaster/widgets/task_list.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/screens/detail_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmaster/widgets/second_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final String title;
  final TaskAdder taskAdder;
  final TaskUpdater taskUpdater;

  HomeScreen({
    @required this.appState,
    @required this.title,
    @required this.taskAdder,
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
    flutterLocals();
  }

  flutterLocals() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'plain title',
        'plain body',
        platformChannelSpecifics,
        payload: 'item x');
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> _scheduleNotification() async {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: 'item x',
        androidAllowWhileIdle: true);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );
            },
          )
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.notification_important),
            onPressed: () => _scheduleNotification(),
          ),
        ],
      ),
      body: buildBody(context),
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