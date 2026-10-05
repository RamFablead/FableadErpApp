import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

/// Reusable Custom Bottom Navigation Bar for Fablead ERP.
/// Displays 4 perfectly balanced modules:
/// 1. Dashboard
/// 2. Products
/// 3. Sale
/// 4. Profile
class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isDarkMode;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {
        'label': 'Dashboard',
        'activeIcon': Icons.grid_view_rounded,
        'inactiveIcon': Icons.grid_view_outlined,
      },
      {
        'label': 'Products',
        'activeIcon': Icons.inventory_2_rounded,
        'inactiveIcon': Icons.inventory_2_outlined,
      },
      {
        'label': 'Sale',
        'activeIcon': Icons.receipt_long_rounded,
        'inactiveIcon': Icons.receipt_long_outlined,
      },
      {
        'label': 'Profile',
        'activeIcon': Icons.person_rounded,
        'inactiveIcon': Icons.person_outline_rounded,
      },
    ];

    final Color barBg = isDarkMode ? AppColors.tidcraftCardBg : Colors.white;
    const Color activeColor = AppColors.primary;
    final Color inactiveColor =
        isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final Color borderColor =
        isDarkMode ? AppColors.tidcraftBorder : const Color(0xFFE2E8F0);
    final Color activeTextColor =
        isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onItemTapped(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Active Indicator Line
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: isSelected ? 24 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Center Icon with Animated Capsule Pill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        width: isSelected ? 54 : 38,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode
                                  ? activeColor.withValues(alpha: 0.20)
                                  : const Color(0xFFFFF2E6))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            (isSelected
                                ? item['activeIcon']
                                : item['inactiveIcon']) as IconData,
                            color: isSelected ? activeColor : inactiveColor,
                            size: 21,
                          ),
                        ),
                      ),

                      // Bottom Label Text
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected ? activeTextColor : inactiveColor,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

