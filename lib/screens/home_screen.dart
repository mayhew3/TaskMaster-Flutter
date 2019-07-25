import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/widgets/task_list.dart';

final homeScreen = const Key('__homeScreen__');

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final String title;

  HomeScreen({
    @required this.appState,
    @required this.title,
    Key key,
  }) : super(key: homeScreen);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: TaskListWidget(
          taskItems: widget.appState.taskItems,
          loading: widget.appState.isLoading,
      )
    );
  }

}