import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/services/storage_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/custom_drawer.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'products/view/product_screen.dart';
import 'profile/controller/profile_controller.dart';
import 'sales&bills/view/all_sales_screen.dart';

/// Clean, modern User Profile screen matching web ERP design with Dark & Light mode toggle and enlarged typography.
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
  final ProfileController _controller = Get.put(ProfileController());

  bool _isDarkMode = false; // Default to Dark Mode theme

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = StorageService.getUser();
    _nameController = TextEditingController(text: user?.name ?? 'Main Branch');
    _emailController = TextEditingController(text: user?.email ?? 'admin@gmail.com');
    _phoneController = TextEditingController(text: user?.phone ?? '9876543210');
    _passwordController = TextEditingController(text: '********');

    _loadProfileData();
  }

  void _loadProfileData() async {
    await _controller.fetchProfile();
    final data = _controller.profileData.value;
    if (data != null && mounted) {
      setState(() {
        if (data.name?.isNotEmpty == true) _nameController.text = data.name!;
        if (data.email?.isNotEmpty == true) _emailController.text = data.email!;
        if (data.phone?.isNotEmpty == true) _phoneController.text = data.phone!;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        backgroundColor: _isDarkMode ? const Color(0xFF1E2746) : Colors.white,
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out from Fablead ERP?',
          style: TextStyle(
            fontSize: 14.sp,
            color: _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
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
                fontSize: 14.sp,
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
    // Dynamic theme colors based on _isDarkMode toggle
    final Color bgColor = _isDarkMode ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9);
    final Color cardBg = _isDarkMode ? const Color(0xFF1B243B) : Colors.white;
    final Color fieldBg = _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color borderColor = _isDarkMode ? const Color(0xFF2E3C62) : const Color(0xFFE2E8F0);
    final Color textPrimary = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final Color textSecondary = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color hintColor = _isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        title: 'Profile',
        showBackButton: false,
        isDarkMode: _isDarkMode,
        onThemeToggle: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
      drawer: CustomDrawer(
        isDarkMode: _isDarkMode,
        activeItem: 'Profile',
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: 3,
        isDarkMode: _isDarkMode,
        onItemTapped: _onBottomNavTapped,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.profileData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFA043)),
          );
        }

        final profile = _controller.profileData.value;
        final storedUser = StorageService.getUser();

        final String displayName = profile?.name?.isNotEmpty == true
            ? profile!.name!
            : (storedUser?.name?.isNotEmpty == true ? storedUser!.name! : 'Main Branch');

        return RefreshIndicator(
          onRefresh: () async {
            _loadProfileData();
          },
          color: const Color(0xFFFFA043),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Screen Header Title & Theme / Logout Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 20.sp, // ENLARGED SCREEN TITLE
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          'User Profile',
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 14.sp, // ENLARGED SUBTITLE
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        // Dark / Light Theme Mode Switch Capsule
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _isDarkMode
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isDarkMode
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isDarkMode
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  size: 18,
                                  color: _isDarkMode
                                      ? const Color(0xFFFFA043)
                                      : const Color(0xFFEA580C),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isDarkMode ? 'Dark' : 'Light',
                                  style: TextStyle(
                                    fontFamily: AppStyles.fontFamily,
                                    fontSize: 12.sp, // ENLARGED TOGGLE TEXT
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 2.w),

                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
                          tooltip: 'Logout',
                          onPressed: () => _handleLogout(context),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 2.2.h),

                // Main Profile Card (Dynamic Theme)
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _isDarkMode ? 0.25 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Orange/Coral Header Banner
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF6B4A),
                                Color(0xFFFFA043),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),

                      // 2. Avatar Overlay & User Title Header Row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Transform.translate(
                          offset: const Offset(0, -45),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Avatar Stack with Edit Pencil Badge
                              Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF1E2746),
                                      border: Border.all(
                                        color: cardBg,
                                        width: 4,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : 'M',
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontFamily,
                                          fontSize: 30.sp, // ENLARGED AVATAR INITIAL
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA043),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cardBg,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 4.w),

                              // Name & Subtitle Text
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontFamily,
                                          fontSize: 18.5.sp, // ENLARGED DISPLAY NAME
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Update Your Photo and Personal Details.',
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontFamily,
                                          fontSize: 13.sp, // ENLARGED SUBTITLE TEXT
                                          color: textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. Profile Form Fields (Name, Email, Phone, Password)
                      Padding(
                        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Name & Email
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildFormField(
                                          label: 'Name',
                                          controller: _nameController,
                                          hintText: 'Enter name',
                                          textPrimary: textPrimary,
                                          fieldBg: fieldBg,
                                          borderColor: borderColor,
                                          hintColor: hintColor,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: _buildFormField(
                                          label: 'Email',
                                          controller: _emailController,
                                          hintText: 'Enter email',
                                          keyboardType: TextInputType.emailAddress,
                                          textPrimary: textPrimary,
                                          fieldBg: fieldBg,
                                          borderColor: borderColor,
                                          hintColor: hintColor,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      _buildFormField(
                                        label: 'Name',
                                        controller: _nameController,
                                        hintText: 'Enter name',
                                        textPrimary: textPrimary,
                                        fieldBg: fieldBg,
                                        borderColor: borderColor,
                                        hintColor: hintColor,
                                      ),
                                      SizedBox(height: 2.h),
                                      _buildFormField(
                                        label: 'Email',
                                        controller: _emailController,
                                        hintText: 'Enter email',
                                        keyboardType: TextInputType.emailAddress,
                                        textPrimary: textPrimary,
                                        fieldBg: fieldBg,
                                        borderColor: borderColor,
                                        hintColor: hintColor,
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),

                            SizedBox(height: 2.h),

                            // Row 2: Phone & Password
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildFormField(
                                          label: 'Phone',
                                          controller: _phoneController,
                                          hintText: 'Enter phone',
                                          keyboardType: TextInputType.phone,
                                          textPrimary: textPrimary,
                                          fieldBg: fieldBg,
                                          borderColor: borderColor,
                                          hintColor: hintColor,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: _buildPasswordField(
                                          textPrimary: textPrimary,
                                          fieldBg: fieldBg,
                                          borderColor: borderColor,
                                          hintColor: hintColor,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      _buildFormField(
                                        label: 'Phone',
                                        controller: _phoneController,
                                        hintText: 'Enter phone',
                                        keyboardType: TextInputType.phone,
                                        textPrimary: textPrimary,
                                        fieldBg: fieldBg,
                                        borderColor: borderColor,
                                        hintColor: hintColor,
                                      ),
                                      SizedBox(height: 2.h),
                                      _buildPasswordField(
                                        textPrimary: textPrimary,
                                        fieldBg: fieldBg,
                                        borderColor: borderColor,
                                        hintColor: hintColor,
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),

                            SizedBox(height: 3.5.h),

                            // 4. Submit Action Button
                            SizedBox(
                              width: 150,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _controller.isUpdating.value
                                    ? null
                                    : () async {
                                        if (_nameController.text.trim().isEmpty ||
                                            _emailController.text.trim().isEmpty) {
                                          Get.snackbar(
                                            'Validation Error',
                                            'Name and Email cannot be empty.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: const Color(0xFFDC2626),
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        await _controller.updateProfile(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          phone: _phoneController.text.trim(),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA043),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _controller.isUpdating.value
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontFamily: AppStyles.fontFamily,
                                          fontSize: 16.sp, // ENLARGED BUTTON TEXT
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Reusable Form Input Field with Dynamic Theme Styling & Enlarged Fonts ---
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required Color textPrimary,
    required Color fieldBg,
    required Color borderColor,
    required Color hintColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 14.5.sp, // ENLARGED FIELD LABEL
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 15.sp, // ENLARGED FIELD TEXT
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 15.sp, // ENLARGED HINT TEXT
              color: hintColor,
            ),
            filled: true,
            fillColor: fieldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFA043), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // --- Password Field with Obscure Eye Toggle & Enlarged Fonts ---
  Widget _buildPasswordField({
    required Color textPrimary,
    required Color fieldBg,
    required Color borderColor,
    required Color hintColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 14.5.sp, // ENLARGED LABEL
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 15.sp, // ENLARGED FIELD TEXT
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter password',
            hintStyle: TextStyle(
              fontSize: 15.sp, // ENLARGED HINT TEXT
              color: hintColor,
            ),
            filled: true,
            fillColor: fieldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: hintColor,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFA043), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
