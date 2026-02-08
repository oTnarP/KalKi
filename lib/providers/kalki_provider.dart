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

  // -- Notification State --
  bool _waterReminderEnabled = false;
  int _waterReminderFrequency = 1;
  bool _menuReminderEnabled = true; // Enabled by default as requested

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
  bool get menuReminderEnabled => _menuReminderEnabled;
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

  String getRoutineItemName(RoutineItem item) {
    // 1. Try lookup by ingredientKey if available
    if (item.ingredientKey != null) {
      final ing = _dataManager.ingredients[item.ingredientKey!];
      if (ing != null) {
        return getIngredientName(ing);
      }
    }

    // 2. Fallback to original id lookup
    final ing = _dataManager.ingredients[item.id];
    if (ing != null) {
      return getIngredientName(ing);
    }
    return item.name;
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
    _menuReminderEnabled = prefs.getBool('menuReminderEnabled') ?? true;

    // Schedule reminders if enabled
    if (_menuReminderEnabled) {
      NotificationService().scheduleDailyMenuReminder(
        checkTitle: t('menu_check_title'),
        checkBody: t('menu_check_body'),
        reminderTitle: t('menu_reminder_title'),
        reminderBody: t('menu_reminder_body'),
        lastCallTitle: t('menu_last_call_title'),
        lastCallBody: t('menu_last_call_body'),
      );
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('isBangla', _isBangla);
    await prefs.setInt('guestCount', _guestCount);
    await prefs.setBool('isPlanLocked', _isPlanLocked);
    await prefs.setBool('waterReminderEnabled', _waterReminderEnabled);
    await prefs.setInt('waterReminderFrequency', _waterReminderFrequency);
    await prefs.setBool('menuReminderEnabled', _menuReminderEnabled);
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

    // 1. Pick Main Dish
    final mainDishes = _dataManager.getDishesBySlot('MAIN');
    Dish mainDish = _pickSeasonalDish(mainDishes, 'main');
    final Set<String> pickedIds = {mainDish.id};

    // 2. Pick Side Dish
    final sideDishes = _dataManager
        .getDishesBySlot('SIDE')
        .where((d) => !pickedIds.contains(d.id))
        .toList();
    Dish sideDish = _pickSeasonalDish(
      sideDishes.isEmpty ? _dataManager.getDishesBySlot('SIDE') : sideDishes,
      'side',
    );
    pickedIds.add(sideDish.id);

    // 3. Pick Breakfast
    final breakfastDishes = _dataManager
        .getDishesBySlot('BREAKFAST')
        .where((d) => !pickedIds.contains(d.id))
        .toList();
    Dish breakfastDish = _pickSeasonalDish(
      breakfastDishes.isEmpty
          ? _dataManager.getDishesBySlot('BREAKFAST')
          : breakfastDishes,
      'breakfast',
    );
    pickedIds.add(breakfastDish.id);

    // 4. Pick Snack
    final snackDishes = _dataManager
        .getDishesBySlot('SNACK')
        .where((d) => !pickedIds.contains(d.id))
        .toList();
    Dish snackDish = _pickSeasonalDish(
      snackDishes.isEmpty ? _dataManager.getDishesBySlot('SNACK') : snackDishes,
      'snack',
    );

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

  Dish _pickSeasonalDish(List<Dish> candidates, String fallbackType) {
    if (candidates.isEmpty) return _getFallbackDish(fallbackType);

    final random = Random();
    final currentMonth = DateTime.now().month;

    // Calculate weights based on seasonality score using map
    // Score 3 (High) -> Weight 10
    // Score 2 (Mid) -> Weight 4
    // Score 1 (Low) -> Weight 1
    // Score 0 (Unknown) -> Weight 5
    final Map<Dish, int> dishWeights = {};
    int totalWeight = 0;

    for (var dish in candidates) {
      int score = _dataManager.getSeasonalityScore(dish, currentMonth);
      int weight;
      switch (score) {
        case 3:
          weight = 10;
          break;
        case 2:
          weight = 4;
          break;
        case 1:
          weight = 1;
          break;
        default:
          weight = 5;
          break;
      }
      dishWeights[dish] = weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return candidates[random.nextInt(candidates.length)];

    int r = random.nextInt(totalWeight);
    int runningSum = 0;

    for (var dish in candidates) {
      runningSum += dishWeights[dish]!;
      if (r < runningSum) {
        return dish;
      }
    }

    return candidates.last;
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
        hours: _waterReminderFrequency,
        title: t('water_title'),
        body: t('water_body'),
      );
    } else {
      // Cancel water reminders only
      await NotificationService().cancelWaterReminders();
    }
  }

  void setWaterReminderFrequency(int hours) async {
    _waterReminderFrequency = hours;
    _savePreferences();
    notifyListeners();

    // Reschedule if reminder is enabled
    if (_waterReminderEnabled) {
      await NotificationService().scheduleWaterReminders(
        hours: hours,
        title: t('water_title'),
        body: t('water_body'),
      );
    }
  }

  void toggleMenuReminder(bool value) async {
    _menuReminderEnabled = value;
    _savePreferences();
    notifyListeners();

    if (value) {
      await NotificationService().scheduleDailyMenuReminder(
        checkTitle: t('menu_check_title'),
        checkBody: t('menu_check_body'),
        reminderTitle: t('menu_reminder_title'),
        reminderBody: t('menu_reminder_body'),
        lastCallTitle: t('menu_last_call_title'),
        lastCallBody: t('menu_last_call_body'),
      );
    } else {
      await NotificationService().cancelMenuReminder();
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
    // Extract essential KEYS for comparison (since e.key is the ID)
    final essentialKeys = _dataManager.essentialItems.map((e) => e.id).toSet();

    final filtered = allIngredients.where((e) {
      return !essentialKeys.contains(e.key);
    }).toList();

    return filtered
        .map((e) {
          final ing = _dataManager.ingredients[e.key];
          final name = ing != null ? getIngredientName(ing) : e.key;

          // Apply multiplier to quantity hint if it exists
          if (e.qtyHint != null && multiplier > 1) {
            final multipliedQty = _multiplyQuantity(e.qtyHint!, multiplier);
            return "$name (${localizeText(multipliedQty)})";
          } else if (e.qtyHint != null) {
            return "$name (${localizeText(e.qtyHint!)})";
          } else {
            return name;
          }
        })
        .toSet()
        .toList();
  }

  /// Helper to localize text (digits and units): "500g" -> "৫০০ গ্রাম" if in Bangla mode
  String localizeText(String input) {
    if (!_isBangla) return input;

    // First localize digits
    String result = input
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯');

    // Localize common units (sorted by length to avoid partial replacements)
    final units = [
      {'en': 'optional', 'bn': 'ঐচ্ছিক'},
      {'en': 'to taste', 'bn': 'স্বাদমতো'},
      {'en': 'as needed', 'bn': 'প্রয়োজনমতো'},
      {'en': 'packets', 'bn': 'প্যাকেট'},
      {'en': 'packet', 'bn': 'প্যাকেট'},
      {'en': 'slices', 'bn': 'পিস'},
      {'en': 'slice', 'bn': 'পিস'},
      {'en': 'bulbs', 'bn': 'টি'},
      {'en': 'bulb', 'bn': 'টি'},
      {'en': 'packs', 'bn': 'প্যাকেট'},
      {'en': 'pack', 'bn': 'প্যাকেট'},
      {'en': 'cups', 'bn': 'কাপ'},
      {'en': 'cup', 'bn': 'কাপ'},
      {'en': 'tbsp', 'bn': 'চামচ'},
      {'en': 'pods', 'bn': 'কোয়া'},
      {'en': 'pod', 'bn': 'কোয়া'},
      {'en': 'pcs', 'bn': 'টি'},
      {'en': 'pc', 'bn': 'টি'},
      {'en': 'tsp', 'bn': 'চা চামচ'},
      {'en': 'pinch', 'bn': 'চিমটি'},
      {'en': 'kg', 'bn': 'কেজি'},
      {'en': 'g', 'bn': 'গ্রাম'},
    ];

    for (var unit in units) {
      result = result.replaceAll(unit['en']!, unit['bn']!);
    }

    return result;
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

    // Fallback if we can't parse: just return original (caller will localize if needed)
    return qtyHint;
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

    // Filter out essentials - fix: extract essential KEYS first
    final essentialKeys = _dataManager.essentialItems.map((e) => e.id).toSet();
    final filtered = allIngredients.where((e) {
      return !essentialKeys.contains(e.key);
    }).toList();

    // Show main dish name with item count
    final itemCount = filtered.length;
    if (itemCount == 0) {
      return mainDishName;
    }

    final itmStr = _isBangla ? 'টি আইটেম' : (itemCount == 1 ? "item" : "items");
    return '$mainDishName • ${localizeText(itemCount.toString())} $itmStr';
  }
}
