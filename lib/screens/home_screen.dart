import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/app_tab.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/stats_counter.dart';
import 'package:taskmaster/screens/task_list.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;
  final TaskAdder taskAdder;
  final TaskCompleter taskCompleter;
  final TaskUpdater taskUpdater;
  final TaskListReloader taskListReloader;
  final TaskDeleter taskDeleter;

  HomeScreen({
    @required this.appState,
    @required this.navHelper,
    @required this.taskAdder,
    @required this.taskCompleter,
    @required this.taskUpdater,
    @required this.taskListReloader,
    @required this.taskDeleter,
    Key key,
  }) : super(key: TaskMasterKeys.homeScreen);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  AppTab activeTab = AppTab.tasks;

  @override
  void initState() {
    super.initState();
    widget.navHelper.updateContext(context);
  }

  BottomNavigationBar getBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) {
        _updateTab(AppTab.values[index]);
      },
      items: AppTab.values.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(
            tab == AppTab.tasks ? Icons.list : Icons.show_chart,
          ),
          title: Text(
            tab == AppTab.stats
                ? 'Stats'
                : 'Tasks',
          ),
        );
      }).toList(),
    );
  }

  Widget getSelectedTab() {
    if (activeTab == AppTab.tasks) {
      return TaskListScreen(
        appState: widget.appState,
        taskAdder: widget.taskAdder,
        taskCompleter: widget.taskCompleter,
        taskUpdater: widget.taskUpdater,
        taskDeleter: widget.taskDeleter,
        taskListReloader: widget.taskListReloader,
        bottomNavigationBar: getBottomNavigationBar(),
      );
    } else {
      return StatsCounter(
        appState: widget.appState,
        numActive: widget.appState.taskItems.where((task) => task.completionDate == null).length,
        numCompleted: widget.appState.taskItems.where((task) => task.completionDate != null).length,
        bottomNavigationBar: getBottomNavigationBar(),
      );
    }
  }

  _updateTab(AppTab tab) {
    setState(() {
      activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getSelectedTab();
  }

}