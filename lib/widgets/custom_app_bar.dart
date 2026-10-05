import 'package:fableaderpapp/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.isDarkMode = false,
    this.onThemeToggle,
    this.onNotificationTap,
    this.onProfileTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? AppColors.tidcraftBg : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDarkMode ? AppColors.tidcraftBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. LEFT: Side Menu Drawer Icon or Back Button in modern container
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (showBackButton) {
                      Navigator.maybePop(context);
                    } else {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        showBackButton
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.menu_rounded,
                        color: textPrimary,
                        size: 19.sp,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. CENTER: Bold & Clear Page Title
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 16.5.sp, // Prominent balanced page title
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              // 3. RIGHT: Actions (Theme Toggle, Notifications, Profile)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...?actions,

                  // Optional Theme Switcher
                  if (onThemeToggle != null) ...[
                    _buildIconButton(
                      isDarkMode: isDarkMode,
                      icon: isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      iconColor: isDarkMode
                          ? AppColors.amberAccent
                          : const Color(0xFF475569),
                      borderColor: borderColor,
                      onTap: onThemeToggle!,
                    ),
                    SizedBox(width: 2.w),
                  ],

                  // Notification Bell Icon with Red Counter Badge
                  GestureDetector(
                    onTap: onNotificationTap ??
                        () => _showNotificationsBottomSheet(
                            context, isDarkMode, textPrimary),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildIconContainer(
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          icon: Icons.notifications_none_rounded,
                          iconColor: textPrimary,
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? AppColors.tidcraftBg
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),

                  // Profile Avatar with Status Dot
                  GestureDetector(
             onTap: () {
               Get.to(ProfileScreen());
             },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF7A00),
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.28),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'FE',
                              style: TextStyle(
                                fontFamily: AppStyles.fontFamily,
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        // Online indicator dot
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? AppColors.tidcraftBg
                                    : Colors.white,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required bool isDarkMode,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: _buildIconContainer(
          isDarkMode: isDarkMode,
          borderColor: borderColor,
          icon: icon,
          iconColor: iconColor,
        ),
      ),
    );
  }

  Widget _buildIconContainer({
    required bool isDarkMode,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 17.sp,
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(
      BuildContext context, bool isDarkMode, Color textPrimary) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '2 New',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.greenAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: AppColors.greenAccent),
                      ),
                      title: Text(
                        'Sale Order #INV-GST-2026 completed',
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          color: textPrimary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('2 mins ago • Payment received: Cash'),
                    ),
                    const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inventory_2_rounded,
                            color: AppColors.primary),
                      ),
                      title: Text(
                        'Inventory Alert: Shoes (38 pcs left)',
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          color: textPrimary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('1 hour ago • Stock update'),
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

  void _showProfileDialog(
      BuildContext context, bool isDarkMode, Color textPrimary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.tidcraftCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'FE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fablead Admin',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      color: textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'admin@fableaderp.com',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      color: Colors.grey,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

