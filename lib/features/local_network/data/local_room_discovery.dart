import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DiscoveredRoom {
  const DiscoveredRoom({
    required this.address,
    required this.port,
    required this.hostName,
  });

  final String address;
  final int port;
  final String hostName;
}

class LocalRoomDiscoveryResponder {
  LocalRoomDiscoveryResponder._(this._socket, this.roomCode, this.serverPort) {
    _subscription = _socket.listen(_handleEvent);
  }

  static const discoveryPort = 40404;
  static const _requestPrefix = 'ASOBIPLAY_DISCOVER:';
  static const _responsePrefix = 'ASOBIPLAY_ROOM:';

  final RawDatagramSocket _socket;
  final String roomCode;
  final int serverPort;
  late final StreamSubscription<RawSocketEvent> _subscription;

  static Future<LocalRoomDiscoveryResponder> start({
    required String roomCode,
    required int serverPort,
  }) async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
    );
    return LocalRoomDiscoveryResponder._(socket, roomCode, serverPort);
  }

  void _handleEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket.receive();
    if (datagram == null) return;
    final message = utf8.decode(datagram.data, allowMalformed: true);
    if (message != '$_requestPrefix$roomCode') return;
    final response = utf8.encode('$_responsePrefix$roomCode:$serverPort');
    _socket.send(response, datagram.address, datagram.port);
  }

  Future<void> close() async {
    await _subscription.cancel();
    _socket.close();
  }

  static Future<DiscoveredRoom?> find(
    String roomCode, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final normalized = roomCode.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalized)) return null;
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final completer = Completer<DiscoveredRoom?>();
    late final StreamSubscription<RawSocketEvent> subscription;
    Timer? timer;

    void finish(DiscoveredRoom? room) {
      if (completer.isCompleted) return;
      completer.complete(room);
      timer?.cancel();
      subscription.cancel();
      socket.close();
    }

    subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      final response = utf8.decode(datagram.data, allowMalformed: true);
      final match = RegExp(
        '^$_responsePrefix$normalized:(\\d+)\$',
      ).firstMatch(response);
      if (match == null) return;
      finish(
        DiscoveredRoom(
          address: datagram.address.address,
          port: int.parse(match.group(1)!),
          hostName: datagram.address.host,
        ),
      );
    });
    timer = Timer(timeout, () => finish(null));
    socket.send(
      utf8.encode('$_requestPrefix$normalized'),
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );
    return completer.future;
  }
}
