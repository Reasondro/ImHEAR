import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: "Home", icon: Icons.home),
  Destination(label: "HearAI", icon: Icons.hearing),
  Destination(label: "Device", icon: Icons.watch),
  Destination(label: "Profile", icon: Icons.person),
];
