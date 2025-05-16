import 'package:flutter/material.dart';

// ! still in development

class OfficialDashboardScreen extends StatelessWidget {
  const OfficialDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Official Dashboard")),
    body: const Center(
      child: Text(
        "This screen is currently still in development. For the current full user experience, please sign out and sign in or sign up as a deaf / disabled user.",
      ),
    ),
  );
}
