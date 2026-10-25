import 'dart:collection';

enum PlayerMark { x, o }

class TicTacToeGame {
  TicTacToeGame({PlayerMark firstPlayer = PlayerMark.x})
    : _currentPlayer = firstPlayer;

  static const _winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  final List<PlayerMark?> _board = List.filled(9, null);
  PlayerMark _currentPlayer;
  PlayerMark? _winner;
  List<int> _winningCells = const [];
  int _moves = 0;

  UnmodifiableListView<PlayerMark?> get board => UnmodifiableListView(_board);
  PlayerMark get currentPlayer => _currentPlayer;
  PlayerMark? get winner => _winner;
  UnmodifiableListView<int> get winningCells =>
      UnmodifiableListView(_winningCells);
  bool get isDraw => _moves == 9 && _winner == null;
  bool get isFinished => _winner != null || isDraw;

  bool playAt(int index) {
    if (index < 0 || index >= _board.length) {
      throw RangeError.index(index, _board, 'index');
    }
    if (isFinished || _board[index] != null) {
      return false;
    }

    _board[index] = _currentPlayer;
    _moves++;
    _findWinner();

    if (!isFinished) {
      _currentPlayer = _currentPlayer == PlayerMark.x
          ? PlayerMark.o
          : PlayerMark.x;
    }
    return true;
  }

  void reset({PlayerMark firstPlayer = PlayerMark.x}) {
    _board.fillRange(0, _board.length, null);
    _currentPlayer = firstPlayer;
    _winner = null;
    _winningCells = const [];
    _moves = 0;
  }

  void _findWinner() {
    for (final line in _winningLines) {
      final mark = _board[line.first];
      if (mark != null && mark == _board[line[1]] && mark == _board[line[2]]) {
        _winner = mark;
        _winningCells = List.unmodifiable(line);
        return;
      }
    }
  }
}
