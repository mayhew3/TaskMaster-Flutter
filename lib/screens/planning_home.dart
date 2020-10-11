
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/screens/task_list.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/widgets/plan_task_list.dart';

import '../typedefs.dart';

class PlanningHome extends StatefulWidget {

  final AppState appState;
  final BottomNavigationBarGetter bottomNavigationBarGetter;
  final TaskHelper taskHelper;

  PlanningHome({
    Key key,
    @required this.appState,
    @required this.bottomNavigationBarGetter,
    @required this.taskHelper,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlanningHomeState();

}

class PlanningHomeState extends State<PlanningHome> {

  Sprint activeSprint;

  @override
  void initState() {
    super.initState();
    activeSprint = widget.appState.getActiveSprint();
  }

  void openPlanning(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PlanTaskList(
            appState: widget.appState,
            taskHelper: widget.taskHelper,
            taskListGetter: widget.appState.getAllTasks,
          );
        },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.activeSprint == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('TaskMaster 3000'),
        ),
        body: Center(
          child: FlatButton(
              color: TaskColors.cardColor,
              onPressed: () => openPlanning(context),
              child: Text('Create Sprint')),
        ),
        bottomNavigationBar: widget.bottomNavigationBarGetter(),
      );
    } else {
      return TaskListScreen(
        appState: widget.appState,
        bottomNavigationBarGetter: widget.bottomNavigationBarGetter,
        taskHelper: widget.taskHelper,
        taskListGetter: widget.appState.getTasksForActiveSprint,
      );
    }
  }

}