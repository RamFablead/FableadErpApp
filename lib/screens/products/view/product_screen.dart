import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../home_screen.dart';
import '../../profile_screen.dart';
import '../../sales&bills/view/all_sales_screen.dart';
import '../controller/product_controller.dart';
import '../modal/AllproductViewLIstModal.dart' as product_modal;
import 'add_product_screen.dart';
import 'import_product_screen.dart';

/// Screen displaying the mobile All Products catalog with filters and cards.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductController _controller = Get.put(ProductController());
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteProduct(product_modal.Data item) {
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
          'Are you sure you want to delete "${item.name ?? 'this product'}"?',
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
            onPressed: () async {
              Navigator.pop(ctx);
              if (item.id != null) {
                await _controller.deleteProduct(item.id!);
              }
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

  void _showProductDetailsDialog(product_modal.Data item) {
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
                      item.name ?? 'N/A',
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
              _buildDetailRow('SKU', item.sKU ?? 'N/A'),
              _buildDetailRow('Category', item.category?.name ?? 'N/A'),
              _buildDetailRow('Unit', item.unit?.unitName ?? 'N/A'),
              _buildDetailRow('Brand', item.brand?.name ?? 'N/A'),
              _buildDetailRow('Price', '₹ ${item.price ?? '0'}'),
              _buildDetailRow('MRP', '₹ ${item.mrp ?? '0.00'}'),
              _buildDetailRow('Quantity', '${item.quantity ?? '0'}'),
              _buildDetailRow(
                'Rent Availability',
                item.isRentAvailable == 1 ? 'Available' : 'Not Available',
                valueColor: item.isRentAvailable == 1
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

  void _showBarcodeDialog(product_modal.Data item) {
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
                'Barcode: ${item.name ?? 'Product'}',
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
                      (item.barcode != null && item.barcode!.isNotEmpty)
                          ? item.barcode!
                          : (item.sKU ?? 'NO-SKU-ASSIGNED'),
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
                child: Obx(() => ListView.separated(
                  shrinkWrap: true,
                  itemCount: _controller.productsList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = _controller.productsList[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 30,
                        color: Color(0xFF1E293B),
                      ),
                      title: Text(
                        p.name ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        'SKU: ${p.sKU ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      trailing: Text(
                        p.isRentAvailable == 1 ? 'Available' : 'Not Available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: p.isRentAvailable == 1
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleExportExcel() {
    Get.snackbar(
      'Export',
      'Exporting products list to Excel...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF15803D),
      colorText: Colors.white,
    );
  }

  void _handleExportPdf() {
    Get.snackbar(
      'Export',
      'Generating PDF catalog report...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'All Products',
        showBackButton: false,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Products'),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: 1, // Products tab
        isDarkMode: false,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => const HomeScreen());
              break;
            case 1:
              break;
            case 2:
              Get.to(() => const AllSalesScreen());
              break;
            case 3:
              Get.to(() => const ProfileScreen());
              break;
          }
        },
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
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchAllData(),
        color: const Color(0xFFFF6B2C),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
        onChanged: (val) {
          _controller.searchQuery.value = val;
        },
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
          suffixIcon: Obx(() => _controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _controller.searchQuery.value = '';
                  },
                )
              : const SizedBox.shrink()),
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
    return Obx(() {
      final categoryOptions = [
        'All Categories',
        ..._controller.categoriesList.map((c) => c.name ?? '').where((n) => n.isNotEmpty)
      ];

      final brandOptions = [
        'All Brands',
        ..._controller.brandsList.map((b) => b.name ?? '').where((n) => n.isNotEmpty)
      ];

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
                  value: categoryOptions.contains(_controller.selectedCategoryFilter.value)
                      ? _controller.selectedCategoryFilter.value
                      : 'All Categories',
                  items: categoryOptions,
                  onChanged: (val) {
                    if (val != null) _controller.selectedCategoryFilter.value = val;
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
                  value: brandOptions.contains(_controller.selectedBrandFilter.value)
                      ? _controller.selectedBrandFilter.value
                      : 'All Brands',
                  items: brandOptions,
                  onChanged: (val) {
                    if (val != null) _controller.selectedBrandFilter.value = val;
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
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
          value: items.contains(value) ? value : items.first,
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
    return Obx(() {
      if (_controller.isLoadingProducts.value) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B2C)),
          ),
        );
      }

      final filtered = _controller.filteredProducts;

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
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _controller.fetchAllData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                  label: Text('Refresh', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: filtered.map((item) => _buildProductCard(item)).toList(),
      );
    });
  }

  // --- Single Product Card ---
  Widget _buildProductCard(product_modal.Data item) {
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
                  item.name ?? 'Unnamed Product',
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

          // Core Attributes in a Row: SKU, Category, Unit, Brand
          Row(
            children: [
              Expanded(child: _buildAttributeItem('SKU', item.sKU ?? 'N/A')),
              const SizedBox(width: 6),
              Expanded(child: _buildAttributeItem('Category', item.category?.name ?? 'N/A')),
              const SizedBox(width: 6),
              Expanded(child: _buildAttributeItem('Unit', item.unit?.unitName ?? 'N/A')),
              const SizedBox(width: 6),
              Expanded(child: _buildAttributeItem('Brand', item.brand?.name ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Bottom Row: Price & Rent Availability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price: ₹ ${item.price ?? '0'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF6B2C),
                ),
              ),
              _buildAvailabilityBadge(item.isRentAvailable == 1),
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

  Widget _buildMoreMenuButton(product_modal.Data item) {
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
          Get.to(() => AddProductScreen(editProduct: item));
        } else if (val == 'barcode') {
          _showBarcodeDialog(item);
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
