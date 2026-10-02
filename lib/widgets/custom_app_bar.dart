import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.isDarkMode = true,
    this.onThemeToggle,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(6.5.h);

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? AppColors.tidcraftBg : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor = isDarkMode ? AppColors.tidcraftBorder : const Color(0xFFE2E8F0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. LEFT: Side Menu Drawer Icon or Back Button
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    showBackButton ? Icons.arrow_back_rounded : Icons.menu_rounded,
                    color: textPrimary,
                    size: 21.sp,
                  ),
                  onPressed: () {
                    if (showBackButton) {
                      Navigator.maybePop(context);
                    } else {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                ),
              ],
            ),

            // 2. CENTER: App Logo + Page Title (Bold, Clear & Centered)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 3.6.h,
                    width: 3.6.h,
                    margin: EdgeInsets.only(right: 2.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tidcraftOrange.withValues(alpha: 0.25),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/logo.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, err, st) {
                              return const Icon(
                                Icons.business_center_rounded,
                                color: AppColors.tidcraftOrange,
                                size: 20,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 14.5.sp, // Clear Balanced Page Title Font
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. RIGHT: Notification Icon with Badge & Profile Avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Optional Theme Switcher
                if (onThemeToggle != null) ...[
                  GestureDetector(
                    onTap: onThemeToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.tidcraftCardBg
                            : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: isDarkMode
                            ? AppColors.amberAccent
                            : const Color(0xFF1E293B),
                        size: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],

                // Notification Bell Icon with Red Counter Badge
                GestureDetector(
                  onTap: onNotificationTap ?? () => _showNotificationsBottomSheet(context, isDarkMode, textPrimary),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.tidcraftCardBg
                              : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: textPrimary,
                          size: 16.sp,
                        ),
                      ),
                      Positioned(
                        top: 1,
                        right: 1,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '3',
                            style: TextStyle(
                              fontSize: 7.5.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),

                // Profile Avatar Icon
                GestureDetector(
                  onTap: onProfileTap ?? () => _showProfileDialog(context, isDarkMode, textPrimary),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.tidcraftOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tidcraftOrange, width: 1.2),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.tidcraftOrange,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context, bool isDarkMode, Color textPrimary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.tidcraftCardBg : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(5.w),
          height: 38.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.greenAccent,
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      title: Text('Sale INV-2025-0980 completed',
                          style: TextStyle(color: textPrimary, fontSize: 11.5.sp, fontWeight: FontWeight.bold)),
                      subtitle: const Text('2 mins ago'),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.tidcraftOrange,
                        child: Icon(Icons.shopping_bag, color: Colors.white),
                      ),
                      title: Text('New Purchase Order Created',
                          style: TextStyle(color: textPrimary, fontSize: 11.5.sp, fontWeight: FontWeight.bold)),
                      subtitle: const Text('1 hour ago'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context, bool isDarkMode, Color textPrimary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.tidcraftCardBg : Colors.white,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.tidcraftOrange,
              child: Text('FE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fablead Admin', style: TextStyle(color: textPrimary, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                Text('admin@fableaderp.com', style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.tidcraftOrange)),
          ),
        ],
      ),
    );
  }
}
