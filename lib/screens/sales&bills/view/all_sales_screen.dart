import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
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

  // Initial dummy bills matching the screenshot
  final List<SalesBillItem> _allBills = [
    SalesBillItem(
      orderNo: 'SI/HO/148',
      date: DateTime(2026, 10, 2),
      customer: 'Rahul Sharma',
      staff: 'Amrita Patel',
      orderType: 'Self Pickup',
      orderStatus: 'Pending',
      paymentStatus: 'Unpaid',
      amount: 2500.00,
      hasGst: false,
      iconBgColor: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
    ),
    SalesBillItem(
      orderNo: 'SI/HO/147',
      date: DateTime(2026, 9, 29),
      customer: 'Priya Patel',
      staff: 'Neha Shah',
      orderType: 'Self Pickup',
      orderStatus: 'Paid',
      paymentStatus: 'Paid',
      amount: 1850.00,
      hasGst: false,
      iconBgColor: const Color(0xFFF0FDF4),
      iconColor: const Color(0xFF16A34A),
    ),
    SalesBillItem(
      orderNo: 'SI/HO/146',
      date: DateTime(2026, 9, 28),
      customer: 'Amit Mehta',
      staff: 'Vikram Chauhan',
      orderType: 'Home Delivery',
      orderStatus: 'Pending',
      paymentStatus: 'Unpaid',
      amount: 2700.00,
      hasGst: false,
      iconBgColor: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
    ),
    SalesBillItem(
      orderNo: 'SI/HO/145',
      date: DateTime(2026, 9, 25),
      customer: 'Neha Shah',
      staff: 'Rohan Desai',
      orderType: 'Self Pickup',
      orderStatus: 'Paid',
      paymentStatus: 'Paid',
      amount: 4990.00,
      hasGst: false,
      iconBgColor: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF2563EB),
    ),
    SalesBillItem(
      orderNo: 'SI/HO/144',
      date: DateTime(2026, 9, 24),
      customer: 'Rohan Desai',
      staff: 'Priya Patel',
      orderType: 'Home Delivery',
      orderStatus: 'Delivered',
      paymentStatus: 'Paid',
      amount: 6750.00,
      hasGst: false,
      iconBgColor: const Color(0xFFFAF5FF),
      iconColor: const Color(0xFF9333EA),
    ),
    SalesBillItem(
      orderNo: 'SI/HO/143',
      date: DateTime(2026, 9, 20),
      customer: 'Suresh Parmar',
      staff: 'Amrita Patel',
      orderType: 'Self Pickup',
      orderStatus: 'Paid',
      paymentStatus: 'Paid',
      amount: 13860.00,
      hasGst: false,
      iconBgColor: const Color(0xFFF0FDF4),
      iconColor: const Color(0xFF16A34A),
    ),
    // Sample items for With GST
    SalesBillItem(
      orderNo: 'SI/GST/201',
      date: DateTime(2026, 9, 30),
      customer: 'KETANKUMAR SURESHCHANDRA',
      staff: 'Amrita Patel',
      orderType: 'Self Pickup',
      orderStatus: 'Paid',
      paymentStatus: 'Paid',
      amount: 15400.00,
      hasGst: true,
      iconBgColor: const Color(0xFFF0FDF4),
      iconColor: const Color(0xFF16A34A),
    ),
    SalesBillItem(
      orderNo: 'SI/GST/200',
      date: DateTime(2026, 9, 27),
      customer: 'Sneha Makvana',
      staff: 'Neha Shah',
      orderType: 'Home Delivery',
      orderStatus: 'Pending',
      paymentStatus: 'Unpaid',
      amount: 8200.00,
      hasGst: true,
      iconBgColor: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
    ),
    SalesBillItem(
      orderNo: 'SI/GST/199',
      date: DateTime(2026, 9, 23),
      customer: 'Vatsal Patel',
      staff: 'Vikram Chauhan',
      orderType: 'Courier Delivery',
      orderStatus: 'Paid',
      paymentStatus: 'Paid',
      amount: 11250.00,
      hasGst: true,
      iconBgColor: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF2563EB),
    ),
  ];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered bills calculation
  List<SalesBillItem> get _filteredBills {
    final query = _searchController.text.trim().toLowerCase();
    final isGstSelected = _selectedGstTab == 'With GST Bills';

    var list = _allBills.where((b) {
      // GST Filter
      if (b.hasGst != isGstSelected) return false;

      // Search Query
      if (query.isNotEmpty) {
        final matchesNo = b.orderNo.toLowerCase().contains(query);
        final matchesCust = b.customer.toLowerCase().contains(query);
        final matchesStaff = b.staff.toLowerCase().contains(query);
        if (!matchesNo && !matchesCust && !matchesStaff) return false;
      }

      // Month Filter
      if (_selectedMonth != 'All Months') {
        final monthIdx = _monthsList.indexOf(_selectedMonth);
        if (b.date.month != monthIdx) return false;
      }

      // Year Filter
      if (_selectedYear != 'All Years') {
        if (b.date.year.toString() != _selectedYear) return false;
      }

      // Staff Filter
      if (_selectedStaff != 'All Staff') {
        if (b.staff != _selectedStaff) return false;
      }

      // Order Type Filter
      if (_selectedOrderType != 'All Order Types') {
        if (b.orderType != _selectedOrderType) return false;
      }

      // Status Filter
      if (_selectedStatus != 'All Statuses') {
        if (b.orderStatus != _selectedStatus && b.paymentStatus != _selectedStatus) {
          return false;
        }
      }

      // Specific Date Filter
      if (_selectedDate != null) {
        if (b.date.year != _selectedDate!.year ||
            b.date.month != _selectedDate!.month ||
            b.date.day != _selectedDate!.day) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    switch (_selectedSort) {
      case 'Oldest First':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest Amount':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest Amount':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'Latest First':
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return list;
  }

  // Statistics
  double get _totalPending {
    return _filteredBills
        .where((b) => b.paymentStatus == 'Unpaid')
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  double get _totalPaid {
    return _filteredBills
        .where((b) => b.paymentStatus == 'Paid')
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  double get _grandTotal => _totalPending + _totalPaid;

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
  void _showBillActionSheet(SalesBillItem bill) {
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
                      'Order Options • ${bill.orderNo}',
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
                    'Order ${bill.orderNo}',
                    'Viewing bill for ${bill.customer}',
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
                    _allBills.removeWhere((b) => b.orderNo == bill.orderNo);
                  });
                  Get.snackbar(
                    'Deleted',
                    'Bill ${bill.orderNo} removed successfully',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBar(),
                const SizedBox(height: 16),
                _buildGstTabSwitcher(),
                const SizedBox(height: 14),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildFilterDropdownsGrid(),
                const SizedBox(height: 14),
                _buildSummaryAndExportRow(),
                const SizedBox(height: 16),
                _buildBillsList(),
              ],
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'all_sales_fab',
        onPressed: () {
          setState(() {
            _isCalculatorOpen = !_isCalculatorOpen;
          });
        },
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.calculate_outlined,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  // --- 1. Header Bar: Back Arrow, Title, "All Drafts", "Import", "+ New Bill" ---
  Widget _buildHeaderBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
            size: 24,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'All Sales & Bills',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Action Buttons: "All Drafts", "Import", "+ New Bill"
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "All Drafts" Navy button
                Material(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _showDraftsDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
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
                              fontSize: 14.sp,
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

                // "Import" Amber/Orange button
                Material(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _showImportDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
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
                              fontSize: 14.sp,
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

                // "+ New Bill" Vibrant Orange button
                Material(
                  color: const Color(0xFFFF6B2C),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Get.to(() => const SalesScreen()),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'New Bill',
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
          ),
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
            amount: _formatCurrency(_totalPending),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            textColor: const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),

          // Total Paid
          _buildStatCard(
            label: 'Total Paid',
            amount: _formatCurrency(_totalPaid),
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            textColor: const Color(0xFF16A34A),
          ),
          const SizedBox(width: 8),

          // Grand Total
          _buildStatCard(
            label: 'Total',
            amount: _formatCurrency(_grandTotal),
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
    final bills = _filteredBills;

    if (bills.isEmpty) {
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
      children: bills.map((bill) {
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
              // Left Circular/Rounded Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bill.iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: bill.iconColor,
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
                      bill.orderNo,
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
                            _formatDate(bill.date),
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
                            bill.customer,
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

              // Status Badges (Pending/Paid, Unpaid/Paid)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStatusBadge(bill.orderStatus),
                  const SizedBox(height: 4),
                  _buildPaymentBadge(bill.paymentStatus),
                ],
              ),
              const SizedBox(width: 10),

              // Total, Amount, Order Type, Staff Name
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
                      _formatCurrency(bill.amount),
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
                            bill.orderType,
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
                            bill.staff,
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
                  onPressed: () => _showBillActionSheet(bill),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
      width: 64,
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
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    final isPaid = status == 'Paid';
    return Container(
      width: 64,
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
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        ),
      ),
    );
  }
}
