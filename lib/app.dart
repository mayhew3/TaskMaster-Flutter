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
  String? _emulatorError;

  @override
  void initState() {
    super.initState();
    var firestore = FirebaseFirestore.instance;

    if (serverEnv == 'local') {
      print('🔧 USING LOCAL FIRESTORE EMULATOR');
      print('📡 Connecting to: 127.0.0.1:8085');
      print('⚠️  Make sure Firebase emulator is running: firebase emulators:start');
      firestore.useFirestoreEmulator('127.0.0.1', 8085);
      firestore.settings = const Settings(
        persistenceEnabled: false,
      );
    } else {
      print('☁️  USING PRODUCTION FIRESTORE (serverEnv: $serverEnv)');
      firestore.settings = const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    }

    var migrator = FirestoreMigrator(client: http.Client(), firestore: firestore);
    var taskRepository = TaskRepository(firestore: firestore);

    store = Store<AppState>(
        appReducer,
        initialState: AppState.init(loading: true),
        middleware: createStoreTaskItemsMiddleware(taskRepository, _navigatorKey, migrator, handleFirestoreError)
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

  void handleFirestoreError(dynamic error) {
    print('🔍 handleFirestoreError called with: $error');

    if (serverEnv != 'local') {
      print('⚠️  Not in local mode, ignoring error');
      return; // Only handle for local emulator
    }

    final errorStr = error.toString();
    print('🔍 Error string: $errorStr');

    if (errorStr.contains('ECONNREFUSED') ||
        errorStr.contains('failed to connect') ||
        errorStr.contains('UNAVAILABLE')) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌❌❌ FIRESTORE EMULATOR CONNECTION FAILED ❌❌❌');
      print('═══════════════════════════════════════════════════════════');
      print('');
      print('Cannot connect to Firestore emulator at 127.0.0.1:8085');
      print('Start the emulator with: firebase emulators:start');
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('');

      if (mounted && _emulatorError == null) {
        print('🔴 Setting error state to show red screen');
        setState(() {
          _emulatorError = errorStr;
        });
      } else {
        print('⚠️  Not setting error state: mounted=$mounted, _emulatorError=$_emulatorError');
      }
    } else {
      print('⚠️  Error does not match connection failure patterns');
    }
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
    // Show error screen if emulator connection failed
    if (_emulatorError != null) {
      return MaterialApp(
        title: 'TaskMaster 3000',
        theme: taskMasterTheme,
        home: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Firestore Emulator Not Running',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cannot connect to Firestore emulator at 127.0.0.1:8085',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'To fix this:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '1. Open a new terminal\n'
                          '2. Run: firebase emulators:start\n'
                          '3. Wait for "All emulators ready!"\n'
                          '4. Hot restart this app (r in terminal)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Or to use production Firebase:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'flutter run',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'monospace',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '(without --dart-define=SERVER=local)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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