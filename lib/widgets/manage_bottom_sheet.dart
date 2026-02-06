import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';

class ManageBottomSheet extends StatelessWidget {
  const ManageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KalKiProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          // Enforce minimum height to prevent jitter
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use MainAxisSize.min
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.t('manage_kalki'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  // Language toggle moved here
                  // Language toggle moved here
                  IconButton(
                    onPressed: () =>
                        provider.toggleLanguage(!provider.isBangla),
                    icon: Text(
                      provider.isBangla ? '🇬🇧' : '🇧🇩',
                      style: const TextStyle(fontSize: 24),
                    ),
                    tooltip: provider.isBangla
                        ? 'Switch to English'
                        : 'বাংলায় দেখুন',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                provider.t('customize_pref'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Use SingleChildScrollView to make the content scrollable if it exceeds screen height
              Flexible(
                // Use Flexible to constrain the height of the SingleChildScrollView
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(provider.t('water_reminder')),
                      Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              provider.t('enable_reminder'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: provider.waterReminderEnabled,
                            onChanged: (val) =>
                                provider.toggleWaterReminder(val),
                            activeTrackColor: AppTheme.primaryColor,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: provider.waterReminderEnabled
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.t('frequency'),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [1, 2, 3].map((hours) {
                                            final isSelected =
                                                provider
                                                    .waterReminderFrequency ==
                                                hours;
                                            return Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: InkWell(
                                                  onTap: () => provider
                                                      .setWaterReminderFrequency(
                                                        hours,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? AppTheme
                                                                .primaryColor
                                                          : Colors.white,
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? AppTheme
                                                                  .primaryColor
                                                            : Colors.grey[300]!,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${hours}h',
                                                        style: TextStyle(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : AppTheme
                                                                    .textPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(provider.t('extra_portions')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.t('guests_tomorrow'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            height: 32, // More compact
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => provider.updateGuestCount(
                                    provider.guestCount - 1,
                                  ),
                                  icon: const Icon(Icons.remove, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '${provider.guestCount}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => provider.updateGuestCount(
                                    provider.guestCount + 1,
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(provider.t('app_settings')),
                      Column(
                        children: [
                          _buildSwitchTile(
                            provider.t('dark_mode'),
                            provider.isDarkMode,
                            (val) => provider.toggleDarkMode(val),
                          ),
                          const SizedBox(height: 16),
                          // Language toggle removed from here
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
