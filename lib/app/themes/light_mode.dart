import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komunika/app/themes/app_colors.dart';

//* the color scheme for the light theme.
final ColorScheme imHearLightColor = ColorScheme.fromSeed(
  seedColor: AppColors.haiti,
  brightness: Brightness.light,
);

// * the overall theme data for the light mode of the application.
final ThemeData imHearLightTheme = ThemeData().copyWith(
  colorScheme: imHearLightColor,
  textTheme: GoogleFonts.outfitTextTheme(),
  appBarTheme: const AppBarTheme(
    toolbarHeight: 65,
    backgroundColor: AppColors.haiti,
    foregroundColor: AppColors.white,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.haiti,
    indicatorColor: AppColors.bittersweet,
    iconTheme: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) =>
          states.contains(WidgetState.selected)
              ? (const IconThemeData(color: AppColors.haiti))
              : (const IconThemeData(color: AppColors.white)),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) =>
          states.contains(WidgetState.selected)
              ? const TextStyle(color: AppColors.bittersweet)
              : const TextStyle(color: AppColors.white),
    ),
  ),

  scaffoldBackgroundColor: AppColors.white,
);
