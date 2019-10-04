import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models.dart';

typedef UserUpdater(GoogleSignInAccount account);
typedef IdTokenUpdater(String idToken);
typedef TaskUpdater(TaskItem taskItem, String name, String description, DateTime startDate);