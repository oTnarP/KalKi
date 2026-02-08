class AppConfig {
  final String appName;
  final String localeDefault;
  final String dateFormat;
  final String marketProfileDefault;

  AppConfig({
    required this.appName,
    required this.localeDefault,
    required this.dateFormat,
    required this.marketProfileDefault,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] ?? 'KalKi',
      localeDefault: json['localeDefault'] ?? 'en',
      dateFormat: json['dateFormat'] ?? 'EEE, d MMM',
      marketProfileDefault: json['marketProfileDefault'] ?? 'BAZAR',
    );
  }
}

class Ingredient {
  final String key;
  final String name;
  final String? nameBn;
  final String section;
  final List<String> synonyms;

  Ingredient({
    required this.key,
    required this.name,
    this.nameBn,
    required this.section,
    this.synonyms = const [],
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      key: json['key'],
      name: json['name'],
      nameBn: json['name_bn'],
      section: json['section'] ?? 'GROCERY',
      synonyms: (json['synonyms'] as List?)?.cast<String>() ?? [],
    );
  }
}

class IngredientEntry {
  final String key;
  final String? qtyHint;

  IngredientEntry({required this.key, this.qtyHint});

  factory IngredientEntry.fromJson(Map<String, dynamic> json) {
    return IngredientEntry(key: json['key'], qtyHint: json['qtyHint']);
  }
}

class Dish {
  final String id;
  final String nameBn;
  final String nameEn;
  final String category;
  final List<String> mealSlots;
  final bool enabled;
  final List<String> profiles;
  final List<IngredientEntry> primaryIngredients;
  final List<String> tags;

  Dish({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.category,
    required this.mealSlots,
    required this.enabled,
    this.profiles = const [],
    this.primaryIngredients = const [],
    this.tags = const [],
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      nameBn: json['name_bn'],
      nameEn: json['name_en'],
      category: json['category'],
      mealSlots: (json['mealSlots'] as List?)?.cast<String>() ?? [],
      enabled: json['enabled'] ?? true,
      profiles: (json['profiles'] as List?)?.cast<String>() ?? [],
      primaryIngredients:
          (json['primaryIngredients'] as List?)
              ?.map((e) => IngredientEntry.fromJson(e))
              .toList() ??
          [],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }
}

class DailyPlan {
  final DateTime date;
  final Dish mainDish;
  final Dish sideDish;
  final Dish breakfast;
  final Dish snack;
  // Computed shopping list could be here or computed on the fly

  DailyPlan({
    required this.date,
    required this.mainDish,
    required this.sideDish,
    required this.breakfast,
    required this.snack,
  });
}

class RoutineItem {
  final String id;
  final String name;
  final String? ingredientKey;
  bool isStarred;
  bool isEnabled;

  RoutineItem({
    required this.id,
    required this.name,
    this.ingredientKey,
    this.isStarred = false,
    this.isEnabled = true,
  });
}
