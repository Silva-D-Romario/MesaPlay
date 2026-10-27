import 'package:flutter/material.dart';

enum GameKind { ticTacToe, checkers, hangman, connectFour }

class GamePreview {
  const GamePreview({
    required this.kind,
    required this.name,
    required this.description,
    required this.icon,
    required this.accent,
    required this.status,
  });

  final GameKind kind;
  final String name;
  final String description;
  final IconData icon;
  final Color accent;
  final String status;
}
