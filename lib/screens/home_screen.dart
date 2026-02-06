import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';
import '../models/kalki_models.dart';
import 'market_mode_screen.dart';
import '../widgets/manage_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('KalKi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const ManageBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Consumer<KalKiProvider>(
                            builder: (context, provider, child) {
                              final plan = provider.tomorrowPlan;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDateHeader(plan),
                                  const SizedBox(height: 16),
                                  // Tomorrow's Menu Section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Tomorrow\'s Menu',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.shopping_basket_outlined,
                                            size: 20,
                                            color: AppTheme.primaryColor,
                                          ),
                                          tooltip: 'Market Mode',
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(8),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const MarketModeScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildDishCard(
                                    context,
                                    'Lunch',
                                    plan.lunch,
                                    Colors.orange[50]!,
                                  ),
                                  _buildDishCard(
                                    context,
                                    'Dinner',
                                    plan.dinner,
                                    Colors.blue[50]!,
                                  ),
                                  if (plan.snack != null)
                                    _buildDishCard(
                                      context,
                                      'Snack',
                                      plan.snack,
                                      Colors.purple[50]!,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      Consumer<KalKiProvider>(
                        builder: (context, provider, child) {
                          final plan = provider.tomorrowPlan;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 24,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: plan.isLocked
                                        ? provider.unlockPlan
                                        : provider.lockPlan,
                                    icon: Icon(
                                      plan.isLocked
                                          ? Icons.lock
                                          : Icons.lock_open,
                                    ),
                                    label: Text(
                                      plan.isLocked
                                          ? 'Unlock Plan'
                                          : 'Lock Plan',
                                    ),
                                    style: OutlinedButton.styleFrom(
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
                                    label: const Text('Change'),
                                    style: ElevatedButton.styleFrom(
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Consumer<KalKiProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Bazaar List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBazaarPreview(provider),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
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

  Widget _buildDateHeader(DayPlan plan) {
    // Simple date formatting
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final dateStr = "${tomorrow.day}/${tomorrow.month}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text(
            'PLANNING FOR',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2, // Capitalized tracking
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tomorrow, $dateStr',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300, // Light/Minimal font
              color: AppTheme.textPrimary,
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
  ) {
    if (dish == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
              color: Colors.black54,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
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

  Widget _buildBazaarPreview(KalKiProvider provider) {
    final list = provider.getGeneratedShoppingList();
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Nothing set for tomorrow yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Show first 3 items + count
    final previewItems = list.take(3).toList();
    final remaining = list.length - 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Very light grey for differentiating section
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...previewItems.map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              if (remaining > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$remaining more',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
