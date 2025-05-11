import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komunika/app/themes/app_colors.dart';

final ColorScheme imHearLightColor = ColorScheme.fromSeed(
  seedColor: AppColors.haiti,
  brightness: Brightness.light,
);

final ThemeData imHearLightTheme = ThemeData().copyWith(
  colorScheme: imHearLightColor,
  // colorScheme: ColorScheme.light(),
  textTheme: GoogleFonts.outfitTextTheme(),
  appBarTheme: const AppBarTheme(
    toolbarHeight: 75,
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
              // : const TextStyle(color: AppColors.haiti),
              : const TextStyle(color: AppColors.white),
    ),
  ),

  scaffoldBackgroundColor: Colors.white,
);
