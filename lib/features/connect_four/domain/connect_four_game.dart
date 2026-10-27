import 'dart:collection';

enum ConnectFourPlayer { one, two }

class ConnectFourGame {
  ConnectFourGame({ConnectFourPlayer firstPlayer = ConnectFourPlayer.one})
    : _currentPlayer = firstPlayer;

  static const rows = 6;
  static const columns = 7;

  final List<ConnectFourPlayer?> _board = List.filled(rows * columns, null);
  ConnectFourPlayer _currentPlayer;
  ConnectFourPlayer? _winner;
  Set<int> _winningCells = const {};

  UnmodifiableListView<ConnectFourPlayer?> get board =>
      UnmodifiableListView(_board);
  ConnectFourPlayer get currentPlayer => _currentPlayer;
  ConnectFourPlayer? get winner => _winner;
  Set<int> get winningCells => Set.unmodifiable(_winningCells);
  bool get isDraw => _winner == null && _board.every((cell) => cell != null);
  bool get isFinished => _winner != null || isDraw;

  bool canDrop(int column) {
    return column >= 0 &&
        column < columns &&
        !isFinished &&
        _board[column] == null;
  }

  bool dropPiece(int column) {
    if (!canDrop(column)) return false;
    for (var row = rows - 1; row >= 0; row--) {
      final index = row * columns + column;
      if (_board[index] != null) continue;
      _board[index] = _currentPlayer;
      final line = _winningLineFor(row, column, _currentPlayer);
      if (line.isNotEmpty) {
        _winner = _currentPlayer;
        _winningCells = line;
      } else if (!isDraw) {
        _currentPlayer = _opponentOf(_currentPlayer);
      }
      return true;
    }
    return false;
  }

  Set<int> _winningLineFor(int row, int column, ConnectFourPlayer player) {
    const directions = [(0, 1), (1, 0), (1, 1), (1, -1)];
    for (final (rowDelta, columnDelta) in directions) {
      final line = <int>[row * columns + column];
      _collect(line, row, column, rowDelta, columnDelta, player);
      _collect(line, row, column, -rowDelta, -columnDelta, player);
      if (line.length >= 4) return line.toSet();
    }
    return const {};
  }

  void _collect(
    List<int> line,
    int originRow,
    int originColumn,
    int rowDelta,
    int columnDelta,
    ConnectFourPlayer player,
  ) {
    var row = originRow + rowDelta;
    var column = originColumn + columnDelta;
    while (_isInside(row, column)) {
      final index = row * columns + column;
      if (_board[index] != player) return;
      line.add(index);
      row += rowDelta;
      column += columnDelta;
    }
  }

  static bool _isInside(int row, int column) {
    return row >= 0 && row < rows && column >= 0 && column < columns;
  }

  static ConnectFourPlayer _opponentOf(ConnectFourPlayer player) {
    return player == ConnectFourPlayer.one
        ? ConnectFourPlayer.two
        : ConnectFourPlayer.one;
  }
}
