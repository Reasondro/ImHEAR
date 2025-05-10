import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Home screen", style: TextStyle(color: AppColors.haiti)),
    );
  }
}
