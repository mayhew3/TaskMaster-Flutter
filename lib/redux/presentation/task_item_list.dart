
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/details_screen.dart';
import 'package:taskmaster/redux/presentation/plan_task_list.dart';
import 'package:taskmaster/redux/presentation/snooze_dialog.dart';
import 'package:taskmaster/redux/presentation/task_item_list_viewmodel.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../keys.dart';
import '../../models/models.dart';
import '../../models/task_colors.dart';
import 'editable_task_item.dart';
import 'header_list_item.dart';
import 'loading_indicator.dart';

class TaskItemList extends StatefulWidget {
  final BuiltList<TaskItem> taskItems;
  final bool sprintMode;

  final String? subHeader;
  final String? subSubHeader;
  TaskItemList({
    Key? key,
    this.subHeader,
    this.subSubHeader,
    required this.taskItems,
    required this.sprintMode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TaskItemListState();
}

class TaskItemListState extends State<TaskItemList> {

  late final Sprint? activeSprint;
  late final BuiltList<TaskItem>? activeSprintItems;

  bool initialized = false;
  late bool showActive;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TaskItemListViewModel>(
        builder: (context, viewModel) {
          if (!initialized) {
            this.showActive = widget.sprintMode;
            this.activeSprint = viewModel.activeSprint;
            this.activeSprintItems =
            this.activeSprint == null ? null : taskItemsForSprintSelector(
                viewModel.taskItems, activeSprint!);
            initialized = true;
          }
          return Container(
            padding: EdgeInsets.only(top: 7.0),
            child: Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return LoadingIndicator(key: TaskMasterKeys.tasksLoading);
                } else if (viewModel.loadFailed) {
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          const Text(
                              "Could not load tasks from server. Please try again."),
                          ElevatedButton(
                            child: const Text('RETRY'),
                            onPressed: () {
                              StoreProvider.of<AppState>(context).dispatch(LoadDataAction());
                            },
                          ),
                        ],
                      )
                  );
                } else {
                  return _buildListView(context, viewModel);
                }
              },
            ),
          );
        },
        converter: TaskItemListViewModel.fromStore
    );
  }

  List<TaskItem> getFilteredTasks(BuiltList<TaskItem> taskItems) {
    List<TaskItem> filtered = taskItems.where((taskItem) {
      bool isInActiveSprint = (activeSprintItems != null && activeSprintItems!.contains(taskItem));
      bool passesActiveFilter = widget.sprintMode ||
          showActive ||
          !isInActiveSprint;
      return passesActiveFilter;
    }).toList();
    return filtered;
  }

  void _addTaskTile({
    required TaskItem taskItem,
    required BuildContext context,
    required List<StatelessWidget> tiles,
    required TaskItemListViewModel viewModel
  }) {
    var snoozeDialog = (TaskItem taskItem) {
      HapticFeedback.mediumImpact();
      showDialog<void>(context: context, builder: (context) => SnoozeDialog(
        taskItem: taskItem,
      ));
    };
    var taskCard = EditableTaskItemWidget(
      taskItem: taskItem,
      sprint: viewModel.activeSprint,
      highlightSprint: (!widget.sprintMode && viewModel.activeSprint != null && activeSprintItems != null && activeSprintItems!.contains(taskItem)),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return DetailsScreen(
              taskItemId: taskItem.id,
            );
          }),
        );
      },
      onLongPress: () => snoozeDialog(taskItem),
      onForcePress: (ForcePressDetails forcePressDetails) => snoozeDialog(taskItem),
      onTaskCompleteToggle: (checkState) => viewModel.onCheckboxClicked(taskItem, checkState),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          try {
            StoreProvider.of<AppState>(context).dispatch(DeleteTaskItemAction(taskItem));
            // _displaySnackBar("Task Deleted!", context);
            return true;
          } catch(err) {
            return false;
          }
        }
        return false;
      },
    );
    tiles.add(taskCard);
  }

  List<TaskItem> _moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }


  Card _createSummaryWidget(Sprint sprint, BuildContext context) {
    var startDate = sprint.startDate;
    var endDate = sprint.endDate;
    var currentDay = DateTime.timestamp().difference(startDate).inDays + 1;
    var totalDays = endDate.difference(startDate).inDays;
    var sprintStr = "Active Sprint - Day " + currentDay.toString() + " of " + totalDays.toString();

    var completed = activeSprintItems!.where((taskItem) => taskItem.completionDate != null);
    var taskStr = completed.length.toString() + "/" + activeSprintItems!.length.toString() + " Tasks Complete";

    return Card(
      color: Color.fromARGB(100, 100, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
        side: BorderSide(
          color: TaskColors.sprintColor,
          width: 1.0,
        ),
      ),
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            )
        ),
        child: Container(
          padding: EdgeInsets.all(13.5),
          child: Row(
            children: <Widget>[
              Container(
                child: Icon(Icons.assignment, color: TaskColors.sprintColor),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          sprintStr,
                          style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      Text(
                          taskStr,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: TaskColors.sprintColor
                          )
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () => setState(() => showActive = !showActive),
                  child: Text(
                    showActive ? "Hide Tasks" : "Show Tasks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card _createNoTasksFoundCard() {
    return Card(
      shadowColor: TaskColors.invisible,
      color: TaskColors.backgroundColor,
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'No eligible tasks found.',
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView _buildListView(BuildContext context, TaskItemListViewModel viewModel) {
    // widget.appState.notificationScheduler.updateHomeScreenContext(context);
    List<TaskItem> otherTasks = getFilteredTasks(widget.taskItems);

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted()
        && !viewModel.recentlyCompleted.any((t) => t.id == taskItem.id)
    );
    final List<TaskItem> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isPastDue());
    final List<TaskItem> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgent());

    final List<TaskItem> targetTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isTarget());

    final List<TaskItem> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduled());

    scheduledTasks.sort((a, b) => a.startDate!.compareTo(b.startDate!));
    completedTasks.sort((a, b) => b.completionDate!.compareTo(a.completionDate!));

    List<StatelessWidget> tiles = [];

    if (!widget.sprintMode) {
      var activeSprint = viewModel.activeSprint;
      if (activeSprint != null) {
        tiles.add(_createSummaryWidget(activeSprint, context));
      }
    }

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Past Due'));
      dueTasks.forEach((task) => _addTaskTile(taskItem: task, context: context, tiles: tiles, viewModel: viewModel));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent'));
      urgentTasks.forEach((task) => _addTaskTile(taskItem: task, context: context, tiles: tiles, viewModel: viewModel));
    }

    if (targetTasks.isNotEmpty) {
      tiles.add(HeadingItem('Target'));
      targetTasks.forEach((task) => _addTaskTile(taskItem: task, context: context, tiles: tiles, viewModel: viewModel));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => _addTaskTile(taskItem: task, context: context, tiles: tiles, viewModel: viewModel));
    }

    if (scheduledTasks.isNotEmpty) {
      tiles.add(HeadingItem('Scheduled'));
      scheduledTasks.sort((t1, t2) {
        return t1.startDate!.compareTo(t2.startDate!);
      });
      scheduledTasks.forEach((task) => _addTaskTile(taskItem: task, context: context, tiles: tiles, viewModel: viewModel));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => _addTaskTile(taskItem: task, context: context, tiles: tiles, viewModel: viewModel));
    }

    if (tiles.isEmpty) {
      tiles.add(_createNoTasksFoundCard());
    }

    if (widget.sprintMode) {
      tiles.add(_createAddMoreButton(context));
    }

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 54),
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  void _openPlanning(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PlanTaskList();
        },
        )
    );
  }

  StatelessWidget _createAddMoreButton(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(25.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child:
            Center(
                child:
                GestureDetector(
                  onTap: () => _openPlanning(context),
                  child: Text(
                      "Add More...",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
                  ),
                )
            ),
            ),
          ],
        )
    );
  }

  Widget getLoadingBody() {
    return Center(
        child: CircularProgressIndicator(
          key: TaskMasterKeys.tasksLoading,
        )
    );
  }

  Widget getTaskListBody(BuildContext context, TaskItemListViewModel viewModel) {
    List<Widget> elements = [];
    var subHeader = widget.subHeader;
    if (subHeader != null) {
      elements.add(
          Container(
            padding: EdgeInsets.only(left: 12.0, top: 12.0),
            child: Text(
              subHeader,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          )
      );
    }
    var subSubHeader = widget.subSubHeader;
    if (subSubHeader != null) {
      elements.add(
          Container(
            padding: EdgeInsets.only(left: 12.0, bottom: 12.0),
            child: Text(
              subSubHeader,
              style: TextStyle(fontSize: 18),
            ),
          )
      );
    }
    ListView listView = _buildListView(context, viewModel);
    Widget expanded = Expanded(child: listView);
    elements.add(expanded);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elements,
    );
  }

}