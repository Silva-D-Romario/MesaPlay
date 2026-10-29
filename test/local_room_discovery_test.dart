import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:asobiplay/features/local_network/data/local_room_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('responde à descoberta do código da sala por UDP', () async {
    final responder = await LocalRoomDiscoveryResponder.start(
      roomCode: '123456',
      serverPort: 43210,
    );
    addTearDown(responder.close);
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    addTearDown(socket.close);
    final response = Completer<String>();
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram != null && !response.isCompleted) {
        response.complete(utf8.decode(datagram.data));
      }
    });

    socket.send(
      utf8.encode('ASOBIPLAY_DISCOVER:123456'),
      InternetAddress.loopbackIPv4,
      LocalRoomDiscoveryResponder.discoveryPort,
    );

    expect(
      await response.future.timeout(const Duration(seconds: 2)),
      'ASOBIPLAY_ROOM:123456:43210',
    );
  });
}
