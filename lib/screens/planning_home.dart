
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/parse_helper.dart';
import 'package:taskmaster/screens/plan_task_list.dart';
import 'package:taskmaster/screens/task_list.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';
import 'package:taskmaster/widgets/nullable_dropdown.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime sprintStart = DateTime.now();
  int numUnits = 7;
  String unitName = 'Days';
  Sprint activeSprint;

  List<String> possibleRecurUnits = [
    'Days',
    'Weeks',
    'Months',
    'Years',
  ];

  @override
  void initState() {
    super.initState();
    activeSprint = widget.appState.getActiveSprint();
  }

  void openPlanning(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PlanTaskList(
            appState: widget.appState,
            taskHelper: widget.taskHelper,
            taskListGetter: widget.appState.getAllTasks,
            numUnits: numUnits,
            unitName: unitName,
            startDate: sprintStart,
          );
        },
        )
    );
    setState(() {
      activeSprint = widget.appState.getActiveSprint();
    });
  }

  String getSubHeader() {
    String startDateFormatted = DateFormat('M/d').format(activeSprint.startDate.value);
    String endDateFormatted = DateFormat('M/d').format(activeSprint.endDate.value);
    return 'Tasks for ' + startDateFormatted + ' - ' + endDateFormatted;
  }

  String getSubSubHeader() {
    DateTime endDate = activeSprint.endDate.value;
    String goodFormat = timeago.format(endDate, allowFromNow: true);
    String better = goodFormat.replaceAll('from now', 'left');
    return '(' + better + ')';
  }

  @override
  Widget build(BuildContext context) {
    if (this.activeSprint == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('New Sprint'),
        ),
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80.0,
                    child: EditableTaskField(
                      initialText: numUnits.toString(),
                      labelText: 'Num',
                      inputType: TextInputType.number,
                      onChanged: (value) => numUnits = ParseHelper.parseInt(value),
                      fieldSetter: (value) => numUnits = ParseHelper.parseInt(value),
                    ),
                  ),
                  Expanded(
                    child: NullableDropdown(
                      initialValue: unitName,
                      labelText: 'Unit',
                      possibleValues: possibleRecurUnits,
                      onChanged: (value) => unitName = value,
                      valueSetter: (value) => unitName = value,
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(7.0),
                child: DateTimeField(
                  decoration: InputDecoration(
                    labelText: 'Starts On',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: sprintStart,
                  onChanged: (value) => sprintStart = value,
                  onShowPicker: (context, currentValue) async {
                    return await showDatePicker(
                        context: context,
                        initialDate: currentValue ?? sprintStart,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100));
                  },
                  format: DateFormat('MM-dd-yyyy'),
                ),
              ),
              FlatButton(
                  color: TaskColors.cardColor,
                  onPressed: () => openPlanning(context),
                  child: Text('Create Sprint')),
            ],
          ),
        ),
        bottomNavigationBar: widget.bottomNavigationBarGetter(),
      );
    } else {
      return TaskListScreen(
        title: 'Sprint Tasks',
        appState: widget.appState,
        bottomNavigationBarGetter: widget.bottomNavigationBarGetter,
        taskHelper: widget.taskHelper,
        taskListGetter: widget.appState.getTasksForActiveSprint,
        subHeader: getSubHeader(),
        subSubHeader: getSubSubHeader(),
      );
    }
  }

}