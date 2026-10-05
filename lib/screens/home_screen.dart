import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_app_bar.dart';

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
  String _selectedTrendPeriod = 'Last 7 Days';
  String _activeDrawerItem = 'Dashboard';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Greeting & Date Selector Row (PERFECT BALANCED FONTS)
              _buildGreetingAndDateRow(textPrimary, textSecondary, cardBg, borderColor),
              SizedBox(height: 2.h),

              // 2. Top 2x2 Metric Grid (Total Sales, Purchases, Customers, Vendors - BALANCED ELEGANT FONTS)
              _buildTop2x2MetricGrid(cardBg, borderColor, textPrimary, textSecondary),
              SizedBox(height: 2.h),

              // 3. Sales & Purchases Target Progress Card (BALANCED FONTS)
              _buildSalesAndPurchasesTargetCard(cardBg, cardBgLight, borderColor, textPrimary, textSecondary),
              SizedBox(height: 2.h),

              // 4. Top 5 Sales (Products) Card (BALANCED FONTS)
              _buildTop5ProductsCard(cardBg, cardBgLight, borderColor, textPrimary, textSecondary),
              SizedBox(height: 2.h),

              // 5. Sales Trend Line Chart Card (BALANCED FONTS & PAINTER)
              _buildSalesTrendChartCard(cardBg, cardBgLight, borderColor, textPrimary, textSecondary),
              SizedBox(height: 2.h),

              // 6. Recent Sales & Recent Purchases Cards (BALANCED FONTS)
              _buildRecentTransactionsSection(cardBg, cardBgLight, borderColor, textPrimary, textSecondary),
              SizedBox(height: 2.5.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(cardBg, borderColor, textPrimary, textSecondary),
    );
  }



  // --- 2. Greeting & Date Pill Row (PERFECT PROPORTIONS) ---
  Widget _buildGreetingAndDateRow(
    Color textPrimary,
    Color textSecondary,
    Color cardBg,
    Color borderColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 16.sp, // BALANCED PERFECT FONT SIZE
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              'Welcome back!',
              style: TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 11.5.sp, // BALANCED SUBTITLE FONT
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Date Dropdown Pill
        PopupMenuButton<String>(
          color: cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: _updateDatePeriod,
          itemBuilder: (context) => [
            'Thu, 26 Sep 2026',
            'Fri, 27 Sep 2026',
            'Sat, 28 Sep 2026',
          ]
              .map((date) => PopupMenuItem(
                    value: date,
                    child: Text(date,
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w500)),
                  ))
              .toList(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: textSecondary, size: 12.sp),
                SizedBox(width: 1.5.w),
                Text(
                  _selectedDatePeriod,
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 10.5.sp, // BALANCED FONT SIZE
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: textSecondary, size: 13.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Top 2x2 Metric Grid Cards (BALANCED CLEAN FONTS) ---
  Widget _buildTop2x2MetricGrid(
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 1.5.h,
      childAspectRatio: 1.35, // Clean balanced proportioned height
      children: [
        // 1. Total Sales Card
        _buildMetricGridCard(
          title: 'Total Sales',
          value: '₹ 4,82,650',
          growthText: '↑ 12% vs last week',
          icon: Icons.shopping_cart_rounded,
          iconBgColor: AppColors.orangeAccent,
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),

        // 2. Purchases Card
        _buildMetricGridCard(
          title: 'Purchases',
          value: '₹ 2,31,480',
          growthText: '↑ 8% vs last week',
          icon: Icons.shopping_bag_rounded,
          iconBgColor: AppColors.tidcraftGreen,
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),

        // 3. Customers Card
        _buildMetricGridCard(
          title: 'Customers',
          value: '1,248',
          growthText: '↑ 15% vs last week',
          icon: Icons.groups_rounded,
          iconBgColor: AppColors.tidcraftPurple,
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),

        // 4. Vendors Card
        _buildMetricGridCard(
          title: 'Vendors',
          value: '356',
          growthText: '↑ 6% vs last week',
          icon: Icons.storefront_rounded,
          iconBgColor: AppColors.tidcraftOrange,
          cardBg: cardBg,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
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
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
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
                padding: EdgeInsets.all(1.8.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 14.sp),
              ),
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 11.sp, // BALANCED PERFECT FONT
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(width: 0.5.w),
                  Icon(Icons.chevron_right_rounded,
                      color: textSecondary, size: 13.sp),
                ],
              ),
            ],
          ),

          // Big Bold Value Text
          Text(
            value,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 16.sp, // BALANCED PERFECT BOLD VALUE
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: 0.3,
            ),
          ),

          // Growth Badge Indicator
          Text(
            growthText,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 9.5.sp, // BALANCED CRISP FONT
              fontWeight: FontWeight.w600,
              color: AppColors.tidcraftGreen,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Sales & Purchases Target Progress Card (BALANCED FONTS) ---
  Widget _buildSalesAndPurchasesTargetCard(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
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
                      color: AppColors.tidcraftOrange, size: 16.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Sales & Purchases',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 14.sp, // BALANCED HEADER FONT
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
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500))))
                        .toList(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
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
                          fontSize: 10.sp, // BALANCED FONT
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 0.5.w),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: textSecondary, size: 13.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.8.h),

          // Block 1: Sales Target Meter
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: cardBgLight,
              borderRadius: BorderRadius.circular(10),
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
                            color: AppColors.tidcraftOrange, size: 14.sp),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Sales',
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 11.5.sp, // BALANCED FONT
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹ 4,82,650',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 13.5.sp, // BALANCED BOLD AMOUNT
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.2.h),

                // Sleek Progress Bar + Percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.68,
                          minHeight: 8, // Sleek height
                          backgroundColor: _isDarkMode
                              ? Colors.black26
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.tidcraftOrange),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.5.w),
                    Text(
                      '68%',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 11.sp, // BALANCED PERCENTAGE
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Text(
                  'Target  ₹ 7,10,000',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 10.sp, // BALANCED TARGET TEXT
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.2.h),

          // Block 2: Purchases Target Meter
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: cardBgLight,
              borderRadius: BorderRadius.circular(10),
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
                        Icon(Icons.shopping_bag_outlined,
                            color: AppColors.amberAccent, size: 14.sp),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Purchases',
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 11.5.sp, // BALANCED FONT
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹ 2,31,480',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 13.5.sp, // BALANCED BOLD AMOUNT
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.2.h),

                // Progress Bar + Percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.52,
                          minHeight: 8, // Sleek height
                          backgroundColor: _isDarkMode
                              ? Colors.black26
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.amberAccent),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.5.w),
                    Text(
                      '52%',
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 11.sp, // BALANCED PERCENTAGE
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Text(
                  'Target  ₹ 4,50,000',
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 10.sp, // BALANCED TARGET TEXT
                    fontWeight: FontWeight.w500,
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

  // --- 5. Top 5 Sales (Products) Card (BALANCED FONTS) ---
  Widget _buildTop5ProductsCard(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final products = [
      {'name': 'T-shirt', 'amount': '₹ 48,200', 'pcs': '48 pcs', 'icon': Icons.checkroom_rounded},
      {'name': 'Jeans', 'amount': '₹ 32,450', 'pcs': '32 pcs', 'icon': Icons.dry_cleaning_rounded},
      {'name': 'Shoes', 'amount': '₹ 28,600', 'pcs': '28 pcs', 'icon': Icons.roller_skating_rounded},
      {'name': 'Watch', 'amount': '₹ 24,300', 'pcs': '22 pcs', 'icon': Icons.watch_rounded},
      {'name': 'Bag', 'amount': '₹ 18,750', 'pcs': '18 pcs', 'icon': Icons.work_rounded},
    ];

    return Container(
      padding: EdgeInsets.all(3.5.w),
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
                  Icon(Icons.inventory_2_rounded,
                      color: AppColors.tidcraftOrange, size: 16.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Top 5 Sales (Products)',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 14.sp, // BALANCED HEADER FONT
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right_rounded,
                  color: textSecondary, size: 16.sp),
            ],
          ),
          SizedBox(height: 1.5.h),

          // Product Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                Divider(color: borderColor, height: 1.5.h),
            itemBuilder: (context, index) {
              final item = products[index];
              return Row(
                children: [
                  Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: cardBgLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: AppColors.tidcraftOrange, size: 14.sp),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 12.sp, // BALANCED PRODUCT NAME
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          item['pcs'] as String,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 10.sp, // BALANCED PCS SUBTITLE
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['amount'] as String,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 12.5.sp, // BALANCED AMOUNT
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 6. Sales Trend Line Chart Card (BALANCED PAINTER) ---
  Widget _buildSalesTrendChartCard(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
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
                      color: AppColors.tidcraftOrange, size: 16.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Sales Trend',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 14.sp, // BALANCED HEADER FONT
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
                    ['Last 7 Days', 'Last 30 Days', 'This Quarter']
                        .map((p) => PopupMenuItem(
                            value: p,
                            child: Text(p,
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500))))
                        .toList(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
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
                          fontSize: 10.sp, // BALANCED FONT
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 0.5.w),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: textSecondary, size: 13.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Custom Line Chart Widget
          SizedBox(
            height: 18.h, // Balanced chart height
            width: double.infinity,
            child: CustomPaint(
              painter: SalesTrendPainter(
                isDarkMode: _isDarkMode,
                textSecondary: textSecondary,
                borderColor: borderColor,
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Chart Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.tidcraftOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Sales',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 10.5.sp, // BALANCED FONT
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 6.w),
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.amberAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Purchases',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 10.5.sp, // BALANCED FONT
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 7. Recent Sales & Recent Purchases Section (BALANCED FONTS) ---
  Widget _buildRecentTransactionsSection(
    Color cardBg,
    Color cardBgLight,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final recentSales = [
      {'initials': 'RK', 'name': 'Ramesh Kumar', 'id': '#INV-10045', 'amount': '₹ 18,750', 'time': 'Today', 'status': 'Paid', 'statusColor': AppColors.tidcraftGreen},
      {'initials': 'AP', 'name': 'Aarti Patel', 'id': '#INV-10044', 'amount': '₹ 12,420', 'time': 'Today', 'status': 'Paid', 'statusColor': AppColors.tidcraftGreen},
      {'initials': 'JS', 'name': 'Jigar Shah', 'id': '#INV-10043', 'amount': '₹ 9,860', 'time': 'Yesterday', 'status': 'Pending', 'statusColor': AppColors.tidcraftOrange},
      {'initials': 'MK', 'name': 'Meena Kapadia', 'id': '#INV-10042', 'amount': '₹ 24,300', 'time': 'Yesterday', 'status': 'Paid', 'statusColor': AppColors.tidcraftGreen},
    ];

    final recentPurchases = [
      {'initials': 'VS', 'name': 'Vishal Suppliers', 'id': '#PUR-20078', 'amount': '₹ 42,600', 'time': 'Today', 'status': 'Received', 'statusColor': AppColors.amberAccent},
      {'initials': 'AG', 'name': 'Apex Global', 'id': '#PUR-20077', 'amount': '₹ 18,950', 'time': 'Yesterday', 'status': 'Received', 'statusColor': AppColors.amberAccent},
      {'initials': 'SK', 'name': 'S.K. Traders', 'id': '#PUR-20076', 'amount': '₹ 11,320', 'time': 'Yesterday', 'status': 'Pending', 'statusColor': AppColors.tidcraftOrange},
      {'initials': 'RM', 'name': 'R M Distributors', 'id': '#PUR-20075', 'amount': '₹ 35,780', 'time': '2 days ago', 'status': 'Received', 'statusColor': AppColors.amberAccent},
    ];

    return Column(
      children: [
        // Recent Sales Container
        _buildTransactionCardBlock(
          title: 'Recent Sales',
          icon: Icons.edit_note_rounded,
          iconColor: AppColors.tidcraftOrange,
          items: recentSales,
          cardBg: cardBg,
          cardBgLight: cardBgLight,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        SizedBox(height: 2.h),

        // Recent Purchases Container
        _buildTransactionCardBlock(
          title: 'Recent Purchases',
          icon: Icons.shopping_cart_outlined,
          iconColor: AppColors.amberAccent,
          items: recentPurchases,
          cardBg: cardBg,
          cardBgLight: cardBgLight,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  Widget _buildTransactionCardBlock({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> items,
    required Color cardBg,
    required Color cardBgLight,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
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
                  Icon(icon, color: iconColor, size: 16.sp),
                  SizedBox(width: 2.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 14.sp, // BALANCED HEADER FONT
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
                      fontSize: 10.5.sp, // BALANCED FONT
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: textSecondary, size: 13.sp),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                Divider(color: borderColor, height: 1.5.h),
            itemBuilder: (context, index) {
              final item = items[index];
              final statusColor = item['statusColor'] as Color;

              return Row(
                children: [
                  // Circular Avatar Initials
                  CircleAvatar(
                    radius: 16, // Clean balanced avatar
                    backgroundColor: _isDarkMode
                        ? cardBgLight
                        : const Color(0xFFE2E8F0),
                    child: Text(
                      item['initials'] as String,
                      style: TextStyle(
                        fontFamily: AppStyles.fontFamily,
                        fontSize: 10.sp, // BALANCED INITIALS
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.5.w),

                  // Name & ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 11.5.sp, // BALANCED NAME FONT
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          item['id'] as String,
                          style: TextStyle(
                            fontFamily: AppStyles.fontFamily,
                            fontSize: 9.5.sp, // BALANCED ID FONT
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount & Status Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['amount'] as String,
                        style: TextStyle(
                          fontFamily: AppStyles.fontFamily,
                          fontSize: 12.5.sp, // BALANCED AMOUNT FONT
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Row(
                        children: [
                          Text(
                            item['time'] as String,
                            style: TextStyle(
                              fontFamily: AppStyles.fontFamily,
                              fontSize: 9.sp, // BALANCED TIME FONT
                              color: textSecondary,
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: TextStyle(
                                fontFamily: AppStyles.fontFamily,
                                fontSize: 9.sp, // BALANCED STATUS FONT
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavigationBar(
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final navItems = [
      {'label': 'Dashboard', 'icon': Icons.home_filled},
      {'label': 'Sales', 'icon': Icons.trending_up_rounded},
      {'label': 'Purchases', 'icon': Icons.shopping_cart_outlined},
      {'label': 'More', 'icon': Icons.grid_view_rounded},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = _selectedBottomNavIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedBottomNavIndex = index;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected
                      ? AppColors.tidcraftOrange
                      : textSecondary,
                  size: 18.sp, // BALANCED ICON SIZE
                ),
                SizedBox(height: 0.3.h),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 9.5.sp, // BALANCED LABEL FONT
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.tidcraftOrange
                        : textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }


}

// --- Custom Painter for Sales Trend Line Chart (Dynamic Dark/Light Aware) ---
class SalesTrendPainter extends CustomPainter {
  final bool isDarkMode;
  final Color textSecondary;
  final Color borderColor;

  SalesTrendPainter({
    required this.isDarkMode,
    required this.textSecondary,
    required this.borderColor,
  });

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
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final purchasePaint = Paint()
      ..color = AppColors.amberAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw horizontal grid lines & Y labels (BALANCED FONTS)
    final yLabels = ['₹ 1.5L', '₹ 1.0L', '₹ 50K', '₹ 0'];
    final double yStep = (height - 25) / (yLabels.length - 1);

    for (int i = 0; i < yLabels.length; i++) {
      double y = i * yStep + 8;
      canvas.drawLine(Offset(40, y), Offset(width, y), gridPaint);

      final textSpan = TextSpan(
        text: yLabels[i],
        style: TextStyle(
          color: textSecondary,
          fontSize: 9, // Crisp painter font
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y - 5));
    }

    // X Axis Labels (BALANCED FONTS)
    final xLabels = [
      'Oct 7',
      'Oct 8',
      'Oct 9',
      'Oct 10',
      'Oct 11',
      'Oct 12',
      'Oct 13'
    ];
    final double xStart = 45;
    final double xStep = (width - xStart) / (xLabels.length - 1);

    for (int i = 0; i < xLabels.length; i++) {
      double x = xStart + i * xStep;
      final textSpan = TextSpan(
        text: xLabels[i],
        style: TextStyle(
          color: textSecondary,
          fontSize: 9, // Crisp painter font
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - 12, height - 12));
    }

    // Points for Sales & Purchases
    final salesNormalized = [0.65, 0.52, 0.50, 0.51, 0.32, 0.40, 0.30];
    final purchaseNormalized = [0.82, 0.72, 0.73, 0.74, 0.58, 0.60, 0.48];

    final Path salesPath = Path();
    final Path purchasePath = Path();

    List<Offset> salesPoints = [];
    List<Offset> purchasePoints = [];

    for (int i = 0; i < xLabels.length; i++) {
      double x = xStart + i * xStep;
      double ySales = salesNormalized[i] * (height - 35) + 8;
      double yPurchase = purchaseNormalized[i] * (height - 35) + 8;

      salesPoints.add(Offset(x, ySales));
      purchasePoints.add(Offset(x, yPurchase));
    }

    // Draw Smooth Curves
    _drawCurvedLine(canvas, salesPoints, salesPath, salesPaint);
    _drawCurvedLine(canvas, purchasePoints, purchasePath, purchasePaint);

    // Draw Dots on Points
    for (var point in salesPoints) {
      canvas.drawCircle(point, 3.5, Paint()..color = AppColors.tidcraftOrange);
      canvas.drawCircle(point, 1.5, Paint()..color = Colors.white);
    }

    for (var point in purchasePoints) {
      canvas.drawCircle(point, 3.5, Paint()..color = AppColors.amberAccent);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
