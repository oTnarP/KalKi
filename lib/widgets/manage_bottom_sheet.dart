import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';

class ManageBottomSheet extends StatelessWidget {
  const ManageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Manage KalKi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your dietary preferences and daily essentials.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader('Dietary Preferences'),
                _buildSwitchTile('I eat Beef', true, (val) {}),
                _buildSwitchTile('I eat Fish', true, (val) {}),
                _buildSwitchTile('I eat Chicken', true, (val) {}),

                const SizedBox(height: 24),
                _buildSectionHeader('Daily Essentials'),
                // Example of essentials management
                Consumer<KalKiProvider>(
                  builder: (context, provider, child) {
                    return Wrap(
                      spacing: 8,
                      children: provider.essentials.map((item) {
                        return FilterChip(
                          label: Text(item.name),
                          selected: item.isEnabled,
                          onSelected: (val) {
                            // Toggle logic (implied for V1)
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: AppTheme.secondaryColor.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: item.isEnabled
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Notifications'),
                _buildSwitchTile('Night Reminder (10:00 PM)', true, (val) {}),
                _buildSwitchTile('Cooking Reminders', false, (val) {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppTheme.primaryColor,
    );
  }
}
