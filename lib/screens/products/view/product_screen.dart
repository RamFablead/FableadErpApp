import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import 'add_product_screen.dart';

/// Product model representing an item in the ERP product list.
class ProductItem {
  final String name;
  final String? imageUrl;
  final IconData placeholderIcon;
  final String sku;
  final String category;
  final String unit;
  final String brand;
  final bool isAvailable;

  const ProductItem({
    required this.name,
    this.imageUrl,
    this.placeholderIcon = Icons.inventory_2_outlined,
    required this.sku,
    required this.category,
    required this.unit,
    required this.brand,
    required this.isAvailable,
  });
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedBrand = 'All Brands';
  bool _isCalculatorOpen = false;

  final List<String> _categories = [
    'All Categories',
    'Clothing',
    'Furniture',
    'Grains & Pulses',
    'Footwear',
  ];

  final List<String> _brands = [
    'All Brands',
    'Nivia',
    'Force',
    'YRUS',
    'Urban Ladder',
  ];

  final List<ProductItem> _allProducts = const [
    ProductItem(
      name: 'Test-Disha-2',
      placeholderIcon: Icons.checkroom_rounded,
      sku: '3352621',
      category: 'Clothing',
      unit: 'FGDF',
      brand: 'Nivia',
      isAvailable: true,
    ),
    ProductItem(
      name: 'Abc',
      placeholderIcon: Icons.sports_tennis_rounded,
      sku: 'N/A',
      category: 'N/A',
      unit: 'Pice',
      brand: 'Force',
      isAvailable: false,
    ),
    ProductItem(
      name: 'SUPER WIDE LEG',
      placeholderIcon: Icons.dry_cleaning_rounded,
      sku: 'N/A',
      category: 'N/A',
      unit: 'Pcs',
      brand: 'YRUS',
      isAvailable: false,
    ),
    ProductItem(
      name: 'Mung 30kg EVERYDAY',
      placeholderIcon: Icons.grain_rounded,
      sku: '57794973',
      category: 'N/A',
      unit: 'N/A',
      brand: 'N/A',
      isAvailable: false,
    ),
    ProductItem(
      name: 'BAJARA-26K.G DAYMAND',
      placeholderIcon: Icons.grass_rounded,
      sku: '35562377',
      category: 'N/A',
      unit: 'N/A',
      brand: 'N/A',
      isAvailable: false,
    ),
    ProductItem(
      name: 'Sofa Set',
      placeholderIcon: Icons.chair_rounded,
      sku: '020',
      category: 'Furniture',
      unit: 'SET',
      brand: 'Urban Ladder',
      isAvailable: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductItem> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch = _searchController.text.isEmpty ||
          p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'All Categories' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesBrand = _selectedBrand == 'All Brands' ||
          p.brand.toLowerCase() == _selectedBrand.toLowerCase();
      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();
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

                // Top Header: Title & Action Buttons
                _buildHeader(context),

                SizedBox(height: 2.5.h),

                // Search, Dropdowns & Quick Export Buttons Bar
                _buildFiltersCard(context),

                SizedBox(height: 2.5.h),

                // Products Table Card
                _buildProductTableCard(context),

                SizedBox(height: 12.h),
              ],
            ),
          ),

          // Floating Calculator Dialog placed in bottom right near FAB
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
        Text(
          'All Products',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Import Products Button
            _buildHeaderButton(
              icon: Icons.cloud_download_outlined,
              label: 'Import Products',
              color: const Color(0xFFFFA043),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Import Products clicked',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 2.w),
            // New Product Button
            _buildHeaderButton(
              icon: Icons.add_rounded,
              label: 'New Product',
              color: const Color(0xFFFFA043),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              SizedBox(width: 1.5.w),
              Text(
                label,
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
    );
  }

  Widget _buildFiltersCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 3.w,
            runSpacing: 2.h,
            children: [
              // Search Input
              SizedBox(
                width: 55.w > 260 ? 55.w : 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                hintText: 'Search...',
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
                  ],
                ),
              ),

              // Category Dropdown
              SizedBox(
                width: 40.w > 180 ? 40.w : 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 0.6.h),
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
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          items: _categories.map((String cat) {
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
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Brand Dropdown
              SizedBox(
                width: 40.w > 180 ? 40.w : 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 0.6.h),
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
                          value: _selectedBrand,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          items: _brands.map((String brand) {
                            return DropdownMenuItem<String>(
                              value: brand,
                              child: Text(
                                brand,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedBrand = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Action Buttons: Excel, PDF, Barcodes, Price History
              Wrap(
                spacing: 1.5.w,
                runSpacing: 1.h,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.table_chart_rounded,
                    label: 'Excel',
                    color: const Color(0xFF15803D),
                    onTap: () {},
                  ),
                  _buildQuickActionButton(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF',
                    color: const Color(0xFFDC2626),
                    onTap: () {},
                  ),
                  _buildQuickActionButton(
                    icon: Icons.qr_code_2_rounded,
                    label: 'All Barcodes',
                    color: const Color(0xFF1E293B),
                    onTap: () {},
                  ),
                  _buildQuickActionButton(
                    icon: Icons.history_rounded,
                    label: 'Price History',
                    color: const Color(0xFF06B6D4),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.9.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              SizedBox(width: 1.w),
              Text(
                label,
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
    );
  }

  Widget _buildProductTableCard(BuildContext context) {
    final products = _filteredProducts;

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
          constraints: const BoxConstraints(minWidth: 900),
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 35,
            headingRowHeight: 52,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 70,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
            columns: [
              DataColumn(
                label: Text(
                  'Product Name',
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
                  'Unit',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Brand',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Rent Availability',
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
            rows: products.isEmpty
                ? [
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'No products found matching filters',
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
                : products.map((item) {
                    return DataRow(
                      cells: [
                        // Product Name & Thumbnail
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  item.placeholderIcon,
                                  color: const Color(0xFF475569),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SKU
                        DataCell(
                          Text(
                            item.sku,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),

                        // Category
                        DataCell(
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),

                        // Unit
                        DataCell(
                          Text(
                            item.unit,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),

                        // Brand
                        DataCell(
                          Text(
                            item.brand,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),

                        // Rent Availability (Pill badge)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.isAvailable
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.isAvailable ? 'Available' : 'Not Available',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Action button (three horizontal dots)
                        DataCell(
                          Container(
                            width: 36,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.more_horiz_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () {
                                _showActionMenu(context, item);
                              },
                            ),
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

  void _showActionMenu(BuildContext context, ProductItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 1.5.h),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(
                  'Edit Product',
                  style: TextStyle(fontSize: 14.sp),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_rounded),
                title: Text(
                  'Print Barcode',
                  style: TextStyle(fontSize: 14.sp),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  'Delete Product',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }
}
