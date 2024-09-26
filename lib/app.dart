import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/middleware/auth_middleware.dart';
import 'package:taskmaster/redux/middleware/store_sprint_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/redux/presentation/home_screen.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/presentation/load_failed.dart';
import 'package:taskmaster/redux/presentation/loading_indicator.dart';
import 'package:taskmaster/redux/presentation/sign_in.dart';
import 'package:taskmaster/redux/presentation/splash.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';
import 'package:taskmaster/routes.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:http/http.dart' as http;

class TaskMasterApp extends StatefulWidget {

  const TaskMasterApp({
    Key? key}) : super(key: key);

  @override
  TaskMasterAppState createState() => TaskMasterAppState();
}

class TaskMasterAppState extends State<TaskMasterApp> {
  late final Store<AppState> store;
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    var taskRepository = TaskRepository(client: http.Client());
    store = Store<AppState>(
        appReducer,
        initialState: AppState.init(loading: true),
        middleware: createStoreTaskItemsMiddleware(taskRepository, _navigatorKey)
          ..addAll(createAuthenticationMiddleware(_navigatorKey))
          ..addAll(createStoreSprintsMiddleware(taskRepository))
          // ..add(new LoggingMiddleware.printer())
    );
    maybeKickOffSignIn();
    configureTimezoneHelper();
    setupBadgeUpdater();
  }

  void setupBadgeUpdater() {
    store.onChange.listen((appState) {
      if (appState.appIsReady() && appState.taskItems.isNotEmpty) {
        var urgentCount = appState.taskItems.where((taskItem) => (taskItem.isUrgent() || taskItem.isPastDue()) && taskItem.completionDate == null).length;
        FlutterAppBadger.isAppBadgeSupported().then((supported) {
          if (supported) {
            print("Updating badge count to $urgentCount");
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
    if (!store.state.isAuthenticated()) {
      store.dispatch(TryToSilentlySignInAction());
    }
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = ThemeData(

    );

    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: "TaskMaster 3000",
        navigatorKey: _navigatorKey,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: TaskColors.menuColor,
              primary: TaskColors.backgroundColor,
              secondary: TaskColors.highlight,
              surface: TaskColors.backgroundColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: TaskColors.menuColor,
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: TaskColors.menuColor,
              indicatorColor: TaskColors.backgroundColor,
              height: 70.0,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: TaskColors.highlight,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: TaskColors.menuColor
                )
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: TaskColors.menuColor
                )
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) { return TaskColors.highlight; }
                if (states.contains(WidgetState.selected)) { return TaskColors.highlight; }
                return TaskColors.highlight;
              }),
            ),
            radioTheme: RadioThemeData(
              fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) { return TaskColors.backgroundColor; }
                if (states.contains(WidgetState.selected)) { return TaskColors.backgroundColor; }
                return TaskColors.backgroundColor;
              }),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) { return TaskColors.highlight; }
                if (states.contains(WidgetState.selected)) { return TaskColors.highlight; }
                return TaskColors.highlight;
              }),
              trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) { return TaskColors.backgroundColor; }
                if (states.contains(WidgetState.selected)) { return TaskColors.backgroundColor; }
                return TaskColors.backgroundColor;
              }),
            ),

        ),
        initialRoute: TaskMasterRoutes.splash,
        routes: <String, WidgetBuilder>{
          TaskMasterRoutes.splash: (context) {
            return SplashScreen(message: "Signing in...");
          },
          TaskMasterRoutes.login: (context) {
            return SignInScreen();
          },
          TaskMasterRoutes.loading: (context) {
            return LoadingIndicator();
          },
          TaskMasterRoutes.loadFailed: (context) {
            return LoadFailedScreen();
          },
          TaskMasterRoutes.home: (context) {
            return HomeScreen(
              onInit: () {},
            );
          },
        },
      ),
    );

  }

}