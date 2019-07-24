import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ]
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMaster',
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'TaskMaster', futureTasks: fetchTaskData()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.futureTasks}) : super(key: key);

  final String title;
  final Future<TaskList> futureTasks;

  @override
  _MyHomePageState createState() => _MyHomePageState(futureTasks: futureTasks);
}

ListView buildTaskView({taskList: TaskList, context}) {
  final Iterable<TaskItem> taskIterable = taskList.tasks;
  final Iterable<ListTile> tiles = taskIterable.map<ListTile>(
          (TaskItem taskItem) {
        return ListTile(
          title: Text(
              taskItem.name,
              style: const TextStyle(fontSize: 18.0)
          ),
        );
      }
  );

  final List<Widget> divided = ListTile.divideTiles(
    context: context,
    tiles: tiles,
  ).toList();

  return ListView(children: divided);
}

Future<TaskList> fetchTaskData() async {
  final response = await http.get("https://taskmaster-general.herokuapp.com/api/tasks");

  if (response.statusCode == 200) {
    try {
      List list = json.decode(response.body);
      return TaskList.fromJson(list);
    } catch(exception, stackTrace) {
      print(exception);
      print(stackTrace);
      throw Exception('Error retrieving task data from the server. Talk to Mayhew.');
    }
  } else {
    throw Exception('Failed to load task list. Talk to Mayhew.');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.futureTasks});

  Future<TaskList> futureTasks;

  // AUTH CODE

  GoogleSignInAccount _currentUser;

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error, stackTrace) {
      print("Login Errored!");
      print(error);
      print(stackTrace);
    }
  }

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        print("Login failed!");
      } else {
        print("Login success!");
      }
    });
    _googleSignIn.signInSilently();
  }

  Widget buildBody(BuildContext context) {
    if (_currentUser != null) {
      return _buildFutureBuilder(futureTasks);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text("You are not currently signed in."),
            RaisedButton(
              child: const Text('SIGN IN'),
              onPressed: _handleSignIn,
            ),
          ],
        ),
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
    );
  }
}

FutureBuilder<TaskList> _buildFutureBuilder(Future<TaskList> futureTasks) {
  return FutureBuilder<TaskList>(
      future: futureTasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          TaskList taskList = snapshot.data;
          return buildTaskView(taskList: taskList, context: context);
        } else if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error}"),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      }
  );
}

class TaskList {
  final List<TaskItem> tasks = List();

  TaskList();

  factory TaskList.fromJson(List json) {
    TaskList taskList = TaskList();
    json.forEach((jsonObj) {
      TaskItem taskItem = TaskItem.fromJson(jsonObj);
      taskList.tasks.add(taskItem);
    });
    return taskList;
  }

  void add({name: String}) {
    TaskItem taskItem = TaskItem(name: name);
    tasks.add(taskItem);
  }
}

class TaskItem {
  final int id;
  final String name;
  final int personId;
  final DateTime dateAdded;
  final DateTime dateCompleted;

  TaskItem({this.id, this.personId, this.dateAdded, this.dateCompleted, this.name});

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      name: json['name'],
      personId: json['person_id'],
      dateAdded: DateTime.parse(json['date_added']),
      dateCompleted: json['date_completed'] == null ? null : DateTime.parse(json['date_completed'])
    );
  }
}