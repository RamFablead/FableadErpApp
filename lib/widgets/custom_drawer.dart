// ignore_for_file: unused_element, unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../screens/accounting/view/account_ledger_screen.dart';
import '../screens/catalogsetup/view/add_brands_screen.dart';
import '../screens/catalogsetup/view/add_product_category_screen.dart';
import '../screens/catalogsetup/view/all_brands_screen.dart';
import '../screens/catalogsetup/view/all_labour_items_screen.dart';
import '../screens/catalogsetup/view/all_units_screen.dart';
import '../screens/catalogsetup/view/product_category_screen.dart';
import '../screens/financers/view/financers_screen.dart';
import '../screens/financers/view/import_financers_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/manageinventory/view/manage_inventory_screen.dart';
import '../screens/manageinventory/view/view_inventory_screen.dart';
import '../screens/productdelivery/view/product_delivery_screen.dart';
import '../screens/products/view/add_product_screen.dart';
import '../screens/products/view/import_product_screen.dart';
import '../screens/products/view/product_screen.dart';
import '../screens/products/view/raw_materials_screen.dart';
import '../screens/sales&bills/view/all_sales_screen.dart';
import '../screens/sales&bills/view/sales_screen.dart';
import '../screens/profile_screen.dart';

/// Clean, modern, professional ERP Side Menu Drawer matching the web dashboard layout.
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
  // Accordion expansion states
  bool _isCatalogExpanded = false;
  bool _isProductsExpanded = false;
  bool _isInventoryExpanded = false;
  bool _isSalesExpanded = false;
  bool _isFinanceExpanded = false;
  bool _isAccountingExpanded = false;
  bool _isReportsExpanded = false;
  bool _isHrExpanded = false;
  bool _isSettingsExpanded = false;
  bool _isProfileExpanded = false;

  @override
  void initState() {
    super.initState();
    _initExpansionState();
  }

  void _initExpansionState() {
    final item = widget.activeItem;

    // Catalog Setup items
    if (const [
      'Catalog Setup',
      'All Categories',
      'New Category',
      'All Brands',
      'New Brand',
      'All Units',
      'All Labour Items',
      'Categories',
    ].contains(item)) {
      _isCatalogExpanded = true;
    }

    // Products items
    if (const [
      'Products',
      'All Products',
      'New Product',
      'All Raw Materials',
      'Import Products',
    ].contains(item)) {
      _isProductsExpanded = true;
    }

    // Inventory items
    if (const [
      'Manage Inventory',
      'All Stock',
      'Stock Overview',
      'View Inventory',
    ].contains(item)) {
      _isInventoryExpanded = true;
    }

    // Sales items
    if (const [
      'Sale',
      'Sales & Bills',
      'All Sales',
      'New Sale',
    ].contains(item)) {
      _isSalesExpanded = true;
    }

    // Profile items
    if (const [
      'Profile',
      'View Profile',
      'Edit Profile',
    ].contains(item)) {
      _isProfileExpanded = true;
    }

    // Finance items
    if (const [
      'Financers',
      'All Financers',
      'Import Financers',
      'Vendors',
    ].contains(item)) {
      _isFinanceExpanded = true;
    }

    // Accounting items
    if (const [
      'Accounting',
      'Account Ledger',
      'Manage Accounting',
      'Receipt & Payment',
      'Expenses',
      'Cash & Bank',
      'Credit/Debit Notes',
      'GST Reports',
    ].contains(item)) {
      _isAccountingExpanded = true;
    }

    // Reports items
    if (const [
      'Reports',
      'Sales Report',
      'Sales Pool Report',
      'TDS Report',
      'Purchase Report',
      'Expenses Report',
      'Profit & Loss',
    ].contains(item)) {
      _isReportsExpanded = true;
    }

    // HR items
    if (const [
      'HR',
      'Staff Attendance',
      'Payroll Progress',
    ].contains(item)) {
      _isHrExpanded = true;
    }

    // Settings items
    if (const [
      'Settings',
      'General Settings',
      'Company Profile',
    ].contains(item)) {
      _isSettingsExpanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final Color drawerBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Drawer(
      backgroundColor: drawerBg,
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // 1. Top Brand & User Profile Header
          _buildDrawerHeader(context, headerBg, borderColor, textPrimary, textSecondary, isDark),

          // 2. Navigation Items List (Active: Dashboard, Products, Sale, Profile)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
              children: [
                // 1. DASHBOARD MODULE
                _buildDirectNavItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  textPrimary: textPrimary,
                  isDark: isDark,
                  onTap: () {
                    widget.onItemSelected?.call('Dashboard');
                    Navigator.pop(context);
                    if (Get.currentRoute != '/HomeScreen') {
                      Get.offAll(() => const HomeScreen());
                    }
                  },
                ),

                SizedBox(height: 0.6.h),

                // 2. PRODUCTS MODULE
                _buildAccordionModule(
                  title: 'Products',
                  icon: Icons.inventory_2_rounded,
                  isExpanded: _isProductsExpanded,
                  onToggle: () => setState(() => _isProductsExpanded = !_isProductsExpanded),
                  activeChildTitles: const [
                    'Products',
                    'All Products',
                    'New Product',
                    // 'All Raw Materials',
                    // 'Import Products',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('All Products', const ProductScreen(), textPrimary),
                    _buildSubItem('New Product', const AddProductScreen(), textPrimary),
                    // _buildSubItem('All Raw Materials', const RawMaterialsScreen(), textPrimary),
                    // _buildSubItem('Import Products', const ImportProductScreen(), textPrimary),
                  ],
                ),

                SizedBox(height: 0.6.h),

                // 3. SALE MODULE
                _buildAccordionModule(
                  title: 'Sale',
                  icon: Icons.shopping_cart_rounded,
                  isExpanded: _isSalesExpanded,
                  onToggle: () => setState(() => _isSalesExpanded = !_isSalesExpanded),
                  activeChildTitles: const [
                    'Sale',
                    'Sales & Bills',
                    'All Sales',
                    'New Sale',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('All Sales', const AllSalesScreen(), textPrimary),
                    _buildSubItem('New Sale', const SalesScreen(), textPrimary),
                  ],
                ),

                SizedBox(height: 0.6.h),

                // 4. PROFILE MODULE (VIEW & EDIT PROFILE)
                _buildAccordionModule(
                  title: 'Profile',
                  icon: Icons.person_rounded,
                  isExpanded: _isProfileExpanded,
                  onToggle: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
                  activeChildTitles: const [
                    'Profile',
                    'View Profile',
                    'Edit Profile',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('View Profile', const ProfileScreen(), textPrimary),
                    _buildSubItem('Edit Profile', const ProfileScreen(openEditDialog: true), textPrimary),
                  ],
                ),

                SizedBox(height: 1.5.h),

                /* ================================================================
                   OTHER MODULES COMMENTED OUT AS PER REQUEST (CAN BE RESTORED)
                   ================================================================

                // ================= SECTION: CATALOG & PRODUCTS =================
                _buildSectionHeader('CATALOG & INVENTORY', textSecondary),

                // 1. Catalog Setup Accordion
                _buildAccordionModule(
                  title: 'Catalog Setup',
                  icon: Icons.label_rounded,
                  isExpanded: _isCatalogExpanded,
                  onToggle: () => setState(() => _isCatalogExpanded = !_isCatalogExpanded),
                  activeChildTitles: const [
                    'Catalog Setup',
                    'All Categories',
                    'New Category',
                    'All Brands',
                    'New Brand',
                    'All Units',
                    'All Labour Items',
                    'Categories',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('All Categories', const ProductCategoryScreen(), textPrimary),
                    _buildSubItem('New Category', const AddProductCategoryScreen(), textPrimary),
                    _buildSubItem('All Brands', const AllBrandsScreen(), textPrimary),
                    _buildSubItem('New Brand', const AddBrandsScreen(), textPrimary),
                    _buildSubItem('All Units', const AllUnitsScreen(), textPrimary),
                    _buildSubItem('All Labour Items', const AllLabourItemsScreen(), textPrimary),
                  ],
                ),

                // Manage Inventory Accordion
                _buildAccordionModule(
                  title: 'Manage Inventory',
                  icon: Icons.warehouse_rounded,
                  isExpanded: _isInventoryExpanded,
                  onToggle: () => setState(() => _isInventoryExpanded = !_isInventoryExpanded),
                  activeChildTitles: const [
                    'Manage Inventory',
                    'All Stock',
                    'Stock Overview',
                    'View Inventory',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('Inventory List', const ManageInventoryScreen(), textPrimary),
                    _buildSubItem('Stock Overview', const ViewInventoryScreen(), textPrimary),
                  ],
                ),

                // Products Delivery (Direct Item)
                _buildDirectNavItem(
                  title: 'Products Delivery',
                  icon: Icons.local_shipping_rounded,
                  textPrimary: textPrimary,
                  isDark: isDark,
                  onTap: () {
                    widget.onItemSelected?.call('Products Delivery');
                    Navigator.pop(context);
                    Get.to(() => const ProductDeliveryScreen());
                  },
                ),

                SizedBox(height: 1.h),

                // ================= SECTION: SALES & BILLING =================
                _buildSectionHeader('SALES & ORDERS', textSecondary),

                // Purchases (Direct Item)
                _buildDirectNavItem(
                  title: 'Purchases',
                  icon: Icons.receipt_long_rounded,
                  textPrimary: textPrimary,
                  isDark: isDark,
                  onTap: () {
                    widget.onItemSelected?.call('Purchases');
                    Navigator.pop(context);
                    Get.to(() => const AllSalesScreen());
                  },
                ),

                // Vendors & Financers Accordion
                _buildAccordionModule(
                  title: 'Vendors & Financers',
                  icon: Icons.handshake_rounded,
                  isExpanded: _isFinanceExpanded,
                  onToggle: () => setState(() => _isFinanceExpanded = !_isFinanceExpanded),
                  activeChildTitles: const [
                    'Financers',
                    'All Financers',
                    'Import Financers',
                    'Vendors',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('All Financers', const FinancersScreen(), textPrimary),
                    _buildSubItem('Import Financers', const ImportFinancersScreen(), textPrimary),
                  ],
                ),

                SizedBox(height: 1.h),

                // ================= SECTION: ACCOUNTS & REPORTS =================
                _buildSectionHeader('FINANCE & REPORTS', textSecondary),

                // Accounting Accordion
                _buildAccordionModule(
                  title: 'Accounting',
                  icon: Icons.account_balance_rounded,
                  isExpanded: _isAccountingExpanded,
                  onToggle: () => setState(() => _isAccountingExpanded = !_isAccountingExpanded),
                  activeChildTitles: const [
                    'Accounting',
                    'Account Ledger',
                    'Manage Accounting',
                    'Receipt & Payment',
                    'Expenses',
                    'Cash & Bank',
                    'Credit/Debit Notes',
                    'GST Reports',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildSubItem('Account Ledger', const AccountLedgerScreen(), textPrimary),
                    _buildDirectSubAction('Manage Accounting', textPrimary),
                    _buildDirectSubAction('Receipt & Payment', textPrimary),
                    _buildDirectSubAction('Expenses', textPrimary),
                    _buildDirectSubAction('Cash & Bank', textPrimary),
                    _buildDirectSubAction('GST Reports', textPrimary),
                  ],
                ),

                // Reports Accordion
                _buildAccordionModule(
                  title: 'Reports & Analytics',
                  icon: Icons.analytics_rounded,
                  isExpanded: _isReportsExpanded,
                  onToggle: () => setState(() => _isReportsExpanded = !_isReportsExpanded),
                  activeChildTitles: const [
                    'Reports',
                    'Sales Report',
                    'Sales Pool Report',
                    'TDS Report',
                    'Purchase Report',
                    'Expenses Report',
                    'Profit & Loss',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildDirectSubAction('Sales Report', textPrimary),
                    _buildDirectSubAction('Purchase Report', textPrimary),
                    _buildDirectSubAction('Expenses Report', textPrimary),
                    _buildDirectSubAction('Profit & Loss Statement', textPrimary),
                  ],
                ),

                SizedBox(height: 1.h),

                // ================= SECTION: SYSTEM & PREFERENCES =================
                _buildSectionHeader('PREFERENCES', textSecondary),

                // HR Accordion
                _buildAccordionModule(
                  title: 'Human Resources',
                  icon: Icons.badge_rounded,
                  isExpanded: _isHrExpanded,
                  onToggle: () => setState(() => _isHrExpanded = !_isHrExpanded),
                  activeChildTitles: const [
                    'HR',
                    'Staff Attendance',
                    'Payroll Progress',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildDirectSubAction('Staff Attendance', textPrimary),
                    _buildDirectSubAction('Payroll Progress', textPrimary),
                  ],
                ),

                // Settings Accordion
                _buildAccordionModule(
                  title: 'Settings',
                  icon: Icons.tune_rounded,
                  isExpanded: _isSettingsExpanded,
                  onToggle: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
                  activeChildTitles: const [
                    'Settings',
                    'General Settings',
                    'Company Profile',
                  ],
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  children: [
                    _buildDirectSubAction('General Settings', textPrimary),
                    _buildDirectSubAction('Company Profile', textPrimary),
                  ],
                ),
                ================================================================ */

                SizedBox(height: 1.5.h),
              ],
            ),
          ),

          // 3. Bottom Footer & Logout Action
          _buildDrawerFooter(context, borderColor, textSecondary, isDark),
        ],
      ),
    );
  }

  // ==================== 1. DRAWER HEADER ====================
  Widget _buildDrawerHeader(
    BuildContext context,
    Color headerBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
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
        bottom: 1.6.h,
        left: 4.w,
        right: 3.w,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo / Title Row with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2746),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.business_center_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Text(
                    'FABLEAD ERP',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: const Color(0xFF1E2746),
                    ),
                  ),
                ],
              ),
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

          SizedBox(height: 1.5.h),

          // User Profile Card
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const ProfileScreen());
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E2746),
                        border: Border.all(
                          color: const Color(0xFFFFA043),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? Image.network(
                                profileImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildAvatarLetter(userName),
                              )
                            : _buildAvatarLetter(userName),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 3.w),

                // Name, Role & Email
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
                              color: const Color(0xFFFFA043).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              userRole,
                              style: TextStyle(
                                fontFamily: AppStyles.fontFamily,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 10.5.sp,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarLetter(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'A',
        style: TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(String title, Color textSecondary) {
    return Padding(
      padding: EdgeInsets.only(left: 3.w, top: 1.2.h, bottom: 0.5.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  // ==================== DIRECT NAV ITEM ====================
  Widget _buildDirectNavItem({
    required String title,
    required IconData icon,
    required Color textPrimary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bool isSelected = widget.activeItem == title;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.2.h),
      child: Material(
        color: isSelected
            ? const Color(0xFF1E2746) // Matching dark navy pill
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.1.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ACCORDION MODULE (MATCHING USER SCREENSHOT) ====================
  Widget _buildAccordionModule({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<String> activeChildTitles,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required List<Widget> children,
  }) {
    final bool hasActiveChild = activeChildTitles.contains(widget.activeItem);
    final bool isHeaderActive = isExpanded || hasActiveChild;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tile matching the user's uploaded screenshot (Dark Navy when open/active)
          Material(
            color: isHeaderActive
                ? const Color(0xFF1E2746)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.1.h),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isHeaderActive
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isHeaderActive ? Colors.white : textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.chevron_right_rounded,
                      color: isHeaderActive
                          ? Colors.white70
                          : textSecondary,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sub-Items (Clean circle bullet outline matching screenshot)
          if (isExpanded) ...[
            SizedBox(height: 0.4.h),
            Column(children: children),
            SizedBox(height: 0.4.h),
          ],
        ],
      ),
    );
  }

  // ==================== SUB ITEM (NAVIGATES TO SCREEN) ====================
  Widget _buildSubItem(
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
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 0.85.h),
        child: Row(
          children: [
            // Circular Radio / Bullet Icon exactly matching the user's screenshot
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 15,
              color: isSelected ? const Color(0xFFFFA043) : const Color(0xFF94A3B8),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 13.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFFFFA043) : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIRECT SUB ACTION (FOR INFORMATIONAL TILES) ====================
  Widget _buildDirectSubAction(
    String title,
    Color textPrimary,
  ) {
    final bool isSelected = widget.activeItem == title;

    return InkWell(
      onTap: () {
        widget.onItemSelected?.call(title);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title module selected.',
              style: TextStyle(fontSize: 13.5.sp, color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1E2746),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 0.85.h),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 15,
              color: isSelected ? const Color(0xFFFFA043) : const Color(0xFF94A3B8),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 13.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFFFFA043) : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DRAWER FOOTER & LOGOUT ====================
  Widget _buildDrawerFooter(
    BuildContext context,
    Color borderColor,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleLogout(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Logout Account',
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            'Fablead ERP • v1.0.0',
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 9.5.sp,
              color: textSecondary.withValues(alpha: 0.7),
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
              'Confirm Logout',
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
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }
}
