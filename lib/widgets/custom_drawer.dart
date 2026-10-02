import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../screens/products/view/product_screen.dart';
import '../screens/products/view/add_product_screen.dart';
import '../screens/products/view/raw_materials_screen.dart';
import '../screens/products/view/import_product_screen.dart';
import '../screens/manageinventory/view/manage_inventory_screen.dart';

class CustomDrawer extends StatefulWidget {
  final bool isDarkMode;
  final String activeItem;
  final Function(String) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.isDarkMode,
    required this.activeItem,
    required this.onItemSelected,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Track expanded tile sections
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
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? AppColors.tidcraftCardBg : Colors.white;
    final headerBg = widget.isDarkMode
        ? AppColors.tidcraftCardLight
        : const Color(0xFF1E293B);
    final borderColor =
        widget.isDarkMode ? AppColors.tidcraftBorder : const Color(0xFFE2E8F0);
    final textPrimary =
        widget.isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = widget.isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final inputBg = widget.isDarkMode
        ? const Color(0xFF16233B)
        : const Color(0xFFF1F5F9);

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // 1. Drawer Header (Side-by-side Avatar & User Details)
          _buildDrawerHeader(headerBg),

          // 2. Search Input Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 13.sp, // LARGER Font
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 13.sp, // LARGER Hint Font
                  color: textSecondary,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: textSecondary, size: 17.sp),
                filled: true,
                fillColor: inputBg,
                contentPadding: EdgeInsets.symmetric(vertical: 1.2.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 3. Scrollable Category List matching exact Web/Mobile screenshots
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w),
              physics: const BouncingScrollPhysics(),
              children: [
                // Single Item: Dashboard
                if (_shouldShow('Dashboard'))
                  _buildSingleMenuItem(
                    title: 'Dashboard',
                    icon: Icons.space_dashboard_outlined,
                    textPrimary: textPrimary,
                  ),

                // Group 1: ERP
                if (_shouldShowAny(['ERP', 'Products', 'All Products', 'New Product', 'All Raw Materials', 'Import Products', 'Catalog Setup', 'Sales & Bills', 'Products Delivery', 'Purchases', 'Vendors', 'Financers', 'Manage Inventory', 'Returns']))
                  _buildExpandableCategory(
                    title: 'ERP',
                    icon: Icons.business_center_outlined,
                    isExpanded: _isErpExpanded,
                    onToggle: () => setState(() => _isErpExpanded = !_isErpExpanded),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    children: [
                      _buildProductsAccordion(textPrimary, textSecondary),
                      _buildSubMenuItem('Catalog Setup', Icons.label_outlined, textPrimary),
                      _buildSubMenuItem('Sales & Bills', Icons.shopping_cart_outlined, textPrimary),
                      _buildSubMenuItem('Products Delivery', Icons.local_shipping_outlined, textPrimary),
                      _buildSubMenuItem('Purchases', Icons.receipt_long_outlined, textPrimary),
                      _buildSubMenuItem('Vendors', Icons.handshake_outlined, textPrimary),
                      _buildSubMenuItem('Financers', Icons.account_balance_outlined, textPrimary),
                      _buildSubMenuItem(
                        'Manage Inventory',
                        Icons.inventory_2_outlined,
                        textPrimary,
                        onTap: () {
                          widget.onItemSelected('Manage Inventory');
                          Navigator.pop(context);
                          Get.to(() => const ManageInventoryScreen());
                        },
                      ),
                      _buildSubMenuItem('Returns', Icons.replay_outlined, textPrimary),
                    ],
                  ),

                // Group 2: CRM
                if (_shouldShowAny(['CRM', 'Customers', 'Manage Leads', 'Follow Ups', 'Meetings', 'Tickets']))
                  _buildExpandableCategory(
                    title: 'CRM',
                    icon: Icons.groups_outlined,
                    isExpanded: _isCrmExpanded,
                    onToggle: () => setState(() => _isCrmExpanded = !_isCrmExpanded),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    children: [
                      _buildSubMenuItem('Customers', Icons.people_outline, textPrimary),
                      _buildSubMenuItem('Manage Leads', Icons.campaign_outlined, textPrimary),
                      _buildSubMenuItem('Follow Ups', Icons.calendar_today_outlined, textPrimary),
                      _buildSubMenuItem('Meetings', Icons.handshake_outlined, textPrimary),
                      _buildSubMenuItem('Tickets', Icons.confirmation_number_outlined, textPrimary),
                    ],
                  ),

                // Group 3: Reports
                if (_shouldShowAny(['Reports', 'Sales Report', 'Sales Pool Report', 'TDS Report', 'Purchase Report', 'Expenses Report', 'Profit & Loss Statement']))
                  _buildExpandableCategory(
                    title: 'Reports',
                    icon: Icons.query_stats_outlined,
                    isExpanded: _isReportsExpanded,
                    onToggle: () => setState(() => _isReportsExpanded = !_isReportsExpanded),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    children: [
                      _buildSubMenuItem('Sales Report', Icons.radio_button_unchecked, textPrimary),
                      _buildSubMenuItem('Sales Pool Report', Icons.radio_button_unchecked, textPrimary),
                      _buildSubMenuItem('TDS Report', Icons.radio_button_unchecked, textPrimary),
                      _buildSubMenuItem('Purchase Report', Icons.radio_button_unchecked, textPrimary),
                      _buildSubMenuItem('Expenses Report', Icons.radio_button_unchecked, textPrimary),
                      _buildSubMenuItem('Profit & Loss Statement', Icons.radio_button_unchecked, textPrimary),
                    ],
                  ),

                // Group 4: Accounting
                if (_shouldShowAny(['Accounting', 'Manage Accounting', 'Receipt & Payment', 'Expenses', 'Cash & Bank', 'Credit/Debit Notes', 'GST Reports']))
                  _buildExpandableCategory(
                    title: 'Accounting',
                    icon: Icons.calculate_outlined,
                    isExpanded: _isAccountingExpanded,
                    onToggle: () => setState(() => _isAccountingExpanded = !_isAccountingExpanded),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    children: [
                      _buildSubMenuItem('Manage Accounting', Icons.assessment_outlined, textPrimary),
                      _buildSubMenuItem('Receipt & Payment', Icons.receipt_outlined, textPrimary),
                      _buildSubMenuItem('Expenses', Icons.credit_card_outlined, textPrimary),
                      _buildSubMenuItem('Cash & Bank', Icons.account_balance_wallet_outlined, textPrimary),
                      _buildSubMenuItem('Credit/Debit Notes', Icons.subtitles_outlined, textPrimary),
                      _buildSubMenuItem('GST Reports', Icons.analytics_outlined, textPrimary),
                    ],
                  ),

                // Group 5: HR
                if (_shouldShowAny(['HR', 'Staff Attendance', 'Payroll Progress']))
                  _buildExpandableCategory(
                    title: 'HR',
                    icon: Icons.badge_outlined,
                    isExpanded: _isHrExpanded,
                    onToggle: () => setState(() => _isHrExpanded = !_isHrExpanded),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    children: [
                      _buildSubMenuItem('Staff Attendance', Icons.check_circle_outline, textPrimary),
                      _buildSubMenuItem('Payroll Progress', Icons.payments_outlined, textPrimary),
                    ],
                  ),

                // Group 6: Settings
                if (_shouldShowAny(['Settings', 'General Settings', 'Company Profile']))
                  _buildExpandableCategory(
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    isExpanded: _isSettingsExpanded,
                    onToggle: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    children: [
                      _buildSubMenuItem('General Settings', Icons.tune_outlined, textPrimary),
                      _buildSubMenuItem('Company Profile', Icons.business_outlined, textPrimary),
                    ],
                  ),
              ],
            ),
          ),

          // 4. Footer & Copyright Notice
          Divider(color: borderColor, height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 20),
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 14.5.sp, // LARGER Logout Font
                      fontWeight: FontWeight.w900,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // Go back to login
                  },
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '© 2026 Copyright - Fablead Developers Technolab',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 9.5.sp, // LARGER Footer Font
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Drawer Header Widget (Side-by-side Photo & User Info Row Layout with LARGER FONTS) ---
  Widget _buildDrawerHeader(Color headerBg) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2.h,
        bottom: 2.2.h,
        left: 4.5.w,
        right: 4.5.w,
      ),
      decoration: BoxDecoration(
        color: headerBg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular FE Profile Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.tidcraftOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'FE',
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Name & Email Side-by-side with Profile Avatar (LARGER FONTS)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fablead Admin',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 16.5.sp, // LARGER Name Font
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'admin@fableaderp.com',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 13.sp, // LARGER Email Font
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Single Menu Item (e.g. Dashboard) ---
  Widget _buildSingleMenuItem({
    required String title,
    required IconData icon,
    required Color textPrimary,
  }) {
    final isSelected = widget.activeItem == title;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.tidcraftOrange.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border(
                left: BorderSide(
                    color: AppColors.tidcraftOrange, width: 4.w.clamp(3.5, 4)))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.3.h),
          leading: Icon(
            icon,
            color: isSelected ? AppColors.tidcraftOrange : textPrimary.withValues(alpha: 0.85),
            size: 19.sp, // LARGER Icon
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 14.5.sp, // LARGER Menu Title Font
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
              color: isSelected ? AppColors.tidcraftOrange : textPrimary,
            ),
          ),
          onTap: () {
            widget.onItemSelected(title);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // --- Expandable Category Block (ERP, CRM, Reports, Accounting, HR, Settings) ---
  Widget _buildExpandableCategory({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Color textPrimary,
    required Color textSecondary,
    required List<Widget> children,
  }) {
    final isSelected = widget.activeItem == title;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 0.5.h),
          decoration: BoxDecoration(
            color: isExpanded
                ? textSecondary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border(
                    left: BorderSide(
                        color: AppColors.tidcraftOrange, width: 4))
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.3.h),
              leading: Icon(
                icon,
                color: isSelected ? AppColors.tidcraftOrange : textPrimary.withValues(alpha: 0.85),
                size: 19.sp, // LARGER Icon
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 14.5.sp, // LARGER Category Title Font
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                  color: isSelected ? AppColors.tidcraftOrange : textPrimary,
                ),
              ),
              trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.chevron_right_rounded,
                color: textSecondary,
                size: 20.sp, // LARGER Arrow
              ),
              onTap: onToggle,
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Column(children: children),
          ),
      ],
    );
  }

  // --- Products Accordion matching UI Design Screenshots ---
  Widget _buildProductsAccordion(
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSelected = widget.activeItem == 'Products' ||
        widget.activeItem == 'All Products' ||
        widget.activeItem == 'New Product' ||
        widget.activeItem == 'All Raw Materials' ||
        widget.activeItem == 'Import Products';

    if (!_isProductsExpanded && !isSelected) {
      // Collapsed View matching Image 1
      return _buildSubMenuItem(
        'Products',
        Icons.inventory_2_outlined,
        textPrimary,
        onTap: () {
          setState(() {
            _isProductsExpanded = true;
          });
        },
      );
    }

    // Expanded View matching Image 2
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppColors.tidcraftCardLight
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDarkMode
              ? AppColors.tidcraftBorder
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Navy Banner Header
          InkWell(
            onTap: () {
              setState(() {
                _isProductsExpanded = !_isProductsExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Dark Navy Banner
                borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Products',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    _isProductsExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Sub-item 1: All Products
          _buildProductChildItem(
            title: 'All Products',
            destination: const ProductScreen(),
            textPrimary: textPrimary,
          ),

          // Sub-item 2: New Product
          _buildProductChildItem(
            title: 'New Product',
            destination: const AddProductScreen(),
            textPrimary: textPrimary,
          ),

          // Sub-item 3: All Raw Materials
          _buildProductChildItem(
            title: 'All Raw Materials',
            destination: const RawMaterialsScreen(),
            textPrimary: textPrimary,
          ),

          // Sub-item 4: Import Products
          _buildProductChildItem(
            title: 'Import Products',
            destination: const ImportProductScreen(),
            textPrimary: textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildProductChildItem({
    required String title,
    required Widget destination,
    required Color textPrimary,
  }) {
    final isSelected = widget.activeItem == title;

    return InkWell(
      onTap: () {
        widget.onItemSelected(title);
        Navigator.pop(context);
        Get.to(() => destination);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isSelected
                  ? AppColors.tidcraftOrange
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.tidcraftOrange : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-menu Item ---
  Widget _buildSubMenuItem(
    String title,
    IconData icon,
    Color textPrimary, {
    VoidCallback? onTap,
  }) {
    final isSelected = widget.activeItem == title;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.3.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.tidcraftOrange.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 3.5.w),
          dense: true,
          leading: Icon(
            icon,
            color: isSelected ? AppColors.tidcraftOrange : textPrimary.withValues(alpha: 0.75),
            size: 15.sp, // LARGER Sub-menu Icon
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 13.sp, // LARGER Sub-menu Font
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? AppColors.tidcraftOrange : textPrimary,
            ),
          ),
          onTap: () {
            if (onTap != null) {
              onTap();
            } else {
              widget.onItemSelected(title);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  // Search Helpers
  bool _shouldShow(String title) {
    if (_searchQuery.isEmpty) return true;
    return title.toLowerCase().contains(_searchQuery);
  }

  bool _shouldShowAny(List<String> titles) {
    if (_searchQuery.isEmpty) return true;
    return titles.any((t) => t.toLowerCase().contains(_searchQuery));
  }
}
