import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/custom_drawer.dart';
import 'products/view/product_screen.dart';
import 'profile_screen.dart';
import 'sales&bills/view/all_sales_screen.dart';
import 'sales&bills/view/sales_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false; // Default to White Theme (Light Mode)
  int _selectedBottomNavIndex = 0;
  String _selectedDatePeriod = 'Thu, 26 Sep 2026';
  String _selectedSalesPeriod = 'This Month';
  String _selectedTrendPeriod = 'This Year';
  String _activeDrawerItem = 'Dashboard';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardService _dashboardService = DashboardService();

  bool _isLoadingDashboard = false;
  DashboardDataModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
    });

    try {
      final response = await _dashboardService.getDashboardData();
      if (response.status && response.data != null && mounted) {
        setState(() {
          _dashboardData = response.data;
          _isLoadingDashboard = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDashboard = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    final symbol = _dashboardData?.currencySymbol ?? '₹';
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    final formattedInt = integerPart.replaceAllMapped(
        reg, (Match m) => '${m[1]},');

    return '$symbol $formattedInt.$decimalPart';
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Today';
    try {
      final dt = DateTime.parse(dateStr.replaceAll(' ', 'T'));
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today';
      }
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
    }
  }

  void _updateDatePeriod(String value) {
    setState(() {
      _selectedDatePeriod = value;
    });
  }

  void _updateSalesPeriod(String value) {
    setState(() {
      _selectedSalesPeriod = value;
    });
  }

  void _updateTrendPeriod(String value) {
    setState(() {
      _selectedTrendPeriod = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Color Palette based on _isDarkMode toggle
    final bgColor = _isDarkMode ? AppColors.tidcraftBg : const Color(0xFFF1F5F9);
    final cardBg = _isDarkMode ? AppColors.tidcraftCardBg : Colors.white;
    final cardBgLight = _isDarkMode ? AppColors.tidcraftCardLight : const Color(0xFFF8FAFC);
    final borderColor = _isDarkMode ? AppColors.tidcraftBorder : const Color(0xFFE2E8F0);
    final textPrimary = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        title: _activeDrawerItem,
        isDarkMode: _isDarkMode,
        onThemeToggle: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
      drawer: CustomDrawer(
        isDarkMode: _isDarkMode,
        activeItem: _activeDrawerItem,
        onItemSelected: (item) {
          setState(() {
            _activeDrawerItem = item;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$item selected', style: const TextStyle(fontFamily: AppStyles.fontFamily)),
              backgroundColor: AppColors.tidcraftOrange,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboard,
          color: AppColors.tidcraftOrange,
          backgroundColor: cardBg,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingDashboard)
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.tidcraftOrange),
                      ),
                    ),
                  ),

                // 1. Greeting & Date Selector Row
                _buildGreetingAndDateRow(
                    textPrimary, textSecondary, cardBg, borderColor),
                SizedBox(height: 2.h),
                // 3. Top 2x2 Metric Grid Cards
                _buildTop2x2MetricGrid(
                    cardBg, borderColor, textPrimary, textSecondary),
                SizedBox(height: 2.h),

                // 4. Sales Target Progress Card
                _buildSalesTargetCard(
                    cardBg, cardBgLight, borderColor, textPrimary,
                    textSecondary),
                SizedBox(height: 2.h),

                // 5. Recent Products Card
                _buildTop5ProductsCard(
                    cardBg, cardBgLight, borderColor, textPrimary,
                    textSecondary),
                SizedBox(height: 2.h),

                // 6. Sales Trend Line Chart Card
                _buildSalesTrendChartCard(
                    cardBg, cardBgLight, borderColor, textPrimary,
                    textSecondary),
                SizedBox(height: 2.h),

                // 7. Recent Sales Cards
                _buildRecentTransactionsSection(
                    cardBg, cardBgLight, borderColor, textPrimary,
                    textSecondary),
                SizedBox(height: 2.5.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedBottomNavIndex,
        isDarkMode: _isDarkMode,
        onItemTapped: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
          _handleBottomNavTap(index);
        },
      ),
    );
  }


  // --- 2. Greeting & Date Pill Row (LARGER READABLE FONTS) ---
  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon,';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  Widget _buildGreetingAndDateRow(
      Color textPrimary,
      Color textSecondary,
      Color cardBg,
      Color borderColor,
      ) {
    final greeting = _getDynamicGreeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 18.5.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              'Welcome back!',
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 14.sp,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Date Dropdown Pill

      ],
    );
  }


  // --- 3. Top 2x2 Metric Grid Cards (NO PURCHASE / NO VENDOR, LARGER FONTS) ---
  Widget _buildTop2x2MetricGrid(
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final totals = _dashboardData?.totals;
    final counts = _dashboardData?.counts;

    final salesVal = totals != null
        ? _formatCurrency(totals.sales)
        : '₹ 49,00,258.99';
    final salesSubtitle = counts != null
        ? '↑ ${counts.salesInvoices} Invoices'
        : '↑ 190 Invoices';

    final invoiceVal = counts != null
        ? '${counts.salesInvoices} Invoices'
        : '190 Invoices';
    const invoiceSubtitle = 'Total Invoices Placed';

    final expenseVal = totals != null
        ? _formatCurrency(totals.expense)
        : '₹ 32,000.00';
    const expenseSubtitle = 'Total Expenses';

    final customersVal = counts != null
        ? '${counts.customers} Clients'
        : '42 Clients';
    const customersSubtitle = 'Active Customers';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 1.5.h,
      childAspectRatio: 1.25,
      // Clean proportion for larger bold fonts
      children: [
        // 1. Total Sales Card
        _buildMetricGridCard(
          title: 'Total Sales',
          value: salesVal,
          growthText: salesSubtitle,
          icon: Icons.receipt_long_rounded,
          iconBgColor: AppColors.orangeAccent,
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: () => Get.to(() => const AllSalesScreen()),
        ),

        // 2. Sales Invoices Card (Replaces Purchase)
        _buildMetricGridCard(
          title: 'Sales Invoices',
          value: invoiceVal,
          growthText: invoiceSubtitle,
          icon: Icons.point_of_sale_rounded,
          iconBgColor: const Color(0xFF10B981),
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: () => Get.to(() => const AllSalesScreen()),
        ),

        // 3. Total Expense Card
        _buildMetricGridCard(
          title: 'Total Expense',
          value: expenseVal,
          growthText: expenseSubtitle,
          icon: Icons.account_balance_wallet_rounded,
          iconBgColor: const Color(0xFFEF4444),
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: null,
        ),

        // 4. Customers Card (Vendor completely removed)
        _buildMetricGridCard(
          title: 'Customers',
          value: customersVal,
          growthText: customersSubtitle,
          icon: Icons.groups_rounded,
          iconBgColor: const Color(0xFF3B82F6),
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: () => Get.to(() => const ProfileScreen()),
        ),
      ],
    );
  }

  Widget _buildMetricGridCard({
    required String title,
    required String value,
    required String growthText,
    required IconData icon,
    required Color iconBgColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(3.2.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDarkMode ? 0.15 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Box & Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16.sp),
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 12.5.sp, // INCREASED FONT SIZE
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(width: 0.5.w),
                    Icon(Icons.chevron_right_rounded,
                        color: textSecondary, size: 14.sp),
                  ],
                ),
              ],
            ),

            // Big Bold Value Text
            Text(
              value,
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 16.5.sp,
                // INCREASED BOLD VALUE
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Growth Badge Indicator
            Text(
              growthText,
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 11.sp, // INCREASED FONT SIZE
                fontWeight: FontWeight.w600,
                color: AppColors.tidcraftGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Sales Target Progress Card (PURCHASE REMOVED, LARGER FONTS) ---
  Widget _buildSalesTargetCard(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final totals = _dashboardData?.totals;
    final salesAmt = totals?.sales ?? 4900258.99;

    // Dynamic sales target (25% higher than current or baseline)
    final double salesTarget = salesAmt > 0 ? (salesAmt * 1.25) : 5000000.0;
    final double salesProgress = salesTarget > 0 ? (salesAmt / salesTarget)
        .clamp(0.0, 1.0) : 0.7;
    final int salesPercent = (salesProgress * 100).round();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded,
                      color: AppColors.tidcraftOrange, size: 18.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Sales Target',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 15.5.sp, // INCREASED HEADER FONT
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),

              // Filter Dropdown Pill
              PopupMenuButton<String>(
                color: cardBgLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onSelected: _updateSalesPeriod,
                itemBuilder: (context) =>
                    ['This Month', 'Last Month', 'This Year']
                        .map((p) => PopupMenuItem(
                            value: p,
                            child: Text(p,
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 12.5.sp, // INCREASED
                                    fontWeight: FontWeight.w500))))
                        .toList(),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: cardBgLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedSalesPeriod,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 13.5.sp, // INCREASED FONT
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: textSecondary, size: 15.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Sales Target Meter Box (Purchases removed)
          Container(
            padding: EdgeInsets.all(3.5.w),
            decoration: BoxDecoration(
              color: cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            color: AppColors.tidcraftOrange, size: 16.sp),
                        SizedBox(width: 2.w),
                        Text(
                          'Sales Achieved',
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 14.5.sp, // INCREASED FONT
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatCurrency(salesAmt),
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 16.5.sp, // INCREASED BOLD AMOUNT
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),

                // Sleek Progress Bar + Percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: salesProgress,
                          minHeight: 10, // Enhanced progress bar height
                          backgroundColor: _isDarkMode
                              ? Colors.black26
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.tidcraftOrange),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '$salesPercent%',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 13.5.sp, // INCREASED PERCENTAGE
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Target: ${_formatCurrency(salesTarget)}',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 13.sp, // INCREASED TARGET TEXT
                    fontWeight: FontWeight.w600,
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

  // --- 5. Recent Products Card (LARGER READABLE FONTS) ---
  Widget _buildTop5ProductsCard(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final recentProducts = _dashboardData?.recentProducts ?? [];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          InkWell(
            onTap: () => Get.to(() => const ProductScreen()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_rounded,
                        color: AppColors.tidcraftOrange, size: 18.sp),
                    SizedBox(width: 2.w),
                    Text(
                      'Recent Products',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 15.5.sp, // INCREASED HEADER FONT
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 14.sp, // INCREASED VIEW ALL
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: textSecondary, size: 17.sp),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 1.8.h),

          // Product Items List
          if (recentProducts.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Center(
                child: Text(
                  _isLoadingDashboard
                      ? 'Loading products...'
                      : 'No products found',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentProducts.length > 5 ? 5 : recentProducts.length,
              separatorBuilder: (context, index) =>
                  Divider(color: borderColor, height: 1.8.h),
              itemBuilder: (context, index) {
                final product = recentProducts[index];
                final hasImage = product.imageUrl.isNotEmpty;

                return InkWell(
                  onTap: () => Get.to(() => const ProductScreen()),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: cardBgLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasImage
                              ? Image.network(
                            product.imageUrl.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.inventory_2_rounded,
                                    color: AppColors.tidcraftOrange,
                                    size: 16.sp),
                          )
                              : Icon(Icons.inventory_2_rounded,
                              color: AppColors.tidcraftOrange, size: 16.sp),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 14.5.sp, // INCREASED PRODUCT NAME
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                'Qty: ${product.quantity.toStringAsFixed(
                                    0)} pcs${product.barcode != null &&
                                    product.barcode!.isNotEmpty ? " • ${product
                                    .barcode}" : ""}',
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 12.5.sp, // INCREASED SUBTITLE
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(product.price),
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 14.5.sp, // INCREASED AMOUNT
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- 6. Sales Trend Line Chart Card (PURCHASE REMOVED, LARGER FONTS) ---
  Widget _buildSalesTrendChartCard(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    // Determine sales chart data according to period
    List<double> salesList = [];
    List<String> xLabels = [];

    final charts = _dashboardData?.charts;
    if (_selectedTrendPeriod == 'This Month' && charts != null &&
        charts.salesThisMonth.isNotEmpty) {
      salesList = charts.salesThisMonth;
      xLabels = List.generate(salesList.length, (i) => '${i + 1}');
    } else {
      // Annual 12 months (or default)
      if (charts != null && charts.salesThisYear.isNotEmpty) {
        salesList = charts.salesThisYear;
      } else if (charts != null && charts.sales.isNotEmpty) {
        salesList = charts.sales;
      } else {
        salesList = [
          0,
          0,
          0,
          5504.2,
          0,
          6999,
          1276061.49,
          3271386.23,
          317403.9,
          22965.74,
          0,
          0
        ];
      }
      xLabels = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart_rounded,
                      color: AppColors.tidcraftOrange, size: 18.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Sales Trend',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 15.5.sp, // INCREASED HEADER FONT
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),

              // Period Selector Dropdown Pill
              PopupMenuButton<String>(
                color: cardBgLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onSelected: _updateTrendPeriod,
                itemBuilder: (context) =>
                    ['This Year', 'This Month']
                        .map((p) => PopupMenuItem(
                            value: p,
                            child: Text(p,
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 14.5.sp, // INCREASED
                                    fontWeight: FontWeight.w500))))
                        .toList(),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: cardBgLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedTrendPeriod,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 13.5.sp, // INCREASED FONT
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: textSecondary, size: 15.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Custom Line Chart Widget
          SizedBox(
            height: 19.h,
            width: double.infinity,
            child: CustomPaint(
              painter: SalesTrendPainter(
                salesData: salesList,
                xLabels: xLabels,
                currencySymbol: _dashboardData?.currencySymbol ?? '₹',
                isDarkMode: _isDarkMode,
                textSecondary: textSecondary,
                borderColor: borderColor,
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Chart Legend Row (Pure Sales Revenue Legend)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.tidcraftOrange,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Total Sales Revenue',
                style: TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 13.sp, // INCREASED FONT
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 7. Recent Sales Section (PURCHASE REMOVED, LARGER FONTS) ---
  Widget _buildRecentTransactionsSection(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final latestSales = _dashboardData?.latestSales ?? [];

    return _buildRecentSalesBlock(
      sales: latestSales,
      cardBg: cardBg,
      cardBgLight: cardBgLight,
      borderColor: borderColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );
  }

  Widget _buildRecentSalesBlock({
    required List<DashboardSaleItemModel> sales,
    required Color cardBg,
    required Color cardBgLight,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          InkWell(
            onTap: () => Get.to(() => const AllSalesScreen()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note_rounded,
                        color: AppColors.tidcraftOrange, size: 18.sp),
                    SizedBox(width: 2.w),
                    Text(
                      'Recent Sales',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 15.5.sp, // INCREASED HEADER FONT
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 14.sp, // INCREASED VIEW ALL
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: textSecondary, size: 16.sp),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 1.8.h),

          if (sales.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Center(
                child: Text(
                  _isLoadingDashboard ? 'Loading sales...' : 'No recent sales',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 12.sp,
                    color: textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length > 5 ? 5 : sales.length,
              separatorBuilder: (context, index) =>
                  Divider(color: borderColor, height: 1.8.h),
              itemBuilder: (context, index) {
                final item = sales[index];
                final initials = item.productName.isNotEmpty
                    ? item.productName.substring(
                    0, item.productName.length >= 2 ? 2 : 1).toUpperCase()
                    : 'SL';

                return InkWell(
                  onTap: () {
                    final targetId = item.orderId ?? item.id;
                    Get.to(() => SalesDetailScreen(orderId: targetId));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.6.h),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18, // Slightly larger avatar
                          backgroundColor: _isDarkMode
                              ? cardBgLight
                              : const Color(0xFFE2E8F0),
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontFamily: AppStyles.fontFamily,
                              fontSize: 11.5.sp, // INCREASED INITIALS
                              fontWeight: FontWeight.bold,
                              color: AppColors.tidcraftOrange,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName.isNotEmpty
                                    ? item.productName
                                    : 'Sale #${item.orderNumber}',
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 14.5.sp, // INCREASED NAME FONT
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                item.orderNumber.isNotEmpty
                                    ? item.orderNumber
                                    : '#${item.id}',
                                style: TextStyle(
                                  fontFamily: AppStyles.fontFamily,
                                  fontSize: 12.sp, // INCREASED ID FONT
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(item.totalAmount),
                              style: TextStyle(
                                fontFamily: AppStyles.fontFamily,
                                fontSize: 14.5.sp, // INCREASED AMOUNT FONT
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.4.h),
                            Row(
                              children: [
                                Text(
                                  _formatDate(item.orderDate),
                                  style: TextStyle(
                                    fontFamily: AppStyles.fontFamily,
                                    fontSize: 12.5.sp, // INCREASED TIME FONT
                                    color: textSecondary,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.tidcraftGreen.withValues(
                                        alpha: 0.15),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.tidcraftGreen
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    (item.paymentMethod != null &&
                                        item.paymentMethod!.isNotEmpty)
                                        ? item.paymentMethod!.toUpperCase()
                                        : 'PAID',
                                    style: TextStyle(
                                      fontFamily: AppStyles.fontFamily,
                                      fontSize: 10.sp, // INCREASED STATUS FONT
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.tidcraftGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on Dashboard
        break;
      case 1:
        // Products
        Get.to(() => const ProductScreen());
        break;
      case 2:
        // Sale
        Get.to(() => const AllSalesScreen());
        break;
      case 3:
        // Profile
        Get.to(() => const ProfileScreen());
        break;
    }
  }


}

// --- Custom Painter for Sales Trend Line Chart (Sales Focused, Larger Fonts) ---
class SalesTrendPainter extends CustomPainter {
  final List<double> salesData;
  final List<String> xLabels;
  final String currencySymbol;
  final bool isDarkMode;
  final Color textSecondary;
  final Color borderColor;

  SalesTrendPainter({
    required this.salesData,
    required this.xLabels,
    this.currencySymbol = '₹',
    required this.isDarkMode,
    required this.textSecondary,
    required this.borderColor,
  });

  String _formatCompact(double amount) {
    if (amount >= 10000000) {
      return '$currencySymbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$currencySymbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$currencySymbol${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '$currencySymbol${amount.toStringAsFixed(0)}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Paints
    final gridPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final salesPaint = Paint()
      ..color = AppColors.tidcraftOrange
      ..strokeWidth = 3.0 // Crisp prominent line
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate maximum value
    double maxVal = 0;
    for (final v in salesData) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 0) maxVal = 10000;

    // Y Axis Labels & Grid Lines (LARGER FONTS)
    final yLabels = [
      _formatCompact(maxVal),
      _formatCompact(maxVal * 0.66),
      _formatCompact(maxVal * 0.33),
      '0',
    ];
    final double yStep = (height - 28) / (yLabels.length - 1);

    for (int i = 0; i < yLabels.length; i++) {
      double y = i * yStep + 8;
      canvas.drawLine(Offset(48, y), Offset(width, y), gridPaint);

      final textSpan = TextSpan(
        text: yLabels[i],
        style: TextStyle(
          color: textSecondary,
          fontSize: 10.5, // INCREASED FONT
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    if (xLabels.isEmpty) return;

    // X Axis Labels (LARGER FONTS)
    final double xStart = 55;
    final int count = xLabels.length;
    final double xStep = count > 1 ? (width - xStart - 10) / (count - 1) : 0;

    // Decide step interval if too many labels (like 31 days)
    int labelInterval = 1;
    if (count > 15) {
      labelInterval = (count / 6).ceil();
    }

    for (int i = 0; i < count; i++) {
      if (i % labelInterval == 0 || i == count - 1) {
        double x = xStart + i * xStep;
        final textSpan = TextSpan(
          text: xLabels[i],
          style: TextStyle(
            color: textSecondary,
            fontSize: 10.5, // INCREASED FONT
            fontWeight: FontWeight.w600,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )
          ..layout();
        textPainter.paint(
            canvas, Offset(x - (textPainter.width / 2), height - 14));
      }
    }

    // Chart points
    final chartHeight = height - 42;
    List<Offset> salesPoints = [];

    for (int i = 0; i < count; i++) {
      double x = xStart + i * xStep;
      double sVal = i < salesData.length ? salesData[i] : 0.0;
      double ySales = (height - 28) -
          ((sVal / maxVal).clamp(0.0, 1.0) * chartHeight);
      salesPoints.add(Offset(x, ySales));
    }

    // Draw Smooth Curves
    final Path salesPath = Path();
    _drawCurvedLine(canvas, salesPoints, salesPath, salesPaint);

    // Draw Dots on Points
    final dotStep = count > 15 ? labelInterval : 1;
    for (int i = 0; i < salesPoints.length; i += dotStep) {
      final point = salesPoints[i];
      canvas.drawCircle(point, 3.5, Paint()..color = AppColors.tidcraftOrange);
      canvas.drawCircle(point, 1.5, Paint()..color = Colors.white);
    }
  }

  void _drawCurvedLine(
      Canvas canvas, List<Offset> points, Path path, Paint paint) {
    if (points.isEmpty) return;
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      double x1 = points[i].dx;
      double y1 = points[i].dy;
      double x2 = points[i + 1].dx;
      double y2 = points[i + 1].dy;

      double controlX1 = x1 + (x2 - x1) / 2;
      double controlY1 = y1;
      double controlX2 = x1 + (x2 - x1) / 2;
      double controlY2 = y2;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SalesTrendPainter oldDelegate) =>
      oldDelegate.salesData != salesData ||
          oldDelegate.isDarkMode != isDarkMode ||
          oldDelegate.xLabels != xLabels;
}
