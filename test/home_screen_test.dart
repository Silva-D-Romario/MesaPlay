import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asobiplay/app/asobiplay_app.dart';

void main() {
  testWidgets('apresenta a identidade e os jogos planejados', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AsobiPlayApp());

    expect(find.text('AsobiPlay'), findsOneWidget);
    expect(find.textContaining('Sua mesa. Seus amigos.'), findsOneWidget);
    expect(find.text('Jogo da Velha'), findsOneWidget);
    expect(find.text('Damas'), findsOneWidget);
    expect(find.text('Forca'), findsOneWidget);
    expect(find.text('Mesmo celular'), findsOneWidget);
    expect(find.text('Sala Wi-Fi'), findsOneWidget);
    expect(find.byKey(const Key('asobiplay-logo')), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Lig 4'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Desenvolvido por Romário Silva'), findsOneWidget);
  });
}
