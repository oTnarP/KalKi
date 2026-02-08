import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/kalki_provider.dart';
import '../theme.dart';
import '../models/models.dart';
import 'market_mode_screen.dart';
import '../widgets/manage_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KalKiProvider>(
      builder: (context, provider, child) {
        // Show loading
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        final plan = provider.currentPlan;

        if (plan == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Plan could not be generated.',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildDateHeader(context, provider.currentPlan!, provider),

                const SizedBox(height: 12),

                // UNIFIED CARD contains everything: Matches user request for "balanced", "icon top middle", "no empty spaces".
                Expanded(
                  child: _buildUnifiedDailyPlanCard(context, plan, provider),
                ),

                const SizedBox(height: 24), // Bottom spacing for safe area
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.shopping_basket_outlined,
          color: AppTheme.primaryColor,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MarketModeScreen()),
          );
        },
      ),
      centerTitle: true,
      title: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 24,
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
                  size: 6,
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
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    DailyPlan plan,
    KalKiProvider provider,
  ) {
    // Simple date format
    // final dateStr = "${plan.date.day}/${plan.date.month}";
    // We use DateFormat inside the text widget directly now
    return Column(
      children: [
        Text(
          provider.t('tomorrow_menu').toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Text(
          DateFormat('d MMM').format(plan.date), // "9 Feb" - Short & Sweet
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400, // Regular, not bold
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedDailyPlanCard(
    BuildContext context,
    DailyPlan plan,
    KalKiProvider provider,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. MAIN CONTENT (Padding wrapper)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${provider.t('lunch')} + ${provider.t('dinner')}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.restaurant,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  Text(
                    provider.t('cook_once'),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  // Center Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      _getDishIcon(plan.mainDish.id),
                      size: 32,
                      color: _getDishColor(plan.mainDish.id),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dish Names (Centered)
                  Text(
                    provider.getDishName(plan.mainDish),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.t('main_dish').toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    provider.getDishName(plan.sideDish),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.t('side_dish').toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      letterSpacing: 1.0,
                    ),
                  ),

                  const Spacer(),

                  Divider(
                    color: Colors.grey.withValues(alpha: 0.1),
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),

                  // Breakfast & Snack (Row)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breakfast
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 18,
                              color: Colors.orange[300],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.getDishName(plan.breakfast),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color, // Adaptive color
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "BREAKFAST",
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),

                      // Snack
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.coffee_outlined,
                              size: 18,
                              color: Colors.brown[300],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.getDishName(plan.snack),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color, // Adaptive color
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "SNACK",
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 2. FOOTER ACTIONS (Integrated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.03), // Subtle contrast
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
              ),
            ),
            child: Column(
              children: [
                // Buttons - Compact & Responsive
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.togglePlanLock,
                          icon: Icon(
                            provider.isPlanLocked
                                ? Icons.lock
                                : Icons.lock_outline,
                            size: 16,
                            color: provider.isPlanLocked
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                          label: Text(
                            provider.isPlanLocked
                                ? provider.t('unlock_plan')
                                : provider.t('lock_plan'),
                            maxLines: 1, // Prevent wrap
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: provider.isPlanLocked
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: provider.isPlanLocked
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            side: BorderSide(
                              color:
                                  (provider.isPlanLocked
                                          ? AppTheme
                                                .primaryColor // Keep colored border for consistency or faded?
                                          : Colors.grey)
                                      .withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            // Faded foreground when disabled (button itself handles disabled color but we want custom)
                            disabledForegroundColor: Colors.grey.withValues(
                              alpha: 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, // Tighter horizontal padding
                              vertical: 10, // Standard height
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Smaller gap
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.isPlanLocked
                              ? null
                              : provider.generateDailyPlan,
                          icon: Icon(
                            Icons.refresh,
                            size: 16,
                            color: provider.isPlanLocked
                                ? Colors.grey[400]
                                : AppTheme.primaryColor,
                          ),
                          label: Text(
                            provider.t('regenerate'),
                            maxLines: 1, // Prevent wrap
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: provider.isPlanLocked
                                  ? Colors.grey[400]
                                  : AppTheme.primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            disabledForegroundColor: Colors.grey,
                            side: BorderSide(
                              color:
                                  (provider.isPlanLocked
                                          ? Colors.grey
                                          : AppTheme.primaryColor)
                                      .withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, // Tighter padding
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Concise Shopping List (Footer)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        provider.getShoppingPreview(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDishIcon(String id) {
    // === FISH & SEAFOOD ===
    if (id.contains('ilish')) return FontAwesomeIcons.fish; // Regular Fish
    if (id.contains('rui') || id.contains('catla')) {
      return FontAwesomeIcons.fishFins; // Detailed Fish
    }
    if (id.contains('chingri') || id.contains('prawn')) {
      return FontAwesomeIcons.shrimp;
    }
    if (id.contains('shutki')) {
      return FontAwesomeIcons.bone; // Dried Fish distinctive
    }
    if (id.contains('mola') || id.contains('small_fish')) {
      return Icons.set_meal; // Small fish group
    }
    if (id.contains('fish')) return FontAwesomeIcons.fish;

    // === MEAT ===
    if (id.contains('chicken') || id.contains('roast')) {
      return FontAwesomeIcons.drumstickBite;
    }
    if (id.contains('beef') || id.contains('mutton') || id.contains('kala')) {
      return FontAwesomeIcons.burger; // Meat icon
    }
    if (id.contains('egg') || id.contains('dim')) return FontAwesomeIcons.egg;

    // === RICE & GRAINS ===
    if (id.contains('khichuri')) return FontAwesomeIcons.spoon; // Mixed rice
    if (id.contains('polao')) return FontAwesomeIcons.cloud; // Fluffy
    if (id.contains('biriyani') || id.contains('kacchi')) {
      return Icons.rice_bowl; // Special bowl
    }
    if (id.contains('rice') || id.contains('bhat')) {
      return FontAwesomeIcons.bowlRice;
    }

    // === BREADS ===
    if (id.contains('paratha')) return FontAwesomeIcons.pizzaSlice; // Triangle
    if (id.contains('ruti') || id.contains('bread')) {
      return FontAwesomeIcons.cookie; // Round
    }

    // === VEGETABLES ===
    if (id.contains('vorta')) return FontAwesomeIcons.mortarPestle; // Mashed
    if (id.contains('shak') || id.contains('leaf')) {
      return FontAwesomeIcons.leaf; // Leafy
    }
    if (id.contains('begun')) return FontAwesomeIcons.seedling; // Eggplantish
    if (id.contains('alu') || id.contains('potato')) {
      return FontAwesomeIcons.cookie; // Round vegetable
    }
    if (id.contains('dal')) return FontAwesomeIcons.mugHot; // Soup
    if (id.contains('vaji') ||
        id.contains('veg') ||
        id.contains('lau') ||
        id.contains('kumra') ||
        id.contains('kopi'))
      return FontAwesomeIcons.carrot;

    // === DESSERT ===
    if (id.contains('halua') || id.contains('misti') || id.contains('shemai')) {
      return FontAwesomeIcons.iceCream;
    }

    return FontAwesomeIcons.utensils;
  }

  Color _getDishColor(String id) {
    // === FISH Colors ===
    if (id.contains('ilish')) return Colors.blue[300]!;
    if (id.contains('rui')) return Colors.teal[300]!;
    if (id.contains('chingri')) return Colors.orange[400]!;
    if (id.contains('shutki')) return Colors.brown[600]!;
    if (id.contains('fish')) return Colors.blue[400]!;

    // === MEAT Colors ===
    if (id.contains('chicken') || id.contains('roast')) {
      return Colors.deepOrange;
    }
    if (id.contains('beef')) return Colors.red[800]!;
    if (id.contains('mutton')) return Colors.red[900]!;
    if (id.contains('egg')) return Colors.amber[600]!;

    // === RICE Colors ===
    if (id.contains('khichuri')) return Colors.yellow[700]!;
    if (id.contains('polao')) return Colors.grey[200]!;
    if (id.contains('biriyani')) return Colors.orange[700]!;
    if (id.contains('rice') || id.contains('bhat')) return Colors.amber[100]!;

    // === VEG Colors ===
    if (id.contains('shak')) return Colors.green[700]!;
    if (id.contains('begun')) return Colors.purple[300]!;
    if (id.contains('vorta')) return Colors.deepOrange[300]!;
    if (id.contains('dal')) return Colors.brown[300]!;
    if (id.contains('vaji') || id.contains('veg')) return Colors.lightGreen;

    return AppTheme.primaryColor;
  }
}
