import 'package:flutter/material.dart';

// ! still in development
class OrgAdminDashboardScreen extends StatelessWidget {
  const OrgAdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Org Admin Dashboard")),
    body: const Center(
      child: Text(
        "This screen is currently still in development. For the current full user experience, please sign out and sign in or sign up as a deaf / disabled user. (p.s. currently nav bar is not 100% accurate)",
      ),
    ),
  );
}
