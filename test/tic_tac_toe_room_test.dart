import 'package:asobiplay/features/local_network/domain/tic_tac_toe_room.dart';
import 'package:asobiplay/features/tic_tac_toe/domain/tic_tac_toe_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicTacToeRoom', () {
    test('aguarda o convidado antes de aceitar jogadas', () {
      final room = TicTacToeRoom(hostName: 'Romario', roomCode: '123456');

      expect(room.playAs(PlayerMark.x, 0), isFalse);
      expect(room.joinGuest('Bia'), isTrue);
      expect(room.snapshot.isReady, isTrue);
      expect(room.playAs(PlayerMark.x, 0), isTrue);
      expect(room.playAs(PlayerMark.x, 1), isFalse);
      expect(room.playAs(PlayerMark.o, 1), isTrue);
    });

    test('valida jogadas, placar e alternância da revanche', () {
      final room = TicTacToeRoom(hostName: 'Romario', roomCode: '123456')
        ..joinGuest('Bia');

      for (final move in [
        (PlayerMark.x, 0),
        (PlayerMark.o, 3),
        (PlayerMark.x, 1),
        (PlayerMark.o, 4),
        (PlayerMark.x, 2),
      ]) {
        expect(room.playAs(move.$1, move.$2), isTrue);
      }

      expect(room.snapshot.winner, PlayerMark.x);
      expect(room.snapshot.scoreX, 1);
      expect(room.nextRound(), isTrue);
      expect(room.snapshot.currentPlayer, PlayerMark.o);
      expect(room.snapshot.round, 2);
    });

    test('serializa e restaura o estado enviado pela rede', () {
      final room = TicTacToeRoom(hostName: 'Romario', roomCode: '654321')
        ..joinGuest('Bia')
        ..playAs(PlayerMark.x, 4);

      final restored = RoomSnapshot.fromJson(room.snapshot.toJson());

      expect(restored.roomCode, '654321');
      expect(restored.hostName, 'Romario');
      expect(restored.guestName, 'Bia');
      expect(restored.board[4], PlayerMark.x);
      expect(restored.currentPlayer, PlayerMark.o);
    });

    test('impede que outro nome ocupe uma sala já reservada', () {
      final room = TicTacToeRoom(hostName: 'Romario')..joinGuest('Bia');

      expect(room.joinGuest('Outra pessoa'), isFalse);
    });
  });
}
