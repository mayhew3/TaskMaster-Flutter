import 'package:flutter/material.dart';
import 'models/task_colors.dart';

ThemeData taskMasterTheme = ThemeData(
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
    height: 70,
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

);