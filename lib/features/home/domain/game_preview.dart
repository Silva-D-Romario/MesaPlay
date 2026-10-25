import 'package:flutter/material.dart';

class GamePreview {
  const GamePreview({
    required this.name,
    required this.description,
    required this.icon,
    required this.accent,
    required this.status,
  });

  final String name;
  final String description;
  final IconData icon;
  final Color accent;
  final String status;
}
