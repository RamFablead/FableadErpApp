import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';
import 'add_brands_screen.dart';

/// Data model representing a brand in the catalog setup.
class BrandItem {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? logoUrl;
  final IconData placeholderIcon;
  final String createdAt;

  const BrandItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.logoUrl,
    this.placeholderIcon = Icons.branding_watermark_rounded,
    required this.createdAt,
  });

  BrandItem copyWith({
    String? name,
    String? email,
    String? phone,
    String? logoUrl,
    String? createdAt,
  }) {
    return BrandItem(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      placeholderIcon: placeholderIcon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Screen displaying the list of all brands in the catalog setup.
class AllBrandsScreen extends StatefulWidget {
  const AllBrandsScreen({super.key});

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  final List<BrandItem> _brands = [
    const BrandItem(
      id: '1',
      name: 'Apple',
      email: 'contact@apple.com',
      phone: '+1 800-692-7753',
      createdAt: '01/10/2026',
    ),
    const BrandItem(
      id: '2',
      name: 'Samsung',
      email: 'support@samsung.com',
      phone: '+1 800-726-7864',
      createdAt: '29/09/2026',
    ),
    const BrandItem(
      id: '3',
      name: 'Nike Inc.',
      email: 'sales@nike.com',
      phone: '+1 800-806-6453',
      createdAt: '28/09/2026',
    ),
    const BrandItem(
      id: '4',
      name: 'Sony Corporation',
      email: 'info@sony.com',
      phone: '+1 800-222-7669',
      createdAt: '25/09/2026',
    ),
    const BrandItem(
      id: '5',
      name: 'Dell Technologies',
      email: 'support@dell.com',
      phone: '+1 800-624-9897',
      createdAt: '20/09/2026',
    ),
    const BrandItem(
      id: '6',
      name: 'LG Electronics',
      email: 'service@lg.com',
      phone: '+1 800-243-0000',
      createdAt: '15/09/2026',
    ),
    const BrandItem(
      id: '7',
      name: 'HP Inc.',
      email: 'contact@hp.com',
      phone: '+1 800-474-6836',
      createdAt: '10/09/2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BrandItem> get _filteredBrands {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _brands;
    return _brands.where((b) {
      return b.name.toLowerCase().contains(query) ||
          b.email.toLowerCase().contains(query) ||
          b.phone.toLowerCase().contains(query);
    }).toList();
  }

  void _handleDelete(BrandItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Brand',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete brand "${item.name}"?',
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
                _brands.removeWhere((b) => b.id == item.id);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Brand "${item.name}" deleted successfully.',
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

  void _handleEdit(BrandItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final emailCtrl = TextEditingController(text: item.email);
    final phoneCtrl = TextEditingController(text: item.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Brand',
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
                'Brand Name',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(nameCtrl, 'Brand Name'),
              SizedBox(height: 1.5.h),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(emailCtrl, 'Email Address'),
              SizedBox(height: 1.5.h),
              Text(
                'Phone',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 0.8.h),
              _buildDialogField(phoneCtrl, 'Phone Number'),
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
              if (newName.isNotEmpty) {
                final index = _brands.indexWhere((b) => b.id == item.id);
                if (index != -1) {
                  setState(() {
                    _brands[index] = item.copyWith(
                      name: newName,
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Brand "$newName" updated successfully.',
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
        title: 'All Brands',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'All Brands'),
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

                // Brands Table Card
                _buildBrandsCard(context),

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
              'All Brands',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // + New Brand Button
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () {
              Get.to(() => const AddBrandsScreen());
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
                    'New Brand',
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

  Widget _buildBrandsCard(BuildContext context) {
    final filtered = _filteredBrands;

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
                      hintText: 'Search brands...',
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

          // Brands Table with Horizontal Scrolling
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
                      'Brand Name',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Phone',
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
                                'No brands found.',
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
                            // Brand Name with Avatar
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFBFDBFE),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.name.isNotEmpty
                                            ? item.name[0].toUpperCase()
                                            : 'B',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2563EB),
                                        ),
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
                            // Email
                            DataCell(
                              Text(
                                item.email,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            // Phone
                            DataCell(
                              Text(
                                item.phone,
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
