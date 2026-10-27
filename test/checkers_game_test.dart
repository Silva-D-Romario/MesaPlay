import 'package:asobiplay/features/checkers/domain/checkers_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckersGame', () {
    test('inicia com doze peças para cada jogador', () {
      final game = CheckersGame();

      expect(game.pieceCount(CheckersPlayer.one), 12);
      expect(game.pieceCount(CheckersPlayer.two), 12);
      expect(game.currentPlayer, CheckersPlayer.one);
    });

    test('realiza movimento simples e alterna o jogador', () {
      final game = CheckersGame();

      expect(game.move(40, 33), isTrue);
      expect(game.board[40], isNull);
      expect(game.board[33]?.player, CheckersPlayer.one);
      expect(game.currentPlayer, CheckersPlayer.two);
    });

    test('obriga captura quando ela está disponível', () {
      final board = List<CheckersPiece?>.filled(64, null)
        ..[42] = const CheckersPiece(player: CheckersPlayer.one)
        ..[33] = const CheckersPiece(player: CheckersPlayer.two)
        ..[46] = const CheckersPiece(player: CheckersPlayer.one);
      final game = CheckersGame.custom(board: board);

      expect(game.legalMovesFor(46), isEmpty);
      expect(game.move(42, 24), isTrue);
      expect(game.board[33], isNull);
    });

    test('mantém o jogador durante captura múltipla', () {
      final board = List<CheckersPiece?>.filled(64, null)
        ..[51] = const CheckersPiece(player: CheckersPlayer.one)
        ..[42] = const CheckersPiece(player: CheckersPlayer.two)
        ..[26] = const CheckersPiece(player: CheckersPlayer.two);
      final game = CheckersGame.custom(board: board);

      expect(game.move(51, 33), isTrue);
      expect(game.currentPlayer, CheckersPlayer.one);
      expect(game.forcedPiece, 33);
      expect(game.move(33, 19), isTrue);
      expect(game.currentPlayer, CheckersPlayer.two);
    });

    test('promove uma peça ao chegar na última linha', () {
      final board = List<CheckersPiece?>.filled(64, null)
        ..[9] = const CheckersPiece(player: CheckersPlayer.one)
        ..[62] = const CheckersPiece(player: CheckersPlayer.two);
      final game = CheckersGame.custom(board: board);

      expect(game.move(9, 0), isTrue);
      expect(game.board[0]?.isKing, isTrue);
    });

    test('declara vitória quando o adversário perde a última peça', () {
      final board = List<CheckersPiece?>.filled(64, null)
        ..[42] = const CheckersPiece(player: CheckersPlayer.one)
        ..[33] = const CheckersPiece(player: CheckersPlayer.two);
      final game = CheckersGame.custom(board: board);

      expect(game.move(42, 24), isTrue);
      expect(game.winner, CheckersPlayer.one);
    });
  });
}
