import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';

void main() {
  group('Recipe.fromJson', () {
    test('membaca rating 5 (int) sebagai 5.0 (double)', () {
      final recipe = Recipe.fromJson({'id': 1, 'name': 'Tes', 'rating': 5});

      expect(recipe.rating, isA<double>());
      expect(recipe.rating, 5.0);
    });

    test('memberi nilai bawaan untuk field yang tidak ada', () {
      final recipe = Recipe.fromJson({'id': 2, 'name': 'Rendang'});

      expect(recipe.cuisine, '-');
      expect(recipe.difficulty, '-');
      expect(recipe.prepTimeMinutes, 0);
      expect(recipe.cookTimeMinutes, 0);
      expect(recipe.servings, 1);
      expect(recipe.caloriesPerServing, 0);
      expect(recipe.rating, 0.0);
      expect(recipe.image, '');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });
  });

  group('RecipeService.fetchRecipes', () {
    test('mengembalikan List<Recipe> dari respons palsu', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'recipes': [
              {'id': 1, 'name': 'Classic Margherita Pizza', 'rating': 4.6},
              {'id': 2, 'name': 'Rendang', 'rating': 5},
            ],
            'total': 2,
            'skip': 0,
            'limit': 2,
          }),
          200,
        );
      });
      final service = RecipeService(client: client);

      final recipes = await service.fetchRecipes();

      expect(recipes, isA<List<Recipe>>());
      expect(recipes, hasLength(2));
      expect(recipes.first.name, 'Classic Margherita Pizza');
      expect(recipes.last.rating, 5.0);
    });

    test('melempar RecipeServiceException jika status 404', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      final service = RecipeService(client: client);

      await expectLater(
        service.fetchRecipes(),
        throwsA(isA<RecipeServiceException>()),
      );
    });
  });
}