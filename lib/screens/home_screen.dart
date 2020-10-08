import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/app_tab.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/widgets/stats_counter.dart';
import 'package:taskmaster/screens/task_list.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;
  final TaskHelper taskHelper;

  HomeScreen({
    @required this.appState,
    @required this.navHelper,
    @required this.taskHelper,
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
          label: tab == AppTab.stats
              ? 'Stats'
              : 'Tasks',
        );
      }).toList(),
    );
  }

  Widget getSelectedTab() {
    if (activeTab == AppTab.tasks) {
      return TaskListScreen(
        appState: widget.appState,
        bottomNavigationBar: getBottomNavigationBar(),
        taskHelper: widget.taskHelper,
      );
    } else {
      return StatsCounter(
        appState: widget.appState,
        numActive: widget.appState.taskItems.where((taskItem) => taskItem.completionDate.value == null).length,
        numCompleted: widget.appState.taskItems.where((taskItem) => taskItem.completionDate.value != null).length,
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