import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/middleware/auth_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/redux/presentation/home_screen.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
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
  late Store<AppState> store;
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    store = Store<AppState>(
        appReducer,
        initialState: AppState.init(loading: true),
        middleware: createStoreTaskItemsMiddleware(TaskRepository(client: http.Client()))
          ..addAll(createAuthenticationMiddleware(_navigatorKey))
    );
    maybeKickOffSignIn();
    configureTimezoneHelper();
  }

  void configureTimezoneHelper() {
    store.dispatch(InitTimezoneHelperAction());
  }

  void maybeKickOffSignIn() {
    if (!store.state.isAuthenticated()) {
      store.dispatch(TryToSilentlySignIn());
    }
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: TaskColors.menuColor,
      canvasColor: TaskColors.backgroundColor,
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return TaskColors.highlight; }
          if (states.contains(MaterialState.selected)) { return TaskColors.highlight; }
          return TaskColors.highlight;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return TaskColors.highlight; }
          if (states.contains(MaterialState.selected)) { return TaskColors.highlight; }
          return TaskColors.highlight;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return TaskColors.highlight; }
          if (states.contains(MaterialState.selected)) { return TaskColors.highlight; }
          return TaskColors.highlight;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return TaskColors.highlight; }
          if (states.contains(MaterialState.selected)) { return TaskColors.highlight; }
          return TaskColors.highlight;
        }),
      ),
    );

    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: "TaskMaster 3000",
        navigatorKey: _navigatorKey,
        theme: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: TaskColors.backgroundColor,
              secondary: TaskColors.highlight,
              surface: TaskColors.menuColor,
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
            )
        ),
        initialRoute: TaskMasterRoutes.splash,
        routes: {
          TaskMasterRoutes.splash: (context) {
            return SplashScreen(message: "Signing in...");
          },
          TaskMasterRoutes.login: (context) {
            return SignInScreen();
          },
          TaskMasterRoutes.home: (context) {
            return HomeScreen(
              onInit: () {
                print("Home Screen: onInit()");
                var store = StoreProvider.of<AppState>(context);
                if (store.state.isAuthenticated()) {
                  print("Home Screen: onInit(), authenticated");
                  store.dispatch(LoadDataAction());
                }
              },
            );
          },
        },
      ),
    );

  }

}