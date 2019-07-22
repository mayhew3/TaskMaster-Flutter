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
      home: MyHomePage(title: 'TaskMaster'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TaskItem> _tasks = List();

  @override
  Widget build(BuildContext context) {
    _tasks.add(TaskItem._(name: "Build a glove"));
    _tasks.add(TaskItem._(name: "Eat a doughnut"));
    _tasks.add(TaskItem._(name: "More butter"));
    final Iterable<ListTile> tiles = _tasks.map(
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(children: divided),
    );
  }
}

class TaskItem {
  final String name;

  TaskItem._({this.name});
}