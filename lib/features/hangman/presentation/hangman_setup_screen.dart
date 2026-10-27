import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'hangman_screen.dart';

class HangmanSetupScreen extends StatefulWidget {
  const HangmanSetupScreen({super.key});

  @override
  State<HangmanSetupScreen> createState() => _HangmanSetupScreenState();
}

class _HangmanSetupScreenState extends State<HangmanSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerOneController = TextEditingController();
  final _playerTwoController = TextEditingController();

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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HangmanScreen(
          playerOne: _playerOneController.text.trim(),
          playerTwo: _playerTwoController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Preparar forca'),
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
                      const Icon(
                        Icons.psychology_alt_rounded,
                        color: AppColors.cyan,
                        size: 54,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Quem conhece a melhor palavra?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'A cada rodada, um jogador escolhe a palavra e o outro tenta descobri-la.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      _NameField(
                        key: const Key('hangman-player-one'),
                        controller: _playerOneController,
                        label: 'Jogador 1',
                        validator: _validateName,
                      ),
                      const SizedBox(height: 14),
                      _NameField(
                        key: const Key('hangman-player-two'),
                        controller: _playerTwoController,
                        label: 'Jogador 2',
                        validator: _validateName,
                      ),
                      const SizedBox(height: 26),
                      FilledButton.icon(
                        key: const Key('start-hangman'),
                        onPressed: _start,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Começar desafio'),
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

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.label,
    required this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
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
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),
      ),
    );
  }
}
