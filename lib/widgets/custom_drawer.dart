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

/// Clean, modern, professional ERP Side Menu Drawer with smooth animated accordion expansions
/// matching the user's web ERP dashboard layout.
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
  bool _isSalesNestedExpanded = false;
  bool _isPurchasesNestedExpanded = false;
  bool _isVendorsNestedExpanded = false;
  bool _isManufactureNestedExpanded = false;
  bool _isFinancersNestedExpanded = false;
  bool _isReturnsNestedExpanded = false;

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
      'All Sales & Bills',
      'New Sale',
      'New Bill',
      'New POS Bill',
      'Products Delivery',
      'Delivery',
      'Purchases',
      'All Purchases',
      'New Purchase',
      'Vendors',
      'All Vendors',
      'New Vendor',
      'Import Vendor',
      'Manufacture Product',
      'All Materials',
      'Material Inventory',
      'Bill of Materials',
      'Production',
      'Financers',
      'All Financers',
      'Import Financers',
      'Manage Inventory',
      'Inventory',
      'Returns',
      'Rental Return',
      'Sales Return',
      'Purchase Return',
    ].contains(item)) {
      _isErpExpanded = true;

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
        'Sales & Bills',
        'Sale',
        'Sales',
        'All Sales',
        'All Sales & Bills',
        'New Sale',
        'New Bill',
        'New POS Bill',
      ].contains(item)) {
        _isSalesNestedExpanded = true;
      }

      if (const [
        'Purchases',
        'All Purchases',
        'New Purchase',
      ].contains(item)) {
        _isPurchasesNestedExpanded = true;
      }

      if (const [
        'Vendors',
        'All Vendors',
        'New Vendor',
        'Import Vendor',
      ].contains(item)) {
        _isVendorsNestedExpanded = true;
      }

      if (const [
        'Manufacture Product',
        'All Materials',
        'Material Inventory',
        'Bill of Materials',
        'Production',
      ].contains(item)) {
        _isManufactureNestedExpanded = true;
      }

      if (const [
        'Financers',
        'All Financers',
        'Import Financers',
      ].contains(item)) {
        _isFinancersNestedExpanded = true;
      }

      if (const [
        'Returns',
        'Rental Return',
        'Sales Return',
        'Purchase Return',
      ].contains(item)) {
        _isReturnsNestedExpanded = true;
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
    if (title == 'All Products' && (active == 'Products' || active == 'All Products')) return true;
    if (title == 'New Product' && active == 'New Product') return true;
    if (title == 'Import Products' && active == 'Import Products') return true;
    if (title == 'All Categories' && (active == 'All Categories' || active == 'Categories' || active == 'Catalog Setup')) return true;
    if (title == 'All Sales & Bills' && (active == 'Sale' || active == 'Sales' || active == 'All Sales' || active == 'All Sales & Bills')) return true;
    if (title == 'New Bill' && active == 'New Sale') return true;
    if (title == 'Products Delivery' && active == 'Delivery') return true;
    if (title == 'All Purchases' && active == 'Purchases') return true;
    if (title == 'All Vendors' && active == 'Vendors') return true;
    if (title == 'All Financers' && active == 'Financers') return true;
    if (title == 'All Materials' && (active == 'All Materials' || active == 'Raw Materials')) return true;
    if (title == 'Material Inventory' && active == 'Material Inventory') return true;
    if (title == 'Bill of Materials' && active == 'Bill of Materials') return true;
    if (title == 'Production' && active == 'Production') return true;
    if (title == 'Manage Inventory' && (active == 'Manage Inventory' || active == 'Inventory' || active == 'Inventory List' || active == 'Stock Overview' || active == 'View Inventory')) return true;
    if (title == 'Rental Return' && active == 'Rental Return') return true;
    if (title == 'Sales Return' && active == 'Sales Return') return true;
    if (title == 'Purchase Return' && active == 'Purchase Return') return true;
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

          // 2. Navigation Items List matching user screenshots
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
                    // Products (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      isExpanded: _isProductsNestedExpanded,
                      onToggle: () => setState(() => _isProductsNestedExpanded = !_isProductsNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Products',
                          destination: const ProductScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New Product',
                          destination: const AddProductScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Import Products',
                          destination: const ImportProductScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Catalog Setup (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Catalog Setup',
                      icon: Icons.local_offer_outlined,
                      isExpanded: _isCatalogNestedExpanded,
                      onToggle: () => setState(() => _isCatalogNestedExpanded = !_isCatalogNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Categories',
                          destination: const ProductCategoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New Category',
                          destination: const AddProductCategoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'All Brands',
                          destination: const AllBrandsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New Brand',
                          destination: const AddBrandsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'All Units',
                          destination: const AllUnitsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'All Labour Items',
                          destination: const AllLabourItemsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Sales & Bills (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Sales & Bills',
                      icon: Icons.shopping_cart_outlined,
                      isExpanded: _isSalesNestedExpanded,
                      onToggle: () => setState(() => _isSalesNestedExpanded = !_isSalesNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Sales & Bills',
                          destination: const AllSalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New Bill',
                          destination: const SalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New POS Bill',
                          destination: const SalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Products Delivery (Direct Nav Item)
                    _buildMenuSubItem(
                      title: 'Products Delivery',
                      icon: Icons.local_shipping_outlined,
                      destination: const ProductDeliveryScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Purchases (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Purchases',
                      icon: Icons.description_outlined,
                      isExpanded: _isPurchasesNestedExpanded,
                      onToggle: () => setState(() => _isPurchasesNestedExpanded = !_isPurchasesNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Purchases',
                          destination: const AllSalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New Purchase',
                          destination: const SalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Vendors (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Vendors',
                      icon: Icons.handshake_outlined,
                      isExpanded: _isVendorsNestedExpanded,
                      onToggle: () => setState(() => _isVendorsNestedExpanded = !_isVendorsNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Vendors',
                          destination: const FinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'New Vendor',
                          destination: const FinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Import Vendor',
                          destination: const ImportFinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Manufacture Product (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Manufacture Product',
                      icon: Icons.precision_manufacturing_outlined,
                      isExpanded: _isManufactureNestedExpanded,
                      onToggle: () => setState(() => _isManufactureNestedExpanded = !_isManufactureNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Materials',
                          destination: const RawMaterialsScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Material Inventory',
                          destination: const ViewInventoryScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Bill of Materials',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Production',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Financers (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Financers',
                      icon: Icons.account_balance_outlined,
                      isExpanded: _isFinancersNestedExpanded,
                      onToggle: () => setState(() => _isFinancersNestedExpanded = !_isFinancersNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'All Financers',
                          destination: const FinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Import Financers',
                          destination: const ImportFinancersScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Manage Inventory (Direct Nav Item - ONLY 1 screen)
                    _buildMenuSubItem(
                      title: 'Manage Inventory',
                      icon: Icons.warehouse_outlined,
                      destination: const ManageInventoryScreen(),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),

                    // Returns (Expandable with smooth animation)
                    _buildExpandableSubModule(
                      title: 'Returns',
                      icon: Icons.reply_outlined,
                      isExpanded: _isReturnsNestedExpanded,
                      onToggle: () => setState(() => _isReturnsNestedExpanded = !_isReturnsNestedExpanded),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      children: [
                        _buildRadioSubItem(
                          title: 'Rental Return',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Sales Return',
                          destination: const AllSalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        _buildRadioSubItem(
                          title: 'Purchase Return',
                          destination: const AllSalesScreen(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
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
                    _buildRadioSubItem(
                      title: 'Sales Report',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Sales Pool Report',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'TDS Report',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Purchase Report',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Expenses Report',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Profit & Loss Statement',
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
                    _buildRadioSubItem(
                      title: 'Plans',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'My Plan Details',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Change Password',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Shop Settings',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Smtp Settings',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'WhatsApp Configuration',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Tax Rates',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Departments',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Designations',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Leave Types',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Manage Holidays',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Holiday Calendar',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Table Truncate',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    _buildRadioSubItem(
                      title: 'Company Profile',
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

  // ==================== TOP LEVEL MENU CARD WITH SMOOTH ANIMATED EXPANSION ====================
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
                      // Trailing Chevron with smooth animated rotation
                      if (showChevron)
                        Padding(
                          padding: EdgeInsets.only(right: 3.w),
                          child: AnimatedRotation(
                            turns: isExpanded ? 0.25 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: chevronColor,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Smooth Animated Expansion for Children
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: isExpanded && children != null && children.isNotEmpty
                  ? Container(
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
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EXPANDABLE SUB-MODULE (DARK NAVY PILL WHEN EXPANDED, MATCHING SCREENSHOTS) ====================
  Widget _buildExpandableSubModule({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tile: smoothly animates to Dark Navy pill (#1E2746) when expanded matching screenshots
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isExpanded
                  ? const Color(0xFF1E2746) // Exact dark navy pill matching user screenshots
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.0.h),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isExpanded
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 14.5.sp,
                            fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
                            color: isExpanded ? Colors.white : textPrimary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 19,
                          color: isExpanded ? Colors.white70 : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Smooth Animated Expansion for nested radio-style sub-items
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: EdgeInsets.only(top: 0.4.h, bottom: 0.4.h, left: 1.5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ==================== RADIO SUB-ITEM (MATCHING SCREENSHOT 3 FILLED BULLET + ORANGE TEXT WHEN SELECTED) ====================
  Widget _buildRadioSubItem({
    required String title,
    Widget? destination,
    VoidCallback? onTap,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final bool isSelected = _isSubItemSelected(title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          } else if (destination != null) {
            widget.onItemSelected?.call(title);
            Navigator.pop(context);
            Get.to(() => destination);
          } else {
            _showModuleSelectedSnackbar(title);
          }
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.85.h),
          child: Row(
            children: [
              // Radio circle matching user screenshot (filled dark navy when active, outline when inactive)
              if (isSelected)
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E2746), // Filled dark navy bullet
                    shape: BoxShape.circle,
                  ),
                )
              else
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF94A3B8), // Slate outline
                      width: 1.5,
                    ),
                  ),
                ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFFFA043) // Vibrant orange text when selected matching Screenshot 3
                        : textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FLAT SUB-ITEM (FOR DIRECT NAVIGATION ITEMS) ====================
  Widget _buildMenuSubItem({
    required String title,
    required IconData icon,
    Widget? destination,
    VoidCallback? onTap,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final bool isSelected = _isSubItemSelected(title);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.25.h),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1E2746) // Dark Navy pill matching Screenshot 3 when selected
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap();
            } else if (destination != null) {
              widget.onItemSelected?.call(title);
              Navigator.pop(context);
              Get.to(() => destination);
            } else {
              _showModuleSelectedSnackbar(title);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.0.h),
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
                      fontSize: 14.5.sp,
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
