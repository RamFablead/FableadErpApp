import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../home_screen.dart';
import '../../products/view/product_screen.dart';
import '../../profile_screen.dart';
import 'sales_screen.dart';

/// Model representing a single Sales & Bill row item
class SalesBillItem {
  final String orderNo;
  final DateTime date;
  final String customer;
  final String staff;
  final String orderType;
  final String orderStatus; // 'Pending' | 'Paid' | 'Delivered' | 'Cancelled'
  final String paymentStatus; // 'Unpaid' | 'Paid'
  final double amount;
  final bool hasGst;
  final Color iconBgColor;
  final Color iconColor;

  const SalesBillItem({
    required this.orderNo,
    required this.date,
    required this.customer,
    required this.staff,
    required this.orderType,
    required this.orderStatus,
    required this.paymentStatus,
    required this.amount,
    required this.hasGst,
    required this.iconBgColor,
    required this.iconColor,
  });
}

/// Model representing a Draft Bill item
class SalesDraftItem {
  final String draftId;
  final String title;
  final DateTime date;
  final double amount;
  final String billType;

  const SalesDraftItem({
    required this.draftId,
    required this.title,
    required this.date,
    required this.amount,
    required this.billType,
  });
}

/// Currency formatting helper
String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final whole = parts[0];
  final dec = parts[1];
  final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
  final formatted = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$formatted.$dec';
}

/// Date formatting helper
String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month - 1];
  final year = dt.year.toString();
  return '$day $month $year';
}

class AllSalesScreen extends StatefulWidget {
  const AllSalesScreen({super.key});

  @override
  State<AllSalesScreen> createState() => _AllSalesScreenState();
}

class _AllSalesScreenState extends State<AllSalesScreen> {
  // Tab Filter: 'Without GST Bills' | 'With GST Bills'
  String _selectedGstTab = 'Without GST Bills';

  // Search
  final TextEditingController _searchController = TextEditingController();

  // Filter Dropdowns
  String _selectedMonth = 'All Months';
  String _selectedYear = 'All Years';
  String _selectedFinancialYear = 'All Financial Years';
  String _selectedStaff = 'All Staff';
  DateTime? _selectedDate;
  String _selectedOrderType = 'All Order Types';
  String _selectedStatus = 'All Statuses';
  String _selectedSort = 'Latest First';

  // Floating Calculator overlay
  bool _isCalculatorOpen = false;

  // --- Live API State ---
  final OrderService _orderService = OrderService();
  final List<OrderItemModel> _allOrders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  double _totalAmount = 0;
  double _totalPendingAmount = 0;
  double _totalPaidAmount = 0;

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  // Dummy Drafts
  final List<SalesDraftItem> _drafts = [
    SalesDraftItem(
      draftId: 'DFT-001',
      title: 'Draft - Rahul Sharma',
      date: DateTime(2026, 10, 2),
      amount: 2500.00,
      billType: 'Sales',
    ),
    SalesDraftItem(
      draftId: 'DFT-002',
      title: 'Quotation - Priya Patel',
      date: DateTime(2026, 9, 29),
      amount: 1850.00,
      billType: 'Quotation',
    ),
    SalesDraftItem(
      draftId: 'DFT-003',
      title: 'Rental - Amit Mehta',
      date: DateTime(2026, 9, 28),
      amount: 3200.00,
      billType: 'Rental',
    ),
  ];

  // Dropdown lists
  final List<String> _monthsList = [
    'All Months', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _yearsList = [
    'All Years', '2027', '2026', '2025', '2024'
  ];

  final List<String> _financialYearsList = [
    'All Financial Years', 'FY 2026-27', 'FY 2025-26', 'FY 2024-25'
  ];

  final List<String> _staffList = [
    'All Staff', 'Amrita Patel', 'Neha Shah', 'Vikram Chauhan', 'Rohan Desai', 'Priya Patel'
  ];

  final List<String> _orderTypesList = [
    'All Order Types', 'Self Pickup', 'Home Delivery', 'Courier Delivery'
  ];

  final List<String> _statusList = [
    'All Statuses', 'Pending', 'Paid', 'Delivered', 'Cancelled'
  ];

  final List<String> _sortList = [
    'Latest First', 'Oldest First', 'Highest Amount', 'Lowest Amount'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders(page: 1, isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _fetchOrders({int page = 1, bool isRefresh = false}) async {
    if (_isLoading || _isLoadingMore) return;
    setState(() {
      if (isRefresh) {
        _isLoading = true;
        _hasError = false;
        _allOrders.clear();
        _currentPage = 1;
        _lastPage = 1;
      } else {
        _isLoadingMore = true;
      }
    });
    try {
      final result = await _orderService.getOrders(page: page);
      setState(() {
        _allOrders.addAll(result.data);
        _currentPage = result.pagination?.currentPage ?? page;
        _lastPage = result.pagination?.lastPage ?? 1;
        _totalAmount = result.totalAmount;
        _totalPendingAmount = result.totalPendingAmount;
        _totalPaidAmount = result.totalPaidAmount;
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = isRefresh;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;
    await _fetchOrders(page: _currentPage + 1);
  }

  // Filtered orders from live API data
  List<OrderItemModel> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();
    final isGstSelected = _selectedGstTab == 'With GST Bills';

    var list = _allOrders.where((order) {
      // 1. GST Filter
      if (order.isWithGst != isGstSelected) return false;

      // 2. Search Query (orderNumber, customerName, staffName)
      if (query.isNotEmpty) {
        final matchesNo = order.orderNumber.toLowerCase().contains(query);
        final matchesCust = order.customerName.toLowerCase().contains(query);
        final matchesStaff = order.effectiveStaffName.toLowerCase().contains(query);
        if (!matchesNo && !matchesCust && !matchesStaff) return false;
      }

      return true;
    }).toList();

    return list;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B2C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- Show Import Dialog ---
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Import Sales & Bills',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload an Excel or CSV file containing sales bill records.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF7ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFFFF6B2C),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap here to browse file',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports .xlsx, .xls, .csv',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.snackbar(
                            'Import Successful',
                            'Sample sales data imported successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF22C55E),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B2C),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Upload & Import',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Show Drafts Dialog ---
  void _showDraftsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF0F172A),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All Draft Bills (${_drafts.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._drafts.map((draft) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: Color(0xFFFF6B2C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${draft.billType} • ${_formatDate(draft.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(draft.amount),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Material(
                            color: const Color(0xFFFF6B2C),
                            borderRadius: BorderRadius.circular(6),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                Get.to(() => const SalesScreen());
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text(
                                  'Resume',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // --- Show Bill Action Bottom Sheet ---
  void _showBillActionSheet(OrderItemModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order Options • ${order.orderNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildActionSheetOption(
                icon: Icons.visibility_outlined,
                label: 'View Bill Details',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Order ${order.orderNumber}',
                    'Viewing bill for ${order.customerName}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF0F172A),
                    colorText: Colors.white,
                  );
                },
              ),
              _buildActionSheetOption(
                icon: Icons.print_outlined,
                label: 'Print Thermal Receipt',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Printing',
                    'Receipt queued to connected printer',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF0F172A),
                    colorText: Colors.white,
                  );
                },
              ),
              _buildActionSheetOption(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Download PDF Invoice',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'PDF Saved',
                    'Invoice downloaded to device storage',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF22C55E),
                    colorText: Colors.white,
                  );
                },
              ),
              _buildActionSheetOption(
                icon: Icons.edit_outlined,
                label: 'Edit Order',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.to(() => const SalesScreen());
                },
              ),
              _buildActionSheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Bill',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _allOrders.removeWhere((o) => o.id == order.id);
                  });
                  Get.snackbar(
                    'Deleted',
                    'Bill ${order.orderNumber} removed successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFEF4444),
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF0F172A),
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'All Sales & Bills',
        showBackButton: false,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Sale'),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: 2, // Sale tab
        isDarkMode: false,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => const HomeScreen());
              break;
            case 1:
              Get.to(() => const ProductScreen());
              break;
            case 2:
              // Already on Sale
              break;
            case 3:
              Get.to(() => const ProfileScreen());
              break;
          }
        },
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFFFF6B2C),
            onRefresh: () => _fetchOrders(page: 1, isRefresh: true),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderBar(),
                  const SizedBox(height: 14),

                  // 1. With GST / Without GST Tabs Switcher (Active)
                  _buildGstTabSwitcher(),
                  const SizedBox(height: 14),

                  // 2. Search Bar (Active)
                  _buildSearchBar(),
                  const SizedBox(height: 14),

                  /* ================================================================
                     DROPDOWN FILTERS COMMENTED OUT AS PER REQUEST (CAN BE RESTORED)
                     ================================================================
                  _buildFilterDropdownsGrid(),
                  const SizedBox(height: 14),
                  ================================================================ */

                  /*
                  // Summary Metrics & Export Row (Commented Out as per request)
                  _buildSummaryAndExportRow(),
                  const SizedBox(height: 16),
                  */

                  _buildBillsList(),

                  // Load more indicator
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B2C),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Floating Calculator Widget overlay
          if (_isCalculatorOpen)
            Positioned(
              right: 16,
              bottom: 80,
              child: CalculatorWidget(
                onClose: () => setState(() => _isCalculatorOpen = false),
              ),
            ),
        ],
      ),
    );
  }

  // --- 1. Top Action Bar: Clean Bill Counter on left, New Sale Button on right ---
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Clean Active Bill Counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2746).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E2746).withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF1E2746),
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                '${_filteredOrders.length} Bills',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2746),
                ),
              ),
            ],
          ),
        ),

        // Right: Action Buttons (All Drafts and Import commented out as requested)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*
            // "All Drafts" Navy button (Commented Out)
            Material(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _showDraftsDialog,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'All Drafts',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // "Import" Orange button (Commented Out)
            Material(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _showImportDialog,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.file_upload_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Import',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            */

            // "+ New Sale" Vibrant Orange button
            Material(
              color: const Color(0xFFFF6B2C),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => Get.to(() => const SalesScreen()),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'New Sale',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. Tab Switcher: "Without GST Bills" | "With GST Bills" ---
  Widget _buildGstTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildGstTabPill(
              title: 'Without GST Bills',
              isSelected: _selectedGstTab == 'Without GST Bills',
              onTap: () => setState(() => _selectedGstTab = 'Without GST Bills'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildGstTabPill(
              title: 'With GST Bills',
              isSelected: _selectedGstTab == 'With GST Bills',
              onTap: () => setState(() => _selectedGstTab = 'With GST Bills'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGstTabPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFFF6B2C) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search order number, customer...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- 4. 2x4 Filter Dropdowns Grid ---
  Widget _buildFilterDropdownsGrid() {
    return Column(
      children: [
        // Row 1: All Months | All Years
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.calendar_month_outlined,
                value: _selectedMonth,
                items: _monthsList,
                onChanged: (val) => setState(() => _selectedMonth = val!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.calendar_today_outlined,
                value: _selectedYear,
                items: _yearsList,
                onChanged: (val) => setState(() => _selectedYear = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 2: All Financial Years | All Staff
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.bar_chart_rounded,
                value: _selectedFinancialYear,
                items: _financialYearsList,
                onChanged: (val) => setState(() => _selectedFinancialYear = val!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.person_outline_rounded,
                value: _selectedStaff,
                items: _staffList,
                onChanged: (val) => setState(() => _selectedStaff = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 3: Choose Date | All Order Types
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Choose Date',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedDate != null)
                        InkWell(
                          onTap: () => setState(() => _selectedDate = null),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.format_list_bulleted_rounded,
                value: _selectedOrderType,
                items: _orderTypesList,
                onChanged: (val) => setState(() => _selectedOrderType = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 4: All Statuses | Latest First
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.local_offer_outlined,
                value: _selectedStatus,
                items: _statusList,
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterDropdown(
                icon: Icons.swap_vert_rounded,
                value: _selectedSort,
                items: _sortList,
                onChanged: (val) => setState(() => _selectedSort = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Summary Statistics & Export Buttons Row ---
  Widget _buildSummaryAndExportRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Total Pending
          _buildStatCard(
            label: 'Total Pending',
            amount: _formatCurrency(_totalPendingAmount),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            textColor: const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),

          // Total Paid
          _buildStatCard(
            label: 'Total Paid',
            amount: _formatCurrency(_totalPaidAmount),
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            textColor: const Color(0xFF16A34A),
          ),
          const SizedBox(width: 8),

          // Grand Total
          _buildStatCard(
            label: 'Total',
            amount: _formatCurrency(_totalAmount),
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            textColor: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),

          // Excel Export Button
          Material(
            color: const Color(0xFF059669),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  'Excel Exported',
                  'Sales & Bills data exported to Excel successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF059669),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.table_chart_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Excel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // PDF Export Button
          Material(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  'PDF Generated',
                  'Sales & Bills summary PDF generated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFDC2626),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String amount,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Sales & Bills Cards List ---
  Widget _buildBillsList() {
    // Loading skeleton
    if (_isLoading) {
      return Column(
        children: List.generate(5, (i) => _buildSkeletonCard()),
      );
    }

    // Error state
    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFEF4444),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchOrders(page: 1, isRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B2C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final orders = _filteredOrders;

    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFFFF6B2C),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No bills found matching filters',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing search keyword or filter options',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: orders.map((order) => _buildOrderCard(order)).toList(),
    );
  }

  /// Icon colour helper based on payment status
  _OrderIconStyle _iconStyleForOrder(OrderItemModel order) {
    if (order.isPaid) {
      return _OrderIconStyle(
        bg: const Color(0xFFF0FDF4),
        icon: const Color(0xFF16A34A),
      );
    }
    if (order.displayPaymentStatus == 'Partially Paid') {
      return _OrderIconStyle(
        bg: const Color(0xFFEFF6FF),
        icon: const Color(0xFF2563EB),
      );
    }
    return _OrderIconStyle(
      bg: const Color(0xFFFFF7ED),
      icon: const Color(0xFFEA580C),
    );
  }

  Widget _buildOrderCard(OrderItemModel order) {
    final style = _iconStyleForOrder(order);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_outlined,
              color: style.icon,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),

          // Order No, Date, Customer Name
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(order.effectiveDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStatusBadge(order.displayPaymentStatus),
              const SizedBox(height: 4),
              _buildPaymentBadge(order.isPaid ? 'Paid' : 'Unpaid'),
            ],
          ),
          const SizedBox(width: 10),

          // Total, Amount, Order Type, Staff
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _formatCurrency(order.totalAmount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.displayOrderType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.effectiveStaffName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // 3-Dots Action Button
          Container(
            width: 32,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF64748B),
                size: 18,
              ),
              onPressed: () => _showBillActionSheet(order),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _shimmerBox(44, 44, radius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(12, 100),
                const SizedBox(height: 6),
                _shimmerBox(10, 140),
                const SizedBox(height: 6),
                _shimmerBox(10, 120),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _shimmerBox(22, 64, radius: 4),
              const SizedBox(height: 4),
              _shimmerBox(22, 64, radius: 4),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(10, 40),
                const SizedBox(height: 4),
                _shimmerBox(12, 90),
                const SizedBox(height: 6),
                _shimmerBox(10, 80),
                const SizedBox(height: 6),
                _shimmerBox(10, 70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double height, double width, {double radius = 6}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'Paid':
        bg = const Color(0xFFF0FDF4);
        text = const Color(0xFF16A34A);
        break;
      case 'Partially Paid':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF2563EB);
        break;
      case 'Delivered':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF2563EB);
        break;
      case 'Pending':
      default:
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFEA580C);
        break;
    }

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    final isPaid = status == 'Paid';
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        ),
      ),
    );
  }
}

/// Small helper to carry icon palette for an order card
class _OrderIconStyle {
  final Color bg;
  final Color icon;
  const _OrderIconStyle({required this.bg, required this.icon});
}
