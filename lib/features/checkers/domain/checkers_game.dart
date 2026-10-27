import 'dart:collection';

enum CheckersPlayer { one, two }

class CheckersRules {
  const CheckersRules({
    this.mandatoryCapture = true,
    this.menCanCaptureBackward = true,
  });

  final bool mandatoryCapture;
  final bool menCanCaptureBackward;
}

class CheckersPiece {
  const CheckersPiece({required this.player, this.isKing = false});

  final CheckersPlayer player;
  final bool isKing;

  CheckersPiece promote() => CheckersPiece(player: player, isKing: true);
}

class CheckersMove {
  const CheckersMove({
    required this.from,
    required this.to,
    this.capturedIndex,
  });

  final int from;
  final int to;
  final int? capturedIndex;
  bool get isCapture => capturedIndex != null;
}

class CheckersGame {
  CheckersGame({
    CheckersPlayer firstPlayer = CheckersPlayer.one,
    this.rules = const CheckersRules(),
  }) : _board = _initialBoard(),
       _currentPlayer = firstPlayer;

  CheckersGame.custom({
    required List<CheckersPiece?> board,
    CheckersPlayer firstPlayer = CheckersPlayer.one,
    this.rules = const CheckersRules(),
  }) : assert(board.length == 64),
       _board = List.of(board),
       _currentPlayer = firstPlayer;

  static const _diagonals = [(-1, -1), (-1, 1), (1, -1), (1, 1)];

  final List<CheckersPiece?> _board;
  final CheckersRules rules;
  CheckersPlayer _currentPlayer;
  CheckersPlayer? _winner;
  int? _forcedPiece;

  UnmodifiableListView<CheckersPiece?> get board =>
      UnmodifiableListView(_board);
  CheckersPlayer get currentPlayer => _currentPlayer;
  CheckersPlayer? get winner => _winner;
  int? get forcedPiece => _forcedPiece;
  bool get isFinished => _winner != null;

  int pieceCount(CheckersPlayer player) =>
      _board.where((piece) => piece?.player == player).length;

  List<CheckersMove> legalMovesFor(int index) {
    if (!_isInsideIndex(index) || isFinished) return const [];
    final piece = _board[index];
    if (piece == null || piece.player != _currentPlayer) return const [];
    if (_forcedPiece != null && _forcedPiece != index) return const [];

    final captures = _captureMovesFor(index, piece);
    if (_forcedPiece == index) return captures;

    final allCaptures = _allCaptureMoves(_currentPlayer);
    if (rules.mandatoryCapture && allCaptures.isNotEmpty) {
      return captures;
    }
    return [...captures, ..._simpleMovesFor(index, piece)];
  }

  bool move(int from, int to) {
    final candidates = legalMovesFor(from);
    CheckersMove? selected;
    for (final move in candidates) {
      if (move.to == to) {
        selected = move;
        break;
      }
    }
    if (selected == null) return false;

    var piece = _board[from]!;
    _board[from] = null;
    if (selected.capturedIndex case final captured?) {
      _board[captured] = null;
    }

    final destinationRow = to ~/ 8;
    if (!piece.isKing &&
        ((piece.player == CheckersPlayer.one && destinationRow == 0) ||
            (piece.player == CheckersPlayer.two && destinationRow == 7))) {
      piece = piece.promote();
    }
    _board[to] = piece;

    if (selected.isCapture && _captureMovesFor(to, piece).isNotEmpty) {
      _forcedPiece = to;
      return true;
    }

    _forcedPiece = null;
    _currentPlayer = _opponentOf(_currentPlayer);
    _updateWinner();
    return true;
  }

  static List<CheckersPiece?> _initialBoard() {
    final board = List<CheckersPiece?>.filled(64, null);
    for (var row = 0; row < 3; row++) {
      for (var column = 0; column < 8; column++) {
        if ((row + column).isOdd) {
          board[row * 8 + column] = const CheckersPiece(
            player: CheckersPlayer.two,
          );
        }
      }
    }
    for (var row = 5; row < 8; row++) {
      for (var column = 0; column < 8; column++) {
        if ((row + column).isOdd) {
          board[row * 8 + column] = const CheckersPiece(
            player: CheckersPlayer.one,
          );
        }
      }
    }
    return board;
  }

  List<CheckersMove> _simpleMovesFor(int index, CheckersPiece piece) {
    if (piece.isKing) {
      return _slidingMovesFor(index);
    }

    final row = index ~/ 8;
    final column = index % 8;
    final direction = piece.player == CheckersPlayer.one ? -1 : 1;
    final moves = <CheckersMove>[];
    for (final columnDelta in [-1, 1]) {
      final targetRow = row + direction;
      final targetColumn = column + columnDelta;
      if (_isInside(targetRow, targetColumn)) {
        final target = targetRow * 8 + targetColumn;
        if (_board[target] == null) {
          moves.add(CheckersMove(from: index, to: target));
        }
      }
    }
    return moves;
  }

  List<CheckersMove> _slidingMovesFor(int index) {
    final moves = <CheckersMove>[];
    final originRow = index ~/ 8;
    final originColumn = index % 8;
    for (final (rowDelta, columnDelta) in _diagonals) {
      var row = originRow + rowDelta;
      var column = originColumn + columnDelta;
      while (_isInside(row, column)) {
        final target = row * 8 + column;
        if (_board[target] != null) break;
        moves.add(CheckersMove(from: index, to: target));
        row += rowDelta;
        column += columnDelta;
      }
    }
    return moves;
  }

  List<CheckersMove> _captureMovesFor(int index, CheckersPiece piece) {
    return piece.isKing
        ? _kingCaptureMoves(index, piece)
        : _manCaptureMoves(index, piece);
  }

  List<CheckersMove> _manCaptureMoves(int index, CheckersPiece piece) {
    final moves = <CheckersMove>[];
    final row = index ~/ 8;
    final column = index % 8;
    final direction = piece.player == CheckersPlayer.one ? -1 : 1;
    final diagonals = rules.menCanCaptureBackward
        ? _diagonals
        : [(direction, -1), (direction, 1)];
    for (final (rowDelta, columnDelta) in diagonals) {
      final capturedRow = row + rowDelta;
      final capturedColumn = column + columnDelta;
      final targetRow = row + rowDelta * 2;
      final targetColumn = column + columnDelta * 2;
      if (!_isInside(targetRow, targetColumn) ||
          !_isInside(capturedRow, capturedColumn)) {
        continue;
      }
      final captured = capturedRow * 8 + capturedColumn;
      final target = targetRow * 8 + targetColumn;
      final capturedPiece = _board[captured];
      if (capturedPiece != null &&
          capturedPiece.player != piece.player &&
          _board[target] == null) {
        moves.add(
          CheckersMove(from: index, to: target, capturedIndex: captured),
        );
      }
    }
    return moves;
  }

  List<CheckersMove> _kingCaptureMoves(int index, CheckersPiece piece) {
    final moves = <CheckersMove>[];
    final originRow = index ~/ 8;
    final originColumn = index % 8;
    for (final (rowDelta, columnDelta) in _diagonals) {
      var row = originRow + rowDelta;
      var column = originColumn + columnDelta;
      int? captured;
      while (_isInside(row, column)) {
        final target = row * 8 + column;
        final targetPiece = _board[target];
        if (targetPiece != null) {
          if (targetPiece.player == piece.player || captured != null) break;
          captured = target;
        } else if (captured != null) {
          moves.add(
            CheckersMove(from: index, to: target, capturedIndex: captured),
          );
        }
        row += rowDelta;
        column += columnDelta;
      }
    }
    return moves;
  }

  List<CheckersMove> _allCaptureMoves(CheckersPlayer player) {
    final moves = <CheckersMove>[];
    for (var index = 0; index < _board.length; index++) {
      final piece = _board[index];
      if (piece?.player == player) {
        moves.addAll(_captureMovesFor(index, piece!));
      }
    }
    return moves;
  }

  bool _hasAnyMove(CheckersPlayer player) {
    if (_allCaptureMoves(player).isNotEmpty) return true;
    for (var index = 0; index < _board.length; index++) {
      final piece = _board[index];
      if (piece?.player == player &&
          _simpleMovesFor(index, piece!).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  void _updateWinner() {
    if (pieceCount(_currentPlayer) == 0 || !_hasAnyMove(_currentPlayer)) {
      _winner = _opponentOf(_currentPlayer);
    }
  }

  static CheckersPlayer _opponentOf(CheckersPlayer player) {
    return player == CheckersPlayer.one
        ? CheckersPlayer.two
        : CheckersPlayer.one;
  }

  static bool _isInside(int row, int column) {
    return row >= 0 && row < 8 && column >= 0 && column < 8;
  }

  static bool _isInsideIndex(int index) => index >= 0 && index < 64;
}
