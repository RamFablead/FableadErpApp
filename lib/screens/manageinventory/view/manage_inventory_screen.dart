import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../products/view/add_product_screen.dart';
import 'view_inventory_screen.dart';

/// Helper to format date as dd-mm-yyyy
String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString();
  return '$d-$m-$y';
}

/// Helper to format price with comma separators
String _formatPrice(double price) {
  final parts = price.toStringAsFixed(2).split('.');
  final whole = parts[0];
  final dec = parts[1];
  final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
  final formatted = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '$formatted.$dec';
}

/// Model representing a stock history record
class StockHistoryRecord {
  final DateTime date;
  final String actionType;
  final double quantityChanged;
  final double resultingStock;
  final String remarks;

  const StockHistoryRecord({
    required this.date,
    required this.actionType,
    required this.quantityChanged,
    required this.resultingStock,
    required this.remarks,
  });
}

/// Model representing an inventory item
class InventoryItem {
  final String id;
  final String productName;
  final double price;
  final double initialStock;
  final double currentStock;
  final String remarks;
  final List<StockHistoryRecord> history;

  const InventoryItem({
    required this.id,
    required this.productName,
    required this.price,
    required this.initialStock,
    required this.currentStock,
    required this.remarks,
    this.history = const [],
  });

  InventoryItem copyWith({
    String? productName,
    double? price,
    double? initialStock,
    double? currentStock,
    String? remarks,
    List<StockHistoryRecord>? history,
  }) {
    return InventoryItem(
      id: id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      initialStock: initialStock ?? this.initialStock,
      currentStock: currentStock ?? this.currentStock,
      remarks: remarks ?? this.remarks,
      history: history ?? this.history,
    );
  }
}

/// Manage Inventory Screen under lib/screens/manageinventory/view/manage_inventory_screen.dart
class ManageInventoryScreen extends StatefulWidget {
  const ManageInventoryScreen({super.key});

  @override
  State<ManageInventoryScreen> createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends State<ManageInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCalculatorOpen = false;

  late List<InventoryItem> _inventoryList;

  @override
  void initState() {
    super.initState();
    _inventoryList = [
      InventoryItem(
        id: '1',
        productName: 'Test-Disha-2',
        price: 500.00,
        initialStock: 0,
        currentStock: 49.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 3)),
            actionType: 'Stock Added',
            quantityChanged: 50.0,
            resultingStock: 50.0,
            remarks: 'Initial batch purchase',
          ),
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 1)),
            actionType: 'Sale Dispatch',
            quantityChanged: -1.0,
            resultingStock: 49.0,
            remarks: 'Order #ORD-1029',
          ),
        ],
      ),
      InventoryItem(
        id: '2',
        productName: 'Abc',
        price: 600.00,
        initialStock: 0,
        currentStock: 6.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 5)),
            actionType: 'Stock Added',
            quantityChanged: 10.0,
            resultingStock: 10.0,
            remarks: 'Stock replenishment',
          ),
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 2)),
            actionType: 'Sale Dispatch',
            quantityChanged: -4.0,
            resultingStock: 6.0,
            remarks: 'Order #ORD-0941',
          ),
        ],
      ),
      InventoryItem(
        id: '3',
        productName: 'SUPER WIDE LEG',
        price: 550.00,
        initialStock: 0,
        currentStock: 22.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 7)),
            actionType: 'Stock Added',
            quantityChanged: 30.0,
            resultingStock: 30.0,
            remarks: 'Factory consignment',
          ),
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 4)),
            actionType: 'Sale Dispatch',
            quantityChanged: -8.0,
            resultingStock: 22.0,
            remarks: 'Retail sale',
          ),
        ],
      ),
      InventoryItem(
        id: '4',
        productName: 'Mung 30kg EVERYDAY',
        price: 90.00,
        initialStock: 0,
        currentStock: 60.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 10)),
            actionType: 'Stock Added',
            quantityChanged: 100.0,
            resultingStock: 100.0,
            remarks: 'Direct farm purchase',
          ),
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 2)),
            actionType: 'Stock Transfer',
            quantityChanged: -40.0,
            resultingStock: 60.0,
            remarks: 'Transferred to Branch-B',
          ),
        ],
      ),
      InventoryItem(
        id: '5',
        productName: 'BAJARA-26K.G DAYMAND',
        price: 30.00,
        initialStock: 0,
        currentStock: 130.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 12)),
            actionType: 'Stock Added',
            quantityChanged: 150.0,
            resultingStock: 150.0,
            remarks: 'Bulk grain procurement',
          ),
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 6)),
            actionType: 'Sale Dispatch',
            quantityChanged: -20.0,
            resultingStock: 130.0,
            remarks: 'Wholesale order',
          ),
        ],
      ),
      InventoryItem(
        id: '6',
        productName: 'Sofa Set',
        price: 34999.00,
        initialStock: 0,
        currentStock: 90.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 15)),
            actionType: 'Stock Added',
            quantityChanged: 100.0,
            resultingStock: 100.0,
            remarks: 'Imported batch',
          ),
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 8)),
            actionType: 'Sale Dispatch',
            quantityChanged: -10.0,
            resultingStock: 90.0,
            remarks: 'Showroom delivery',
          ),
        ],
      ),
      InventoryItem(
        id: '7',
        productName: 'Abc-Test',
        price: 550.00,
        initialStock: 0,
        currentStock: 200.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 20)),
            actionType: 'Stock Added',
            quantityChanged: 200.0,
            resultingStock: 200.0,
            remarks: 'Initial inventory load',
          ),
        ],
      ),
      InventoryItem(
        id: '8',
        productName: 'Edit Testing From Desktop Application',
        price: 200.00,
        initialStock: 0,
        currentStock: 100.00,
        remarks: 'N/A',
        history: [
          StockHistoryRecord(
            date: DateTime.now().subtract(const Duration(days: 25)),
            actionType: 'Stock Added',
            quantityChanged: 100.0,
            resultingStock: 100.0,
            remarks: 'Desktop sync inventory',
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> get _filteredInventory {
    final query = _searchController.text.trim().toLowerCase();
    return _inventoryList.where((item) {
      final matchesSearch = query.isEmpty ||
          item.productName.toLowerCase().contains(query) ||
          item.price.toStringAsFixed(2).contains(query) ||
          item.remarks.toLowerCase().contains(query);

      return matchesSearch;
    }).toList();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
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
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _showViewHistoryDialog(InventoryItem item) {
    Get.to(() => ViewInventoryScreen(productName: item.productName));
  }

  void _showAddEditStockDialog(InventoryItem item) {
    final qtyController = TextEditingController();
    final remarkController = TextEditingController();
    String selectedMode = 'Add Stock';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Add / Edit Stock',
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
                    const SizedBox(height: 4),
                    Text(
                      'Product: ${item.productName}',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Current Stock: ${item.currentStock.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedMode = 'Add Stock';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedMode == 'Add Stock'
                                    ? const Color(0xFFFF6B2C).withOpacity(0.12)
                                    : const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: selectedMode == 'Add Stock'
                                      ? const Color(0xFFFF6B2C)
                                      : const Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '+ Add to Stock',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: selectedMode == 'Add Stock'
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selectedMode == 'Add Stock'
                                        ? const Color(0xFFFF6B2C)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedMode = 'Set Exact Stock';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedMode == 'Set Exact Stock'
                                    ? const Color(0xFFFF6B2C).withOpacity(0.12)
                                    : const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: selectedMode == 'Set Exact Stock'
                                      ? const Color(0xFFFF6B2C)
                                      : const Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Set Exact Stock',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: selectedMode == 'Set Exact Stock'
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selectedMode == 'Set Exact Stock'
                                        ? const Color(0xFFFF6B2C)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: selectedMode == 'Add Stock'
                            ? 'Enter quantity to add'
                            : 'Enter new total stock',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFFFF6B2C), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarkController,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Received new shipment',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFFFF6B2C), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Material(
                          color: const Color(0xFFFF6B2C),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              final parsedQty =
                                  double.tryParse(qtyController.text.trim());
                              if (parsedQty == null || parsedQty <= 0) {
                                Get.snackbar(
                                  'Invalid Input',
                                  'Please enter a valid quantity.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFEF4444),
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final double newTotal;
                              final double changedQty;
                              if (selectedMode == 'Add Stock') {
                                changedQty = parsedQty;
                                newTotal = item.currentStock + parsedQty;
                              } else {
                                changedQty = parsedQty - item.currentStock;
                                newTotal = parsedQty;
                              }

                              final newRecord = StockHistoryRecord(
                                date: DateTime.now(),
                                actionType: selectedMode == 'Add Stock'
                                    ? 'Stock Added'
                                    : 'Stock Adjusted',
                                quantityChanged: changedQty,
                                resultingStock: newTotal,
                                remarks: remarkController.text.trim().isEmpty
                                    ? 'Manual Adjustment'
                                    : remarkController.text.trim(),
                              );

                              setState(() {
                                final idx = _inventoryList
                                    .indexWhere((e) => e.id == item.id);
                                if (idx != -1) {
                                  _inventoryList[idx] = item.copyWith(
                                    currentStock: newTotal,
                                    history: [newRecord, ...item.history],
                                  );
                                }
                              });

                              Navigator.pop(ctx);
                              Get.snackbar(
                                'Success',
                                'Stock updated successfully.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF10B981),
                                colorText: Colors.white,
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 11),
                              child: Text(
                                'Update Stock',
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
              ),
            );
          },
        );
      },
    );
  }

  void _showTransferStockDialog(InventoryItem item) {
    final qtyController = TextEditingController();
    final remarksController = TextEditingController();
    String? selectedTargetBranch;

    final targetBranches = [
      'North Branch',
      'South Branch',
      'West Warehouse',
      'Downtown Outlet',
      'Central Distribution Center',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title + Red Close Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transfer Stock',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFEF4444),
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 1. Product (Read-only grey box)
                      Text(
                        'Product',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          item.productName.toLowerCase(),
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. Available Stock (Read-only grey box)
                      Text(
                        'Available Stock',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          item.currentStock.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 3. From Branch (Read-only grey box showing "Main Branch")
                      Text(
                        'From Branch',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'Main Branch',
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 4. To Branch * (Dropdown)
                      Row(
                        children: [
                          Text(
                            'To Branch',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedTargetBranch,
                            hint: Text(
                              'Select Target Branch',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                              size: 22,
                            ),
                            items: targetBranches.map((branch) {
                              return DropdownMenuItem<String>(
                                value: branch,
                                child: Text(
                                  branch,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedTargetBranch = val;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 5. Transfer Quantity *
                      Row(
                        children: [
                          Text(
                            'Transfer Quantity',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: qtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter transfer quantity',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFF6B2C), width: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 6. Remarks (optional)
                      Text(
                        'Remarks',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          TextField(
                            controller: remarksController,
                            minLines: 3,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter remarks (optional)',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFFF6B2C), width: 1.5),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: Icon(
                              Icons.drag_handle_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Bottom Action Buttons: Transfer Stock (Orange) & Cancel (Slate)
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Material(
                              color: const Color(0xFFFF7A1A),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  if (selectedTargetBranch == null) {
                                    Get.snackbar(
                                      'Select Target Branch',
                                      'Please select a target branch for transfer.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFEF4444),
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  final parsedQty = double.tryParse(qtyController.text.trim());
                                  if (parsedQty == null || parsedQty <= 0) {
                                    Get.snackbar(
                                      'Invalid Quantity',
                                      'Please enter a valid transfer quantity.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFEF4444),
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  if (parsedQty > item.currentStock) {
                                    Get.snackbar(
                                      'Insufficient Stock',
                                      'Transfer quantity exceeds available stock.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFEF4444),
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  final newTotal = item.currentStock - parsedQty;
                                  final newRecord = StockHistoryRecord(
                                    date: DateTime.now(),
                                    actionType: 'Transfer to $selectedTargetBranch',
                                    quantityChanged: -parsedQty,
                                    resultingStock: newTotal,
                                    remarks: remarksController.text.trim().isEmpty
                                        ? 'Transferred from Main Branch to $selectedTargetBranch'
                                        : remarksController.text.trim(),
                                  );

                                  setState(() {
                                    final idx = _inventoryList.indexWhere((p) => p.id == item.id);
                                    if (idx != -1) {
                                      _inventoryList[idx] = item.copyWith(
                                        currentStock: newTotal,
                                        history: [newRecord, ...item.history],
                                      );
                                    }
                                  });

                                  Navigator.pop(ctx);
                                  Get.snackbar(
                                    'Success',
                                    'Stock transferred successfully.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFF10B981),
                                    colorText: Colors.white,
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  child: Center(
                                    child: Text(
                                      'Transfer Stock',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            flex: 4,
                            child: Material(
                              color: const Color(0xFF475569),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => Navigator.pop(ctx),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: SafeArea is intentionally omitted per requirements.
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCalculatorOpen = !_isCalculatorOpen;
          });
        },
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1.5.h),

                // 1. Top Header Row: Back Arrow + All Inventory + "+ New Product" Button
                _buildHeader(context),

                SizedBox(height: 2.h),

                // 2. Search Bar: "Search product..."
                _buildSearchBar(),

                SizedBox(height: 1.5.h),

                // 3. Side-by-Side Date Pickers: Start Date & End Date
                _buildDatePickers(),

                SizedBox(height: 2.h),

                // 4. Inventory Cards List matching UI screenshot
                _buildInventoryCardsList(),

                SizedBox(height: 10.h),
              ],
            ),
          ),

          // Floating Calculator Dialog
          if (_isCalculatorOpen)
            Positioned(
              right: 4.w,
              bottom: 9.h,
              child: CalculatorWidget(
                onClose: () {
                  setState(() {
                    _isCalculatorOpen = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // --- 1. Top Header ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF0F172A),
                  size: 22,
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
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'All Inventory',
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
            ],
          ),
        ),
        const SizedBox(width: 8),

        // "+ New Product" Orange Button
        Material(
          color: const Color(0xFFFF6B2C),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              Get.to(() => const AddProductScreen());
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
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
                    'New Product',
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
    );
  }

  // --- 2. Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search product...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 22,
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  // --- 3. Date Pickers (Side by side 2 columns) ---
  Widget _buildDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Start Date Box
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: _selectStartDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _startDate != null
                                  ? _formatDate(_startDate!)
                                  : 'dd-mm-yyyy',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _startDate != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
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

            const SizedBox(width: 12),

            // End Date Box
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: _selectEndDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _endDate != null
                                  ? _formatDate(_endDate!)
                                  : 'dd-mm-yyyy',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _endDate != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
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
        if (_startDate != null || _endDate != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: Text(
                'Clear Dates',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- 4. Inventory Cards List ---
  Widget _buildInventoryCardsList() {
    final filtered = _filteredInventory;

    if (filtered.isEmpty) {
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
                Icons.inventory_2_outlined,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                'No products found matching your search.',
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

    return Column(
      children: filtered.map((item) => _buildProductCard(item)).toList(),
    );
  }

  // --- Product Card matching Screenshot ---
  Widget _buildProductCard(InventoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Product Name + Three dots menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Price in Bright Orange
                      Text(
                        '₹ ${_formatPrice(item.price)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF6B2C),
                        ),
                      ),
                    ],
                  ),
                ),

                // Three-dot Options Menu
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'history') {
                      Get.to(() => ViewInventoryScreen(productName: item.productName));
                    } else if (val == 'stock') {
                      _showAddEditStockDialog(item);
                    } else if (val == 'transfer') {
                      _showTransferStockDialog(item);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'history',
                      child: Text(
                        'View History',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'stock',
                      child: Text(
                        'Add / Edit Stock',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'transfer',
                      child: Text(
                        'Transfer Stock',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle Stats Row (Initial Stock, Current Stock, Remarks)
            Row(
              children: [
                // Initial Stock
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Initial Stock',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.initialStock == item.initialStock.roundToDouble()
                            ? item.initialStock.toInt().toString()
                            : item.initialStock.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Current Stock
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Stock',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.currentStock.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Remarks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remarks',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.remarks,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Bottom Action Buttons Row (Soft Peach/Orange Tinted Buttons)
            Row(
              children: [
                // View History Button
                Expanded(
                  child: _buildPeachActionButton(
                    icon: Icons.access_time_rounded,
                    label: 'View History',
                    onTap: () => Get.to(() => ViewInventoryScreen(productName: item.productName)),
                  ),
                ),
                const SizedBox(width: 8),

                // Add / Edit Stock Button
                Expanded(
                  child: _buildPeachActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Add / Edit Stock',
                    onTap: () => _showAddEditStockDialog(item),
                  ),
                ),
                const SizedBox(width: 8),

                // Transfer Stock Button
                Expanded(
                  child: _buildPeachActionButton(
                    icon: Icons.sync_alt_rounded,
                    label: 'Transfer Stock',
                    onTap: () => _showTransferStockDialog(item),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Soft Peach Tint Action Button matching design ---
  Widget _buildPeachActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFFFF2EA),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFFFF6B2C),
                size: 15,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6B2C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
