import 'package:flutter/material.dart';
import '../models/kalki_models.dart';
import '../translations.dart';

class KalKiProvider extends ChangeNotifier {
  // Mock Data
  final List<Dish> _allDishes = [
    Dish(
      id: '1',
      name: 'Beef Bhuna',
      category: DishCategory.beef,
      ingredients: [
        IngredientItem(name: 'Beef', qtyHint: '500g'),
        IngredientItem(name: 'Onion'),
      ],
    ),
    Dish(
      id: '2',
      name: 'Chicken Curry',
      category: DishCategory.chicken,
      ingredients: [
        IngredientItem(name: 'Chicken', qtyHint: '1kg'),
        IngredientItem(name: 'Potato'),
      ],
    ),
    Dish(
      id: '3',
      name: 'Rui Fish Fry',
      category: DishCategory.fish,
      ingredients: [IngredientItem(name: 'Rui Fish', qtyHint: '2 pcs')],
    ),
    Dish(
      id: '4',
      name: 'Lal Shak',
      category: DishCategory.vegetable,
      ingredients: [IngredientItem(name: 'Lal Shak', qtyHint: '2 bundles')],
    ),
    Dish(
      id: '5',
      name: 'Dal Butter Fry',
      category: DishCategory.lentil,
      ingredients: [IngredientItem(name: 'Lentils', qtyHint: '1 cup')],
    ),
    Dish(
      id: '6',
      name: 'Dim Bhaji',
      category: DishCategory.egg,
      ingredients: [IngredientItem(name: 'Egg', qtyHint: '2 pcs')],
    ),
    Dish(
      id: '7',
      name: 'Singara',
      category: DishCategory.vegetable,
      ingredients: [IngredientItem(name: 'Singara', qtyHint: '2 pcs')],
    ),
  ];

  final List<RoutineItem> _essentials = [
    RoutineItem(id: 'e1', name: 'Rice', isStarred: true),
    RoutineItem(id: 'e2', name: 'Oil', isStarred: true),
    RoutineItem(id: 'e3', name: 'Salt'),
    RoutineItem(id: 'e4', name: 'Onion', isStarred: true),
    RoutineItem(id: 'e5', name: 'Chili'),
    RoutineItem(id: 'e6', name: 'Toothpaste'),
    RoutineItem(id: 'e7', name: 'Soap'),
  ];

  late DayPlan _tomorrowPlan;

  // Market Mode State
  bool _isMarketMode = false;
  final Set<String> _checkedItems = {};

  // Water Reminder State
  bool _waterReminderEnabled = false;
  int _waterReminderFrequency = 1; // Hours

  // New Features State
  int _guestCount = 0;
  bool _isDarkMode = false;
  bool _isBangla = false;

  KalKiProvider() {
    _generateTomorrowPlan();
  }

  DayPlan get tomorrowPlan => _tomorrowPlan;
  List<RoutineItem> get essentials => _essentials;
  bool get isMarketMode => _isMarketMode;
  Set<String> get checkedItems => _checkedItems;
  bool get waterReminderEnabled => _waterReminderEnabled;
  int get waterReminderFrequency => _waterReminderFrequency;
  int get guestCount => _guestCount;
  bool get isDarkMode => _isDarkMode;
  bool get isBangla => _isBangla;

  void _generateTomorrowPlan() {
    // Simple mock logic: Randomly pick lunch and dinner
    _tomorrowPlan = DayPlan(
      date: DateTime.now().add(const Duration(days: 1)),
      lunch: _allDishes[0], // Beef Bhuna
      dinner: _allDishes[0], // Beef Bhuna (Same as Lunch)
      snack: _allDishes[6], // Singara
    );
    notifyListeners();
  }

  void regeneratePlan() {
    if (_tomorrowPlan.isLocked) return;

    // Rotate dishes for demo
    var currentLunchIndex = _allDishes.indexOf(_tomorrowPlan.lunch!);
    var nextLunchIndex = (currentLunchIndex + 1) % _allDishes.length;
    // Keep Dinner same as Lunch
    _tomorrowPlan.lunch = _allDishes[nextLunchIndex];
    _tomorrowPlan.dinner = _allDishes[nextLunchIndex];
    notifyListeners();
  }

  void lockPlan() {
    _tomorrowPlan.isLocked = true;
    notifyListeners();
  }

  void unlockPlan() {
    _tomorrowPlan.isLocked = false;
    notifyListeners();
  }

  void toggleMarketMode() {
    _isMarketMode = !_isMarketMode;
    if (!_isMarketMode) {
      _checkedItems.clear(); // Reset on exit? Or keep? Reset as per plan F4
    }
    notifyListeners();
  }

  void toggleCheckItem(String key) {
    if (_checkedItems.contains(key)) {
      _checkedItems.remove(key);
    } else {
      _checkedItems.add(key);
    }
    notifyListeners();
  }

  bool isItemChecked(String key) {
    return _checkedItems.contains(key);
  }

  void toggleWaterReminder(bool value) {
    _waterReminderEnabled = value;
    notifyListeners();
  }

  void setWaterReminderFrequency(int hours) {
    _waterReminderFrequency = hours;
    notifyListeners();
  }

  void updateGuestCount(int count) {
    if (count < 0) return;
    _guestCount = count;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleLanguage(bool isBangla) {
    _isBangla = isBangla;
    notifyListeners();
  }

  String t(String key) {
    String langCode = _isBangla ? 'bn' : 'en';
    return AppTranslations.localizedValues[langCode]?[key] ?? key;
  }

  // Get specific ingredient list for market
  List<String> getGeneratedShoppingList() {
    final list = <String>[];
    if (_tomorrowPlan.lunch != null) {
      list.addAll(
        _tomorrowPlan.lunch!.ingredients.map(
          (e) => "${e.name} ${e.qtyHint ?? ''}",
        ),
      );
    }
    if (_tomorrowPlan.dinner != null) {
      list.addAll(
        _tomorrowPlan.dinner!.ingredients.map(
          (e) => "${e.name} ${e.qtyHint ?? ''}",
        ),
      );
    }
    if (_tomorrowPlan.snack != null) {
      list.addAll(
        _tomorrowPlan.snack!.ingredients.map(
          (e) => "${e.name} ${e.qtyHint ?? ''}",
        ),
      );
    }
    return list.toSet().toList(); // Unique items
  }
}
