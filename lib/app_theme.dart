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
      // White text with a thin white outline so the button reads as a
      // button on the dialog's blue card surface. (M3's default
      // foreground-only treatment relied on a different bg from the
      // surface — both share #286BB5 here, so we add the outline
      // ourselves rather than tinting the label.)
      foregroundColor: Colors.white,
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.5),
        width: 1,
      ),
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
  // Default background for any modal bottom sheet (e.g. the dates / context
  // popups added in TM-358). Sheets that need a different surface still
  // override `backgroundColor` per-call.
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: TaskColors.popupBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
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
