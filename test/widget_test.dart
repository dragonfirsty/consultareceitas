import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:consultareceitas/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('converte ingredientes e medidas da resposta da API', () {
    final meal = Meal.fromJson({
      'idMeal': '123',
      'strMeal': 'Pasta',
      'strMealThumb': 'https://example.com/pasta.jpg',
      'strIngredient1': 'Tomato',
      'strMeasure1': '2',
      'strIngredient2': 'Basil',
      'strMeasure2': '',
    });

    expect(meal.id, '123');
    expect(meal.ingredients, ['2 Tomato', 'Basil']);
  });

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

  testWidgets('alterna o favorito na tela de detalhes', (
    WidgetTester tester,
  ) async {
    const meal = Meal(
      id: '123',
      name: 'Pasta',
      imageUrl: '',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: RecipeDetailPage(meal: meal),
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
