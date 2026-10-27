import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/checkers_game.dart';
import 'checkers_colors.dart';
import 'checkers_screen.dart';

class CheckersSetupScreen extends StatefulWidget {
  const CheckersSetupScreen({super.key});

  @override
  State<CheckersSetupScreen> createState() => _CheckersSetupScreenState();
}

class _CheckersSetupScreenState extends State<CheckersSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerOneController = TextEditingController();
  final _playerTwoController = TextEditingController();
  var _boardIndex = 0;
  var _playerOneColorIndex = 0;
  var _playerTwoColorIndex = 3;
  var _mandatoryCapture = true;
  var _menCanCaptureBackward = true;
  String? _colorError;

  @override
  void dispose() {
    _playerOneController.dispose();
    _playerTwoController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o nome';
    if (value.trim().length > 20) return 'Use no máximo 20 caracteres';
    return null;
  }

  void _start() {
    if (!_formKey.currentState!.validate()) return;
    if (_playerOneColorIndex == _playerTwoColorIndex) {
      setState(
        () => _colorError = 'Escolha cores diferentes para os jogadores.',
      );
      return;
    }
    final playerOneColor = checkersPieceColorOptions[_playerOneColorIndex];
    final playerTwoColor = checkersPieceColorOptions[_playerTwoColorIndex];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckersScreen(
          playerOne: _playerOneController.text.trim(),
          playerTwo: _playerTwoController.text.trim(),
          boardColors: checkersBoardOptions[_boardIndex],
          pieceColors: CheckersPieceColors(
            playerOne: playerOneColor.color,
            playerTwo: playerTwoColor.color,
          ),
          rules: CheckersRules(
            mandatoryCapture: _mandatoryCapture,
            menCanCaptureBackward: _menCanCaptureBackward,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Preparar damas'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.3,
            colors: [Color(0xFF20214A), AppColors.background],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Monte seu tabuleiro',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Defina os jogadores e combine as cores antes da partida.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _NameField(
                              key: const Key('checkers-player-one'),
                              controller: _playerOneController,
                              label: 'Jogador 1',
                              color: AppColors.primary,
                              validator: _validateName,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _NameField(
                              key: const Key('checkers-player-two'),
                              controller: _playerTwoController,
                              label: 'Jogador 2',
                              color: AppColors.secondary,
                              validator: _validateName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const _SectionTitle('Cor do tabuleiro'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(checkersBoardOptions.length, (
                          index,
                        ) {
                          final colors = checkersBoardOptions[index];
                          return ChoiceChip(
                            key: Key('board-theme-$index'),
                            selected: _boardIndex == index,
                            onSelected: (_) =>
                                setState(() => _boardIndex = index),
                            avatar: _BoardSwatch(colors: colors),
                            label: Text(colors.name),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Peças do Jogador 1'),
                      const SizedBox(height: 12),
                      _PieceColorPicker(
                        player: 1,
                        selectedIndex: _playerOneColorIndex,
                        onSelected: (index) => setState(() {
                          _playerOneColorIndex = index;
                          _colorError = null;
                        }),
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle('Peças do Jogador 2'),
                      const SizedBox(height: 12),
                      _PieceColorPicker(
                        player: 2,
                        selectedIndex: _playerTwoColorIndex,
                        onSelected: (index) => setState(() {
                          _playerTwoColorIndex = index;
                          _colorError = null;
                        }),
                      ),
                      if (_colorError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _colorError!,
                          key: const Key('checkers-color-error'),
                          style: const TextStyle(color: AppColors.coral),
                        ),
                      ],
                      const SizedBox(height: 26),
                      const _SectionTitle('Regras da partida'),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        key: const Key('mandatory-capture'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Captura obrigatória'),
                        subtitle: const Text(
                          'Se houver uma captura, ela deve ser realizada.',
                        ),
                        value: _mandatoryCapture,
                        onChanged: (value) =>
                            setState(() => _mandatoryCapture = value),
                      ),
                      SwitchListTile.adaptive(
                        key: const Key('backward-capture'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Peão pode capturar para trás'),
                        subtitle: const Text(
                          'A dama continua podendo capturar em todas as direções.',
                        ),
                        value: _menCanCaptureBackward,
                        onChanged: (value) =>
                            setState(() => _menCanCaptureBackward = value),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        key: const Key('start-checkers'),
                        onPressed: _start,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Começar partida'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.label,
    required this.color,
    required this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLength: 20,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.coral),
        ),
      ),
    );
  }
}

class _BoardSwatch extends StatelessWidget {
  const _BoardSwatch({required this.colors});

  final CheckersBoardColors colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 22, color: colors.light),
          Container(width: 10, height: 22, color: colors.dark),
        ],
      ),
    );
  }
}

class _PieceColorPicker extends StatelessWidget {
  const _PieceColorPicker({
    required this.player,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int player;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(checkersPieceColorOptions.length, (index) {
        final option = checkersPieceColorOptions[index];
        return ChoiceChip(
          key: Key('player-$player-color-$index'),
          selected: selectedIndex == index,
          onSelected: (_) => onSelected(index),
          avatar: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54),
            ),
          ),
          label: Text(option.name),
        );
      }),
    );
  }
}
