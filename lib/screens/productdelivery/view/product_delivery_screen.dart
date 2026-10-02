import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';

/// Model representing a Product Delivery order item
class DeliveryOrder {
  final String orderNumber;
  final String date;
  final DateTime dateTime;
  final String customer;
  final double totalAmount;
  final String deliveredBy;
  final String status; // 'Pending', 'Partially Delivered', 'Delivered'
  final Color themeColor;

  const DeliveryOrder({
    required this.orderNumber,
    required this.date,
    required this.dateTime,
    required this.customer,
    required this.totalAmount,
    required this.deliveredBy,
    required this.status,
    required this.themeColor,
  });

  DeliveryOrder copyWith({
    String? status,
  }) {
    return DeliveryOrder(
      orderNumber: orderNumber,
      date: date,
      dateTime: dateTime,
      customer: customer,
      totalAmount: totalAmount,
      deliveredBy: deliveredBy,
      status: status ?? this.status,
      themeColor: themeColor,
    );
  }
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

/// Helper to format date
String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString();
  return '$d-$m-$y';
}

class ProductDeliveryScreen extends StatefulWidget {
  const ProductDeliveryScreen({super.key});

  @override
  State<ProductDeliveryScreen> createState() => _ProductDeliveryScreenState();
}

class _ProductDeliveryScreenState extends State<ProductDeliveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  String _selectedStatus = 'All Statuses';
  DateTime? _fromDate;
  DateTime? _toDate;

  late List<DeliveryOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = [
      DeliveryOrder(
        orderNumber: 'INV-2026-0149',
        date: '28-Sep-2026',
        dateTime: DateTime(2026, 9, 28),
        customer: 'KETANKUMAR SURESHCHANDRA LAKDAWALA',
        totalAmount: 24999.00,
        deliveredBy: 'Main Branch',
        status: 'Pending',
        themeColor: const Color(0xFFEA580C),
      ),
      DeliveryOrder(
        orderNumber: 'INV-2026-0144',
        date: '24-Sep-2026',
        dateTime: DateTime(2026, 9, 24),
        customer: 'KETANKUMAR SURESHCHANDRA LAKDAWALA',
        totalAmount: 200.00,
        deliveredBy: 'Main Branch',
        status: 'Pending',
        themeColor: const Color(0xFF2563EB),
      ),
      DeliveryOrder(
        orderNumber: 'SI/HO/127',
        date: '08-Sep-2026',
        dateTime: DateTime(2026, 9, 8),
        customer: 'Default Customer',
        totalAmount: 11998.00,
        deliveredBy: 'Main Branch',
        status: 'Partially Delivered',
        themeColor: const Color(0xFF16A34A),
      ),
      DeliveryOrder(
        orderNumber: 'SI/HO/86',
        date: '13-Aug-2026',
        dateTime: DateTime(2026, 8, 13),
        customer: 'Default Customer',
        totalAmount: 200000.00,
        deliveredBy: 'Main Branch',
        status: 'Delivered',
        themeColor: const Color(0xFFE11D48),
      ),
      DeliveryOrder(
        orderNumber: 'SI/HO/82',
        date: '13-Aug-2026',
        dateTime: DateTime(2026, 8, 13),
        customer: 'Default Customer',
        totalAmount: 3275.00,
        deliveredBy: 'Main Branch',
        status: 'Pending',
        themeColor: const Color(0xFF9333EA),
      ),
      DeliveryOrder(
        orderNumber: 'SI/HO/81',
        date: '13-Aug-2026',
        dateTime: DateTime(2026, 8, 13),
        customer: 'Bhavik',
        totalAmount: 200000.00,
        deliveredBy: 'Main Branch',
        status: 'Pending',
        themeColor: const Color(0xFF0D9488),
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DeliveryOrder> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();
    return _orders.where((order) {
      final matchesQuery = query.isEmpty ||
          order.orderNumber.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query) ||
          order.deliveredBy.toLowerCase().contains(query) ||
          order.status.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == 'All Statuses' ||
          order.status.toLowerCase() == _selectedStatus.toLowerCase();

      final matchesFrom = _fromDate == null ||
          order.dateTime.isAfter(_fromDate!.subtract(const Duration(days: 1)));

      final matchesTo = _toDate == null ||
          order.dateTime.isBefore(_toDate!.add(const Duration(days: 1)));

      return matchesQuery && matchesStatus && matchesFrom && matchesTo;
    }).toList();
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _showOrderDetails(DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
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
              _buildDetailRow('Order Number', order.orderNumber),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildDetailRow('Date', order.date),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildDetailRow('Customer', order.customer),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildDetailRow('Total Amount', _formatCurrency(order.totalAmount)),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildDetailRow('Delivered By', order.deliveredBy),
              const Divider(color: Color(0xFFF1F5F9), height: 16),
              _buildDetailRow('Status', order.status),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B2C)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPdfDialog(order);
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined,
                          color: Color(0xFFFF6B2C), size: 18),
                      label: Text(
                        'View PDF',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B2C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B2C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showStatusUpdateDialog(order);
                      },
                      child: Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPdfDialog(DeliveryOrder order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined,
                            color: Color(0xFFFF6B2C), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery PDF',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
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
                  'Order Invoice #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customer: ${order.customer}\nDate: ${order.date}\nTotal: ${_formatCurrency(order.totalAmount)}\nStatus: ${order.status}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.snackbar(
                          'PDF Downloaded',
                          'PDF for order ${order.orderNumber} downloaded successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF0F172A),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(12),
                          duration: const Duration(seconds: 2),
                        );
                      },
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                        'Download',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  void _showStatusUpdateDialog(DeliveryOrder order) {
    String tempStatus = order.status;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Delivery Status',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Order: ${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...['Pending', 'Partially Delivered', 'Delivered']
                        .map((status) {
                      return RadioListTile<String>(
                        title: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        value: status,
                        groupValue: tempStatus,
                        activeColor: const Color(0xFFFF6B2C),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => tempStatus = val);
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B2C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              final idx = _orders.indexWhere(
                                  (o) => o.orderNumber == order.orderNumber);
                              if (idx != -1) {
                                _orders[idx] =
                                    _orders[idx].copyWith(status: tempStatus);
                              }
                            });
                            Navigator.pop(ctx);
                            Get.snackbar(
                              'Status Updated',
                              'Order ${order.orderNumber} status changed to $tempStatus',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF0F172A),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(12),
                            );
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildFilterCard(),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildDeliveryCard(filtered[index]);
                    },
                  ),
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
        heroTag: 'product_delivery_fab',
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

  // --- Top Header: Back Arrow, Title, Subtitle ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products Delivery',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'View and manage delivery status for all sales orders',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Filter Card: Search Order Number + Status + From Date + To Date ---
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Order Number Input
          Container(
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
                hintText: 'Search order number',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filters Row: Status | From | To
          Row(
            children: [
              // Status Dropdown
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            'All Statuses',
                            'Pending',
                            'Partially Delivered',
                            'Delivered'
                          ].map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(
                                s,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStatus = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // From Date Picker
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickFromDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF64748B),
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _fromDate != null
                                    ? _formatDate(_fromDate!)
                                    : 'dd-mm-yyyy',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _fromDate != null
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // To Date Picker
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickToDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF64748B),
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _toDate != null
                                    ? _formatDate(_toDate!)
                                    : 'dd-mm-yyyy',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _toDate != null
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Delivery Card matching reference screenshot ---
  Widget _buildDeliveryCard(DeliveryOrder order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Package Icon + Order Number + Pipe + Date + Status Badge + Chevron Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Colored Package Icon Container
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: order.themeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: order.themeColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Order Number + Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (order.status == 'Partially Delivered') ...[
                            Text(
                              order.orderNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    order.date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.orderNumber,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '|',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFFCBD5E1),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    order.date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Status Badge Pill
                    _buildStatusBadge(order.status),

                    const SizedBox(width: 4),

                    // Chevron Right
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Middle Row: Customer Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            order.customer,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row: Total Amount | Vertical Divider | Delivered By | PDF Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Total Amount
                    Row(
                      children: [
                        const Icon(
                          Icons.currency_rupee_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _formatCurrency(order.totalAmount),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Vertical Divider
                    Container(
                      height: 28,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),

                    const SizedBox(width: 14),

                    // Delivered By
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivered By',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  order.deliveredBy,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PDF Button
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Color(0xFFFED7AA)),
                      ),
                      child: InkWell(
                        onTap: () => _showPdfDialog(order),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_outlined,
                                color: Color(0xFFFF6B2C),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PDF',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFF6B2C),
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
            ),
          ),
        ),
      ),
    );
  }

  // --- Status Badge matching pill style in screenshot ---
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'partially delivered':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF9333EA);
        break;
      case 'delivered':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              'No delivery orders match your filters',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search query, status, or date range.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
