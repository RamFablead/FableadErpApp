import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';

/// Data model representing a labour / service charge item.
class LabourItem {
  final String id;
  final String name;
  final String code;
  final String rate;
  final String taxRate;
  final String createdAt;

  const LabourItem({
    required this.id,
    required this.name,
    required this.code,
    required this.rate,
    this.taxRate = '18% GST',
    required this.createdAt,
  });

  LabourItem copyWith({
    String? name,
    String? code,
    String? rate,
    String? taxRate,
    String? createdAt,
  }) {
    return LabourItem(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      taxRate: taxRate ?? this.taxRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Screen displaying all labour items and service charges in catalog setup.
class AllLabourItemsScreen extends StatefulWidget {
  const AllLabourItemsScreen({super.key});

  @override
  State<AllLabourItemsScreen> createState() => _AllLabourItemsScreenState();
}

class _AllLabourItemsScreenState extends State<AllLabourItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  final List<LabourItem> _items = [
    const LabourItem(
      id: '1',
      name: 'Assembly Labour Charge',
      code: 'LAB-001',
      rate: '₹250.00 / hr',
      taxRate: '18% GST',
      createdAt: '01/10/2026',
    ),
    const LabourItem(
      id: '2',
      name: 'Packaging & Boxing Service',
      code: 'LAB-002',
      rate: '₹80.00 / pc',
      taxRate: '18% GST',
      createdAt: '30/09/2026',
    ),
    const LabourItem(
      id: '3',
      name: 'Fabric Cutting Work',
      code: 'LAB-003',
      rate: '₹120.00 / mtr',
      taxRate: '12% GST',
      createdAt: '28/09/2026',
    ),
    const LabourItem(
      id: '4',
      name: 'Stitching & Tailoring',
      code: 'LAB-004',
      rate: '₹350.00 / pc',
      taxRate: '12% GST',
      createdAt: '25/09/2026',
    ),
    const LabourItem(
      id: '5',
      name: 'Hardware Installation',
      code: 'LAB-005',
      rate: '₹500.00 / unit',
      taxRate: '18% GST',
      createdAt: '22/09/2026',
    ),
    const LabourItem(
      id: '6',
      name: 'Loading & Unloading',
      code: 'LAB-006',
      rate: '₹400.00 / truck',
      taxRate: 'Exempted',
      createdAt: '18/09/2026',
    ),
    const LabourItem(
      id: '7',
      name: 'Machine Maintenance',
      code: 'LAB-007',
      rate: '₹800.00 / visit',
      taxRate: '18% GST',
      createdAt: '10/09/2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LabourItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.code.toLowerCase().contains(query) ||
          item.rate.toLowerCase().contains(query);
    }).toList();
  }

  void _handleAddNewLabourItem() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final rateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Add New Labour Item',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Labour Item / Service Name',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(nameCtrl, 'e.g. Welding Work, Assembly'),
              SizedBox(height: 1.5.h),
              Text(
                'Item / Service Code',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(codeCtrl, 'e.g. LAB-008'),
              SizedBox(height: 1.5.h),
              Text(
                'Standard Rate',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(rateCtrl, 'e.g. ₹300.00 / hr'),
            ],
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
              final name = nameCtrl.text.trim();
              final code = codeCtrl.text.trim().toUpperCase();
              final rate = rateCtrl.text.trim();
              if (name.isNotEmpty && code.isNotEmpty) {
                setState(() {
                  _items.insert(
                    0,
                    LabourItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      code: code,
                      rate: rate.isNotEmpty ? rate : '₹0.00',
                      taxRate: '18% GST',
                      createdAt: 'Today',
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Labour item "$name" added successfully.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF15803D),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA043),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Add Item',
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

  void _handleEdit(LabourItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final codeCtrl = TextEditingController(text: item.code);
    final rateCtrl = TextEditingController(text: item.rate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Labour Item',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Labour Item Name',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(nameCtrl, 'Item Name'),
              SizedBox(height: 1.5.h),
              Text(
                'Service Code',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(codeCtrl, 'Code'),
              SizedBox(height: 1.5.h),
              Text(
                'Standard Rate',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(rateCtrl, 'Rate'),
            ],
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
              final newName = nameCtrl.text.trim();
              final newCode = codeCtrl.text.trim().toUpperCase();
              final newRate = rateCtrl.text.trim();
              if (newName.isNotEmpty && newCode.isNotEmpty) {
                final index = _items.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  setState(() {
                    _items[index] = item.copyWith(
                      name: newName,
                      code: newCode,
                      rate: newRate.isNotEmpty ? newRate : item.rate,
                    );
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Labour item "$newName" updated successfully.',
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF15803D),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA043),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Save',
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

  void _handleDelete(LabourItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Labour Item',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete labour item "${item.name}"?',
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
                _items.removeWhere((i) => i.id == item.id);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Labour item "${item.name}" deleted successfully.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
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

  Widget _buildDialogField(TextEditingController ctrl, String hint) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: TextField(
          controller: ctrl,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF94A3B8),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'All Labour Items',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(
        isDarkMode: false,
        activeItem: 'All Labour Items',
      ),
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
                // Top Header: Actions
                _buildHeader(context),

                SizedBox(height: 2.h),

                // Labour Items Table Card
                _buildLabourCard(context),

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
              'All Labour Items',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // + New Labour Item Button
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: _handleAddNewLabourItem,
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
                    'New Labour Item',
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

  Widget _buildLabourCard(BuildContext context) {
    final filtered = _filteredItems;

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
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      hintText: 'Search labour items...',
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

          SizedBox(height: 2.5.h),

          // Table with Horizontal Scrolling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 720),
              child: DataTable(
                horizontalMargin: 16,
                columnSpacing: 35,
                headingRowHeight: 48,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 68,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFFAFAFA)),
                columns: [
                  DataColumn(
                    label: Text(
                      'Labour / Service Name',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Code',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Rate',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tax',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Created At',
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
                                'No labour items found.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                          ],
                        ),
                      ]
                    : filtered.map((item) {
                        return DataRow(
                          cells: [
                            // Labour Item Name
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFFEDD5),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.handyman_rounded,
                                        size: 18,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
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
                            // Code badge
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  item.code,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                            // Rate
                            DataCell(
                              Text(
                                item.rate,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                            // Tax
                            DataCell(
                              Text(
                                item.taxRate,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            // Created At
                            DataCell(
                              Text(
                                item.createdAt,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            // Actions
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Button
                                  Material(
                                    color: const Color(0xFFFFA043),
                                    borderRadius: BorderRadius.circular(4),
                                    child: InkWell(
                                      onTap: () => _handleEdit(item),
                                      borderRadius: BorderRadius.circular(4),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 1.5.w),
                                  // Delete Button
                                  Material(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(4),
                                    child: InkWell(
                                      onTap: () => _handleDelete(item),
                                      borderRadius: BorderRadius.circular(4),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Copyright © 2026 Fablead ERP. All rights reserved.',
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
