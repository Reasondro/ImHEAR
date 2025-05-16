import 'package:flutter/material.dart';

// * class to store navigation bar elements (or destination)
class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

// ? for this prototype, the destination is mainly developed for the disabled (deaf) user
const destinations = [
  Destination(label: "Home", icon: Icons.home),
  Destination(label: "HearAI", icon: Icons.hearing),
  Destination(label: "Device", icon: Icons.watch),
  Destination(label: "Profile", icon: Icons.person),
];
