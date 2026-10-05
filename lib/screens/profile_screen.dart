import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/custom_drawer.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'products/view/product_screen.dart';
import 'sales&bills/view/all_sales_screen.dart';

/// Screen displaying the User Profile, Account Details & Preferences (View & Edit).
class ProfileScreen extends StatefulWidget {
  final bool openEditDialog;

  const ProfileScreen({
    super.key,
    this.openEditDialog = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.openEditDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEditProfileDialog();
      });
    }
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        Get.offAll(() => const HomeScreen());
        break;
      case 1:
        Get.to(() => const ProductScreen());
        break;
      case 2:
        Get.to(() => const AllSalesScreen());
        break;
      case 3:
        // Already on Profile
        break;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 26,
            ),
            SizedBox(width: 2.w),
            Text(
              'Logout Account',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out from Fablead ERP?',
          style: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAuth();
      if (!mounted) return;
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = StorageService.getUser();
    final String userName =
        user?.name?.isNotEmpty == true ? user!.name! : 'Main Branch';
    final String userEmail =
        user?.email?.isNotEmpty == true ? user!.email! : 'admin@gmail.com';
    final String userRole =
        user?.role?.isNotEmpty == true ? user!.role!.toUpperCase() : 'ADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: false,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(
        isDarkMode: false,
        activeItem: 'Profile',
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: 3,
        isDarkMode: _isDarkMode,
        onItemTapped: _onBottomNavTapped,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
        child: Column(
          children: [
            // Top Profile Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E2746),
                      border: Border.all(
                        color: const Color(0xFFFFA043),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA043).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 1.5.h),

                  // Name & Role
                  Text(
                    userName,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),

                  SizedBox(height: 0.4.h),

                  Text(
                    userEmail,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),

                  SizedBox(height: 1.2.h),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA043).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFA043).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 15,
                          color: Color(0xFFEA580C),
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          userRole,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 1.5.h),

                  // Edit Profile Button
                  OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1E2746)),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2746),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Account Information Section
            _buildInfoCard(
              title: 'Account Information',
              icon: Icons.person_outline_rounded,
              items: [
                _buildInfoRow('Full Name', userName),
                _buildInfoRow('Email Address', userEmail),
                _buildInfoRow('Account Role', userRole),
                _buildInfoRow('Status', 'Active', isStatus: true),
              ],
            ),

            SizedBox(height: 2.h),

            // ERP System Details Section
            _buildInfoCard(
              title: 'ERP Details',
              icon: Icons.business_rounded,
              items: [
                _buildInfoRow('Branch', 'Main Branch'),
                _buildInfoRow('Server', 'erp-demo.fableadtech.com'),
                _buildInfoRow('Access Level', 'Full Administrator'),
                _buildInfoRow('Version', 'v1.0.0'),
              ],
            ),

            SizedBox(height: 2.5.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                label: Text(
                  'Logout Account',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1E2746)),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final UserModel? user = StorageService.getUser();
    final nameCtrl = TextEditingController(text: user?.name ?? 'Main Branch');
    final emailCtrl = TextEditingController(text: user?.email ?? 'admin@gmail.com');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2746).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, color: Color(0xFF1E2746), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Email Address',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile changes noted. (Will be saved via API)'),
                  backgroundColor: Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA043),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
