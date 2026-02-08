import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class KalkiDataManager {
  static final KalkiDataManager _instance = KalkiDataManager._internal();
  factory KalkiDataManager() => _instance;
  KalkiDataManager._internal();

  // AppConfig? appConfig; // Remvoed
  List<Dish> dishes = [];
  Map<String, Ingredient> ingredients = {};
  Set<String> essentials = {};
  List<RoutineItem> essentialItems = [];
  Map<String, List<IngredientEntry>> ingredientProfiles = {};
  Map<String, Map<String, int>> ingredientSeasonality = {};
  Map<String, Map<String, int>> dishSeasonOverrides = {};

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> loadAllData() async {
    if (_isLoaded) return;

    // Load App Config - REMOVED (Unused)
    // appConfig = AppConfig.fromJson(jsonDecode(configString));

    // Load Ingredients
    debugPrint("Loading ingredients...");
    final ingredientsString = await rootBundle.loadString(
      'assets/kalki_ingredients.json',
    );
    // ... (rest of ingredients loading)

    // Load Essentials
    debugPrint("Loading essentials...");
    final essentialsString = await rootBundle.loadString(
      'assets/kalki_essentials.json',
    );
    // ...

    // Load Ingredient Profiles
    debugPrint("Loading profiles...");
    final profilesString = await rootBundle.loadString(
      'assets/kalki_ingredient_profiles.json',
    );
    // ...

    // Load Dishes
    debugPrint("Loading dishes...");
    final dishesString = await rootBundle.loadString(
      'assets/kalki_dishes.json',
    );
    // ...

    // Load Seasonality
    debugPrint("Loading seasonality...");
    final seasonalityString = await rootBundle.loadString(
      'assets/kalki_ingredient_seasonality.json',
    );
    // ...

    // Load Dish Overrides
    debugPrint("Loading overrides...");
    final overridesString = await rootBundle.loadString(
      'assets/kalki_dish_season_overrides.json',
    );
    // ...
    final ingredientsList = (jsonDecode(ingredientsString) as List)
        .map((e) => Ingredient.fromJson(e))
        .toList();
    for (var i in ingredientsList) {
      ingredients[i.key] = i;
    }

    // Parse Essentials
    final essentialsList = jsonDecode(essentialsString) as List;
    for (var e in essentialsList) {
      if (e['ingredientKey'] != null) {
        essentials.add(e['ingredientKey']);
        essentialItems.add(
          RoutineItem(
            id: e['key'] ?? e['ingredientKey'],
            name: e['name'] ?? 'Unknown',
            ingredientKey: e['ingredientKey'],
            isStarred: e['defaultStarred'] ?? false,
          ),
        );
      }
    }

    // Parse Ingredient Profiles
    final profilesJson = jsonDecode(profilesString) as Map<String, dynamic>;
    profilesJson.forEach((key, value) {
      ingredientProfiles[key] = (value as List)
          .map((e) => IngredientEntry(key: e['key'], qtyHint: e['qtyHint']))
          .toList();
    });

    // Parse Dishes
    dishes = (jsonDecode(dishesString) as List)
        .map((e) => Dish.fromJson(e))
        .toList();

    // Parse Seasonality
    final seasonalityJson =
        jsonDecode(seasonalityString) as Map<String, dynamic>;
    seasonalityJson.forEach((key, value) {
      ingredientSeasonality[key] = Map<String, int>.from(value);
    });

    // Parse Dish Overrides
    final overridesJson = jsonDecode(overridesString) as Map<String, dynamic>;
    overridesJson.forEach((key, value) {
      dishSeasonOverrides[key] = Map<String, int>.from(value);
    });

    _isLoaded = true;
  }

  Dish? getDish(String id) {
    try {
      return dishes.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Dish> getDishesByCategory(String category) {
    return dishes.where((d) => d.category == category && d.enabled).toList();
  }

  List<Dish> getDishesBySlot(String slot) {
    return dishes
        .where((d) => d.mealSlots.contains(slot) && d.enabled)
        .toList();
  }

  /// Returns a combined list of ingredients for a dish (primary + profile)
  List<IngredientEntry> getIngredientsForDish(Dish dish) {
    final List<IngredientEntry> allIngredients = [];

    // Add primary ingredients
    allIngredients.addAll(dish.primaryIngredients);

    // Add profile ingredients
    for (var profileKey in dish.profiles) {
      if (ingredientProfiles.containsKey(profileKey)) {
        allIngredients.addAll(ingredientProfiles[profileKey]!);
      }
    }

    return allIngredients;
  }

  int getSeasonalityScore(Dish dish, int month) {
    // 1. Check for explicit dish override
    if (dishSeasonOverrides.containsKey(dish.id)) {
      final monthMap = dishSeasonOverrides[dish.id]!;
      // JSON keys are strings "1", "2"...
      if (monthMap.containsKey(month.toString())) {
        return monthMap[month.toString()]!;
      }
    }

    // 2. If no override, calculate based on primary ingredients
    if (dish.primaryIngredients.isEmpty) {
      return 3; // Default to high score if no ingredients listed (assumed available)
    }

    int totalScore = 0;
    int count = 0;

    for (var entry in dish.primaryIngredients) {
      // Check if this ingredient has seasonality data
      if (ingredientSeasonality.containsKey(entry.key)) {
        final monthMap = ingredientSeasonality[entry.key]!;
        if (monthMap.containsKey(month.toString())) {
          totalScore += monthMap[month.toString()]!;
          count++;
        } else {
          // Default to full availability if month missing but ingredient present
          totalScore += 3;
          count++;
        }
      }
      // If ingredient not in seasonality file, assume it's available year-round (score 3)
      // e.g. salt, oil, spices might not be in seasonality json but refer to essentials
      else {
        totalScore += 3;
        count++;
      }
    }

    if (count == 0) return 3;

    // Return average rounded
    return (totalScore / count).round();
  }
}
