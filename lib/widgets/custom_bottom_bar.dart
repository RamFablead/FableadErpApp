import 'package:flutter/material.dart';
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
        'activeIcon': Icons.dashboard_rounded,
        'inactiveIcon': Icons.dashboard_outlined,
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

    final Color barBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    const Color activeColor = Color(0xFFFFA043); // Brand Primary Orange
    final Color inactiveColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color activeTextColor =
        isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active Pill Capsule for Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: isSelected ? 52 : 36,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode
                                  ? activeColor.withValues(alpha: 0.22)
                                  : const Color(0xFFFFF2E6))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Icon(
                            (isSelected
                                ? item['activeIcon']
                                : item['inactiveIcon']) as IconData,
                            color: isSelected ? activeColor : inactiveColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Label
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? activeTextColor : inactiveColor,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
