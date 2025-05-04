import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ColorScheme kotabaLightColorTheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 25, 25, 63),
  brightness: Brightness.light,
);

final ThemeData kotabaLightTheme = ThemeData().copyWith(
  colorScheme: kotabaLightColorTheme,
  // colorScheme: ColorScheme.light(),
  textTheme: GoogleFonts.dmSansTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 25, 25, 63),
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
);
