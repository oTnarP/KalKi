import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/kalki_data_manager.dart';
import '../services/notification_service.dart';
import '../translations.dart'; // Ensure this exists or mock it if it was deleted (it wasn't)

class KalKiProvider extends ChangeNotifier {
  final KalkiDataManager _dataManager = KalkiDataManager();
  DailyPlan? _currentPlan;
  bool _isLoading = true;

  // -- UI State --
  bool _isDarkMode = false;
  bool _isBangla = false;
  int _guestCount = 0;

  // -- Water Reminder State --
  bool _waterReminderEnabled = false;
  int _waterReminderFrequency = 1;

  // -- Market Mode State --
  bool _isMarketMode = false;
  final Set<String> _checkedItems = {};

  // -- Plan Lock State --
  bool _isPlanLocked = false;

  // -- Getters --
  DailyPlan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isBangla => _isBangla;
  int get guestCount => _guestCount;
  bool get waterReminderEnabled => _waterReminderEnabled;
  int get waterReminderFrequency => _waterReminderFrequency;
  bool get isMarketMode => _isMarketMode;
  Set<String> get checkedItems => _checkedItems;
  bool get isPlanLocked => _isPlanLocked;

  List<RoutineItem> get essentials => _dataManager.essentialItems;

  // -- Translation Helpers --
  String t(String key) {
    final code = _isBangla ? 'bn' : 'en';
    return AppTranslations.localizedValues[code]?[key] ?? key;
  }

  String getDishName(Dish dish) {
    String name = _isBangla ? dish.nameBn : dish.nameEn;
    // Remove content inside parentheses (e.g., "Eggplant (Begun)" -> "Eggplant")
    return name.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
  }

  String getIngredientName(Ingredient ing) {
    if (_isBangla && ing.nameBn != null && ing.nameBn!.isNotEmpty) {
      return ing.nameBn!;
    }
    return ing.name;
  }

  // Constructor
  KalKiProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _dataManager.loadAllData();
      generateDailyPlan();
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void generateDailyPlan() {
    if (!_dataManager.isLoaded || _isPlanLocked) return;

    final random = Random();

    // 1. Pick Main Dish
    final mainDishes = _dataManager.getDishesBySlot('MAIN');
    Dish mainDish = mainDishes.isNotEmpty
        ? mainDishes[random.nextInt(mainDishes.length)]
        : _getFallbackDish('main');

    // 2. Pick Side Dish
    final sideDishes = _dataManager.getDishesBySlot('SIDE');
    Dish sideDish = sideDishes.isNotEmpty
        ? sideDishes[random.nextInt(sideDishes.length)]
        : _getFallbackDish('side');

    // 3. Pick Breakfast
    final breakfastDishes = _dataManager.getDishesBySlot('BREAKFAST');
    Dish breakfastDish = breakfastDishes.isNotEmpty
        ? breakfastDishes[random.nextInt(breakfastDishes.length)]
        : _getFallbackDish('breakfast');

    // 4. Pick Snack
    final snackDishes = _dataManager.getDishesBySlot('SNACK');
    Dish snackDish = snackDishes.isNotEmpty
        ? snackDishes[random.nextInt(snackDishes.length)]
        : _getFallbackDish('snack');

    _currentPlan = DailyPlan(
      date: DateTime.now().add(const Duration(days: 1)),
      mainDish: mainDish,
      sideDish: sideDish,
      breakfast: breakfastDish,
      snack: snackDish,
    );

    notifyListeners();
  }

  void togglePlanLock() {
    _isPlanLocked = !_isPlanLocked;
    notifyListeners();
  }

  void regeneratePlan() {
    generateDailyPlan();
  }

  void lockPlan() {
    // Placeholder for locking logic
    // _currentPlan?.isLocked = true;
    notifyListeners();
  }

  void unlockPlan() {
    // Placeholder
    // _currentPlan?.isLocked = false;
    notifyListeners();
  }

  Dish _getFallbackDish(String type) {
    return Dish(
      id: 'fallback_$type',
      nameBn: 'N/A',
      nameEn: 'Not Available',
      category: 'UNKNOWN',
      mealSlots: [],
      enabled: false,
    );
  }

  // -- UI Methods --

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleLanguage(bool value) {
    _isBangla = value;
    notifyListeners();
  }

  void updateGuestCount(int count) {
    if (count < 0) return;
    _guestCount = count;
    notifyListeners();
  }

  void toggleWaterReminder(bool value) async {
    _waterReminderEnabled = value;
    notifyListeners();

    if (value) {
      // Schedule notifications with current frequency
      await NotificationService().scheduleWaterReminders(
        _waterReminderFrequency,
      );
    } else {
      // Cancel all notifications
      await NotificationService().cancelAllReminders();
    }
  }

  void setWaterReminderFrequency(int hours) async {
    _waterReminderFrequency = hours;
    notifyListeners();

    // Reschedule if reminder is enabled
    if (_waterReminderEnabled) {
      await NotificationService().scheduleWaterReminders(hours);
    }
  }

  // -- Market Mode Methods --

  void toggleMarketMode() {
    _isMarketMode = !_isMarketMode;
    if (!_isMarketMode) {
      _checkedItems.clear(); // Reset on exit?
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

  /// Generates a list of strings for the shopping list (Market Mode)
  List<String> getGeneratedShoppingList() {
    if (_currentPlan == null) return [];

    // Calculate multiplier: 1 person + guests
    final multiplier = 1 + _guestCount;

    // Gather ingredients from all meals
    final allIngredients = <IngredientEntry>[];
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.mainDish),
    );
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.sideDish),
    );
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.breakfast),
    );
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.snack),
    );

    // Map to names, filtering out essentials if needed?
    // Market Mode usually shows everything or maybe excludes essentials?
    // The original filtered out nothing or maybe logic was different.
    // Let's filter out essentials that are *starred* or *standard*?
    // Actually, MarketScreen separates "FOR TOMORROW" from "ESSENTIALS".
    // So "FOR TOMORROW" should probably exclude essentials that are in the pantry list?
    // Let's exclude anything in `_dataManager.essentials`.

    final filtered = allIngredients.where((e) {
      return !_dataManager.essentials.contains(e.key);
    }).toList();

    return filtered
        .map((e) {
          final ing = _dataManager.ingredients[e.key];
          final name = ing != null ? getIngredientName(ing) : e.key;

          // Apply multiplier to quantity hint if it exists
          if (e.qtyHint != null && multiplier > 1) {
            final multipliedQty = _multiplyQuantity(e.qtyHint!, multiplier);
            return "$name ($multipliedQty)";
          } else if (e.qtyHint != null) {
            return "$name (${e.qtyHint})";
          } else {
            return name;
          }
        })
        .toSet()
        .toList();
  }

  /// Helper to multiply quantity strings like "500g" -> "1500g" (with multiplier=3)
  String _multiplyQuantity(String qtyHint, int multiplier) {
    // Try to extract number from the beginning of the string
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*(.*)$').firstMatch(qtyHint);

    if (match != null) {
      final numStr = match.group(1)!;
      final unit = match.group(2)!;

      // Parse as double, multiply, then format
      final originalQty = double.tryParse(numStr);
      if (originalQty != null) {
        final newQty = originalQty * multiplier;
        // Format nicely (remove .0 if whole number)
        final formatted = newQty % 1 == 0
            ? newQty.toInt().toString()
            : newQty.toString();
        return '$formatted$unit';
      }
    }

    // Fallback if we can't parse: just append multiplier
    return '$qtyHint ×$multiplier';
  }

  /// Generates a compact shopping preview string for HomeScreen
  String getShoppingPreview() {
    if (_currentPlan == null) return '';

    // Calculate multiplier: 1 person + guests
    final multiplier = 1 + _guestCount;

    // Gather ingredients from Main + Side
    final allIngredients = <IngredientEntry>[];
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.mainDish),
    );
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.sideDish),
    );

    // Filter out essentials
    final filtered = allIngredients.where((e) {
      return !_dataManager.essentials.contains(e.key);
    }).toList();

    if (filtered.isEmpty) return t('check_pantry');

    // Build preview with calculated quantities
    final items = <String>[];
    for (var entry in filtered.take(2)) {
      final ing = _dataManager.ingredients[entry.key];
      final name = ing != null ? getIngredientName(ing) : entry.key;

      if (entry.qtyHint != null && multiplier > 1) {
        final calculated = _multiplyQuantity(entry.qtyHint!, multiplier);
        items.add('$name ($calculated)');
      } else if (entry.qtyHint != null) {
        items.add('$name (${entry.qtyHint})');
      } else {
        items.add(name);
      }
    }

    final remaining = filtered.length - items.length;
    final itemsText = items.join('\n');
    final suffix = remaining > 0 ? '\n+ $remaining ${t('more_items')}' : '';

    return '$itemsText$suffix';
  }
}
