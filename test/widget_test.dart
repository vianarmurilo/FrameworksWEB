import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:financeiro/main.dart';

void main() {
  testWidgets('renderiza fluxo de autenticacao', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinMindApp()));

    expect(find.text('FinMind AI+'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
