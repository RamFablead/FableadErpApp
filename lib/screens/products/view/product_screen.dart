import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';
import 'add_product_screen.dart';
import 'import_product_screen.dart';

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

  ProductItem copyWith({
    String? name,
    String? imageUrl,
    IconData? placeholderIcon,
    String? sku,
    String? category,
    String? unit,
    String? brand,
    bool? isAvailable,
  }) {
    return ProductItem(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      placeholderIcon: placeholderIcon ?? this.placeholderIcon,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      brand: brand ?? this.brand,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Screen displaying the mobile All Products catalog with filters and cards.
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
    'Sports',
    'Footwear',
  ];

  final List<String> _brands = [
    'All Brands',
    'Nivia',
    'Force',
    'YRUS',
    'Urban Ladder',
    'SG',
  ];

  late List<ProductItem> _allProducts;

  @override
  void initState() {
    super.initState();
    _allProducts = [
      const ProductItem(
        name: 'Test-Disha-2',
        placeholderIcon: Icons.checkroom_rounded,
        sku: '3352621',
        category: 'Clothing',
        unit: 'FGDF',
        brand: 'Nivia',
        isAvailable: true,
      ),
      const ProductItem(
        name: 'Abc',
        placeholderIcon: Icons.sports_tennis_rounded,
        sku: 'N/A',
        category: 'N/A',
        unit: 'Pice',
        brand: 'Force',
        isAvailable: false,
      ),
      const ProductItem(
        name: 'SUPER WIDE LEG',
        placeholderIcon: Icons.dry_cleaning_rounded,
        sku: 'N/A',
        category: 'N/A',
        unit: 'Pcs',
        brand: 'YRUS',
        isAvailable: false,
      ),
      const ProductItem(
        name: 'Mung 30kg EVERYDAY',
        placeholderIcon: Icons.grain_rounded,
        sku: '57794973',
        category: 'N/A',
        unit: 'N/A',
        brand: 'N/A',
        isAvailable: false,
      ),
      const ProductItem(
        name: 'BAJARA-26K.G DAYMAND',
        placeholderIcon: Icons.grass_rounded,
        sku: '35562377',
        category: 'N/A',
        unit: 'N/A',
        brand: 'N/A',
        isAvailable: false,
      ),
      const ProductItem(
        name: 'Sofa Set',
        placeholderIcon: Icons.chair_rounded,
        sku: '020',
        category: 'Furniture',
        unit: 'SET',
        brand: 'Urban Ladder',
        isAvailable: false,
      ),
      const ProductItem(
        name: 'Abc-Test',
        placeholderIcon: Icons.sports_cricket_rounded,
        sku: '0523157',
        category: 'Sports',
        unit: 'FGDF',
        brand: 'SG',
        isAvailable: false,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductItem> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _allProducts.where((p) {
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All Categories' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesBrand = _selectedBrand == 'All Brands' ||
          p.brand.toLowerCase() == _selectedBrand.toLowerCase();

      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();
  }

  void _toggleAvailability(ProductItem item) {
    final index = _allProducts.indexWhere((p) => p.name == item.name);
    if (index != -1) {
      setState(() {
        _allProducts[index] = item.copyWith(isAvailable: !item.isAvailable);
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} marked as ${!item.isAvailable ? "Available" : "Not Available"}.',
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor:
              !item.isAvailable ? const Color(0xFF15803D) : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteProduct(ProductItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Product',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: TextStyle(
            fontSize: 14.5.sp,
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
                _allProducts.removeWhere((p) => p.name == item.name);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Product "${item.name}" deleted successfully.',
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

  void _showProductDetailsDialog(ProductItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
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
              _buildDetailRow('SKU', item.sku),
              _buildDetailRow('Category', item.category),
              _buildDetailRow('Unit', item.unit),
              _buildDetailRow('Brand', item.brand),
              _buildDetailRow(
                'Rent Availability',
                item.isAvailable ? 'Available' : 'Not Available',
                valueColor: item.isAvailable
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
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
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _showBarcodeDialog(ProductItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Barcode: ${item.name}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.view_week_rounded,
                      size: 64,
                      color: Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.sku == 'N/A' ? 'NO-SKU-ASSIGNED' : item.sku,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllBarcodesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'All Product Barcodes',
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _allProducts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = _allProducts[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 30,
                        color: Color(0xFF1E293B),
                      ),
                      title: Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        'SKU: ${p.sku}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      trailing: Text(
                        p.isAvailable ? 'Available' : 'Not Available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: p.isAvailable
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriceHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Price History Audit',
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildHistoryTile(
                      'Test-Disha-2',
                      'Price adjusted from ₹ 450.00 to ₹ 500.00',
                      '28-09-2026',
                    ),
                    _buildHistoryTile(
                      'SUPER WIDE LEG',
                      'Price adjusted from ₹ 520.00 to ₹ 550.00',
                      '24-09-2026',
                    ),
                    _buildHistoryTile(
                      'Sofa Set',
                      'Catalog launch base price ₹ 34,999.00',
                      '15-09-2026',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String title, String subtitle, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExportExcel() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting products list to Excel...',
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleExportPdf() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating PDF catalog report...',
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'All Products',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Products'),
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
                // 1. Header Actions (Import Products & New Product)
                _buildHeader(context),

                SizedBox(height: 2.h),

                // 2. Search Product Input
                _buildSearchBar(),

                SizedBox(height: 1.5.h),

                // 3. Dropdowns: Category & Brand (Side-by-side)
                _buildCategoryAndBrandDropdowns(),

                SizedBox(height: 1.8.h),

                // 4. Quick Action Buttons: Excel, PDF, All Barcodes, Price History
                _buildActionButtonsRow(),

                SizedBox(height: 2.h),

                // 5. Products Cards List
                _buildProductsCardsList(),

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

  // --- 1. Top Header Actions ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Import Products Button
        _buildHeaderActionButton(
          icon: Icons.cloud_upload_outlined,
          label: 'Import Products',
          onTap: () => Get.to(() => const ImportProductScreen()),
        ),
        const SizedBox(width: 8),

        // New Product Button
        _buildHeaderActionButton(
          icon: Icons.add_rounded,
          label: 'New Product',
          onTap: () => Get.to(() => const AddProductScreen()),
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFFF6B2C),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
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

  // --- 3. Category & Brand Dropdowns (Side by side) ---
  Widget _buildCategoryAndBrandDropdowns() {
    return Row(
      children: [
        // Category Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              _buildDropdown(
                value: _selectedCategory,
                items: _categories,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Brand Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brand',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              _buildDropdown(
                value: _selectedBrand,
                items: _brands,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBrand = val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
          items: items.map((String itm) {
            return DropdownMenuItem<String>(
              value: itm,
              child: Text(
                itm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF334155),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- 4. Action Buttons Row: Excel, PDF, All Barcodes, Price History ---
  Widget _buildActionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPillButton(
            icon: Icons.table_chart_rounded,
            label: 'Excel',
            color: const Color(0xFF15803D),
            onTap: _handleExportExcel,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildPillButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: const Color(0xFFDC2626),
            onTap: _handleExportPdf,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildPillButton(
            icon: Icons.view_week_rounded,
            label: 'All Barcodes',
            color: const Color(0xFF1E293B),
            onTap: _showAllBarcodesDialog,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildPillButton(
            icon: Icons.history_rounded,
            label: 'Price History',
            color: const Color(0xFF0EA5E9),
            onTap: _showPriceHistoryDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildPillButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 15),
                const SizedBox(width: 4),
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
      ),
    );
  }

  // --- 5. Product Cards List ---
  Widget _buildProductsCardsList() {
    final filtered = _filteredProducts;

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

  // --- Single Product Card ---
  Widget _buildProductCard(ProductItem item) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Product Name + Options Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildMoreMenuButton(item),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Core Attributes in a Row: SKU, Category, Unit, Brand
          Row(
            children: [
              Expanded(child: _buildAttributeItem('SKU', item.sku)),
              const SizedBox(width: 6),
              Expanded(child: _buildAttributeItem('Category', item.category)),
              const SizedBox(width: 6),
              Expanded(child: _buildAttributeItem('Unit', item.unit)),
              const SizedBox(width: 6),
              Expanded(child: _buildAttributeItem('Brand', item.brand)),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Bottom Row: Rent Availability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Rent Availability',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildAvailabilityBadge(item.isAvailable),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Not Available',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMoreMenuButton(ProductItem item) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          color: Color(0xFF64748B),
          size: 18,
        ),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (val) {
        if (val == 'details') {
          _showProductDetailsDialog(item);
        } else if (val == 'edit') {
          Get.to(() => const AddProductScreen());
        } else if (val == 'barcode') {
          _showBarcodeDialog(item);
        } else if (val == 'toggle') {
          _toggleAvailability(item);
        } else if (val == 'delete') {
          _deleteProduct(item);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text('View Details', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text('Edit Product', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'barcode',
          child: Row(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text('View Barcode', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                item.isAvailable
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline,
                size: 18,
                color: item.isAvailable
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF16A34A),
              ),
              const SizedBox(width: 8),
              Text(
                item.isAvailable ? 'Mark Unavailable' : 'Mark Available',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
