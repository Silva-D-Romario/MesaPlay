import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/checkers_game.dart';
import 'checkers_colors.dart';

class CheckersScreen extends StatefulWidget {
  const CheckersScreen({
    required this.playerOne,
    required this.playerTwo,
    required this.boardColors,
    required this.pieceColors,
    super.key,
  });

  final String playerOne;
  final String playerTwo;
  final CheckersBoardColors boardColors;
  final CheckersPieceColors pieceColors;

  @override
  State<CheckersScreen> createState() => _CheckersScreenState();
}

class _CheckersScreenState extends State<CheckersScreen> {
  late CheckersGame _game;
  var _scoreOne = 0;
  var _scoreTwo = 0;
  var _round = 1;
  var _starter = CheckersPlayer.one;
  int? _selected;
  var _winnerCounted = false;

  @override
  void initState() {
    super.initState();
    _game = CheckersGame();
  }

  String _nameFor(CheckersPlayer player) {
    return player == CheckersPlayer.one ? widget.playerOne : widget.playerTwo;
  }

  Color _colorFor(CheckersPlayer player) {
    return player == CheckersPlayer.one
        ? widget.pieceColors.playerOne
        : widget.pieceColors.playerTwo;
  }

  void _tapCell(int index) {
    if (_game.isFinished) return;
    final piece = _game.board[index];

    if (_selected != null &&
        _game.legalMovesFor(_selected!).any((move) => move.to == index)) {
      setState(() {
        _game.move(_selected!, index);
        _selected = _game.forcedPiece;
        final winner = _game.winner;
        if (winner != null && !_winnerCounted) {
          winner == CheckersPlayer.one ? _scoreOne++ : _scoreTwo++;
          _winnerCounted = true;
        }
      });
      return;
    }

    if (piece?.player == _game.currentPlayer &&
        _game.legalMovesFor(index).isNotEmpty) {
      setState(() => _selected = index);
    } else if (_game.forcedPiece == null) {
      setState(() => _selected = null);
    }
  }

  void _nextRound() {
    setState(() {
      _starter = _starter == CheckersPlayer.one
          ? CheckersPlayer.two
          : CheckersPlayer.one;
      _game = CheckersGame(firstPlayer: _starter);
      _selected = null;
      _winnerCounted = false;
      _round++;
    });
  }

  void _resetMatch() {
    setState(() {
      _scoreOne = 0;
      _scoreTwo = 0;
      _round = 1;
      _starter = CheckersPlayer.one;
      _game = CheckersGame();
      _selected = null;
      _winnerCounted = false;
    });
  }

  String get _status {
    if (_game.winner case final winner?) {
      return '${_nameFor(winner)} venceu!';
    }
    if (_game.forcedPiece != null) {
      return '${_nameFor(_game.currentPlayer)} deve continuar capturando';
    }
    return 'Vez de ${_nameFor(_game.currentPlayer)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.25,
            colors: [Color(0xFF20214A), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                sliver: SliverList.list(
                  children: [
                    _TopBar(onReset: _resetMatch),
                    const SizedBox(height: 18),
                    _Scoreboard(
                      playerOne: widget.playerOne,
                      playerTwo: widget.playerTwo,
                      scoreOne: _scoreOne,
                      scoreTwo: _scoreTwo,
                      pieceOne: widget.pieceColors.playerOne,
                      pieceTwo: widget.pieceColors.playerTwo,
                      active: _game.isFinished ? null : _game.currentPlayer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rodada $_round  ·  $_status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _game.winner == null
                            ? _colorFor(_game.currentPlayer)
                            : _colorFor(_game.winner!),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CheckersBoard(
                      key: const Key('checkers-board'),
                      game: _game,
                      selected: _selected,
                      boardColors: widget.boardColors,
                      pieceColors: widget.pieceColors,
                      onTap: _tapCell,
                    ),
                    const SizedBox(height: 18),
                    if (_game.isFinished)
                      _ResultCard(
                        text: _status,
                        color: _colorFor(_game.winner!),
                        onNextRound: _nextRound,
                      )
                    else
                      const _RulesTip(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Damas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('Mesmo celular · tabuleiro 8 × 8'),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Zerar placar',
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({
    required this.playerOne,
    required this.playerTwo,
    required this.scoreOne,
    required this.scoreTwo,
    required this.pieceOne,
    required this.pieceTwo,
    required this.active,
  });

  final String playerOne;
  final String playerTwo;
  final int scoreOne;
  final int scoreTwo;
  final Color pieceOne;
  final Color pieceTwo;
  final CheckersPlayer? active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerCard(
            name: playerOne,
            score: scoreOne,
            color: pieceOne,
            active: active == CheckersPlayer.one,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '×',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _PlayerCard(
            name: playerTwo,
            score: scoreTwo,
            color: pieceTwo,
            active: active == CheckersPlayer.two,
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    required this.score,
    required this.color,
    required this.active,
  });

  final String name;
  final int score;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.14) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? color : AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 9, backgroundColor: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('$score vitória${score == 1 ? '' : 's'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckersBoard extends StatelessWidget {
  const _CheckersBoard({
    required this.game,
    required this.selected,
    required this.boardColors,
    required this.pieceColors,
    required this.onTap,
    super.key,
  });

  final CheckersGame game;
  final int? selected;
  final CheckersBoardColors boardColors;
  final CheckersPieceColors pieceColors;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final destinations = selected == null
        ? const <int>[]
        : game.legalMovesFor(selected!).map((move) => move.to).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 560.0);
        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 28),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                final row = index ~/ 8;
                final column = index % 8;
                final piece = game.board[index];
                final isSelected = selected == index;
                final isDestination = destinations.contains(index);
                final squareColor = (row + column).isEven
                    ? boardColors.light
                    : boardColors.dark;
                final pieceColor = piece?.player == CheckersPlayer.one
                    ? pieceColors.playerOne
                    : pieceColors.playerTwo;

                return GestureDetector(
                  key: Key('checkers-cell-$index'),
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    color: isSelected
                        ? Color.alphaBlend(
                            AppColors.primary.withValues(alpha: 0.42),
                            squareColor,
                          )
                        : squareColor,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isDestination)
                          Container(
                            width: size / 28,
                            height: size / 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.72),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (piece != null)
                          Container(
                            width: size / 11,
                            height: size / 11,
                            decoration: BoxDecoration(
                              color: pieceColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.65),
                                width: isSelected ? 3 : 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: piece.isKing
                                ? Icon(
                                    Icons.workspace_premium_rounded,
                                    size: size / 20,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RulesTip extends StatelessWidget {
  const _RulesTip();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Selecione uma peça e depois uma casa destacada. Capturas são obrigatórias e podem continuar na mesma jogada.',
      textAlign: TextAlign.center,
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.text,
    required this.color,
    required this.onNextRound,
  });

  final String text;
  final Color color;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 36),
          const SizedBox(height: 8),
          Text(text, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onNextRound,
            child: const Text('Jogar novamente'),
          ),
        ],
      ),
    );
  }
}
