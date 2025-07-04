import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/app_theme.dart';
import 'package:taskmaster/firestore_migrator.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/middleware/auth_middleware.dart';
import 'package:taskmaster/redux/middleware/store_sprint_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/redux/presentation/home_screen.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/presentation/load_failed.dart';
import 'package:taskmaster/redux/presentation/sign_in.dart';
import 'package:taskmaster/redux/presentation/splash.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';
import 'package:taskmaster/routes.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:http/http.dart' as http;

class TaskMasterApp extends StatefulWidget {

  const TaskMasterApp({
    super.key});

  @override
  TaskMasterAppState createState() => TaskMasterAppState();
}

class TaskMasterAppState extends State<TaskMasterApp> {
  late final Store<AppState> store;
  static final _navigatorKey = GlobalKey<NavigatorState>();

  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  @override
  void initState() {
    super.initState();
    var firestore = FirebaseFirestore.instance;

    if (serverEnv == 'local') {
      firestore.useFirestoreEmulator('127.0.0.1', 8085);
      firestore.settings = const Settings(
        persistenceEnabled: false,
      );
    } else {
      firestore.settings = const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    }

    var migrator = FirestoreMigrator(client: http.Client(), firestore: firestore);
    var taskRepository = TaskRepository(firestore: firestore);

    store = Store<AppState>(
        appReducer,
        initialState: AppState.init(loading: true),
        middleware: createStoreTaskItemsMiddleware(taskRepository, _navigatorKey, migrator)
          ..addAll(createAuthenticationMiddleware(_navigatorKey))
          ..addAll(createStoreSprintsMiddleware(taskRepository))
          // ..add(new LoggingMiddleware.printer())
    );
    store.state.googleSignIn.initialize().then((_) {
      store.dispatch(GoogleInitializedAction());
      maybeKickOffSignIn();
      configureTimezoneHelper();
      setupBadgeUpdater();
    });
  }

  void setupBadgeUpdater() {
    store.onChange.listen((appState) {
      if (appState.appIsReady() && appState.taskItems.isNotEmpty) {
        var urgentTasks = appState.taskItems.where((taskItem) => (taskItem.isUrgent() || taskItem.isPastDue()) && taskItem.completionDate == null && taskItem.retired == null);
        var taskIds = urgentTasks.map((taskItem) => {'id': taskItem.docId, 'name': taskItem.name}).toList();
        print('Urgent tasks: $taskIds');
        var urgentCount = urgentTasks.length;
        FlutterAppBadger.isAppBadgeSupported().then((supported) {
          if (supported) {
            print('Updating badge count to $urgentCount');
            FlutterAppBadger.updateBadgeCount(urgentCount);
          }
        }
        );
      }
    });
  }

  void configureTimezoneHelper() {
    store.dispatch(InitTimezoneHelperAction());
  }

  void maybeKickOffSignIn() {
    if (!store.state.isAuthenticated() && store.state.googleInitialized) {
      store.dispatch(TryToSilentlySignInAction());
    }
  }

  @override
  Widget build(BuildContext context) {

    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'TaskMaster 3000',
        navigatorKey: _navigatorKey,
        theme: taskMasterTheme,
        initialRoute: TaskMasterRoutes.home,
        routes: <String, WidgetBuilder>{
          TaskMasterRoutes.logout: (context) {
            return SplashScreen(message: 'Signing out...');
          },
          TaskMasterRoutes.login: (context) {
            return SignInScreen();
          },
          TaskMasterRoutes.loadFailed: (context) {
            return LoadFailedScreen();
          },
          TaskMasterRoutes.home: (context) {
            return HomeScreen();
          },
        },
      ),
    );

  }

}