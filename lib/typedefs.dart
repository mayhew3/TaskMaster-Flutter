import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models.dart';

typedef UserUpdater(GoogleSignInAccount account);
typedef IdTokenUpdater(String idToken);

typedef TaskAdder(TaskItem taskItem);

typedef TaskCompleter(TaskItem taskItem, bool completed);

typedef TaskUpdater({
  TaskItem taskItem,
  String name,
  String description,
  String project,
  String context,
  int urgency,
  int priority,
  int duration,
  DateTime startDate,
  DateTime targetDate,
  DateTime dueDate,
  DateTime urgentDate,
  int gamePoints,
  int recurNumber,
  String recurUnit,
  bool recurWait,
});