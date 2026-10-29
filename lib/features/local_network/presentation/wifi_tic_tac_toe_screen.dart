import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../tic_tac_toe/domain/tic_tac_toe_game.dart';
import '../data/local_room_client.dart';
import '../data/local_room_server.dart';
import '../domain/tic_tac_toe_room.dart';

class WifiTicTacToeScreen extends StatefulWidget {
  const WifiTicTacToeScreen.host({required LocalRoomServer server, super.key})
    : _server = server,
      _client = null;

  const WifiTicTacToeScreen.guest({required LocalRoomClient client, super.key})
    : _server = null,
      _client = client;

  final LocalRoomServer? _server;
  final LocalRoomClient? _client;

  bool get isHost => _server != null;

  @override
  State<WifiTicTacToeScreen> createState() => _WifiTicTacToeScreenState();
}

class _WifiTicTacToeScreenState extends State<WifiTicTacToeScreen> {
  StreamSubscription<RoomSnapshot>? _subscription;
  late RoomSnapshot _snapshot;
  String? _connectionError;

  PlayerMark get _localMark => widget.isHost ? PlayerMark.x : PlayerMark.o;

  @override
  void initState() {
    super.initState();
    _snapshot = widget._server?.snapshot ?? widget._client!.snapshot!;
    final stream = widget._server?.states ?? widget._client!.states;
    _subscription = stream.listen(
      (state) {
        if (!mounted) return;
        setState(() {
          _snapshot = state;
          _connectionError = null;
        });
      },
      onError: (_) {
        if (mounted) {
          setState(
            () => _connectionError = 'A conexão com a sala foi perdida.',
          );
        }
      },
      onDone: () {
        if (mounted && !widget.isHost) {
          setState(() => _connectionError = 'O anfitrião encerrou a sala.');
        }
      },
    );
  }

  @override
  void dispose() {
    final subscription = _subscription;
    if (subscription != null) unawaited(subscription.cancel());
    final server = widget._server;
    if (server != null) unawaited(server.close());
    final client = widget._client;
    if (client != null) unawaited(client.close());
    super.dispose();
  }

  void _play(int index) {
    if (!_snapshot.isReady ||
        _snapshot.isFinished ||
        _snapshot.currentPlayer != _localMark ||
        _snapshot.board[index] != null) {
      return;
    }
    if (widget.isHost) {
      widget._server!.playHost(index);
    } else {
      widget._client!.play(index);
    }
  }

  void _nextRound() {
    if (widget.isHost) {
      widget._server!.nextRound();
    } else {
      widget._client!.nextRound();
    }
  }

  String _nameFor(PlayerMark mark) {
    return mark == PlayerMark.x
        ? _snapshot.hostName
        : (_snapshot.guestName ?? 'Convidado');
  }

  String get _status {
    if (!_snapshot.isReady) return 'Aguardando o segundo jogador';
    if (_snapshot.winner case final winner?) {
      return '${_nameFor(winner)} venceu!';
    }
    if (_snapshot.isDraw) return 'Empate!';
    return 'Vez de ${_nameFor(_snapshot.currentPlayer)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.25,
            colors: [Color(0xFF173C4C), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
                sliver: SliverList.list(
                  children: [
                    const _TopBar(),
                    const SizedBox(height: 16),
                    if (widget.isHost)
                      _RoomAccessCard(
                        code: widget._server!.roomCode,
                        address:
                            '${widget._server!.localAddress}:${widget._server!.port}',
                      ),
                    if (widget.isHost) const SizedBox(height: 14),
                    if (_connectionError != null)
                      _ErrorCard(message: _connectionError!),
                    if (_connectionError != null) const SizedBox(height: 14),
                    _Scoreboard(snapshot: _snapshot),
                    const SizedBox(height: 14),
                    _TurnBanner(
                      status: _status,
                      localTurn:
                          _snapshot.isReady &&
                          !_snapshot.isFinished &&
                          _snapshot.currentPlayer == _localMark,
                    ),
                    const SizedBox(height: 18),
                    if (!_snapshot.isReady)
                      const _WaitingCard()
                    else ...[
                      _NetworkBoard(snapshot: _snapshot, onTap: _play),
                      const SizedBox(height: 18),
                      if (_snapshot.isFinished)
                        _ResultCard(text: _status, onNextRound: _nextRound)
                      else
                        Text(
                          _snapshot.currentPlayer == _localMark
                              ? 'Sua vez: toque em uma casa livre.'
                              : 'Aguarde a jogada de ${_nameFor(_snapshot.currentPlayer)}.',
                          textAlign: TextAlign.center,
                        ),
                    ],
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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Sair da sala',
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
              Text('Sala Wi-Fi · anfitrião valida as jogadas'),
            ],
          ),
        ),
        Icon(Icons.wifi_rounded, color: AppColors.primary),
      ],
    );
  }
}

class _RoomAccessCard extends StatelessWidget {
  const _RoomAccessCard({required this.code, required this.address});

  final String code;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('wifi-room-access'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, color: AppColors.primary, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Código da sala'),
                Text(
                  code,
                  key: const Key('wifi-room-code-display'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                Text('Conexão manual: $address'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.snapshot});

  final RoomSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerCard(
            name: snapshot.hostName,
            symbol: 'X',
            score: snapshot.scoreX,
            color: AppColors.primary,
            active:
                snapshot.isReady &&
                !snapshot.isFinished &&
                snapshot.currentPlayer == PlayerMark.x,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlayerCard(
            name: snapshot.guestName ?? 'Aguardando...',
            symbol: 'O',
            score: snapshot.scoreO,
            color: AppColors.cyan,
            active:
                snapshot.isReady &&
                !snapshot.isFinished &&
                snapshot.currentPlayer == PlayerMark.o,
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    required this.symbol,
    required this.score,
    required this.color,
    required this.active,
  });

  final String name;
  final String symbol;
  final int score;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.13) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Text(
            symbol,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
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

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.status, required this.localTurn});

  final String status;
  final bool localTurn;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('wifi-turn-status'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: localTurn ? AppColors.primary : AppColors.surfaceLight,
          width: localTurn ? 2 : 1,
        ),
      ),
      child: Text(
        localTurn ? '$status · SUA VEZ' : status,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: localTurn ? AppColors.primary : AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NetworkBoard extends StatelessWidget {
  const _NetworkBoard({required this.snapshot, required this.onTap});

  final RoomSnapshot snapshot;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            key: const Key('wifi-tic-tac-toe-board'),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final mark = snapshot.board[index];
              final winning = snapshot.winningCells.contains(index);
              final color = mark == PlayerMark.x
                  ? AppColors.primary
                  : AppColors.cyan;
              return InkWell(
                key: Key('wifi-cell-$index'),
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: winning
                        ? color.withValues(alpha: 0.22)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: winning ? color : AppColors.surfaceLight,
                      width: winning ? 3 : 1,
                    ),
                  ),
                  child: Text(
                    switch (mark) {
                      PlayerMark.x => 'X',
                      PlayerMark.o => 'O',
                      null => '',
                    },
                    style: TextStyle(
                      color: color,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  const _WaitingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('wifi-waiting-player'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 18),
          Text(
            'Aguardando o convidado entrar...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mantenha esta tela aberta e compartilhe o código da sala.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.text, required this.onNextRound});

  final String text;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('wifi-round-result'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Text(text, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('wifi-next-round'),
            onPressed: onNextRound,
            child: const Text('Jogar novamente'),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, textAlign: TextAlign.center),
    );
  }
}
