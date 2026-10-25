import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/tic_tac_toe_game.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({
    required this.playerX,
    required this.playerO,
    super.key,
  });

  final String playerX;
  final String playerO;

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  final _game = TicTacToeGame();
  var _xScore = 0;
  var _oScore = 0;
  var _draws = 0;
  var _round = 1;
  var _roundStarter = PlayerMark.x;

  String _nameFor(PlayerMark mark) {
    return mark == PlayerMark.x ? widget.playerX : widget.playerO;
  }

  Color _colorFor(PlayerMark mark) {
    return mark == PlayerMark.x ? AppColors.primary : AppColors.secondary;
  }

  void _playAt(int index) {
    if (!_game.playAt(index)) return;

    setState(() {
      if (_game.winner == PlayerMark.x) _xScore++;
      if (_game.winner == PlayerMark.o) _oScore++;
      if (_game.isDraw) _draws++;
    });
  }

  void _nextRound() {
    setState(() {
      _roundStarter = _roundStarter == PlayerMark.x
          ? PlayerMark.o
          : PlayerMark.x;
      _round++;
      _game.reset(firstPlayer: _roundStarter);
    });
  }

  void _resetMatch() {
    setState(() {
      _xScore = 0;
      _oScore = 0;
      _draws = 0;
      _round = 1;
      _roundStarter = PlayerMark.x;
      _game.reset();
    });
  }

  String get _statusText {
    final winner = _game.winner;
    if (winner != null) return '${_nameFor(winner)} venceu!';
    if (_game.isDraw) return 'Rodada empatada';
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                sliver: SliverList.list(
                  children: [
                    _GameTopBar(onReset: _resetMatch),
                    const SizedBox(height: 20),
                    _Scoreboard(
                      playerX: widget.playerX,
                      playerO: widget.playerO,
                      xScore: _xScore,
                      oScore: _oScore,
                      draws: _draws,
                      activeMark: _game.isFinished ? null : _game.currentPlayer,
                    ),
                    const SizedBox(height: 22),
                    _StatusPill(
                      round: _round,
                      text: _statusText,
                      color: _game.winner == null
                          ? _colorFor(_game.currentPlayer)
                          : _colorFor(_game.winner!),
                    ),
                    const SizedBox(height: 20),
                    _Board(game: _game, onPlay: _playAt),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _game.isFinished
                          ? _RoundResult(
                              key: const Key('round-result'),
                              text: _statusText,
                              color: _game.winner == null
                                  ? AppColors.cyan
                                  : _colorFor(_game.winner!),
                              onNextRound: _nextRound,
                              onFinish: () => Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst),
                            )
                          : const _GameTip(key: Key('game-tip')),
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

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({required this.onReset});

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
                'Jogo da Velha',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('Mesmo celular'),
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
    required this.playerX,
    required this.playerO,
    required this.xScore,
    required this.oScore,
    required this.draws,
    required this.activeMark,
  });

  final String playerX;
  final String playerO;
  final int xScore;
  final int oScore;
  final int draws;
  final PlayerMark? activeMark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScoreCard(
            name: playerX,
            mark: 'X',
            score: xScore,
            color: AppColors.primary,
            active: activeMark == PlayerMark.x,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Text(
                'EMPATES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$draws',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ScoreCard(
            name: playerO,
            mark: 'O',
            score: oScore,
            color: AppColors.secondary,
            active: activeMark == PlayerMark.o,
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.name,
    required this.mark,
    required this.score,
    required this.color,
    required this.active,
  });

  final String name;
  final String mark;
  final int score;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.13) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color : AppColors.surfaceLight,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            mark,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.round,
    required this.text,
    required this.color,
  });

  final int round;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'Rodada $round  ·  $text',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.game, required this.onPlay});

  final TicTacToeGame game;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 430.0);
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final mark = game.board[index];
                final winning = game.winningCells.contains(index);
                final color = mark == null
                    ? AppColors.textSecondary
                    : mark == PlayerMark.x
                    ? AppColors.primary
                    : AppColors.secondary;

                return Material(
                  color: winning
                      ? color.withValues(alpha: 0.22)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    key: Key('cell-$index'),
                    onTap: () => onPlay(index),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: mark == null
                          ? const SizedBox.shrink()
                          : Icon(
                              mark == PlayerMark.x
                                  ? Icons.close_rounded
                                  : Icons.circle_outlined,
                              key: ValueKey(mark),
                              color: color,
                              size: size / 5,
                              weight: 800,
                            ),
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

class _GameTip extends StatelessWidget {
  const _GameTip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app_rounded, color: AppColors.textSecondary, size: 18),
        SizedBox(width: 8),
        Flexible(child: Text('Toque em uma casa vazia para jogar.')),
      ],
    );
  }
}

class _RoundResult extends StatelessWidget {
  const _RoundResult({
    required this.text,
    required this.color,
    required this.onNextRound,
    required this.onFinish,
    super.key,
  });

  final String text;
  final Color color;
  final VoidCallback onNextRound;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const Key('next-round'),
                  onPressed: onNextRound,
                  child: const Text('Jogar novamente'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: 'Voltar ao início',
                onPressed: onFinish,
                icon: const Icon(Icons.home_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
