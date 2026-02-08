import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/kalki_data_manager.dart';
import '../services/notification_service.dart';
import '../translations.dart';

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

      // Load preferences first (settings only)
      await _loadPreferences();

      // Load data from assets
      await _dataManager.loadAllData();

      // NOW load saved plan (after dishes are loaded)
      await _loadSavedPlan();

      // Generate plan only if no saved plan exists
      if (_currentPlan == null) {
        await generateDailyPlan();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -- Persistence --
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _isBangla = prefs.getBool('isBangla') ?? false;
    _guestCount = prefs.getInt('guestCount') ?? 0;
    _isPlanLocked = prefs.getBool('isPlanLocked') ?? false;
    _waterReminderEnabled = prefs.getBool('waterReminderEnabled') ?? false;
    _waterReminderFrequency = prefs.getInt('waterReminderFrequency') ?? 1;
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('isBangla', _isBangla);
    await prefs.setInt('guestCount', _guestCount);
    await prefs.setBool('isPlanLocked', _isPlanLocked);
    await prefs.setBool('waterReminderEnabled', _waterReminderEnabled);
    await prefs.setInt('waterReminderFrequency', _waterReminderFrequency);
  }

  Future<void> _loadSavedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final mainDishId = prefs.getString('plan_mainDish');
    final sideDishId = prefs.getString('plan_sideDish');
    final breakfastId = prefs.getString('plan_breakfast');
    final snackId = prefs.getString('plan_snack');
    final planDateMs = prefs.getInt('plan_date');

    // Only restore if all dish IDs exist
    if (mainDishId != null &&
        sideDishId != null &&
        breakfastId != null &&
        snackId != null) {
      final mainDish =
          _dataManager.getDish(mainDishId) ?? _getFallbackDish('main');
      final sideDish =
          _dataManager.getDish(sideDishId) ?? _getFallbackDish('side');
      final breakfast =
          _dataManager.getDish(breakfastId) ?? _getFallbackDish('breakfast');
      final snack = _dataManager.getDish(snackId) ?? _getFallbackDish('snack');

      _currentPlan = DailyPlan(
        date: planDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(planDateMs)
            : DateTime.now().add(const Duration(days: 1)),
        mainDish: mainDish,
        sideDish: sideDish,
        breakfast: breakfast,
        snack: snack,
      );
    }
  }

  Future<void> _savePlan() async {
    if (_currentPlan == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plan_mainDish', _currentPlan!.mainDish.id);
    await prefs.setString('plan_sideDish', _currentPlan!.sideDish.id);
    await prefs.setString('plan_breakfast', _currentPlan!.breakfast.id);
    await prefs.setString('plan_snack', _currentPlan!.snack.id);
    await prefs.setInt('plan_date', _currentPlan!.date.millisecondsSinceEpoch);
  }

  Future<void> generateDailyPlan() async {
    // Allow generation if: data is loaded AND (no plan exists OR plan is not locked)
    if (!_dataManager.isLoaded) return;
    if (_currentPlan != null && _isPlanLocked) return;

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

    // Save the plan to persistence
    await _savePlan();

    notifyListeners();
  }

  void togglePlanLock() {
    _isPlanLocked = !_isPlanLocked;
    _savePreferences();
    if (_isPlanLocked) {
      _savePlan(); // Save plan when locking
    }
    notifyListeners();
  }

  void regeneratePlan() {
    if (!_isPlanLocked) {
      generateDailyPlan();
    }
  }

  void lockPlan() {
    _isPlanLocked = true;
    _savePreferences();
    notifyListeners();
  }

  void unlockPlan() {
    _isPlanLocked = false;
    _savePreferences();
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
    _savePreferences();
    notifyListeners();
  }

  void toggleLanguage(bool value) {
    _isBangla = value;
    _savePreferences();
    notifyListeners();
  }

  void updateGuestCount(int count) {
    if (count < 0) return;
    _guestCount = count;
    _savePreferences();
    notifyListeners();
  }

  void toggleWaterReminder(bool value) async {
    _waterReminderEnabled = value;
    _savePreferences();
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
    _savePreferences();
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

    // Map to names, filtering out essentials
    // "FOR TOMORROW" excludes items that are in the essentials/pantry list
    // Extract essential names for comparison
    final essentialNames = _dataManager.essentialItems
        .map((e) => e.name)
        .toSet();

    final filtered = allIngredients.where((e) {
      return !essentialNames.contains(e.key);
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

    // Always show main dish name
    final mainDishName = getDishName(_currentPlan!.mainDish);

    // Gather ingredients from Main + Side
    final allIngredients = <IngredientEntry>[];
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.mainDish),
    );
    allIngredients.addAll(
      _dataManager.getIngredientsForDish(_currentPlan!.sideDish),
    );

    // Filter out essentials - fix: extract essential names first
    final essentialNames = _dataManager.essentialItems
        .map((e) => e.name)
        .toSet();
    final filtered = allIngredients.where((e) {
      return !essentialNames.contains(e.key);
    }).toList();

    // Show main dish name with item count
    final itemCount = filtered.length;
    if (itemCount == 0) {
      return mainDishName;
    }

    return '$mainDishName • $itemCount ${itemCount == 1 ? "item" : "items"}';
  }
}
