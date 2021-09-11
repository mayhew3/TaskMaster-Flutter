import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/screens/planning_home.dart';
import 'package:taskmaster/screens/stats_counter.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/screens/task_list.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;
  final TaskHelper taskHelper;

  HomeScreen({
    required this.appState,
    required this.navHelper,
    required this.taskHelper,
    Key? key,
  }) : super(key: TaskMasterKeys.homeScreen);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  late TopNavItem activeTab;
  List<TopNavItem> navItems = [];

  @override
  void initState() {
    super.initState();

    var planNav = new TopNavItem(
        label: 'Plan',
        icon: Icons.assignment,
        widget: PlanningHome(
          appState: widget.appState,
          taskHelper: widget.taskHelper,
          bottomNavigationBarGetter: getBottomNavigationBar,
        ));
    var taskNav = new TopNavItem(
        label: 'Tasks',
        icon: Icons.list,
        widget: TaskListScreen(
          title: 'All Tasks',
          appState: widget.appState,
          bottomNavigationBarGetter: getBottomNavigationBar,
          taskListGetter: widget.appState.getAllTasks,
          taskHelper: widget.taskHelper,
        ));
    var statsNav = new TopNavItem(
        label: 'Stats',
        icon: Icons.show_chart,
        widget: StatsCounter(
          appState: widget.appState,
          numActive: widget.appState.taskItems.where((taskItem) => taskItem.completionDate.value == null).length,
          numCompleted: widget.appState.taskItems.where((taskItem) => taskItem.completionDate.value != null).length,
          bottomNavigationBarGetter: getBottomNavigationBar,
        ));

    navItems.add(planNav);
    navItems.add(taskNav);
    navItems.add(statsNav);

    activeTab = planNav;

    widget.navHelper.updateContext(context);
  }

  BottomNavigationBar getBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: navItems.indexOf(activeTab),
      onTap: (index) {
        _updateTab(navItems[index]);
      },
      items: navItems.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(
            tab.icon,
          ),
          label: tab.label
        );
      }).toList(),
    );
  }

  Widget getSelectedTab() {
    return activeTab.widget;
  }

  _updateTab(TopNavItem tab) {
    setState(() {
      activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getSelectedTab();
  }

}