import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/hangman_game.dart';

enum _HangmanPhase { chooseWord, handoff, guessing }

class HangmanScreen extends StatefulWidget {
  const HangmanScreen({
    required this.playerOne,
    required this.playerTwo,
    super.key,
  });

  final String playerOne;
  final String playerTwo;

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  final _wordFormKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _hintController = TextEditingController();
  _HangmanPhase _phase = _HangmanPhase.chooseWord;
  HangmanGame? _game;
  var _secretWord = '';
  var _hint = '';
  var _setterIsPlayerOne = true;
  var _scoreOne = 0;
  var _scoreTwo = 0;
  var _round = 1;
  var _showSecret = false;
  var _roundScored = false;

  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  void dispose() {
    _wordController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  String get _setter =>
      _setterIsPlayerOne ? widget.playerOne : widget.playerTwo;
  String get _guesser =>
      _setterIsPlayerOne ? widget.playerTwo : widget.playerOne;

  String? _validateWord(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a palavra';
    final letters = value.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    if (letters.length < 2) return 'Use pelo menos duas letras';
    if (value.trim().length > 28) return 'Use no máximo 28 caracteres';
    return null;
  }

  void _saveSecret() {
    if (!_wordFormKey.currentState!.validate()) return;
    setState(() {
      _secretWord = _wordController.text.trim();
      _hint = _hintController.text.trim();
      _wordController.clear();
      _hintController.clear();
      _showSecret = false;
      _phase = _HangmanPhase.handoff;
    });
  }

  void _startGuessing() {
    setState(() {
      _game = HangmanGame(secretWord: _secretWord);
      _roundScored = false;
      _phase = _HangmanPhase.guessing;
    });
  }

  void _guess(String letter) {
    final game = _game;
    if (game == null || !game.guess(letter)) return;
    setState(() {
      if (game.isFinished && !_roundScored) {
        if (game.isWon) {
          _setterIsPlayerOne ? _scoreTwo++ : _scoreOne++;
        } else {
          _setterIsPlayerOne ? _scoreOne++ : _scoreTwo++;
        }
        _roundScored = true;
      }
    });
  }

  void _nextRound() {
    setState(() {
      _setterIsPlayerOne = !_setterIsPlayerOne;
      _round++;
      _game = null;
      _secretWord = '';
      _hint = '';
      _roundScored = false;
      _phase = _HangmanPhase.chooseWord;
    });
  }

  void _resetMatch() {
    setState(() {
      _setterIsPlayerOne = true;
      _scoreOne = 0;
      _scoreTwo = 0;
      _round = 1;
      _game = null;
      _secretWord = '';
      _hint = '';
      _roundScored = false;
      _phase = _HangmanPhase.chooseWord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.25,
            colors: [Color(0xFF0D3A42), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                sliver: SliverList.list(
                  children: [
                    _TopBar(onReset: _resetMatch),
                    const SizedBox(height: 18),
                    _Scoreboard(
                      playerOne: widget.playerOne,
                      playerTwo: widget.playerTwo,
                      scoreOne: _scoreOne,
                      scoreTwo: _scoreTwo,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rodada $_round',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: switch (_phase) {
                        _HangmanPhase.chooseWord => _WordEntry(
                          key: const ValueKey('word-entry'),
                          formKey: _wordFormKey,
                          setter: _setter,
                          guesser: _guesser,
                          wordController: _wordController,
                          hintController: _hintController,
                          showSecret: _showSecret,
                          validateWord: _validateWord,
                          onToggleVisibility: () =>
                              setState(() => _showSecret = !_showSecret),
                          onSubmit: _saveSecret,
                        ),
                        _HangmanPhase.handoff => _Handoff(
                          key: const ValueKey('handoff'),
                          guesser: _guesser,
                          onReady: _startGuessing,
                        ),
                        _HangmanPhase.guessing => _GuessingBoard(
                          key: const ValueKey('guessing'),
                          game: _game!,
                          guesser: _guesser,
                          setter: _setter,
                          hint: _hint,
                          alphabet: _alphabet,
                          onGuess: _guess,
                          onNextRound: _nextRound,
                        ),
                      },
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
                'Forca',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('Mesmo celular · sete tentativas'),
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
  });

  final String playerOne;
  final String playerTwo;
  final int scoreOne;
  final int scoreTwo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Score(name: playerOne, score: scoreOne),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '×',
              style: TextStyle(
                color: AppColors.cyan,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: _Score(
              name: playerTwo,
              score: scoreTwo,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({
    required this.name,
    required this.score,
    this.textAlign = TextAlign.start,
  });

  final String name;
  final int score;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.start
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
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
        Text('$score ponto${score == 1 ? '' : 's'}', textAlign: textAlign),
      ],
    );
  }
}

class _WordEntry extends StatelessWidget {
  const _WordEntry({
    required this.formKey,
    required this.setter,
    required this.guesser,
    required this.wordController,
    required this.hintController,
    required this.showSecret,
    required this.validateWord,
    required this.onToggleVisibility,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final String setter;
  final String guesser;
  final TextEditingController wordController;
  final TextEditingController hintController;
  final bool showSecret;
  final FormFieldValidator<String> validateWord;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.cyan, size: 42),
            const SizedBox(height: 14),
            Text(
              '$setter escolhe a palavra',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Não deixe $guesser olhar para a tela agora.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('secret-word'),
              controller: wordController,
              validator: validateWord,
              obscureText: !showSecret,
              maxLength: 28,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('Palavra secreta').copyWith(
                counterText: '',
                suffixIcon: IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    showSecret
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('word-hint'),
              controller: hintController,
              maxLength: 50,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(
                'Dica opcional',
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('save-secret'),
              onPressed: onSubmit,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Guardar palavra'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handoff extends StatelessWidget {
  const _Handoff({required this.guesser, required this.onReady, super.key});

  final String guesser;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          const Icon(
            Icons.mobile_screen_share_rounded,
            color: AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: 18),
          Text(
            'Passe o celular para $guesser',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          const Text(
            'A palavra já foi escondida. Toque abaixo quando o novo jogador estiver pronto.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('ready-to-guess'),
              onPressed: onReady,
              child: const Text('Estou pronto'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuessingBoard extends StatelessWidget {
  const _GuessingBoard({
    required this.game,
    required this.guesser,
    required this.setter,
    required this.hint,
    required this.alphabet,
    required this.onGuess,
    required this.onNextRound,
    super.key,
  });

  final HangmanGame game;
  final String guesser;
  final String setter;
  final String hint;
  final String alphabet;
  final ValueChanged<String> onGuess;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          child: Column(
            children: [
              SizedBox(
                height: 210,
                child: CustomPaint(
                  key: const Key('hangman-drawing'),
                  painter: HangmanPainter(errors: game.errors),
                  size: const Size(double.infinity, 210),
                ),
              ),
              Text(
                game.isLost ? game.secretWord.toUpperCase() : game.maskedWord,
                key: const Key('masked-word'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              if (hint.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Dica: $hint', textAlign: TextAlign.center),
              ],
              const SizedBox(height: 10),
              Text(
                '${game.errors} de ${game.maxErrors} erros',
                style: const TextStyle(color: AppColors.coral),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (!game.isFinished)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: alphabet.split('').map((letter) {
              final used =
                  game.guessedLetters.contains(letter) ||
                  game.wrongLetters.contains(letter);
              return SizedBox(
                width: 42,
                height: 42,
                child: FilledButton(
                  key: Key('letter-$letter'),
                  onPressed: used ? null : () => onGuess(letter),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.surfaceLight,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: used
                        ? AppColors.surface
                        : AppColors.surfaceLight,
                  ),
                  child: Text(letter),
                ),
              );
            }).toList(),
          )
        else
          _RoundResult(
            game: game,
            guesser: guesser,
            setter: setter,
            onNextRound: onNextRound,
          ),
      ],
    );
  }
}

class _RoundResult extends StatelessWidget {
  const _RoundResult({
    required this.game,
    required this.guesser,
    required this.setter,
    required this.onNextRound,
  });

  final HangmanGame game;
  final String guesser;
  final String setter;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    final winner = game.isWon ? guesser : setter;
    final color = game.isWon ? AppColors.primary : AppColors.coral;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 38),
          const SizedBox(height: 8),
          Text(
            '$winner ganhou a rodada!',
            key: const Key('hangman-result'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text('A palavra era ${game.secretWord.toUpperCase()}.'),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('next-hangman-round'),
            onPressed: onNextRound,
            child: const Text('Próxima rodada'),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: child,
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.background,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.surfaceLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.cyan, width: 2),
    ),
  );
}

class HangmanPainter extends CustomPainter {
  HangmanPainter({required this.errors});

  final int errors;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final bodyPaint = Paint()
      ..color = errors >= 7 ? AppColors.coral : AppColors.cyan
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final left = size.width * 0.27;
    final top = size.height * 0.08;
    final hookX = size.width * 0.62;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.92),
      Offset(size.width * 0.48, size.height * 0.92),
      basePaint,
    );
    canvas.drawLine(
      Offset(left, size.height * 0.92),
      Offset(left, top),
      basePaint,
    );
    canvas.drawLine(Offset(left, top), Offset(hookX, top), basePaint);
    canvas.drawLine(
      Offset(hookX, top),
      Offset(hookX, size.height * 0.22),
      basePaint,
    );

    if (errors >= 1) {
      final headCenter = errors >= 7
          ? Offset(hookX + size.width * 0.08, size.height * 0.37)
          : Offset(hookX, size.height * 0.31);
      canvas.drawCircle(headCenter, size.height * 0.09, bodyPaint);
    }
    if (errors >= 2) {
      canvas.drawLine(
        Offset(hookX, size.height * 0.40),
        Offset(hookX, size.height * 0.65),
        bodyPaint,
      );
    }
    if (errors >= 3) {
      canvas.drawLine(
        Offset(hookX, size.height * 0.47),
        Offset(hookX - size.width * 0.12, size.height * 0.57),
        bodyPaint,
      );
    }
    if (errors >= 4) {
      canvas.drawLine(
        Offset(hookX, size.height * 0.47),
        Offset(hookX + size.width * 0.12, size.height * 0.57),
        bodyPaint,
      );
    }
    if (errors >= 5) {
      canvas.drawLine(
        Offset(hookX, size.height * 0.65),
        Offset(hookX - size.width * 0.1, size.height * 0.82),
        bodyPaint,
      );
    }
    if (errors >= 6) {
      canvas.drawLine(
        Offset(hookX, size.height * 0.65),
        Offset(hookX + size.width * 0.1, size.height * 0.82),
        bodyPaint,
      );
    }
    if (errors >= 7) {
      final finishPaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(hookX - size.width * 0.035, size.height * 0.39),
        Offset(hookX + size.width * 0.01, size.height * 0.42),
        finishPaint,
      );
      canvas.drawLine(
        Offset(hookX - size.width * 0.01, size.height * 0.38),
        Offset(hookX + size.width * 0.035, size.height * 0.41),
        finishPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.errors != errors;
  }
}
