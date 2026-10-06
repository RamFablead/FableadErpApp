import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../core/widgets/calculator_widget.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../services/pdf_invoice_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../home_screen.dart';
import '../../products/view/product_screen.dart';
import '../../profile_screen.dart';
import 'invoice_pdf_viewer_screen.dart';
import 'sales_detail_screen.dart';
import 'sales_screen.dart';

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

/// Internal state container for each GST Tab
class _GstTabState {
  final List<OrderItemModel> orders = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 1;
  int lastPage = 1;
  int total = 0;
  bool isLoaded = false;
  double totalAmount = 0;
  double totalPendingAmount = 0;
  double totalPaidAmount = 0;
}

class _AllSalesScreenState extends State<AllSalesScreen> {
  // Tab Filter: 'Without GST Bills' | 'With GST Bills'
  String _selectedGstTab = 'Without GST Bills';

  // Search
  final TextEditingController _searchController = TextEditingController();

  // Floating Calculator overlay
  bool _isCalculatorOpen = false;

  // Live API State
  final OrderService _orderService = OrderService();
  final PdfInvoiceService _pdfInvoiceService = PdfInvoiceService();
  final _GstTabState _withoutGstState = _GstTabState();
  final _GstTabState _withGstState = _GstTabState();

  _GstTabState get _currentState =>
      _selectedGstTab == 'With GST Bills' ? _withGstState : _withoutGstState;

  bool get _isLoading => _currentState.isLoading;
  bool get _isLoadingMore => _currentState.isLoadingMore;
  bool get _hasError => _currentState.hasError;
  String get _errorMessage => _currentState.errorMessage;

  String _getGstOptionForTab(String tab) {
    return tab == 'With GST Bills' ? 'with_gst' : 'without_gst';
  }

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load Without GST Bills (initial tab)
    _fetchOrders(tab: 'Without GST Bills', page: 1, isRefresh: true);
    // Pre-fetch With GST Bills in background
    _fetchOrders(tab: 'With GST Bills', page: 1, isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _fetchOrders({
    String? tab,
    int page = 1,
    bool isRefresh = false,
  }) async {
    final targetTab = tab ?? _selectedGstTab;
    final state = targetTab == 'With GST Bills' ? _withGstState : _withoutGstState;
    final gstOption = _getGstOptionForTab(targetTab);

    if (state.isLoading || state.isLoadingMore) return;

    setState(() {
      if (isRefresh) {
        state.isLoading = true;
        state.hasError = false;
        state.orders.clear();
        state.currentPage = 1;
        state.lastPage = 1;
      } else {
        state.isLoadingMore = true;
      }
    });

    try {
      final result = await _orderService.getOrders(
        page: page,
        perPage: 25,
        gstOption: gstOption,
      );

      if (!mounted) return;

      setState(() {
        state.orders.addAll(result.data);
        state.currentPage = result.pagination?.currentPage ?? page;
        state.lastPage = result.pagination?.lastPage ?? 1;
        state.total = result.pagination?.total ?? state.orders.length;
        state.totalAmount = result.totalAmount;
        state.totalPendingAmount = result.totalPendingAmount;
        state.totalPaidAmount = result.totalPaidAmount;
        state.isLoaded = true;
        state.isLoading = false;
        state.isLoadingMore = false;
        state.hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        state.isLoading = false;
        state.isLoadingMore = false;
        state.hasError = isRefresh;
        state.errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    final state = _currentState;
    if (state.isLoading || state.isLoadingMore || state.currentPage >= state.lastPage) {
      return;
    }
    await _fetchOrders(tab: _selectedGstTab, page: state.currentPage + 1);
  }

  // Filtered orders list
  List<OrderItemModel> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();
    final list = _currentState.orders;

    if (query.isEmpty) return list;

    return list.where((order) {
      final matchesNo = order.orderNumber.toLowerCase().contains(query);
      final matchesCust = order.customerName.toLowerCase().contains(query);
      final matchesStaff = order.effectiveStaffName.toLowerCase().contains(query);
      return matchesNo || matchesCust || matchesStaff;
    }).toList();
  }

  void _switchGstTab(String tab) {
    if (_selectedGstTab == tab) return;
    setState(() {
      _selectedGstTab = tab;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    final state = _currentState;
    if (!state.isLoaded && !state.isLoading) {
      _fetchOrders(tab: tab, page: 1, isRefresh: true);
    }
  }

  // Delete Action
  void _confirmDeleteOrder(OrderItemModel order) {
    showDialog(
      context: context,
      builder: (dialogCtx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                      Icons.delete_outline_rounded, color: Color(0xFFEF4444),
                      size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete Bill',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete bill #${order
              .orderNumber}? This action cannot be undone.',
          style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF475569)),
        ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color(0xFF64748B),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _handleDeleteOrder(order);
            },
            child: Text('Delete', style: TextStyle(
                fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteOrder(OrderItemModel order) async {
    Get.showSnackbar(
      const GetSnackBar(
        message: 'Deleting bill...',
        duration: Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF0F172A),
        showProgressIndicator: true,
      ),
    );

    try {
      final response = await _orderService.deleteOrder(order.id);
      if (response.status) {
        setState(() {
          _withoutGstState.orders.removeWhere((o) => o.id == order.id);
          _withGstState.orders.removeWhere((o) => o.id == order.id);
        });

        Get.closeCurrentSnackbar();
        Get.snackbar(
          'Deleted',
          response.message.isNotEmpty
              ? response.message
              : 'Bill deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
        _fetchOrders(page: 1, isRefresh: true);
      } else {
        Get.closeCurrentSnackbar();
        Get.snackbar(
          'Failed',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to delete order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  void _openInvoicePdf(OrderItemModel order) {
    Get.to(() => InvoicePdfViewerScreen(
          orderId: order.id,
          orderNumber: order.orderNumber,
          pdfUrl: order.effectiveInvoicePdfUrl,
        ));
  }

  Future<void> _downloadOrPrintInvoice(OrderItemModel order) async {
    Get.showSnackbar(
      GetSnackBar(
        message: 'Downloading Invoice #${order.orderNumber}...',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        showProgressIndicator: true,
      ),
    );

    try {
      final filePath = await _pdfInvoiceService.downloadInvoicePdf(
        orderId: order.id,
        orderNumber: order.orderNumber,
        rawPdfUrl: order.effectiveInvoicePdfUrl,
      );

      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Invoice Downloaded',
        'Invoice #${order.orderNumber} saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => _pdfInvoiceService.openPdfFile(filePath),
          child: const Text(
            'OPEN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Download Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  void _showOrderHistorySheet(OrderItemModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history_rounded,
                            color: Color(0xFF2563EB), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order History & Audit',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Bill #${order.orderNumber}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildHistoryTile(Icons.calendar_today_rounded, 'Order Date',
                      _formatDate(order.effectiveDate)),
                  _buildHistoryTile(Icons.person_outline_rounded, 'Customer',
                      order.customerName),
                  if (order.customerPhone.isNotEmpty)
                    _buildHistoryTile(
                        Icons.phone_outlined, 'Contact', order.customerPhone),
                  _buildHistoryTile(Icons.badge_outlined, 'Staff / Biller',
                      order.effectiveStaffName),
                  _buildHistoryTile(Icons.local_shipping_outlined, 'Order Type',
                      order.displayOrderType),
                  _buildHistoryTile(Icons.payment_rounded, 'Payment Status',
                      order.displayPaymentStatus),
                  _buildHistoryTile(Icons.currency_rupee_rounded, 'Total Amount',
                      _formatCurrency(order.totalAmount)),
                  if (order.remarks != null && order.remarks!.isNotEmpty)
                    _buildHistoryTile(
                        Icons.notes_rounded, 'Remarks', order.remarks!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown Popup Menu matching ERP screenshot:
  /// History, View, Edit, Invoice, Print Invoice, Delete
  /// (Explicitly without Upload QR & Raise Ticket)
  Widget _buildPopupMenu(OrderItemModel order) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Color(0xFF94A3B8),
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 6,
      offset: const Offset(0, 30),
      onSelected: (value) {
        switch (value) {
          case 'history':
            _showOrderHistorySheet(order);
            break;
          case 'view':
            Get.to(() => SalesDetailScreen(
                  orderId: order.id,
                  initialOrder: order,
                ));
            break;
          case 'edit':
            Get.to(() => SalesScreen(editOrderId: order.id));
            break;
          case 'invoice':
            _openInvoicePdf(order);
            break;
          case 'print':
            _downloadOrPrintInvoice(order);
            break;
          case 'delete':
            _confirmDeleteOrder(order);
            break;
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          'history',
          Icons.history_rounded,
          'History',
          const Color(0xFF334155),
        ),
        _buildPopupMenuItem(
          'view',
          Icons.visibility_outlined,
          'View',
          const Color(0xFF334155),
        ),
        _buildPopupMenuItem(
          'edit',
          Icons.edit_outlined,
          'Edit',
          const Color(0xFF334155),
        ),
        _buildPopupMenuItem(
          'invoice',
          Icons.description_outlined,
          'Invoice',
          const Color(0xFF334155),
        ),
        _buildPopupMenuItem(
          'print',
          Icons.print_outlined,
          'Print Invoice',
          const Color(0xFF334155),
        ),
        const PopupMenuDivider(height: 1),
        _buildPopupMenuItem(
          'delete',
          Icons.delete_outline_rounded,
          'Delete',
          const Color(0xFFEF4444),
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    IconData icon,
    String label,
    Color color, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isDestructive ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showBillActionSheet(OrderItemModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Bill #${order.orderNumber}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  _buildActionTile(
                    icon: Icons.history_rounded,
                    label: 'History',
                    color: const Color(0xFF0F172A),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showOrderHistorySheet(order);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    color: const Color(0xFF0F172A),
                    onTap: () {
                      Navigator.pop(ctx);
                      Get.to(() => SalesDetailScreen(
                            orderId: order.id,
                            initialOrder: order,
                          ));
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: const Color(0xFF0F172A),
                    onTap: () {
                      Navigator.pop(ctx);
                      Get.to(() => SalesScreen(editOrderId: order.id));
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.description_outlined,
                    label: 'Invoice',
                    color: const Color(0xFF0F172A),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openInvoicePdf(order);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.print_outlined,
                    label: 'Print Invoice',
                    color: const Color(0xFF0F172A),
                    onTap: () {
                      Navigator.pop(ctx);
                      _downloadOrPrintInvoice(order);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDeleteOrder(order);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: const Icon(
          Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        selectedIndex: 2,
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
            onRefresh: () => _fetchOrders(tab: _selectedGstTab, page: 1, isRefresh: true),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderBar(),
                  const SizedBox(height: 14),

                  // GST Tab Switcher (Without GST vs With GST)
                  _buildGstTabSwitcher(),
                  const SizedBox(height: 14),

                  // Modern Search Input
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // Bills List
                  _buildBillsList(),

                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B2C),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (_isCalculatorOpen)
            Positioned(
              right: 16,
              bottom: 85,
              child: CalculatorWidget(
                onClose: () => setState(() => _isCalculatorOpen = false),
              ),
            ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.small(
      //   backgroundColor: const Color(0xFF1E293B),
      //   elevation: 3,
      //   onPressed: () => setState(() => _isCalculatorOpen = !_isCalculatorOpen),
      //   child: Icon(
      //     _isCalculatorOpen ? Icons.close_rounded : Icons.calculate_outlined,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }

  // --- 1. Top Header Bar ---
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B2C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                      Icons.receipt_long_rounded, color: Color(0xFFFF6B2C),
                      size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${_filteredOrders.length} Bills',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF6B2C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // "+ New Sale" Button
        ElevatedButton.icon(
          onPressed: () => Get.to(() => const SalesScreen()),
          icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
          label: Text(
            'New Sale',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B2C),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          ),
        ),
      ],
    );
  }

  // --- 2. Redesigned GST Tab Switcher ---
  Widget _buildGstTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGstTabItem(
              title: 'Without GST Bills',
              isSelected: _selectedGstTab == 'Without GST Bills',
              count: _withoutGstState.isLoaded ? _withoutGstState.total : null,
              onTap: () => _switchGstTab('Without GST Bills'),
            ),
          ),
          Expanded(
            child: _buildGstTabItem(
              title: 'With GST Bills',
              isSelected: _selectedGstTab == 'With GST Bills',
              count: _withGstState.isLoaded ? _withGstState.total : null,
              onTap: () => _switchGstTab('With GST Bills'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGstTabItem({
    required String title,
    required bool isSelected,
    int? count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF0F172A) : const Color(
                    0xFF64748B),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF6B2C) : const Color(
                      0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 3. Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: 'Search bill no, customer, staff...',
          hintStyle: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
              Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- 4. Bills List View ---
  Widget _buildBillsList() {
    if (_isLoading) {
      return Column(
        children: List.generate(4, (i) => _buildSkeletonCard()),
      );
    }

    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444),
                size: 36),
            const SizedBox(height: 10),
            Text(
              'Failed to load bills',
              style: TextStyle(fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5.sp, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _fetchOrders(tab: _selectedGstTab, page: 1, isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B2C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final orders = _filteredOrders;

    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                  Icons.receipt_outlined, color: Color(0xFFFF6B2C), size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'No bills found',
              style: TextStyle(fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'No bills available in $_selectedGstTab',
              style: TextStyle(
                  fontSize: 12.5.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: orders.map((order) => _buildModernOrderCard(order)).toList(),
    );
  }

  // --- 5. Redesigned Premium Bill Card ---
  Widget _buildModernOrderCard(OrderItemModel order) {
    final isPaid = order.isPaid;
    final isGst = _selectedGstTab == 'With GST Bills';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Get.to(() =>
                SalesDetailScreen(orderId: order.id, initialOrder: order));
          },
          onLongPress: () => _showBillActionSheet(order),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isGst
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: isGst
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFFF6B2C),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(order.effectiveDate),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Amount + Action Menu
                    Row(
                      children: [
                        Text(
                          _formatCurrency(order.totalAmount),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildPopupMenu(order),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Customer & Staff details
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 15,
                              color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.customerName.isNotEmpty
                                  ? order.customerName
                                  : 'Walk-in Customer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.effectiveStaffName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 14,
                              color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            order.effectiveStaffName,
                            style: TextStyle(fontSize: 12.sp,
                                color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 13,
                              color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            order.displayOrderType,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badges
                    Row(
                      children: [
                        // Quick Invoice PDF Button
                        InkWell(
                          onTap: () => _openInvoicePdf(order),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFFED7AA),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.picture_as_pdf_outlined,
                                    size: 12, color: Color(0xFFFF6B2C)),
                                const SizedBox(width: 3),
                                Text(
                                  'Invoice',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFF6B2C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // GST tag
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isGst
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isGst
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            isGst ? 'GST' : 'Non-GST',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isGst
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),

                        // Payment Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isPaid
                                  ? const Color(0xFFBBF7D0)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : 'UNPAID',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: isPaid
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEF4444),
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
        ),
      ),
    );
  }

  // --- Skeleton Loading Card ---
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 90,
                          height: 12,
                          color: const Color(0xFFE2E8F0)),
                      const SizedBox(height: 6),
                      Container(width: 60,
                          height: 10,
                          color: const Color(0xFFE2E8F0)),
                    ],
                  ),
                ],
              ),
              Container(width: 70, height: 16, color: const Color(0xFFE2E8F0)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 110, height: 10, color: const Color(0xFFE2E8F0)),
              Container(width: 50, height: 18, color: const Color(0xFFE2E8F0)),
            ],
          ),
        ],
      ),
    );
  }
}