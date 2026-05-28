import '../../../models/task_list_view.dart';

/// User-facing display labels for the task list's group / sort axes.
///
/// Single source of truth shared by the View Options sheet
/// (`view_options_sheet.dart`) and the wide-layout summary chip bar
/// (`view_options_summary_bar.dart`) so the chip labels can't drift
/// from the picker labels when an axis is added or renamed (TM-385 R5).
const kGroupAxisLabels = <TaskGroupAxis, String>{
  TaskGroupAxis.dueStatus: 'Due Status',
  TaskGroupAxis.none: 'None',
  TaskGroupAxis.priority: 'Priority',
  TaskGroupAxis.area: 'Area',
  TaskGroupAxis.points: 'Points',
  TaskGroupAxis.duration: 'Estimated Time',
};

const kSortAxisLabels = <TaskSortAxis, String>{
  TaskSortAxis.urgency: 'Urgency',
  TaskSortAxis.dateAdded: 'Date Added',
  TaskSortAxis.points: 'Points',
  TaskSortAxis.area: 'Area',
  TaskSortAxis.duration: 'Estimated Time',
  TaskSortAxis.priority: 'Priority',
  TaskSortAxis.efficiency: 'Efficiency',
};
