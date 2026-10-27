import 'package:asobiplay/features/connect_four/domain/connect_four_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectFourGame', () {
    test('aplica gravidade e alterna o jogador', () {
      final game = ConnectFourGame();

      expect(game.dropPiece(2), isTrue);
      expect(game.board[37], ConnectFourPlayer.one);
      expect(game.currentPlayer, ConnectFourPlayer.two);
      expect(game.dropPiece(2), isTrue);
      expect(game.board[30], ConnectFourPlayer.two);
    });

    test('rejeita uma coluna cheia', () {
      final game = ConnectFourGame();

      for (var move = 0; move < 6; move++) {
        expect(game.dropPiece(0), isTrue);
      }

      expect(game.canDrop(0), isFalse);
      expect(game.dropPiece(0), isFalse);
    });

    test('reconhece vitória horizontal', () {
      final game = ConnectFourGame();
      for (final column in [0, 0, 1, 1, 2, 2, 3]) {
        game.dropPiece(column);
      }

      expect(game.winner, ConnectFourPlayer.one);
      expect(game.winningCells, containsAll([35, 36, 37, 38]));
      expect(game.isFinished, isTrue);
    });

    test('reconhece vitória vertical', () {
      final game = ConnectFourGame();
      for (final column in [0, 1, 0, 1, 0, 1, 0]) {
        game.dropPiece(column);
      }

      expect(game.winner, ConnectFourPlayer.one);
      expect(game.winningCells.length, 4);
    });

    test('reconhece vitória diagonal', () {
      final game = ConnectFourGame();
      for (final column in [0, 1, 1, 2, 4, 2, 2, 3, 4, 3, 5, 3, 3]) {
        game.dropPiece(column);
      }

      expect(game.winner, ConnectFourPlayer.one);
      expect(game.winningCells.length, greaterThanOrEqualTo(4));
    });
  });
}
