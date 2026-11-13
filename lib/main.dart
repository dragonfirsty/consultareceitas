// Integrantes: Leonardo Moya e Vinicius Silvestre

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _favoriteMealIdsKey = 'favorite_meal_ids';

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
  const Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.category,
    this.area,
    this.instructions,
    this.ingredients = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    for (var index = 1; index <= 20; index++) {
      final ingredient = json['strIngredient$index'] as String?;
      final measure = json['strMeasure$index'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        final item = measure == null || measure.trim().isEmpty
            ? ingredient.trim()
            : '${measure.trim()} ${ingredient.trim()}';
        ingredients.add(item);
      }
    }

    return Meal(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? 'Receita sem nome',
      imageUrl: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      ingredients: ingredients,
    );
  }

  final String id;
  final String name;
  final String imageUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final List<String> ingredients;
}

class RecipeSearchPage extends StatefulWidget {
  const RecipeSearchPage({super.key});

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final _searchController = TextEditingController();
  List<Meal> _meals = [];
  final _favoriteMealIds = <String>{};
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _favoriteMealIds.addAll(
          preferences.getStringList(_favoriteMealIdsKey) ?? [],
        );
      });
    } on Exception {
      if (!mounted) return;
      _showStorageError();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFavorite(Meal meal, bool isFavorite) {
    final wasFavorite = _favoriteMealIds.contains(meal.id);
    setState(() {
      if (isFavorite) {
        _favoriteMealIds.add(meal.id);
      } else {
        _favoriteMealIds.remove(meal.id);
      }
    });
    unawaited(_saveFavorites(meal.id, wasFavorite));
  }

  Future<void> _saveFavorites(String mealId, bool wasFavorite) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _favoriteMealIdsKey,
        _favoriteMealIds.toList(),
      );
    } on Exception {
      if (!mounted) return;
      setState(() {
        if (wasFavorite) {
          _favoriteMealIds.add(mealId);
        } else {
          _favoriteMealIds.remove(mealId);
        }
      });
      _showStorageError();
    }
  }

  void _showStorageError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível salvar os favoritos.'),
      ),
    );
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecipeDetailPage(
                    meal: meal,
                    isFavorite: _favoriteMealIds.contains(meal.id),
                    onFavoriteChanged: (isFavorite) {
                      _setFavorite(meal, isFavorite);
                    },
                  ),
                ),
              );
            },
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
            trailing: Icon(
              _favoriteMealIds.contains(meal.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _favoriteMealIds.contains(meal.id) ? Colors.red : null,
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

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({
    required this.meal,
    this.isFavorite = false,
    this.onFavoriteChanged,
    super.key,
  });

  final Meal meal;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Meal? _details;
  String? _errorMessage;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _loadDetails();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  Future<void> _loadDetails() async {
    try {
      final uri = Uri.https(
        'www.themealdb.com',
        '/api/json/v1/1/lookup.php',
        {'i': widget.meal.id},
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('A API retornou o status ${response.statusCode}.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>?;
      final mealJson = meals?.whereType<Map<String, dynamic>>().firstOrNull;
      if (mealJson == null) {
        throw Exception('A receita não foi encontrada.');
      }

      if (!mounted) return;
      setState(() {
        _details = Meal.fromJson(mealJson);
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Não foi possível carregar os detalhes. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.name),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: _isFavorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: details == null && _errorMessage == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : _buildDetails(details!),
    );
  }

  Widget _buildDetails(Meal meal) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (meal.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              meal.imageUrl,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          meal.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (meal.category != null || meal.area != null) ...[
          const SizedBox(height: 8),
          Text(
            [meal.category, meal.area].whereType<String>().join(' • '),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        if (meal.ingredients.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Ingredientes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...meal.ingredients.map(
            (ingredient) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check),
              title: Text(ingredient),
            ),
          ),
        ],
        if (meal.instructions != null &&
            meal.instructions!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Modo de preparo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(meal.instructions!),
        ],
      ],
    );
  }
}
