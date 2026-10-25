import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesaplay/app/mesaplay_app.dart';

void main() {
  testWidgets('cadastra jogadores, conclui rodada e mantém o placar', (
    tester,
  ) async {
    await tester.pumpWidget(const MesaPlayApp());

    await tester.tap(find.text('Mesmo celular'));
    await tester.pumpAndSettle();

    expect(find.text('Quem vai jogar?'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('player-x-name')), 'Romario');
    await tester.enterText(find.byKey(const Key('player-o-name')), 'Ana');
    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Vez de Romario'), findsOneWidget);

    for (final index in [0, 3, 1, 4, 2]) {
      final cell = find.byKey(Key('cell-$index'));
      await tester.ensureVisible(cell);
      await tester.tap(cell);
      await tester.pump();
    }

    expect(find.textContaining('Romario venceu!'), findsNWidgets(2));
    expect(find.text('1 vitória'), findsOneWidget);

    final nextRound = find.byKey(const Key('next-round'));
    await tester.ensureVisible(nextRound);
    await tester.pumpAndSettle();
    await tester.tap(nextRound);
    await tester.pumpAndSettle();

    expect(find.textContaining('Vez de Ana'), findsOneWidget);
    expect(find.text('1 vitória'), findsOneWidget);
  });

  testWidgets('valida nomes obrigatórios antes de iniciar', (tester) async {
    await tester.pumpWidget(const MesaPlayApp());
    await tester.tap(find.text('Mesmo celular'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pump();

    expect(find.text('Informe o nome do jogador'), findsNWidgets(2));
    expect(find.text('Quem vai jogar?'), findsOneWidget);
  });
}
