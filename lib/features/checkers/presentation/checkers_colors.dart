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
  const CheckersPieceColors({required this.playerOne, required this.playerTwo});

  final Color playerOne;
  final Color playerTwo;
}

class CheckersPieceColor {
  const CheckersPieceColor({required this.name, required this.color});

  final String name;
  final Color color;
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

const checkersPieceColorOptions = [
  CheckersPieceColor(name: 'Vermelho', color: Color(0xFFFF5D6C)),
  CheckersPieceColor(name: 'Prata', color: Color(0xFFC9D1D9)),
  CheckersPieceColor(name: 'Preto', color: Color(0xFF11151D)),
  CheckersPieceColor(name: 'Azul', color: Color(0xFF32C5FF)),
  CheckersPieceColor(name: 'Amarelo', color: Color(0xFFFFD166)),
];
