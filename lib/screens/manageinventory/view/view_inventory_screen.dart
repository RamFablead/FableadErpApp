import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';

/// Model representing an Inventory Transaction record
class InventoryTransactionRecord {
  final String id;
  final String type; // 'Purchase', 'Transfer In', 'Transfer Out', 'Adjustment In', 'Adjustment Out'
  final String currentStock;
  final String quantity;
  final String date;
  final String createdBy;
  final String? referenceId;
  final String? remarks;

  const InventoryTransactionRecord({
    required this.id,
    required this.type,
    required this.currentStock,
    required this.quantity,
    required this.date,
    required this.createdBy,
    this.referenceId,
    this.remarks,
  });
}

/// View Inventory Screen under lib/screens/manageinventory/view/view_inventory_screen.dart
class ViewInventoryScreen extends StatefulWidget {
  final String productName;

  const ViewInventoryScreen({
    super.key,
    this.productName = 'test-disha-2',
  });

  @override
  State<ViewInventoryScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<ViewInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  late List<InventoryTransactionRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = [
      const InventoryTransactionRecord(
        id: '1',
        type: 'Purchase',
        currentStock: '10.00',
        quantity: '10.00',
        date: '12 Sep 2026, 10:30 AM',
        createdBy: 'Admin',
        referenceId: 'PO-2026-0091',
        remarks: 'Direct factory supplier purchase consignment',
      ),
      const InventoryTransactionRecord(
        id: '2',
        type: 'Transfer In',
        currentStock: '5.00',
        quantity: '5.00',
        date: '10 Sep 2026, 02:15 PM',
        createdBy: 'Vatsal',
        referenceId: 'TR-IN-4421',
        remarks: 'Stock transferred in from North Warehouse',
      ),
      const InventoryTransactionRecord(
        id: '3',
        type: 'Transfer Out',
        currentStock: '3.00',
        quantity: '3.00',
        date: '05 Sep 2026, 11:20 AM',
        createdBy: 'Akshay',
        referenceId: 'TR-OUT-8812',
        remarks: 'Internal inter-branch transfer to Outlet #3',
      ),
      const InventoryTransactionRecord(
        id: '4',
        type: 'Adjustment In',
        currentStock: '8.00',
        quantity: '8.00',
        date: '01 Sep 2026, 09:45 AM',
        createdBy: 'Salman',
        referenceId: 'ADJ-IN-109',
        remarks: 'Physical audit count discrepancy reconciliation',
      ),
      const InventoryTransactionRecord(
        id: '5',
        type: 'Adjustment Out',
        currentStock: '2.00',
        quantity: '2.00',
        date: '28 Aug 2026, 04:30 PM',
        createdBy: 'Admin',
        referenceId: 'ADJ-OUT-082',
        remarks: 'Damaged item write-off during shelf stocktaking',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryTransactionRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _records;
    return _records.where((item) {
      return item.type.toLowerCase().contains(query) ||
          item.createdBy.toLowerCase().contains(query) ||
          item.date.toLowerCase().contains(query) ||
          item.currentStock.toLowerCase().contains(query) ||
          item.quantity.toLowerCase().contains(query) ||
          (item.referenceId?.toLowerCase().contains(query) ?? false) ||
          (item.remarks?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return Icons.all_inbox_rounded;
      case 'transfer in':
        return Icons.swap_horiz_rounded;
      case 'transfer out':
        return Icons.swap_horiz_rounded;
      case 'adjustment in':
        return Icons.add_rounded;
      case 'adjustment out':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return const Color(0xFFFF7A1A);
      case 'transfer in':
        return const Color(0xFF2563EB);
      case 'transfer out':
        return const Color(0xFFEF4444);
      case 'adjustment in':
        return const Color(0xFF16A34A);
      case 'adjustment out':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFFF6B2C);
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return const Color(0xFFFFF3E8);
      case 'transfer in':
        return const Color(0xFFEFF6FF);
      case 'transfer out':
        return const Color(0xFFFEF2F2);
      case 'adjustment in':
        return const Color(0xFFF0FDF4);
      case 'adjustment out':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFFFF7ED);
    }
  }

  void _showTransactionDetailsModal(InventoryTransactionRecord item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  _buildDetailRow('Product', widget.productName),
                  const SizedBox(height: 10),
                  _buildDetailRow('Type', item.type, isBadge: true),
                  const SizedBox(height: 10),
                  _buildDetailRow('Quantity', item.quantity),
                  const SizedBox(height: 10),
                  _buildDetailRow('Current Stock', item.currentStock),
                  const SizedBox(height: 10),
                  _buildDetailRow('Date', item.date),
                  const SizedBox(height: 10),
                  _buildDetailRow('Create By', item.createdBy),
                  if (item.referenceId != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('Reference No', item.referenceId!),
                  ],
                  if (item.remarks != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('Remarks', item.remarks!),
                  ],
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Close',
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBadge = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getTypeBgColor(value),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _getTypeColor(value),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRecords;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCalculatorOpen = !_isCalculatorOpen;
          });
        },
        backgroundColor: const Color(0xFFFF6B2C),
        elevation: 4,
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding > 0 ? topPadding + 12 : 20,
              left: 16,
              right: 16,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Back button + Title & Subtitle
                _buildHeader(),

                const SizedBox(height: 16),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 16),

                // List of Transaction Cards
                if (list.isEmpty)
                  _buildEmptyState()
                else
                  ...list.map((item) => _buildTransactionCard(item)),
              ],
            ),
          ),

          // Floating Calculator overlay
          if (_isCalculatorOpen)
            CalculatorWidget(
              onClose: () {
                setState(() {
                  _isCalculatorOpen = false;
                });
              },
            ),
        ],
      ),
    );
  }

  // --- Header: Back Arrow + View Inventory & Subtitle ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          tooltip: 'Back',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'View Inventory',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.productName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Search Bar matching reference ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  // --- Transaction Card matching reference ---
  Widget _buildTransactionCard(InventoryTransactionRecord item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showTransactionDetailsModal(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon Container + Type + Current Stock + Quantity + Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getTypeBgColor(item.type),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          _getTypeIcon(item.type),
                          color: _getTypeColor(item.type),
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Type
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.type,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Current Stock
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Stock',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.currentStock,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Quantity
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.quantity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Chevron Right
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bottom Row: Date + Create By
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Date
                    Expanded(
                      flex: 6,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.date,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Create By
                    Expanded(
                      flex: 4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create By',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.createdBy,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 10),
            Text(
              'No inventory logs found.',
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
