import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home/home_screen.dart';
import 'theme/app_colors.dart';

class TrackerApp extends StatefulWidget {
  const TrackerApp({super.key});

  @override
  State<TrackerApp> createState() => _TrackerAppState();
}

class _TrackerAppState extends State<TrackerApp> {
  AppPalette _palette = AppPalette.defaultTheme;
  @override
  Widget build(BuildContext context) {
    final neon = _palette == AppPalette.neonTokyo;
    final background = neon ? NeonTokyo.background : AppColors.background;

    final colorScheme = ColorScheme.dark(
      primary: neon ? NeonTokyo.primary : AppColors.primary,
      secondary: neon ? NeonTokyo.secondary : AppColors.secondary,
      tertiary: neon ? NeonTokyo.tertiary : AppColors.tertiary,
      surface: neon ? NeonTokyo.surface : AppColors.surface,
      onPrimary: Colors.black,
      onSecondary: neon ? Colors.black : AppColors.textPrimary,
      onTertiary: neon ? Colors.black : Colors.white,
      onSurface: neon ? NeonTokyo.textPrimary : AppColors.textPrimary,
      onSurfaceVariant: neon
          ? NeonTokyo.textSecondary
          : AppColors.textSecondary,
      outline: neon ? NeonTokyo.border : AppColors.border,
      surfaceContainerHighest: neon
          ? NeonTokyo.surfaceLight
          : AppColors.surfaceLight,
    );

    final baseTextTheme = GoogleFonts.oswaldTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymLogger',

      theme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: background,

        colorScheme: colorScheme,

        textTheme: baseTextTheme.copyWith(
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: colorScheme.outline),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,

          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),

          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),

          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,

            side: BorderSide(color: colorScheme.outline),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
        ),

        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }

            return colorScheme.surfaceContainerHighest;
          }),

          checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),

          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      home: HomeScreen(
        palette: _palette,
        onPaletteChanged: (newPalette) {
          setState(() {
            _palette = newPalette;
          });
        },
      ),
    );
  }
}
