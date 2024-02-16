
import 'models.dart';

class DataPayload {
  final List<TaskItem> taskItems;
  final List<Sprint> sprints;
  final List<TaskRecurrence> taskRecurrences;

  const DataPayload({required this.taskItems, required this.sprints, required this.taskRecurrences});
}