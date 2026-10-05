import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';

/// Data model representing a measurement unit in catalog setup.
class UnitItem {
  final String id;
  final String name;
  final String code;
  final String baseUnit;
  final String createdAt;

  const UnitItem({
    required this.id,
    required this.name,
    required this.code,
    this.baseUnit = 'Yes',
    required this.createdAt,
  });

  UnitItem copyWith({
    String? name,
    String? code,
    String? baseUnit,
    String? createdAt,
  }) {
    return UnitItem(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      baseUnit: baseUnit ?? this.baseUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Screen displaying all measurement units in the catalog setup.
class AllUnitsScreen extends StatefulWidget {
  const AllUnitsScreen({super.key});

  @override
  State<AllUnitsScreen> createState() => _AllUnitsScreenState();
}

class _AllUnitsScreenState extends State<AllUnitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  final List<UnitItem> _units = [
    const UnitItem(
      id: '1',
      name: 'Pieces',
      code: 'PCS',
      baseUnit: 'Yes',
      createdAt: '01/10/2026',
    ),
    const UnitItem(
      id: '2',
      name: 'Kilogram',
      code: 'KG',
      baseUnit: 'Yes',
      createdAt: '29/09/2026',
    ),
    const UnitItem(
      id: '3',
      name: 'Gram',
      code: 'GM',
      baseUnit: 'No',
      createdAt: '28/09/2026',
    ),
    const UnitItem(
      id: '4',
      name: 'Meter',
      code: 'MTR',
      baseUnit: 'Yes',
      createdAt: '25/09/2026',
    ),
    const UnitItem(
      id: '5',
      name: 'Box',
      code: 'BOX',
      baseUnit: 'No',
      createdAt: '20/09/2026',
    ),
    const UnitItem(
      id: '6',
      name: 'Litre',
      code: 'LTR',
      baseUnit: 'Yes',
      createdAt: '15/09/2026',
    ),
    const UnitItem(
      id: '7',
      name: 'Dozen',
      code: 'DZN',
      baseUnit: 'No',
      createdAt: '12/09/2026',
    ),
    const UnitItem(
      id: '8',
      name: 'Packet',
      code: 'PKT',
      baseUnit: 'No',
      createdAt: '05/09/2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UnitItem> get _filteredUnits {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _units;
    return _units.where((u) {
      return u.name.toLowerCase().contains(query) ||
          u.code.toLowerCase().contains(query);
    }).toList();
  }

  void _handleAddNewUnit() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Add New Unit',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Name',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 0.8.h),
            _buildDialogField(nameCtrl, 'e.g. Kilogram, Pieces'),
            SizedBox(height: 1.5.h),
            Text(
              'Short Code',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 0.8.h),
            _buildDialogField(codeCtrl, 'e.g. KG, PCS, MTR'),
          ],
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
              if (name.isNotEmpty && code.isNotEmpty) {
                setState(() {
                  _units.insert(
                    0,
                    UnitItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      code: code,
                      baseUnit: 'Yes',
                      createdAt: 'Today',
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Unit "$name ($code)" created successfully.',
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
              'Add Unit',
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

  void _handleEdit(UnitItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final codeCtrl = TextEditingController(text: item.code);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Unit',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Name',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 0.8.h),
            _buildDialogField(nameCtrl, 'Unit Name'),
            SizedBox(height: 1.5.h),
            Text(
              'Short Code',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 0.8.h),
            _buildDialogField(codeCtrl, 'Short Code'),
          ],
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
              if (newName.isNotEmpty && newCode.isNotEmpty) {
                final index = _units.indexWhere((u) => u.id == item.id);
                if (index != -1) {
                  setState(() {
                    _units[index] = item.copyWith(name: newName, code: newCode);
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unit "$newName" updated successfully.',
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

  void _handleDelete(UnitItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Unit',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete unit "${item.name} (${item.code})"?',
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
                _units.removeWhere((u) => u.id == item.id);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Unit "${item.name}" deleted successfully.',
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
        title: 'All Units',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'All Units'),
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

                // Units Table Card
                _buildUnitsCard(context),

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
              'All Units',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // + New Unit Button
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: _handleAddNewUnit,
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
                    'New Unit',
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

  Widget _buildUnitsCard(BuildContext context) {
    final filtered = _filteredUnits;

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
                      hintText: 'Search units...',
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

          // Units Table with Horizontal Scrolling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 700),
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
                      'Unit Name',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Short Code',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Base Unit',
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
                                'No units found.',
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
                          ],
                        ),
                      ]
                    : filtered.map((item) {
                        return DataRow(
                          cells: [
                            // Unit Name
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFBBF7D0),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.straighten_rounded,
                                        size: 18,
                                        color: Color(0xFF16A34A),
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
                            // Base Unit
                            DataCell(
                              Text(
                                item.baseUnit,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: item.baseUnit == 'Yes'
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFF64748B),
                                  fontWeight: item.baseUnit == 'Yes'
                                      ? FontWeight.w700
                                      : FontWeight.normal,
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
