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

/// Clean, modern, professional ERP Side Menu Drawer matching the user's web ERP dashboard layout.
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
  // Top-level module expansion states
  bool _isErpExpanded = false;
  bool _isCrmExpanded = false;
  bool _isReportsExpanded = false;
  bool _isAccountingExpanded = false;
  bool _isHrExpanded = false;
  bool _isSettingsExpanded = false;

  // Nested expansion states inside ERP
  bool _isProductsNestedExpanded = false;
  bool _isCatalogNestedExpanded = false;
  bool _isInventoryNestedExpanded = false;
  bool _isFinancersNestedExpanded = false;

  @override
  void initState() {
    super.initState();
    _initExpansionState();
  }

  void _initExpansionState() {
    final item = widget.activeItem;

    // ERP Module Items
    if (const [
      'ERP',
      'Products',
      'All Products',
      'New Product',
      'All Raw Materials',
      'Import Products',
      'Catalog Setup',
      'All Categories',
      'New Category',
      'All Brands',
      'New Brand',
      'All Units',
      'All Labour Items',
      'Categories',
      'Sales & Bills',
      'Sale',
      'Sales',
      'All Sales',
      'New Sale',
      'Products Delivery',
      'Delivery',
      'Purchases',
      'Vendors',
      'Manufacture Product',
      'Financers',
      'All Financers',
      'Import Financers',
      'Manage Inventory',
      'Inventory',
      'Inventory List',
      'Stock Overview',
      'View Inventory',
      'Returns',
    ].contains(item)) {
      _isErpExpanded = true;

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
        _isCatalogNestedExpanded = true;
      }

      if (const [
        'Products',
        'All Products',
        'New Product',
        'All Raw Materials',
        'Import Products',
      ].contains(item)) {
        _isProductsNestedExpanded = true;
      }

      if (const [
        'Manage Inventory',
        'Inventory',
        'Inventory List',
        'Stock Overview',
        'View Inventory',
      ].contains(item)) {
        _isInventoryNestedExpanded = true;
      }

      if (const [
        'Financers',
        'All Financers',
        'Import Financers',
      ].contains(item)) {
        _isFinancersNestedExpanded = true;
      }
    }

    // CRM Module Items
    if (const [
      'CRM',
      'Customers',
      'Manage Leads',
      'Follow Ups',
      'Meetings',
      'Tickets',
    ].contains(item)) {
      _isCrmExpanded = true;
    }

    // Reports Module Items
    if (const [
      'Reports',
      'Sales Report',
      'Sales Pool Report',
      'TDS Report',
      'Purchase Report',
      'Expenses Report',
      'Profit & Loss',
      'Profit & Loss Statement',
    ].contains(item)) {
      _isReportsExpanded = true;
    }

    // Accounting Module Items
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

    // HR Module Items
    if (const [
      'HR',
      'Staff',
      'Attendance',
      'Staff Attendance',
      'Leaves',
      'Payroll',
      'Payroll Progress',
      'Advance Pay',
      'My Branch',
    ].contains(item)) {
      _isHrExpanded = true;
    }

    // Settings Module Items
    if (const [
      'Settings',
      'Plans',
      'My Plan Details',
      'Change Password',
      'Shop Settings',
      'Smtp Settings',
      'WhatsApp Configuration',
      'Tax Rates',
      'Departments',
      'Designations',
      'Leave Types',
      'Manage Holidays',
      'Holiday Calendar',
      'Table Truncate',
      'General Settings',
      'Company Profile',
      'Profile',
      'View Profile',
      'Edit Profile',
    ].contains(item)) {
      _isSettingsExpanded = true;
    }
  }

  bool _isSubItemSelected(String title) {
    final active = widget.activeItem;
    if (active == title) return true;
    if (title == 'Products' && (active == 'All Products' || active == 'New Product')) return true;
    if (title == 'Catalog Setup' && (active == 'All Categories' || active == 'Categories')) return true;
    if (title == 'Sales & Bills' && (active == 'Sale' || active == 'Sales' || active == 'All Sales')) return true;
    if (title == 'Products Delivery' && active == 'Delivery') return true;
    if (title == 'Manage Inventory' && (active == 'Inventory' || active == 'Inventory List')) return true;
    if (title == 'Manufacture Product' && active == 'Raw Materials') return true;
    if (title == 'Company Profile' && (active == 'Profile' || active == 'View Profile' || active == 'Edit Profile')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final Color drawerBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final bool isDashboardActive = widget.activeItem == 'Dashboard' || widget.activeItem.isEmpty;

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

          // 2. Navigation Items List matching the user's ERP layout
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
              children: [
                // 1. DASHBOARD
                _buildTopLevelCard(
                  title: 'Dashboard',
                  icon: Icons.speed_rounded,
                  accentColor: const Color(0xFFE11D48), // Red strip
                  cardBg: const Color(0xFF1E2746),
                  isExpanded: false,
                  isSelected: isDashboardActive,
                  showChevron: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () {
                    widget.onItemSelected?.call('Dashboard');
                    Navigator.pop(context);
                    if (Get.currentRoute != '/HomeScreen') {
                      Get.offAll(() => const HomeScreen());
                    }
                  },
                ),

                // 2. ERP MODULE (Products, Catalog Setup, Sales & Bills, Delivery, Purchases, Vendors, Manufacture, Financers, Inventory, Returns)
                _buildTopLevelCard(
                  title: 'ERP',
                  icon: Icons.factory_rounded,
                  accentColor: const Color(0xFF475569), // Slate strip
                  cardBg: const Color(0xFFF1F5F9), // Light slate
                  iconColor: const Color(0xFF475569),
                  isExpanded: _isErpExpanded,
                  isSelected: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _isErpExpanded = !_isErpExpanded),
                  children: [
                    // Products
                    _buildMenuSubItem(
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      destination: const ProductScreen(),
                      nestedChildren: [
                        _buildNestedSubItem(
                          title: 'All Products',
                          destination: const ProductScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'New Product',
                          destination: const AddProductScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'All Raw Materials',
                          destination: const RawMaterialsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'Import Products',
                          destination: const ImportProductScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                      isNestedExpanded: _isProductsNestedExpanded,
                      onNestedToggle: () => setState(() => _isProductsNestedExpanded = !_isProductsNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Catalog Setup
                    _buildMenuSubItem(
                      title: 'Catalog Setup',
                      icon: Icons.local_offer_outlined,
                      destination: const ProductCategoryScreen(),
                      nestedChildren: [
                        _buildNestedSubItem(
                          title: 'All Categories',
                          destination: const ProductCategoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'New Category',
                          destination: const AddProductCategoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'All Brands',
                          destination: const AllBrandsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'New Brand',
                          destination: const AddBrandsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'All Units',
                          destination: const AllUnitsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'All Labour Items',
                          destination: const AllLabourItemsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                      isNestedExpanded: _isCatalogNestedExpanded,
                      onNestedToggle: () => setState(() => _isCatalogNestedExpanded = !_isCatalogNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Sales & Bills
                    _buildMenuSubItem(
                      title: 'Sales & Bills',
                      icon: Icons.shopping_cart_outlined,
                      destination: const AllSalesScreen(),
                      nestedChildren: [
                        _buildNestedSubItem(
                          title: 'All Sales',
                          destination: const AllSalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'New Sale',
                          destination: const SalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                      isNestedExpanded: false,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Products Delivery
                    _buildMenuSubItem(
                      title: 'Products Delivery',
                      icon: Icons.local_shipping_outlined,
                      destination: const ProductDeliveryScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Purchases
                    _buildMenuSubItem(
                      title: 'Purchases',
                      icon: Icons.description_outlined,
                      destination: const AllSalesScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Vendors
                    _buildMenuSubItem(
                      title: 'Vendors',
                      icon: Icons.handshake_outlined,
                      destination: const FinancersScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Manufacture Product
                    _buildMenuSubItem(
                      title: 'Manufacture Product',
                      icon: Icons.precision_manufacturing_outlined,
                      destination: const RawMaterialsScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Financers
                    _buildMenuSubItem(
                      title: 'Financers',
                      icon: Icons.account_balance_outlined,
                      destination: const FinancersScreen(),
                      nestedChildren: [
                        _buildNestedSubItem(
                          title: 'All Financers',
                          destination: const FinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'Import Financers',
                          destination: const ImportFinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                      isNestedExpanded: _isFinancersNestedExpanded,
                      onNestedToggle: () => setState(() => _isFinancersNestedExpanded = !_isFinancersNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Manage Inventory
                    _buildMenuSubItem(
                      title: 'Manage Inventory',
                      icon: Icons.warehouse_outlined,
                      destination: const ManageInventoryScreen(),
                      nestedChildren: [
                        _buildNestedSubItem(
                          title: 'Inventory List',
                          destination: const ManageInventoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildNestedSubItem(
                          title: 'Stock Overview',
                          destination: const ViewInventoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                      isNestedExpanded: _isInventoryNestedExpanded,
                      onNestedToggle: () => setState(() => _isInventoryNestedExpanded = !_isInventoryNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Returns
                    _buildMenuSubItem(
                      title: 'Returns',
                      icon: Icons.reply_outlined,
                      destination: const AllSalesScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),

                // 3. CRM MODULE (Customers, Manage Leads, Follow Ups, Meetings, Tickets)
                _buildTopLevelCard(
                  title: 'CRM',
                  icon: Icons.groups_rounded,
                  accentColor: const Color(0xFF6366F1), // Indigo strip
                  cardBg: const Color(0xFFEEF2FF), // Light indigo
                  iconColor: const Color(0xFF6366F1),
                  isExpanded: _isCrmExpanded,
                  isSelected: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _isCrmExpanded = !_isCrmExpanded),
                  children: [
                    _buildMenuSubItem(
                      title: 'Customers',
                      icon: Icons.people_alt_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Manage Leads',
                      icon: Icons.campaign_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Follow Ups',
                      icon: Icons.event_available_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Meetings',
                      icon: Icons.handshake_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Tickets',
                      icon: Icons.confirmation_number_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),

                // 4. REPORTS MODULE (Sales, Sales Pool, TDS, Purchase, Expenses, Profit & Loss)
                _buildTopLevelCard(
                  title: 'Reports',
                  icon: Icons.schedule_rounded,
                  accentColor: const Color(0xFFD946EF), // Magenta strip
                  cardBg: const Color(0xFFFDF2F8), // Light pink
                  iconColor: const Color(0xFF475569),
                  isExpanded: _isReportsExpanded,
                  isSelected: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _isReportsExpanded = !_isReportsExpanded),
                  children: [
                    _buildMenuSubItem(
                      title: 'Sales Report',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Sales Pool Report',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'TDS Report',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Purchase Report',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Expenses Report',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Profit & Loss Statement',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),

                // 5. ACCOUNTING MODULE (Manage Accounting, Receipt & Payment, Expenses, Cash & Bank, Credit/Debit, GST Reports)
                _buildTopLevelCard(
                  title: 'Accounting',
                  icon: Icons.calculate_rounded,
                  accentColor: const Color(0xFF16A34A), // Green strip
                  cardBg: const Color(0xFFF0FDF4), // Light green
                  iconColor: const Color(0xFF16A34A),
                  isExpanded: _isAccountingExpanded,
                  isSelected: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _isAccountingExpanded = !_isAccountingExpanded),
                  children: [
                    _buildMenuSubItem(
                      title: 'Manage Accounting',
                      icon: Icons.calculate_outlined,
                      destination: const AccountLedgerScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Receipt & Payment',
                      icon: Icons.receipt_long_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Expenses',
                      icon: Icons.account_balance_wallet_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Cash & Bank',
                      icon: Icons.menu_book_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Credit/Debit Notes',
                      icon: Icons.credit_card_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'GST Reports',
                      icon: Icons.insights_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),

                // 6. HR MODULE (Staff, Attendance, Leaves, Payroll, Advance Pay, My Branch)
                _buildTopLevelCard(
                  title: 'HR',
                  icon: Icons.badge_rounded,
                  accentColor: const Color(0xFFEA580C), // Orange strip
                  cardBg: const Color(0xFFFFF7ED), // Light orange
                  iconColor: const Color(0xFF64748B),
                  isExpanded: _isHrExpanded,
                  isSelected: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _isHrExpanded = !_isHrExpanded),
                  children: [
                    _buildMenuSubItem(
                      title: 'Staff',
                      icon: Icons.person_outline_rounded,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Attendance',
                      icon: Icons.access_time_rounded,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Leaves',
                      icon: Icons.calendar_month_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Payroll',
                      icon: Icons.request_quote_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Advance Pay',
                      icon: Icons.payments_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'My Branch',
                      icon: Icons.account_tree_outlined,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),

                // 7. SETTINGS MODULE (Plans, My Plan Details, Change Password, Shop Settings, Smtp, WhatsApp, Tax Rates, Departments, Designations, Leave Types, Manage Holidays, Holiday Calendar, Table Truncate, Company Profile)
                _buildTopLevelCard(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  accentColor: const Color(0xFF2563EB), // Blue strip
                  cardBg: const Color(0xFFEFF6FF), // Light blue
                  iconColor: const Color(0xFF2563EB),
                  isExpanded: _isSettingsExpanded,
                  isSelected: false,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
                  children: [
                    _buildMenuSubItem(
                      title: 'Plans',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'My Plan Details',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Change Password',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Shop Settings',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Smtp Settings',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'WhatsApp Configuration',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Tax Rates',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Departments',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Designations',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Leave Types',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Manage Holidays',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Holiday Calendar',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Table Truncate',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildMenuSubItem(
                      title: 'Company Profile',
                      icon: Icons.radio_button_unchecked_rounded,
                      isRadioStyle: true,
                      destination: const ProfileScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),

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
              Expanded(
                child: Row(
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
                    Flexible(
                      child: Text(
                        'FABLEAD ERP',
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: const Color(0xFF1E2746),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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

          // User Info Tile
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ProfileScreen());
              },
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E2746), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 1.5.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.8.w,
                                vertical: 0.2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFFDBA74),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 12.sp,
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
                            fontSize: 13.5.sp,
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

  // ==================== TOP LEVEL MENU CARD (EXACT USER SCREENSHOT DESIGN) ====================
  Widget _buildTopLevelCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color cardBg,
    Color? iconColor,
    required bool isExpanded,
    required bool isSelected,
    required VoidCallback onTap,
    bool showChevron = true,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    List<Widget>? children,
  }) {
    final bool activeDark = isSelected;
    final Color actualBg = activeDark
        ? const Color(0xFF1E2746)
        : (isDark ? const Color(0xFF1E293B) : cardBg);
    final Color titleColor = activeDark ? Colors.white : textPrimary;
    final Color actualIconColor = activeDark
        ? Colors.white
        : (iconColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)));
    final Color chevronColor = activeDark
        ? Colors.white70
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E2746));

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.35.h),
      decoration: BoxDecoration(
        color: actualBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Colored left accent bar matching user screenshot
                      Container(
                        width: 4.5,
                        color: accentColor,
                      ),
                      SizedBox(width: 3.w),
                      // Leading Category Icon
                      Icon(
                        icon,
                        color: actualIconColor,
                        size: 21,
                      ),
                      SizedBox(width: 3.5.w),
                      // Title
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.15.h),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: AppStyles.fontFamily,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      // Trailing Chevron
                      if (showChevron)
                        Padding(
                          padding: EdgeInsets.only(right: 3.w),
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.chevron_right_rounded,
                            color: chevronColor,
                            size: 22,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Expanded content if open
            if (isExpanded && children != null && children.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 0.4.h, bottom: 0.8.h, left: 1.w, right: 1.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.7),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: children,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== SUB ITEM (MATCHING USER SCREENSHOT DESIGN) ====================
  Widget _buildMenuSubItem({
    required String title,
    required IconData icon,
    Widget? destination,
    VoidCallback? onTap,
    List<Widget>? nestedChildren,
    bool isNestedExpanded = false,
    VoidCallback? onNestedToggle,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    bool isRadioStyle = false,
  }) {
    final bool isSelected = _isSubItemSelected(title);
    final Color itemColor = isSelected
        ? const Color(0xFFFFA043)
        : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155));
    final Color iconColor = isSelected
        ? const Color(0xFFFFA043)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap();
              } else if (destination != null) {
                widget.onItemSelected?.call(title);
                Navigator.pop(context);
                Get.to(() => destination);
              } else if (nestedChildren != null && onNestedToggle != null) {
                onNestedToggle();
              } else {
                _showModuleSelectedSnackbar(title);
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.85.h),
              child: Row(
                children: [
                  if (isRadioStyle)
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: isSelected ? const Color(0xFFFFA043) : const Color(0xFF64748B),
                    )
                  else
                    Icon(
                      icon,
                      size: 19,
                      color: iconColor,
                    ),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: itemColor,
                      ),
                    ),
                  ),
                  if (nestedChildren != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isNestedExpanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.chevron_right_rounded,
                        size: 18,
                        color: textSecondary,
                      ),
                      onPressed: onNestedToggle,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isNestedExpanded && nestedChildren != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Column(children: nestedChildren),
          ),
        ],
      ],
    );
  }

  // ==================== NESTED SUB ITEM (FOR ACCESSIBLE CHILD SCREENS) ====================
  Widget _buildNestedSubItem({
    required String title,
    required Widget destination,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final bool isSelected = widget.activeItem == title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onItemSelected?.call(title);
          Navigator.pop(context);
          Get.to(() => destination);
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.65.h),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 14,
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
      ),
    );
  }

  void _showModuleSelectedSnackbar(String title) {
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
        title: Text(
          'Logout Confirmation',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF475569),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
      Get.offAll(() => const LoginScreen());
    }
  }
}
