import 'package:flutter/material.dart';

class CheckersBoardColors {
  const CheckersBoardColors({
    required this.name,
    required this.light,
    required this.dark,
  });

  final String name;
  final Color light;
  final Color dark;
}

class CheckersPieceColors {
  const CheckersPieceColors({
    required this.name,
    required this.playerOne,
    required this.playerTwo,
  });

  final String name;
  final Color playerOne;
  final Color playerTwo;
}

const checkersBoardOptions = [
  CheckersBoardColors(
    name: 'Clássico',
    light: Color(0xFFF0D9B5),
    dark: Color(0xFF8B5A3C),
  ),
  CheckersBoardColors(
    name: 'Oceano',
    light: Color(0xFFBDE8F4),
    dark: Color(0xFF28627A),
  ),
  CheckersBoardColors(
    name: 'Neon',
    light: Color(0xFFDDD6FE),
    dark: Color(0xFF4C1D95),
  ),
];

const checkersPieceOptions = [
  CheckersPieceColors(
    name: 'Rubi e ônix',
    playerOne: Color(0xFFFF5D6C),
    playerTwo: Color(0xFF161A24),
  ),
  CheckersPieceColors(
    name: 'Azul e ouro',
    playerOne: Color(0xFF32C5FF),
    playerTwo: Color(0xFFFFC857),
  ),
  CheckersPieceColors(
    name: 'Limão e violeta',
    playerOne: Color(0xFFB8FF55),
    playerTwo: Color(0xFF8E7CFF),
  ),
];
