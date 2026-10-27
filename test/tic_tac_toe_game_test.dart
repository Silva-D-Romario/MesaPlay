import 'package:flutter_test/flutter_test.dart';
import 'package:asobiplay/features/tic_tac_toe/domain/tic_tac_toe_game.dart';

void main() {
  group('TicTacToeGame', () {
    test('começa vazio com X', () {
      final game = TicTacToeGame();

      expect(game.board, everyElement(isNull));
      expect(game.currentPlayer, PlayerMark.x);
      expect(game.isFinished, isFalse);
    });

    test('alterna jogadores e não permite sobrescrever uma casa', () {
      final game = TicTacToeGame();

      expect(game.playAt(0), isTrue);
      expect(game.currentPlayer, PlayerMark.o);
      expect(game.playAt(0), isFalse);
      expect(game.currentPlayer, PlayerMark.o);
    });

    test('identifica vitória e bloqueia novas jogadas', () {
      final game = TicTacToeGame();

      for (final index in [0, 3, 1, 4, 2]) {
        game.playAt(index);
      }

      expect(game.winner, PlayerMark.x);
      expect(game.winningCells, [0, 1, 2]);
      expect(game.isFinished, isTrue);
      expect(game.playAt(5), isFalse);
    });

    test('identifica empate', () {
      final game = TicTacToeGame();

      for (final index in [0, 1, 2, 4, 3, 5, 7, 6, 8]) {
        game.playAt(index);
      }

      expect(game.winner, isNull);
      expect(game.isDraw, isTrue);
    });

    test('reinicia com o jogador informado', () {
      final game = TicTacToeGame()..playAt(0);

      game.reset(firstPlayer: PlayerMark.o);

      expect(game.board, everyElement(isNull));
      expect(game.currentPlayer, PlayerMark.o);
      expect(game.isFinished, isFalse);
    });

    test('rejeita índice fora do tabuleiro', () {
      final game = TicTacToeGame();

      expect(() => game.playAt(9), throwsRangeError);
    });
  });
}
