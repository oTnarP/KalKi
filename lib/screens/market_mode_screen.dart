import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';

class MarketModeScreen extends StatelessWidget {
  const MarketModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<KalKiProvider>(
        builder: (context, provider, child) {
          final cookingList = provider.getGeneratedShoppingList();
          final essentials = provider.essentials
              .where((e) => e.isEnabled)
              .toList();
          final starredEssentials = essentials
              .where((e) => e.isStarred)
              .toList();
          final otherEssentials = essentials
              .where((e) => !e.isStarred)
              .toList();

          final totalItems =
              cookingList.length +
              starredEssentials.length +
              otherEssentials.length;
          final pickedCount = provider.checkedItems.length;
          final progress = totalItems > 0 ? pickedCount / totalItems : 0.0;

          return SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(
                  context,
                  pickedCount,
                  totalItems,
                  progress,
                  provider,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      if (cookingList.isNotEmpty) ...[
                        _buildSectionTitle(
                          provider.t('for_tomorrow'),
                          Icons.restaurant,
                        ),
                        const SizedBox(height: 12),
                        ...cookingList.map(
                          (item) => _buildMinimalCheckItem(
                            context,
                            provider,
                            item,
                            isCooking: true,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      if (starredEssentials.isNotEmpty) ...[
                        _buildSectionTitle(
                          provider.t('essentials'),
                          Icons.star_border,
                        ),
                        const SizedBox(height: 12),
                        ...starredEssentials.map(
                          (item) => _buildMinimalCheckItem(
                            context,
                            provider,
                            item.name,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      if (otherEssentials.isNotEmpty) ...[
                        _buildSectionTitle(provider.t('others'), Icons.api),
                        const SizedBox(height: 12),
                        ...otherEssentials.map(
                          (item) => _buildMinimalCheckItem(
                            context,
                            provider,
                            item.name,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      const SizedBox(height: 80), // Fab space
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomHeader(
    BuildContext context,
    int picked,
    int total,
    double progress,
    KalKiProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: Theme.of(context).iconTheme.color,
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                provider.t('shopping_list'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(width: 40), // Balance back button
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.t('picked_items'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$picked',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).textTheme.displaySmall?.color ??
                                AppTheme.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '/$total',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100, width: 4),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[100],
                    color: AppTheme.primaryColor,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalCheckItem(
    BuildContext context,
    KalKiProvider provider,
    String name, {
    bool isCooking = false,
  }) {
    final isChecked = provider.isItemChecked(name);

    return GestureDetector(
      onTap: () => provider.toggleCheckItem(name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isChecked
              ? Theme.of(context).disabledColor.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: isChecked
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isChecked ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: isChecked
                      ? Colors.grey[400]
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
