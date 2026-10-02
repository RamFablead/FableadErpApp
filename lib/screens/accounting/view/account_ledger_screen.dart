import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';

/// Data model for an Account Ledger Item (Paid or Pending)
class LedgerBillItem {
  final String billNo;
  final DateTime billDate;
  final String itemsDescription;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final bool isPaid;
  final Color iconBgColor;
  final Color iconColor;
  final String vendorName;

  const LedgerBillItem({
    required this.billNo,
    required this.billDate,
    required this.itemsDescription,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
    this.paymentDate,
    this.paymentMethod,
    required this.isPaid,
    required this.iconBgColor,
    required this.iconColor,
    required this.vendorName,
  });
}

/// Helper to format currency
String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final whole = parts[0];
  final dec = parts[1];
  final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
  final formatted = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$formatted.$dec';
}

/// Helper to format dates
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

class AccountLedgerScreen extends StatefulWidget {
  const AccountLedgerScreen({super.key});

  @override
  State<AccountLedgerScreen> createState() => _AccountLedgerScreenState();
}

class _AccountLedgerScreenState extends State<AccountLedgerScreen> {
  // Filters
  String _selectedType = 'Vendor';
  String _selectedVendor = 'All Vendors';
  String _selectedMonth = 'All Months';
  String _selectedYear = '2026';

  // Calculator Overlay
  bool _isCalculatorOpen = false;

  final List<String> _typeList = ['Vendor', 'Customer', 'Staff', 'All'];

  final List<String> _vendorList = [
    'All Vendors',
    'Apex Supplies',
    'Global Traders',
    'Prime Logistics',
    'ABC Stationers',
    'TechCorp IT',
  ];

  final List<String> _monthsList = [
    'All Months',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> _yearsList = ['2027', '2026', '2025', '2024'];

  // All Ledger Items matching the screenshot
  final List<LedgerBillItem> _allLedgerItems = [
    // --- Paid Payments ---
    LedgerBillItem(
      billNo: 'BILL-001',
      billDate: DateTime(2026, 10, 5),
      itemsDescription: 'Stationery, Cleaning Items',
      totalAmount: 12500.00,
      paidAmount: 12500.00,
      remainingAmount: 0.00,
      paymentDate: DateTime(2026, 10, 5),
      paymentMethod: 'Bank Transfer',
      isPaid: true,
      iconBgColor: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
      vendorName: 'ABC Stationers',
    ),
    LedgerBillItem(
      billNo: 'BILL-002',
      billDate: DateTime(2026, 9, 18),
      itemsDescription: 'Office Supplies',
      totalAmount: 8750.00,
      paidAmount: 8750.00,
      remainingAmount: 0.00,
      paymentDate: DateTime(2026, 9, 18),
      paymentMethod: 'Cash',
      isPaid: true,
      iconBgColor: const Color(0xFFEEF2FF),
      iconColor: const Color(0xFF6366F1),
      vendorName: 'Global Traders',
    ),
    LedgerBillItem(
      billNo: 'BILL-003',
      billDate: DateTime(2026, 9, 2),
      itemsDescription: 'IT Equipment',
      totalAmount: 17200.00,
      paidAmount: 17200.00,
      remainingAmount: 0.00,
      paymentDate: DateTime(2026, 9, 2),
      paymentMethod: 'UPI',
      isPaid: true,
      iconBgColor: const Color(0xFFF0FDF4),
      iconColor: const Color(0xFF16A34A),
      vendorName: 'TechCorp IT',
    ),

    // --- Pending Payments ---
    LedgerBillItem(
      billNo: 'BILL-004',
      billDate: DateTime(2026, 10, 10),
      itemsDescription: 'Raw Materials',
      totalAmount: 9800.00,
      paidAmount: 0.00,
      remainingAmount: 9800.00,
      isPaid: false,
      iconBgColor: const Color(0xFFFEF2F2),
      iconColor: const Color(0xFFEF4444),
      vendorName: 'Apex Supplies',
    ),
    LedgerBillItem(
      billNo: 'BILL-005',
      billDate: DateTime(2026, 9, 22),
      itemsDescription: 'Packaging Items',
      totalAmount: 6500.00,
      paidAmount: 2300.00,
      remainingAmount: 4200.00,
      isPaid: false,
      iconBgColor: const Color(0xFFFEFCE8),
      iconColor: const Color(0xFFCA8A04),
      vendorName: 'Prime Logistics',
    ),
    LedgerBillItem(
      billNo: 'BILL-006',
      billDate: DateTime(2026, 9, 15),
      itemsDescription: 'Maintenance',
      totalAmount: 7300.00,
      paidAmount: 0.00,
      remainingAmount: 7300.00,
      isPaid: false,
      iconBgColor: const Color(0xFFFAF5FF),
      iconColor: const Color(0xFF9333EA),
      vendorName: 'Global Traders',
    ),
  ];

  // Filtering
  List<LedgerBillItem> get _filteredPaidItems {
    return _filterList(_allLedgerItems.where((i) => i.isPaid).toList());
  }

  List<LedgerBillItem> get _filteredPendingItems {
    return _filterList(_allLedgerItems.where((i) => !i.isPaid).toList());
  }

  List<LedgerBillItem> _filterList(List<LedgerBillItem> list) {
    return list.where((item) {
      if (_selectedVendor != 'All Vendors' && item.vendorName != _selectedVendor) {
        return false;
      }
      if (_selectedYear != 'All Years' && item.billDate.year.toString() != _selectedYear) {
        return false;
      }
      if (_selectedMonth != 'All Months') {
        final monthIdx = _monthsList.indexOf(_selectedMonth);
        if (item.billDate.month != monthIdx) return false;
      }
      return true;
    }).toList();
  }

  double get _totalPaidAmount {
    return _filteredPaidItems.fold(0.0, (sum, i) => sum + i.paidAmount);
  }

  double get _totalPendingAmount {
    return _filteredPendingItems.fold(0.0, (sum, i) => sum + i.remainingAmount);
  }

  // --- Show Bill Action Bottom Sheet ---
  void _showItemOptions(LedgerBillItem item) {
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
                      'Ledger Options • ${item.billNo}',
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
                label: 'View Ledger Details',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    item.billNo,
                    'Vendor: ${item.vendorName} • Items: ${item.itemsDescription}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF0F172A),
                    colorText: Colors.white,
                  );
                },
              ),
              if (!item.isPaid)
                _buildActionSheetOption(
                  icon: Icons.payments_outlined,
                  label: 'Pay Now / Record Payment',
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.snackbar(
                      'Payment',
                      'Recording payment for ${item.billNo}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF22C55E),
                      colorText: Colors.white,
                    );
                  },
                ),
              _buildActionSheetOption(
                icon: Icons.receipt_long_outlined,
                label: 'Download Voucher',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Voucher Downloaded',
                    'Voucher for ${item.billNo} saved to device',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF059669),
                    colorText: Colors.white,
                  );
                },
              ),
              _buildActionSheetOption(
                icon: Icons.print_outlined,
                label: 'Print Voucher',
                onTap: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Printing',
                    'Queued ${item.billNo} voucher to printer',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF0F172A),
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
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Account Ledger',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Accounting'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFiltersSection(),
                const SizedBox(height: 14),
                _buildExportButtonsRow(),
                const SizedBox(height: 20),
                _buildPaidPaymentsSection(),
                const SizedBox(height: 24),
                _buildPendingPaymentsSection(),
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
        heroTag: 'account_ledger_fab',
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



  // --- 2. Filter Dropdowns Section (Type, Vendor Name, Month, Year) ---
  Widget _buildFiltersSection() {
    return Column(
      children: [
        // Row 1: Type | Vendor Name
        Row(
          children: [
            Expanded(
              child: _buildLabeledFilter(
                label: 'Type',
                icon: Icons.local_offer_outlined,
                value: _selectedType,
                items: _typeList,
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLabeledFilter(
                label: 'Vendor Name',
                icon: Icons.storefront_outlined,
                value: _selectedVendor,
                items: _vendorList,
                onChanged: (val) => setState(() => _selectedVendor = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Month | Year
        Row(
          children: [
            Expanded(
              child: _buildLabeledFilter(
                label: 'Month',
                icon: Icons.calendar_month_outlined,
                value: _selectedMonth,
                items: _monthsList,
                onChanged: (val) => setState(() => _selectedMonth = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLabeledFilter(
                label: 'Year',
                icon: Icons.calendar_today_outlined,
                value: _selectedYear,
                items: _yearsList,
                onChanged: (val) => setState(() => _selectedYear = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabeledFilter({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
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
        ),
      ],
    );
  }

  // --- 3. Export Buttons: PDF and Excel ---
  Widget _buildExportButtonsRow() {
    return Row(
      children: [
        // PDF Red Button
        Expanded(
          child: Material(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  'PDF Downloaded',
                  'Account Ledger PDF generated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFDC2626),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Excel Green Button
        Expanded(
          child: Material(
            color: const Color(0xFF059669),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  'Excel Exported',
                  'Account Ledger spreadsheet exported successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF059669),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.table_chart_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Excel',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. Paid Payments Section ---
  Widget _buildPaidPaymentsSection() {
    final paidItems = _filteredPaidItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Paid Payments',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Soft Green "Total Paid: ₹38,450.00" Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Text(
                'Total Paid: ${_formatCurrency(_totalPaidAmount)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Paid Items List
        if (paidItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'No paid payments found',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          )
        else
          ...paidItems.map((item) => _buildLedgerCard(item)),
      ],
    );
  }

  // --- 5. Pending Payments Section ---
  Widget _buildPendingPaymentsSection() {
    final pendingItems = _filteredPendingItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              color: Color(0xFFEA580C),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pending Payments',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Soft Peach "Total Pending: ₹21,300.00" Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Text(
                'Total Pending: ${_formatCurrency(_totalPendingAmount)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEA580C),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Pending Items List
        if (pendingItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'No pending payments found',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          )
        else
          ...pendingItems.map((item) => _buildLedgerCard(item)),
      ],
    );
  }

  // --- 6. Ledger Item Card ---
  Widget _buildLedgerCard(LedgerBillItem item) {
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
          // Left Tinted Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_outlined,
              color: item.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),

          // Bill No, Date, Items Description
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.billNo,
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
                        _formatDate(item.billDate),
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
                      Icons.inventory_2_outlined,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.itemsDescription,
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

          // Column 2: Total Amount & Paid/Remaining Amount
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _formatCurrency(item.totalAmount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.isPaid ? 'Paid Amount' : 'Remaining Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _formatCurrency(
                      item.isPaid ? item.paidAmount : item.remainingAmount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: item.isPaid
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
          ),

          // Column 3: Payment Date & Payment Method (if Paid)
          if (item.isPaid && item.paymentDate != null) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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
                          _formatDate(item.paymentDate!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.payment_outlined,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.paymentMethod ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(width: 6),

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
              onPressed: () => _showItemOptions(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
