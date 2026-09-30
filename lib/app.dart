import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home/home_screen.dart';
import 'theme/app_colors.dart';

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,

      surface: AppColors.surface,

      onPrimary: Colors.black,
      onSecondary: AppColors.textPrimary,
      onTertiary: Colors.white,
      onSurface: AppColors.textPrimary,
    );

    final baseTextTheme = GoogleFonts.oswaldTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymLogger',

      theme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: AppColors.background,

        colorScheme: colorScheme,

        textTheme: baseTextTheme.copyWith(
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),

        cardTheme: const CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            side: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,

          hintStyle: TextStyle(
            color: AppColors.textSecondary,
          ),

          labelStyle: TextStyle(
            color: AppColors.textSecondary,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            borderSide: BorderSide.none,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,

            side: const BorderSide(
              color: AppColors.border,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),

        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return AppColors.surfaceLight;
          }),

          checkColor: const WidgetStatePropertyAll(
            Colors.black,
          ),

          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}