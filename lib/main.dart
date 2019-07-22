import 'package:flutter/material.dart';

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

Future<TaskList> fetchTaskData() async =>
    Future.delayed(Duration(seconds: 5), () {
      TaskList _tasks = TaskList();
      _tasks.add(name: "Build a glove");
      _tasks.add(name: "Eat a doughnut");
      _tasks.add(name: "More butter");
      return _tasks;
    });

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.futureTasks});

  Future<TaskList> futureTasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<TaskList>(
          future: futureTasks,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              TaskList taskList = snapshot.data;
              return buildTaskView(taskList: taskList, context: context);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          }
      ),
    );
  }
}

class TaskList {
  final List<TaskItem> tasks = List();

  void add({name: String}) {
    TaskItem taskItem = TaskItem._(name: name);
    tasks.add(taskItem);
  }
}

class TaskItem {
  final String name;

  TaskItem._({this.name});
}