import 'package:flutter/material.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import '../../models/models.dart';
import '../redux/containers/active_tab.dart';

class HomeScreen extends StatefulWidget {
  final void Function() onInit;

  HomeScreen({required this.onInit}) : super(key: Key('__homeScreen__'));

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late TopNavItem activeTab;
  List<TopNavItem> navItems = [];

  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ActiveTab(
      builder: (BuildContext context, AppTab activeTab) {
        return Scaffold(
          appBar: AppBar(
            title: Text("TaskMaster 3000"),
            actions: [
            ],
          ),
          body: activeTab == AppTab.tasks ? FilteredTodos() : Stats(),
          floatingActionButton: FloatingActionButton(
            key: ArchSampleKeys.addTodoFab,
            onPressed: () {
              Navigator.pushNamed(context, ArchSampleRoutes.addTodo);
            },
            child: Icon(Icons.add),
            tooltip: ArchSampleLocalizations.of(context).addTodo,
          ),
          bottomNavigationBar: TabSelector(),
        );
      },
    );
  }
}