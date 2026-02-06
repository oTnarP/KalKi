import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';
import '../models/kalki_models.dart';
import 'market_mode_screen.dart';
import '../widgets/manage_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KalKiProvider>(
      builder: (context, provider, child) {
        final plan = provider.tomorrowPlan;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.shopping_basket_outlined,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketModeScreen(),
                  ),
                );
              },
            ),
            centerTitle: true,
            title: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Kal',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                  TextSpan(
                    text: 'Ki',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 4),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                  ),
                ],
              ),
            ),
            actions: [
              // Settings Icon directly in AppBar
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const ManageBottomSheet(),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Date
                      _buildDateHeader(context, plan, provider),

                      // Main Content (Hero)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main Meal Card (Lunch & Dinner)
                            _buildMainDishCard(
                              context,
                              "${provider.t('lunch')} & ${provider.t('dinner')}",
                              plan.lunch,
                              provider.isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            // Small Snack Card
                            if (plan.snack != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: _buildDishCard(
                                  context,
                                  provider.t('snack'),
                                  plan.snack,
                                  provider.isDarkMode
                                      ? Colors.purple.withValues(alpha: 0.15)
                                      : Colors.purple[50]!,
                                  provider.isDarkMode,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 32,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: plan.isLocked
                                    ? provider.unlockPlan
                                    : provider.lockPlan,
                                icon: Icon(
                                  plan.isLocked ? Icons.lock : Icons.lock_open,
                                ),
                                label: Text(
                                  plan.isLocked
                                      ? provider.t('unlock_plan')
                                      : provider.t('lock_plan'),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  foregroundColor: plan.isLocked
                                      ? Colors.grey
                                      : AppTheme.primaryColor,
                                  side: BorderSide(
                                    color: plan.isLocked
                                        ? Colors.grey
                                        : AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: plan.isLocked
                                    ? null
                                    : provider.regeneratePlan,
                                icon: const Icon(Icons.refresh),
                                label: Text(provider.t('change')),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: plan.isLocked
                                      ? Colors.grey[300]
                                      : AppTheme.primaryColor,
                                  foregroundColor: plan.isLocked
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(DishCategory category) {
    switch (category) {
      case DishCategory.beef:
        return Icons.kebab_dining;
      case DishCategory.chicken:
        return Icons.set_meal;
      case DishCategory.fish:
        return Icons.set_meal; // Fallback or find better
      case DishCategory.vegetable:
        return Icons.grass;
      case DishCategory.lentil:
        return Icons.all_inbox; // Grains?
      case DishCategory.egg:
        return Icons.egg;
    }
  }

  Widget _buildMainDishCard(
    BuildContext context,
    String mealType,
    Dish? dish,
    bool isDarkMode,
  ) {
    if (dish == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppTheme.primaryColor.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(dish.category),
              color: AppTheme.primaryColor,
              size: 48, // Big Hero Icon
            ),
          ),
          const SizedBox(height: 24),
          Text(
            mealType.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dish.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28, // Hero Text
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          if (dish.ingredients.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: dish.ingredients
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    DayPlan plan,
    KalKiProvider provider,
  ) {
    // Simple date formatting
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final dateStr = "${tomorrow.day}/${tomorrow.month}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            provider.t('planning_for'),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 2, // Capitalized tracking
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.t('tomorrow')}, $dateStr',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300, // Light/Minimal font
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(
    BuildContext context,
    String mealType,
    Dish? dish,
    Color bgColor,
    bool isDarkMode,
  ) {
    if (dish == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(
              _getCategoryIcon(dish.category),
              color: isDarkMode ? Colors.white70 : Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dish.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (dish.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dish.ingredients.map((e) => e.name).join(", "),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
