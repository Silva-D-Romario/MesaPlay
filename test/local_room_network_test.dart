import 'package:asobiplay/features/local_network/data/local_room_client.dart';
import 'package:asobiplay/features/local_network/data/local_room_server.dart';
import 'package:asobiplay/features/tic_tac_toe/domain/tic_tac_toe_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sincroniza anfitrião e convidado por WebSocket', () async {
    final server = await LocalRoomServer.start(
      hostName: 'Romario',
      roomCode: '123456',
      enableDiscovery: false,
    );
    addTearDown(server.close);
    final client = await LocalRoomClient.connect(
      address: '127.0.0.1',
      port: server.port,
      guestName: 'Bia',
    );
    addTearDown(client.close);

    expect(client.snapshot?.isReady, isTrue);
    expect(server.playHost(0), isTrue);
    final guestTurn = await client.states.firstWhere(
      (state) => state.board[0] == PlayerMark.x,
    );
    expect(guestTurn.currentPlayer, PlayerMark.o);

    client.play(4);
    final hostState = await server.states.firstWhere(
      (state) => state.board[4] == PlayerMark.o,
    );
    expect(hostState.currentPlayer, PlayerMark.x);
  });
}
