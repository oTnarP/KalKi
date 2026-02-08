import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  child: totalItems == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.t('shopping_list_empty'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.t('all_set'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          children: [
                            // Completion Celebration
                            if (progress >= 1.0 && totalItems > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.celebration,
                                      color: Colors.green.shade700,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '🎉 ${provider.t('all_done')}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            provider.t('happy_cooking'),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (cookingList.isNotEmpty) ...[
                              _buildSectionTitle(
                                provider.t('for_tomorrow'),
                                Icons.restaurant_menu,
                                iconColor: Colors.deepOrange,
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
                                Icons.star,
                                iconColor: Colors.amber.shade700,
                              ),
                              const SizedBox(height: 12),
                              ...starredEssentials.map(
                                (item) => _buildMinimalCheckItem(
                                  context,
                                  provider,
                                  provider.getRoutineItemName(item),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            if (otherEssentials.isNotEmpty) ...[
                              _buildSectionTitle(
                                provider.t('others'),
                                Icons.shopping_basket,
                                iconColor: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 12),
                              ...otherEssentials.map(
                                (item) => _buildMinimalCheckItem(
                                  context,
                                  provider,
                                  provider.getRoutineItemName(item),
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
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  letterSpacing: -0.5,
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
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: provider.localizeText(picked.toString()),
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
                          text: provider.localizeText('/$total'),
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
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      color: progress >= 1.0
                          ? Colors.green
                          : AppTheme.primaryColor,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    provider.localizeText('${(progress * 100).toInt()}%'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: progress >= 1.0
                          ? Colors.green
                          : Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: iconColor ?? AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: (iconColor ?? AppTheme.primaryColor).withValues(
                alpha: 0.2,
              ),
            ),
          ),
        ],
      ),
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
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isChecked
                      ? Colors.grey[400]
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
