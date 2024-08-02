import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/redux/presentation/home_screen.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/actions/actions.dart';
import 'package:taskmaster/routes.dart';

class TaskMasterApp extends StatelessWidget {
  final Store<AppState> store;

  const TaskMasterApp({
    Key? key,
    required this.store}) : super(key: key);

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
        routes: {
          TaskMasterRoutes.home: (context) {
            return HomeScreen(
              onInit: () {
                StoreProvider.of<AppState>(context).dispatch(LoadTaskItemsAction());
              },
            );
          }
        },
      ),
    );

  }

}