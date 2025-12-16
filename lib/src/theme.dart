import 'package:flutter/material.dart';

const kFontFamily = 'monospace';

ThemeData inspectorTheme({
  Brightness brightness = Brightness.light,
}) {
  final isDark = brightness == Brightness.dark;

  const debugAccent = Colors.red;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: kFontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: debugAccent,
      brightness: brightness,
      primary: debugAccent,
      secondary: debugAccent.withValues(alpha: 0.85),
    ),
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF121212) : const Color(0xFFFDF7F0),
    appBarTheme: AppBarTheme(
      backgroundColor: debugAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        fontSize: 14,
        fontFamily: kFontFamily,
      ),
    ),
    iconTheme: IconThemeData(
      color: debugAccent,
      size: 22,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.white,
          width: 3,
        ),
      ),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontFamily: kFontFamily,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: kFontFamily,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          width: 1,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white54,
      thickness: 0.5,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 14,
        color: isDark ? Colors.white70 : Colors.black87,
        letterSpacing: 0.3,
      ),
      labelLarge: const TextStyle(
        fontFamily: kFontFamily,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: debugAccent.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: StadiumBorder(
        side: BorderSide(color: debugAccent),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: kFontFamily,
        letterSpacing: 0.3,
      ),
      behavior: SnackBarBehavior.fixed,
    ),
  );
}
