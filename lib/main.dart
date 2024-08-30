import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/app.dart';
import 'package:taskmaster/redux/middleware/auth_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _navigatorKey = GlobalKey<NavigatorState>();

  runApp(TaskMasterApp(
    store: Store<AppState>(
        appReducer,
        initialState: AppState.init(loading: true),
        middleware: createStoreTaskItemsMiddleware(TaskRepository(client: http.Client()))
          ..addAll(createAuthenticationMiddleware(_navigatorKey))
    ),
  ));
}
