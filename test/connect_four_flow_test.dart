import 'package:asobiplay/core/theme/app_theme.dart';
import 'package:asobiplay/features/connect_four/presentation/connect_four_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cadastra jogadores, vence uma rodada e mantém o placar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const ConnectFourSetupScreen()),
    );

    await tester.enterText(
      find.byKey(const Key('connect-four-player-one')),
      'Romario',
    );
    await tester.enterText(
      find.byKey(const Key('connect-four-player-two')),
      'Bia',
    );
    await tester.tap(find.byKey(const Key('start-connect-four')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('connect-four-board')), findsOneWidget);
    expect(find.textContaining('Vez de Romario'), findsOneWidget);

    for (final column in [0, 0, 1, 1, 2, 2, 3]) {
      await tester.tap(find.byKey(Key('connect-four-column-$column')));
      await tester.pump();
    }

    expect(find.byKey(const Key('connect-four-result')), findsOneWidget);
    expect(find.text('Romario conectou quatro!'), findsOneWidget);
    expect(find.text('1 vitória'), findsOneWidget);

    await tester.tap(find.byKey(const Key('next-connect-four-round')));
    await tester.pump();
    expect(find.textContaining('Vez de Bia'), findsOneWidget);
  });
}
