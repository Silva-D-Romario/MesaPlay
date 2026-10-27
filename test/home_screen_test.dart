import 'package:flutter_test/flutter_test.dart';
import 'package:asobiplay/app/asobiplay_app.dart';

void main() {
  testWidgets('apresenta a identidade e os jogos planejados', (tester) async {
    await tester.pumpWidget(const AsobiPlayApp());

    expect(find.text('AsobiPlay'), findsOneWidget);
    expect(find.textContaining('Sua mesa. Seus amigos.'), findsOneWidget);
    expect(find.text('Jogo da Velha'), findsOneWidget);
    expect(find.text('Lig 4'), findsOneWidget);
    expect(find.text('Damas'), findsOneWidget);
    expect(find.text('Mesmo celular'), findsOneWidget);
    expect(find.text('Sala Wi-Fi'), findsOneWidget);
  });
}
