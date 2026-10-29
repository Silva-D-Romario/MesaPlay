import 'dart:math';

import '../../tic_tac_toe/domain/tic_tac_toe_game.dart';

class RoomSnapshot {
  const RoomSnapshot({
    required this.roomCode,
    required this.hostName,
    required this.guestName,
    required this.guestConnected,
    required this.board,
    required this.currentPlayer,
    required this.winner,
    required this.winningCells,
    required this.isDraw,
    required this.scoreX,
    required this.scoreO,
    required this.round,
  });

  final String roomCode;
  final String hostName;
  final String? guestName;
  final bool guestConnected;
  final List<PlayerMark?> board;
  final PlayerMark currentPlayer;
  final PlayerMark? winner;
  final List<int> winningCells;
  final bool isDraw;
  final int scoreX;
  final int scoreO;
  final int round;

  bool get isReady => guestName != null && guestConnected;
  bool get isFinished => winner != null || isDraw;

  Map<String, Object?> toJson() => {
    'type': 'state',
    'roomCode': roomCode,
    'hostName': hostName,
    'guestName': guestName,
    'guestConnected': guestConnected,
    'board': board.map(_markName).toList(),
    'currentPlayer': _markName(currentPlayer),
    'winner': _markName(winner),
    'winningCells': winningCells,
    'isDraw': isDraw,
    'scoreX': scoreX,
    'scoreO': scoreO,
    'round': round,
  };

  factory RoomSnapshot.fromJson(Map<String, dynamic> json) {
    final rawBoard = json['board'];
    final rawWinningCells = json['winningCells'];
    if (rawBoard is! List || rawBoard.length != 9) {
      throw const FormatException('Tabuleiro de sala inválido');
    }
    return RoomSnapshot(
      roomCode: json['roomCode'] as String,
      hostName: json['hostName'] as String,
      guestName: json['guestName'] as String?,
      guestConnected: json['guestConnected'] as bool? ?? false,
      board: rawBoard.map((value) => _markFromName(value as String?)).toList(),
      currentPlayer: _markFromName(json['currentPlayer'] as String?)!,
      winner: _markFromName(json['winner'] as String?),
      winningCells: rawWinningCells is List
          ? rawWinningCells.cast<num>().map((value) => value.toInt()).toList()
          : const [],
      isDraw: json['isDraw'] as bool? ?? false,
      scoreX: (json['scoreX'] as num?)?.toInt() ?? 0,
      scoreO: (json['scoreO'] as num?)?.toInt() ?? 0,
      round: (json['round'] as num?)?.toInt() ?? 1,
    );
  }

  static String? _markName(PlayerMark? mark) => switch (mark) {
    PlayerMark.x => 'x',
    PlayerMark.o => 'o',
    null => null,
  };

  static PlayerMark? _markFromName(String? value) => switch (value) {
    'x' => PlayerMark.x,
    'o' => PlayerMark.o,
    _ => null,
  };
}

class TicTacToeRoom {
  TicTacToeRoom({required this.hostName, String? roomCode})
    : roomCode = roomCode ?? generateRoomCode();

  final String hostName;
  final String roomCode;
  String? _guestName;
  bool _guestConnected = false;
  TicTacToeGame _game = TicTacToeGame();
  PlayerMark _starter = PlayerMark.x;
  int _scoreX = 0;
  int _scoreO = 0;
  int _round = 1;
  bool _roundScored = false;

  RoomSnapshot get snapshot => RoomSnapshot(
    roomCode: roomCode,
    hostName: hostName,
    guestName: _guestName,
    guestConnected: _guestConnected,
    board: _game.board.toList(),
    currentPlayer: _game.currentPlayer,
    winner: _game.winner,
    winningCells: _game.winningCells.toList(),
    isDraw: _game.isDraw,
    scoreX: _scoreX,
    scoreO: _scoreO,
    round: _round,
  );

  bool joinGuest(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty ||
        (_guestName != null && _guestName != normalized)) {
      return false;
    }
    _guestName = normalized;
    _guestConnected = true;
    return true;
  }

  void setGuestConnected(bool connected) {
    _guestConnected = connected && _guestName != null;
  }

  bool playAs(PlayerMark player, int index) {
    if (!snapshot.isReady || player != _game.currentPlayer) return false;
    final played = _game.playAt(index);
    if (!played || !_game.isFinished || _roundScored) return played;
    if (_game.winner == PlayerMark.x) _scoreX++;
    if (_game.winner == PlayerMark.o) _scoreO++;
    _roundScored = true;
    return true;
  }

  bool nextRound() {
    if (!snapshot.isReady || !_game.isFinished) return false;
    _starter = _starter == PlayerMark.x ? PlayerMark.o : PlayerMark.x;
    _game = TicTacToeGame(firstPlayer: _starter);
    _round++;
    _roundScored = false;
    return true;
  }

  static String generateRoomCode([Random? random]) {
    final generator = random ?? Random.secure();
    return (100000 + generator.nextInt(900000)).toString();
  }
}
