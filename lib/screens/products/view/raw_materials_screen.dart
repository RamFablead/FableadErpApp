import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import 'add_product_screen.dart';

/// Model representing a raw material item.
class RawMaterialItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unit;
  final double currentStock;
  final double minStock;
  final double unitCost;
  final String status;

  const RawMaterialItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    required this.unitCost,
    required this.status,
  });

  RawMaterialItem copyWith({
    String? name,
    String? sku,
    String? category,
    String? unit,
    double? currentStock,
    double? minStock,
    double? unitCost,
    String? status,
  }) {
    return RawMaterialItem(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unitCost: unitCost ?? this.unitCost,
      status: status ?? this.status,
    );
  }
}

/// Screen displaying the list of All Raw Materials under Products.
class RawMaterialsScreen extends StatefulWidget {
  const RawMaterialsScreen({super.key});

  @override
  State<RawMaterialsScreen> createState() => _RawMaterialsScreenState();
}

class _RawMaterialsScreenState extends State<RawMaterialsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;
  String _selectedCategory = 'All Categories';

  final List<String> _categories = [
    'All Categories',
    'Metals & Steel',
    'Fabrics & Yarn',
    'Wood & Timber',
    'Chemicals & Dyes',
    'Plastics & Polymers',
  ];

  final List<RawMaterialItem> _allMaterials = [
    const RawMaterialItem(
      id: '1',
      name: 'Stainless Steel Sheet 304',
      sku: 'RM-SS-304',
      category: 'Metals & Steel',
      unit: 'Kg',
      currentStock: 1250.0,
      minStock: 200.0,
      unitCost: 240.0,
      status: 'In Stock',
    ),
    const RawMaterialItem(
      id: '2',
      name: 'Combed Cotton Yarn 30s',
      sku: 'RM-CTN-30S',
      category: 'Fabrics & Yarn',
      unit: 'Spool',
      currentStock: 480.0,
      minStock: 100.0,
      unitCost: 185.0,
      status: 'In Stock',
    ),
    const RawMaterialItem(
      id: '3',
      name: 'Teak Wood Plank 6x2',
      sku: 'RM-WD-TK',
      category: 'Wood & Timber',
      unit: 'Sq.Ft',
      currentStock: 45.0,
      minStock: 50.0,
      unitCost: 1200.0,
      status: 'Low Stock',
    ),
    const RawMaterialItem(
      id: '4',
      name: 'Reactive Black Dye D-300',
      sku: 'RM-CHM-BLK',
      category: 'Chemicals & Dyes',
      unit: 'Litre',
      currentStock: 650.0,
      minStock: 80.0,
      unitCost: 350.0,
      status: 'In Stock',
    ),
    const RawMaterialItem(
      id: '5',
      name: 'High-Density Polyethylene Granules',
      sku: 'RM-HDPE-01',
      category: 'Plastics & Polymers',
      unit: 'Kg',
      currentStock: 18.0,
      minStock: 100.0,
      unitCost: 95.0,
      status: 'Out of Stock',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RawMaterialItem> get _filteredMaterials {
    final query = _searchController.text.trim().toLowerCase();
    return _allMaterials.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'All Categories' ||
          item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _handleDelete(RawMaterialItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Raw Material',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _allMaterials.removeWhere((m) => m.id == item.id);
              });
              Get.snackbar(
                'Deleted',
                'Raw material "${item.name}" has been removed.',
                backgroundColor: const Color(0xFFDC2626),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
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
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Top Header: Title & Action Button
                _buildHeader(context),

                SizedBox(height: 2.5.h),

                // Search & Filter Card
                _buildFilterCard(),

                SizedBox(height: 2.5.h),

                // Materials Table Card
                _buildMaterialsTableCard(),

                SizedBox(height: 5.h),

                // Footer Copyright
                _buildFooter(),

                SizedBox(height: 8.h),
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

  Widget _buildHeader(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 1.5.h,
      spacing: 2.w,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Navigator.canPop(context)) ...[
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
              SizedBox(width: 1.w),
            ],
            Text(
              'All Raw Materials',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // Add Raw Material Button using Get.to
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () {
              Get.to(() => const AddProductScreen());
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Add Raw Material',
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


  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2.w,
        runSpacing: 1.5.h,
        children: [
          // Search Input
          Container(
            width: 260,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search material or SKU...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),

          // Category Dropdown
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTableCard() {
    final filtered = _filteredMaterials;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 850),
          child: DataTable(
            horizontalMargin: 18,
            columnSpacing: 35,
            headingRowHeight: 50,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 68,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
            columns: [
              DataColumn(
                label: Text(
                  'Material Name',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'SKU',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Stock',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Unit Cost',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Action',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
            rows: filtered.isEmpty
                ? [
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'No raw materials found',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                      ],
                    ),
                  ]
                : filtered.map((item) {
                    final statusColor = item.status == 'In Stock'
                        ? const Color(0xFF15803D)
                        : item.status == 'Low Stock'
                            ? const Color(0xFFD97706)
                            : const Color(0xFFDC2626);

                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.category_rounded,
                                  color: Color(0xFF475569),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            item.sku,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${item.currentStock} ${item.unit}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${item.unitCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Color(0xFFEF4444),
                            ),
                            onPressed: () => _handleDelete(item),
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2026 Copyright - Fablead Developers Technolab',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}
