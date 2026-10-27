import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/connect_four_game.dart';

class ConnectFourScreen extends StatefulWidget {
  const ConnectFourScreen({
    required this.playerOne,
    required this.playerTwo,
    super.key,
  });

  final String playerOne;
  final String playerTwo;

  @override
  State<ConnectFourScreen> createState() => _ConnectFourScreenState();
}

class _ConnectFourScreenState extends State<ConnectFourScreen> {
  late ConnectFourGame _game;
  var _scoreOne = 0;
  var _scoreTwo = 0;
  var _round = 1;
  var _starter = ConnectFourPlayer.one;
  var _winnerCounted = false;

  static const _playerOneColor = AppColors.coral;
  static const _playerTwoColor = Color(0xFFFFD166);

  @override
  void initState() {
    super.initState();
    _game = ConnectFourGame();
  }

  String _nameFor(ConnectFourPlayer player) {
    return player == ConnectFourPlayer.one
        ? widget.playerOne
        : widget.playerTwo;
  }

  Color _colorFor(ConnectFourPlayer player) {
    return player == ConnectFourPlayer.one ? _playerOneColor : _playerTwoColor;
  }

  void _drop(int column) {
    if (!_game.dropPiece(column)) return;
    setState(() {
      final winner = _game.winner;
      if (winner != null && !_winnerCounted) {
        winner == ConnectFourPlayer.one ? _scoreOne++ : _scoreTwo++;
        _winnerCounted = true;
      }
    });
  }

  void _nextRound() {
    setState(() {
      _starter = _starter == ConnectFourPlayer.one
          ? ConnectFourPlayer.two
          : ConnectFourPlayer.one;
      _game = ConnectFourGame(firstPlayer: _starter);
      _winnerCounted = false;
      _round++;
    });
  }

  void _resetMatch() {
    setState(() {
      _scoreOne = 0;
      _scoreTwo = 0;
      _round = 1;
      _starter = ConnectFourPlayer.one;
      _game = ConnectFourGame();
      _winnerCounted = false;
    });
  }

  String get _status {
    if (_game.winner case final winner?) {
      return '${_nameFor(winner)} conectou quatro!';
    }
    if (_game.isDraw) return 'Empate! O tabuleiro ficou cheio.';
    return 'Vez de ${_nameFor(_game.currentPlayer)}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _game.winner == null
        ? _colorFor(_game.currentPlayer)
        : _colorFor(_game.winner!);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.25,
            colors: [Color(0xFF3D253A), AppColors.background],
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
                      active: _game.isFinished ? null : _game.currentPlayer,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      key: const Key('connect-four-turn'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.8),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Rodada $_round  ·  $_status',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ConnectFourBoard(game: _game, onDrop: _drop),
                    const SizedBox(height: 18),
                    if (_game.isFinished)
                      _ResultCard(
                        text: _status,
                        color: statusColor,
                        onNextRound: _nextRound,
                      )
                    else
                      const Text(
                        'Toque em uma coluna. A primeira sequência de quatro peças vence.',
                        textAlign: TextAlign.center,
                      ),
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
                'Lig 4',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('Mesmo celular · 7 colunas × 6 linhas'),
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
    required this.active,
  });

  final String playerOne;
  final String playerTwo;
  final int scoreOne;
  final int scoreTwo;
  final ConnectFourPlayer? active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerCard(
            name: playerOne,
            score: scoreOne,
            color: _ConnectFourScreenState._playerOneColor,
            active: active == ConnectFourPlayer.one,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlayerCard(
            name: playerTwo,
            score: scoreTwo,
            color: _ConnectFourScreenState._playerTwoColor,
            active: active == ConnectFourPlayer.two,
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.16) : AppColors.surface,
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
                    fontWeight: FontWeight.w800,
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

class _ConnectFourBoard extends StatelessWidget {
  const _ConnectFourBoard({required this.game, required this.onDrop});

  final ConnectFourGame game;
  final ValueChanged<int> onDrop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 590.0);
        final height = width * ConnectFourGame.rows / ConnectFourGame.columns;
        return Center(
          child: SizedBox(
            key: const Key('connect-four-board'),
            width: width,
            height: height,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3457D5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 24),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ConnectFourGame.columns,
                        ),
                    itemCount: ConnectFourGame.rows * ConnectFourGame.columns,
                    itemBuilder: (context, index) {
                      final player = game.board[index];
                      final color = switch (player) {
                        ConnectFourPlayer.one => AppColors.coral,
                        ConnectFourPlayer.two => const Color(0xFFFFD166),
                        null => AppColors.background,
                      };
                      final winner = game.winningCells.contains(index);
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: winner ? Colors.white : Colors.white24,
                              width: winner ? 4 : 1,
                            ),
                            boxShadow: winner
                                ? const [
                                    BoxShadow(
                                      color: Colors.white54,
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: List.generate(
                    ConnectFourGame.columns,
                    (column) => Expanded(
                      child: GestureDetector(
                        key: Key('connect-four-column-$column'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onDrop(column),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      key: const Key('connect-four-result'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 38),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('next-connect-four-round'),
            onPressed: onNextRound,
            child: const Text('Jogar novamente'),
          ),
        ],
      ),
    );
  }
}
