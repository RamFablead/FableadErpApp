import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../screens/accounting/view/account_ledger_screen.dart';
import '../screens/catalogsetup/view/product_category_screen.dart';
import '../screens/financers/view/financers_screen.dart';
import '../screens/login_screen.dart';
import '../screens/manageinventory/view/manage_inventory_screen.dart';
import '../screens/productdelivery/view/product_delivery_screen.dart';
import '../screens/products/view/add_product_screen.dart';
import '../screens/products/view/import_product_screen.dart';
import '../screens/products/view/product_screen.dart';
import '../screens/products/view/raw_materials_screen.dart';
import '../screens/sales&bills/view/all_sales_screen.dart';

class CustomDrawer extends StatefulWidget {
  final bool isDarkMode;
  final String activeItem;
  final Function(String)? onItemSelected;

  const CustomDrawer({
    super.key,
    required this.isDarkMode,
    required this.activeItem,
    this.onItemSelected,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  // Track expanded sections
  bool _isErpExpanded = true;
  bool _isProductsExpanded = false;
  bool _isCrmExpanded = false;
  bool _isReportsExpanded = false;
  bool _isAccountingExpanded = false;
  bool _isHrExpanded = false;
  bool _isSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.activeItem == 'Products' ||
        widget.activeItem == 'All Products' ||
        widget.activeItem == 'New Product' ||
        widget.activeItem == 'All Raw Materials' ||
        widget.activeItem == 'Import Products') {
      _isProductsExpanded = true;
      _isErpExpanded = true;
    }
    if (widget.activeItem == 'Account Ledger') {
      _isAccountingExpanded = true;
      _isErpExpanded = false;
    }
    if (widget.activeItem == 'Catalog Setup' ||
        widget.activeItem == 'Sales & Bills' ||
        widget.activeItem == 'Products Delivery' ||
        widget.activeItem == 'Financers' ||
        widget.activeItem == 'Manage Inventory') {
      _isErpExpanded = true;
    }
  }



  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final Color drawerBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final Color borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Drawer(
      backgroundColor: drawerBg,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 1. Simple & Sober Header
          _buildSoberHeader(context, headerBg, borderColor, textPrimary, textSecondary),

          // 2. Navigation List
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              children: [
                // Dashboard Item
                _buildSimpleNavItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  textPrimary: textPrimary,
                  onTap: () {
                    widget.onItemSelected?.call('Dashboard');
                    Navigator.pop(context);
                  },
                ),

                // Section 1: ERP
                _buildSectionHeader('ERP & INVENTORY', textSecondary),
                _buildExpandableSection(
                  title: 'ERP Modules',
                  icon: Icons.business_center_outlined,
                  isExpanded: _isErpExpanded,
                  onToggle: () => setState(() => _isErpExpanded = !_isErpExpanded),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  children: [
                      _buildProductsAccordion(textPrimary, textSecondary, isDark),
                      _buildSubItem(
                        title: 'Catalog Setup',
                        icon: Icons.label_outline,
                        textPrimary: textPrimary,
                        onTap: () {
                          widget.onItemSelected?.call('Catalog Setup');
                          Navigator.pop(context);
                          Get.to(() => const ProductCategoryScreen());
                        },
                      ),
                      _buildSubItem(
                        title: 'Sales & Bills',
                        icon: Icons.shopping_cart_outlined,
                        textPrimary: textPrimary,
                        onTap: () {
                          widget.onItemSelected?.call('Sales & Bills');
                          Navigator.pop(context);
                          Get.to(() => const AllSalesScreen());
                        },
                      ),
                      _buildSubItem(
                        title: 'Products Delivery',
                        icon: Icons.local_shipping_outlined,
                        textPrimary: textPrimary,
                        onTap: () {
                          widget.onItemSelected?.call('Products Delivery');
                          Navigator.pop(context);
                          Get.to(() => const ProductDeliveryScreen());
                        },
                      ),
                      _buildSubItem(
                        title: 'Purchases',
                        icon: Icons.receipt_long_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Vendors',
                        icon: Icons.handshake_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Financers',
                        icon: Icons.account_balance_outlined,
                        textPrimary: textPrimary,
                        onTap: () {
                          widget.onItemSelected?.call('Financers');
                          Navigator.pop(context);
                          Get.to(() => const FinancersScreen());
                        },
                      ),
                      _buildSubItem(
                        title: 'Manage Inventory',
                        icon: Icons.inventory_2_outlined,
                        textPrimary: textPrimary,
                        onTap: () {
                          widget.onItemSelected?.call('Manage Inventory');
                          Navigator.pop(context);
                          Get.to(() => const ManageInventoryScreen());
                        },
                      ),
                      _buildSubItem(
                        title: 'Returns',
                        icon: Icons.replay_outlined,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),

                // Section 2: CRM
                _buildSectionHeader('CRM & RELATIONS', textSecondary),
                _buildExpandableSection(
                  title: 'CRM',
                  icon: Icons.groups_outlined,
                  isExpanded: _isCrmExpanded,
                  onToggle: () => setState(() => _isCrmExpanded = !_isCrmExpanded),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  children: [
                      _buildSubItem(
                        title: 'Customers',
                        icon: Icons.people_outline,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Manage Leads',
                        icon: Icons.campaign_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Follow Ups',
                        icon: Icons.calendar_today_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Meetings',
                        icon: Icons.handshake_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Tickets',
                        icon: Icons.confirmation_number_outlined,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),

                // Section 3: Accounting & Finance
                _buildSectionHeader('FINANCE & ACCOUNTS', textSecondary),
                _buildExpandableSection(
                  title: 'Accounting',
                  icon: Icons.calculate_outlined,
                  isExpanded: _isAccountingExpanded,
                  onToggle: () => setState(() => _isAccountingExpanded = !_isAccountingExpanded),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  children: [
                      _buildSubItem(
                        title: 'Account Ledger',
                        icon: Icons.menu_book_outlined,
                        textPrimary: textPrimary,
                        onTap: () {
                          widget.onItemSelected?.call('Account Ledger');
                          Navigator.pop(context);
                          Get.to(() => const AccountLedgerScreen());
                        },
                      ),
                      _buildSubItem(
                        title: 'Manage Accounting',
                        icon: Icons.assessment_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Receipt & Payment',
                        icon: Icons.receipt_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Expenses',
                        icon: Icons.credit_card_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Cash & Bank',
                        icon: Icons.account_balance_wallet_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Credit/Debit Notes',
                        icon: Icons.subtitles_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'GST Reports',
                        icon: Icons.analytics_outlined,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),

                // Section 4: Reports
                _buildSectionHeader('REPORTS & STATS', textSecondary),
                _buildExpandableSection(
                  title: 'Reports',
                  icon: Icons.query_stats_outlined,
                  isExpanded: _isReportsExpanded,
                  onToggle: () => setState(() => _isReportsExpanded = !_isReportsExpanded),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  children: [
                      _buildSubItem(
                        title: 'Sales Report',
                        icon: Icons.bar_chart_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Sales Pool Report',
                        icon: Icons.pie_chart_outline,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'TDS Report',
                        icon: Icons.request_quote_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Purchase Report',
                        icon: Icons.receipt_long_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Expenses Report',
                        icon: Icons.account_balance_wallet_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Profit & Loss Statement',
                        icon: Icons.show_chart_outlined,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),

                // Section 5: HR
                _buildSectionHeader('HUMAN RESOURCES', textSecondary),
                _buildExpandableSection(
                  title: 'HR',
                  icon: Icons.badge_outlined,
                  isExpanded: _isHrExpanded,
                  onToggle: () => setState(() => _isHrExpanded = !_isHrExpanded),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  children: [
                      _buildSubItem(
                        title: 'Staff Attendance',
                        icon: Icons.check_circle_outline,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Payroll Progress',
                        icon: Icons.payments_outlined,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),

                // Section 6: Settings
                _buildSectionHeader('PREFERENCES', textSecondary),
                _buildExpandableSection(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  isExpanded: _isSettingsExpanded,
                  onToggle: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  children: [
                      _buildSubItem(
                        title: 'General Settings',
                        icon: Icons.tune_outlined,
                        textPrimary: textPrimary,
                      ),
                      _buildSubItem(
                        title: 'Company Profile',
                        icon: Icons.domain_outlined,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),

                SizedBox(height: 1.h),
              ],
            ),
          ),

          // 4. Simple Sober Footer
          _buildSoberFooter(context, borderColor, textSecondary),
        ],
      ),
    );
  }

  // ==================== 1. SOBER HEADER ====================
  Widget _buildSoberHeader(
    BuildContext context,
    Color headerBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final UserModel? user = StorageService.getUser();
    final String userName =
        user?.name?.isNotEmpty == true ? user!.name! : 'Main Branch';
    final String userEmail =
        user?.email?.isNotEmpty == true ? user!.email! : 'admin@gmail.com';
    final String userRole =
        user?.role?.isNotEmpty == true ? user!.role!.toUpperCase() : 'ADMIN';
    final String? profileImageUrl = user?.profileImageUrl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 1.2.h,
        bottom: 1.8.h,
        left: 4.w,
        right: 3.w,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Clean Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? Image.network(
                      profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitials(userName),
                    )
                  : _buildInitials(userName),
            ),
          ),

          SizedBox(width: 3.w),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        userRole,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.3.h),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 11.sp,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Simple Close Button
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close_rounded,
              color: textSecondary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'A',
        style: TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(String title, Color textSecondary) {
    return Padding(
      padding: EdgeInsets.only(left: 3.5.w, top: 1.2.h, bottom: 0.4.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: textSecondary.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  // ==================== 2. SIMPLE NAV ITEM ====================
  Widget _buildSimpleNavItem({
    required String title,
    required IconData icon,
    required IconData activeIcon,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    final bool isSelected = widget.activeItem == title;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.2.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border(
                left: BorderSide(color: AppColors.primary, width: 3.5),
              )
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.1.h),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : textPrimary.withValues(alpha: 0.8),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : textPrimary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // ==================== 3. EXPANDABLE SECTION ====================
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Color textPrimary,
    required Color textSecondary,
    required List<Widget> children,
  }) {
    final bool hasActiveChild = _hasActiveChild(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: hasActiveChild
                      ? AppColors.primary
                      : textPrimary.withValues(alpha: 0.8),
                  size: 20,
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 15.sp,
                      fontWeight: hasActiveChild ? FontWeight.w700 : FontWeight.w600,
                      color: hasActiveChild ? AppColors.primary : textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  color: textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Column(
              children: children,
            ),
          ),
      ],
    );
  }

  // ==================== 4. PRODUCTS ACCORDION ====================
  Widget _buildProductsAccordion(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final bool isSelected = widget.activeItem == 'Products' ||
        widget.activeItem == 'All Products' ||
        widget.activeItem == 'New Product' ||
        widget.activeItem == 'All Raw Materials' ||
        widget.activeItem == 'Import Products';

    if (!_isProductsExpanded && !isSelected) {
      return _buildSubItem(
        title: 'Products',
        icon: Icons.inventory_2_outlined,
        textPrimary: textPrimary,
        onTap: () {
          setState(() {
            _isProductsExpanded = true;
          });
        },
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.3.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isProductsExpanded = !_isProductsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Products',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isProductsExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: textSecondary,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
          _buildChildProductItem('All Products', const ProductScreen(), textPrimary),
          _buildChildProductItem('New Product', const AddProductScreen(), textPrimary),
          _buildChildProductItem('All Raw Materials', const RawMaterialsScreen(), textPrimary),
          _buildChildProductItem('Import Products', const ImportProductScreen(), textPrimary),
        ],
      ),
    );
  }

  Widget _buildChildProductItem(
    String title,
    Widget destination,
    Color textPrimary,
  ) {
    final bool isSelected = widget.activeItem == title;

    return InkWell(
      onTap: () {
        widget.onItemSelected?.call(title);
        Navigator.pop(context);
        Get.to(() => destination);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 14,
              color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
            SizedBox(width: 2.5.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 5. SUB NAV ITEM ====================
  Widget _buildSubItem({
    required String title,
    required IconData icon,
    required Color textPrimary,
    VoidCallback? onTap,
  }) {
    final bool isSelected = widget.activeItem == title;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.15.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.05.h),
          leading: Icon(
            icon,
            size: 18,
            color: isSelected
                ? AppColors.primary
                : textPrimary.withValues(alpha: 0.65),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : textPrimary,
            ),
          ),
          onTap: () {
            if (onTap != null) {
              onTap();
            } else {
              widget.onItemSelected?.call(title);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  // ==================== 6. SOBER FOOTER & LOGOUT ====================
  Widget _buildSoberFooter(
    BuildContext context,
    Color borderColor,
    Color textSecondary,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sober Logout Tile
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
            leading: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            onTap: () => _handleLogout(context),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Text(
              'Fablead ERP • v1.0.0',
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 9.5.sp,
                color: textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAuth();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  // ==================== HELPERS ====================
  bool _hasActiveChild(String groupTitle) {
    if (groupTitle.contains('ERP')) {
      return widget.activeItem == 'Products' ||
          widget.activeItem == 'All Products' ||
          widget.activeItem == 'New Product' ||
          widget.activeItem == 'All Raw Materials' ||
          widget.activeItem == 'Import Products' ||
          widget.activeItem == 'Catalog Setup' ||
          widget.activeItem == 'Sales & Bills' ||
          widget.activeItem == 'Products Delivery' ||
          widget.activeItem == 'Purchases' ||
          widget.activeItem == 'Vendors' ||
          widget.activeItem == 'Financers' ||
          widget.activeItem == 'Manage Inventory' ||
          widget.activeItem == 'Returns';
    }
    if (groupTitle.contains('CRM')) {
      return [
        'Customers',
        'Manage Leads',
        'Follow Ups',
        'Meetings',
        'Tickets'
      ].contains(widget.activeItem);
    }
    if (groupTitle.contains('Reports')) {
      return [
        'Sales Report',
        'Sales Pool Report',
        'TDS Report',
        'Purchase Report',
        'Expenses Report',
        'Profit & Loss Statement'
      ].contains(widget.activeItem);
    }
    if (groupTitle.contains('Finance') || groupTitle.contains('Accounting')) {
      return [
        'Account Ledger',
        'Manage Accounting',
        'Receipt & Payment',
        'Expenses',
        'Cash & Bank',
        'Credit/Debit Notes',
        'GST Reports'
      ].contains(widget.activeItem);
    }
    return false;
  }
}
