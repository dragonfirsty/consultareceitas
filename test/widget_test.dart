import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:consultareceitas/main.dart';

void main() {
  testWidgets('exibe a tela inicial de consulta', (WidgetTester tester) async {
    await tester.pumpWidget(const RecipeApp());

    expect(
      find.text('Receitas - Leonardo Moya e Vinicius Silvestre'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Pesquisar'), findsOneWidget);
    expect(
      find.text('Digite uma receita e toque em Pesquisar.'),
      findsOneWidget,
    );
  });

  testWidgets('informa quando a pesquisa está vazia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RecipeApp());

    await tester.tap(find.text('Pesquisar'));
    await tester.pump();

    expect(
      find.text('Digite o nome de uma receita para pesquisar.'),
      findsOneWidget,
    );
  });
}
