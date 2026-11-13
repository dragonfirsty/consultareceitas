// Integrantes: Leonardo Moya e Vinicius Silvestre

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de Receitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const RecipeSearchPage(),
    );
  }
}

class Meal {
  const Meal({required this.name, required this.imageUrl});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['strMeal'] as String? ?? 'Receita sem nome',
      imageUrl: json['strMealThumb'] as String? ?? '',
    );
  }

  final String name;
  final String imageUrl;
}

class RecipeSearchPage extends StatefulWidget {
  const RecipeSearchPage({super.key});

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final _searchController = TextEditingController();
  List<Meal> _meals = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMeals() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) {
      setState(() {
        _errorMessage = 'Digite o nome de uma receita para pesquisar.';
        _meals = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
      _meals = [];
    });

    try {
      final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {
        's': searchTerm,
      });
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('A API retornou o status ${response.statusCode}.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mealsJson = data['meals'] as List<dynamic>?;
      final meals =
          mealsJson
              ?.whereType<Map<String, dynamic>>()
              .map(Meal.fromJson)
              .toList() ??
          [];

      if (!mounted) return;
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Não foi possível consultar as receitas. '
            'Verifique sua conexão e tente novamente.\n$error';
      });
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    if (_hasSearched && _meals.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma receita encontrada.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    if (!_hasSearched) {
      return const Center(
        child: Text(
          'Digite uma receita e toque em Pesquisar.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _meals.length,
      itemBuilder: (context, index) {
        final meal = _meals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: Image.network(
              meal.imageUrl,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.restaurant, size: 48),
            ),
            title: Text(
              meal.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas - Leonardo Moya e Vinicius Silvestre'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchMeals(),
                    decoration: const InputDecoration(
                      labelText: 'Nome da receita',
                      hintText: 'Ex.: chicken, pasta, bolo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchMeals,
                  child: const Text('Pesquisar'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
