import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/typedefs.dart';

class TaskDisplayGrouping {
  final String displayName;
  final int displayOrder;
  final TaskItemFilter filter;
  final TaskItemOrdering? ordering;
  List<SprintDisplayTask> taskItems = [];

  TaskDisplayGrouping({required this.displayName, required this.displayOrder, required this.filter, this.ordering});

  void stealItemsThatMatch(List<SprintDisplayTask> otherList) {
    taskItems = otherList.where(filter).toList(growable: false);
    for (var task in taskItems) {
      otherList.remove(task);
    }
    if (ordering != null) {
      taskItems.sort(ordering);
    }
  }
}