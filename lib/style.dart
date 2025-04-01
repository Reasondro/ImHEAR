import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ColorScheme kotabaColorTheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 25, 25, 63),
  brightness: Brightness.light,
);

final ThemeData kotabaTheme = ThemeData().copyWith(
  colorScheme: kotabaColorTheme,
  textTheme: GoogleFonts.dmSansTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(255, 25, 25, 63),
    foregroundColor: Colors.white,
  ),
);
