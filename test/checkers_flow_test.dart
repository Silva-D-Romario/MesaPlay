import 'package:asobiplay/core/theme/app_theme.dart';
import 'package:asobiplay/features/checkers/presentation/checkers_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('configura cores e inicia partida local de damas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const CheckersSetupScreen()),
    );

    await tester.enterText(
      find.byKey(const Key('checkers-player-one')),
      'Romario',
    );
    await tester.enterText(find.byKey(const Key('checkers-player-two')), 'Bia');
    await tester.tap(find.byKey(const Key('board-theme-1')));
    await tester.tap(find.byKey(const Key('piece-theme-2')));
    final start = find.byKey(const Key('start-checkers'));
    await tester.ensureVisible(start);
    await tester.pumpAndSettle();
    await tester.tap(start);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkers-board')), findsOneWidget);
    expect(find.text('Romario'), findsOneWidget);
    expect(find.text('Bia'), findsOneWidget);
    expect(find.textContaining('Vez de Romario'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkers-cell-40')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('checkers-cell-33')));
    await tester.pump();

    expect(find.textContaining('Vez de Bia'), findsOneWidget);
  });
}
