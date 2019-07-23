import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMaster',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildFutureBuilder(futureTasks),
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