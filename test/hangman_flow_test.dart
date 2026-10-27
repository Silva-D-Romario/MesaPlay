import 'package:asobiplay/core/theme/app_theme.dart';
import 'package:asobiplay/features/hangman/presentation/hangman_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('protege a palavra, joga uma rodada e atualiza o placar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const HangmanSetupScreen()),
    );

    await tester.enterText(
      find.byKey(const Key('hangman-player-one')),
      'Romario',
    );
    await tester.enterText(find.byKey(const Key('hangman-player-two')), 'Bia');
    await tester.tap(find.byKey(const Key('start-hangman')));
    await tester.pumpAndSettle();

    expect(find.text('Romario escolhe a palavra'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('secret-word')), 'CASA');
    await tester.enterText(
      find.byKey(const Key('word-hint')),
      'Lugar de morar',
    );
    await tester.tap(find.byKey(const Key('save-secret')));
    await tester.pumpAndSettle();

    expect(find.text('Passe o celular para Bia'), findsOneWidget);
    expect(find.text('CASA'), findsNothing);
    await tester.tap(find.byKey(const Key('ready-to-guess')));
    await tester.pumpAndSettle();

    expect(find.text('_ _ _ _'), findsOneWidget);
    expect(find.text('Dica: Lugar de morar'), findsOneWidget);
    for (final letter in ['C', 'A', 'S']) {
      await tester.tap(find.byKey(Key('letter-$letter')));
      await tester.pump();
    }

    expect(find.byKey(const Key('hangman-result')), findsOneWidget);
    expect(find.text('Bia ganhou a rodada!'), findsOneWidget);
    expect(find.text('1 ponto'), findsOneWidget);

    await tester.tap(find.byKey(const Key('next-hangman-round')));
    await tester.pumpAndSettle();
    expect(find.text('Bia escolhe a palavra'), findsOneWidget);
  });
}
