import 'package:flutter/material.dart';

class AppThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(33, 33, 33, 1),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: const Color.fromRGBO(48, 48, 48, 1),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      surface: Color.fromRGBO(48, 48, 48, 1),
      primary: Colors.red,
      secondary: Colors.redAccent,
      onSurface: Colors.white,
      surfaceContainerHighest: Color.fromRGBO(66, 66, 66, 0.102),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    hintColor: Colors.grey,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.red,
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.red,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: Colors.white,
    dividerColor: Colors.black26,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black87),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.red,
      secondary: Colors.redAccent,
      surface: Colors.transparent,
      onSurface: Colors.black87,
      surfaceContainerHighest: Color.fromRGBO(102, 102, 102, 0.102),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
    hintColor: Colors.black54,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.red,
    ),
    extensions: [
      const StatsColorsTheme(
        low: Colors.red,
        medium: Colors.orange,
        high: Colors.yellow,
        max: Colors.green,
      ),
    ],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    ),
  );
}

@immutable
class StatsColorsTheme extends ThemeExtension<StatsColorsTheme> {
  final Color low;
  final Color medium;
  final Color high;
  final Color max;

  const StatsColorsTheme({
    required this.low,
    required this.medium,
    required this.high,
    required this.max,
  });

  @override
  ThemeExtension<StatsColorsTheme> copyWith({
    Color? low,
    Color? medium,
    Color? high,
    Color? max,
  }) {
    return StatsColorsTheme(
      low: low ?? this.low,
      medium: medium ?? this.medium,
      high: high ?? this.high,
      max: max ?? this.max,
    );
  }

  @override
  ThemeExtension<StatsColorsTheme> lerp(
    ThemeExtension<StatsColorsTheme>? other,
    double t,
  ) {
    if (other is! StatsColorsTheme) {
      return this;
    }
    return StatsColorsTheme(
      low: Color.lerp(low, other.low, t)!,
      medium: Color.lerp(medium, other.medium, t)!,
      high: Color.lerp(high, other.high, t)!,
      max: Color.lerp(max, other.max, t)!,
    );
  }
}
