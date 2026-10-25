import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'tic_tac_toe_screen.dart';

class TicTacToeSetupScreen extends StatefulWidget {
  const TicTacToeSetupScreen({super.key});

  @override
  State<TicTacToeSetupScreen> createState() => _TicTacToeSetupScreenState();
}

class _TicTacToeSetupScreenState extends State<TicTacToeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerXController = TextEditingController();
  final _playerOController = TextEditingController();

  @override
  void dispose() {
    _playerXController.dispose();
    _playerOController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TicTacToeScreen(
          playerX: _playerXController.text.trim(),
          playerO: _playerOController.text.trim(),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome do jogador';
    }
    if (value.trim().length > 20) {
      return 'Use no máximo 20 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Preparar partida'),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _GameBadge(),
                      const SizedBox(height: 28),
                      Text(
                        'Quem vai jogar?',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Escolha os nomes. O placar será mantido durante esta disputa.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _PlayerField(
                        key: const Key('player-x-name'),
                        controller: _playerXController,
                        label: 'Jogador X',
                        hint: 'Ex.: Romário',
                        color: AppColors.primary,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 18),
                      _PlayerField(
                        key: const Key('player-o-name'),
                        controller: _playerOController,
                        label: 'Jogador O',
                        hint: 'Ex.: Ana',
                        color: AppColors.secondary,
                        validator: _validateName,
                        onSubmitted: (_) => _startGame(),
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        key: const Key('start-game'),
                        onPressed: _startGame,
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

class _GameBadge extends StatelessWidget {
  const _GameBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_3x3_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'JOGO DA VELHA · MESMO CELULAR',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerField extends StatelessWidget {
  const _PlayerField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
    required this.validator,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Color color;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      maxLength: 20,
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(13),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              label.characters.last,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}
