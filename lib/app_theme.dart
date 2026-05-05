import 'package:flutter/material.dart';
import 'models/task_colors.dart';

ThemeData taskMaestroTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: TaskColors.menuColor,
    primary: TaskColors.primaryLight,
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
    foregroundColor: Colors.white,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: Colors.white,
      // Brand magenta so primary CTAs stand out on the new card-coloured
      // dialog/sheet surfaces (which share the AppBar's blue).
      backgroundColor: TaskColors.highlight,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      // No fill (M3 convention) — text buttons read as coloured labels
      // on whatever surface they sit on. The brand magenta makes dialog
      // actions (Cancel / Submit / etc.) visibly read as buttons rather
      // than disappear into the dialog's blue card surface.
      foregroundColor: TaskColors.highlight,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2.0,
    color: TaskColors.cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    clipBehavior: Clip.antiAlias,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: TaskColors.cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: TaskColors.cardColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  dividerTheme: DividerThemeData(
    color: TaskColors.hairline,
    space: 1,
    thickness: 1,
  ),
  chipTheme: ChipThemeData(
    shape: StadiumBorder(),
    side: BorderSide.none,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: TaskColors.cardColor,
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: TaskColors.primaryLight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
