import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/tic_tac_toe_room.dart';

class LocalRoomClient {
  LocalRoomClient._(this._socket);

  final WebSocket _socket;
  final StreamController<RoomSnapshot> _states =
      StreamController<RoomSnapshot>.broadcast(sync: true);
  RoomSnapshot? _snapshot;

  Stream<RoomSnapshot> get states => _states.stream;
  RoomSnapshot? get snapshot => _snapshot;

  static Future<LocalRoomClient> connect({
    required String address,
    required int port,
    required String guestName,
  }) async {
    final socket = await WebSocket.connect(
      'ws://${address.trim()}:$port/ws',
    ).timeout(const Duration(seconds: 6));
    final client = LocalRoomClient._(socket);
    final firstState = Completer<void>();
    socket.listen(
      (message) => client._handleMessage(message, firstState),
      onDone: () {
        if (!firstState.isCompleted) {
          firstState.completeError(StateError('Conexão encerrada pela sala'));
        }
        client._states.close();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!firstState.isCompleted) {
          firstState.completeError(error, stackTrace);
        }
        if (!client._states.isClosed) {
          client._states.addError(error, stackTrace);
        }
      },
      cancelOnError: true,
    );
    socket.add(jsonEncode({'type': 'join', 'name': guestName.trim()}));
    await firstState.future.timeout(const Duration(seconds: 6));
    return client;
  }

  void _handleMessage(dynamic rawMessage, Completer<void> firstState) {
    try {
      final decoded = jsonDecode(rawMessage as String);
      if (decoded is! Map<String, dynamic> || decoded['type'] != 'state') {
        return;
      }
      final state = RoomSnapshot.fromJson(decoded);
      _snapshot = state;
      if (!_states.isClosed) _states.add(state);
      if (!firstState.isCompleted) firstState.complete();
    } on Object catch (error, stackTrace) {
      if (!firstState.isCompleted) firstState.completeError(error, stackTrace);
    }
  }

  void play(int index) {
    _socket.add(jsonEncode({'type': 'move', 'index': index}));
  }

  void nextRound() {
    _socket.add(jsonEncode({'type': 'next_round'}));
  }

  Future<void> close() => _socket.close();
}
