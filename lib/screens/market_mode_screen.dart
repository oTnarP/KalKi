import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';

class MarketModeScreen extends StatelessWidget {
  const MarketModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // "Finish Shopping" effectively
            Navigator.pop(context);
          },
        ),
        title: const Text('Market Mode'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('DONE'),
          ),
        ],
      ),
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

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildHeader('For Tomorrow\'s Cooking'),
              ...cookingList.map(
                (item) =>
                    _buildCheckItem(context, provider, item, isCooking: true),
              ),

              if (starredEssentials.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildHeader('Starred Essentials'),
                ...starredEssentials.map(
                  (item) => _buildCheckItem(context, provider, item.name),
                ),
              ],

              if (otherEssentials.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildHeader('Other Essentials'),
                ...otherEssentials.map(
                  (item) => _buildCheckItem(context, provider, item.name),
                ),
              ],

              const SizedBox(height: 100), // Bottom padding
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        label: const Text('Finish Shopping'),
        icon: const Icon(Icons.check),
        backgroundColor: AppTheme.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context,
    KalKiProvider provider,
    String name, {
    bool isCooking = false,
  }) {
    final isChecked = provider.isItemChecked(name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: isChecked ? Colors.grey[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isChecked ? Colors.transparent : Colors.grey[200]!,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => provider.toggleCheckItem(name),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isChecked
                      ? Colors.grey
                      : (isCooking
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary),
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? Colors.grey : AppTheme.textPrimary,
                      fontWeight: isCooking
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
