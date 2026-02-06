// Simple data models for KalKi

enum DishCategory { beef, chicken, fish, vegetable, lentil, egg }

enum MealType { lunch, dinner, snack }

class IngredientItem {
  final String name;
  final String? qtyHint;

  IngredientItem({required this.name, this.qtyHint});
}

class Dish {
  final String id;
  final String name;
  final DishCategory category;
  final List<IngredientItem> ingredients;
  bool enabled;

  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
    this.enabled = true,
  });
}

class RoutineItem {
  final String id;
  final String name;
  bool isStarred;
  bool isEnabled;

  RoutineItem({
    required this.id,
    required this.name,
    this.isStarred = false,
    this.isEnabled = true,
  });
}

class DayPlan {
  final DateTime date;
  Dish? lunch;
  Dish? dinner;
  Dish? snack;
  bool isLocked;

  DayPlan({
    required this.date,
    this.lunch,
    this.dinner,
    this.snack,
    this.isLocked = false,
  });
}
