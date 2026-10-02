import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';
import 'add_product_category_screen.dart';

/// Data model representing a product category item.
class CategoryItem {
  final String id;
  final String name;
  final String? imageUrl;
  final IconData placeholderIcon;
  final String createdAt;

  const CategoryItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.placeholderIcon = Icons.category_outlined,
    required this.createdAt,
  });

  CategoryItem copyWith({
    String? name,
    String? imageUrl,
    String? createdAt,
  }) {
    return CategoryItem(
      id: id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      placeholderIcon: placeholderIcon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Screen displaying the list of all product categories in the catalog setup.
class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  final List<CategoryItem> _categories = [
    const CategoryItem(
      id: '1',
      name: 'Male1',
      placeholderIcon: Icons.person_outline_rounded,
      createdAt: '30/09/2026',
    ),
    const CategoryItem(
      id: '2',
      name: 'Test Category 15',
      placeholderIcon: Icons.auto_awesome_rounded,
      createdAt: '30/09/2026',
    ),
    const CategoryItem(
      id: '3',
      name: 'Test Category',
      placeholderIcon: Icons.dashboard_outlined,
      createdAt: '30/09/2026',
    ),
    const CategoryItem(
      id: '4',
      name: 'Drinks',
      placeholderIcon: Icons.local_drink_outlined,
      createdAt: '28/09/2026',
    ),
    const CategoryItem(
      id: '5',
      name: 'Clean House',
      placeholderIcon: Icons.cleaning_services_outlined,
      createdAt: '28/09/2026',
    ),
    const CategoryItem(
      id: '6',
      name: 'Female',
      placeholderIcon: Icons.face_3_outlined,
      createdAt: '15/09/2026',
    ),
    const CategoryItem(
      id: '7',
      name: 'Food',
      placeholderIcon: Icons.restaurant_outlined,
      createdAt: '27/08/2026',
    ),
    const CategoryItem(
      id: '8',
      name: 'Furniture',
      placeholderIcon: Icons.chair_outlined,
      createdAt: '03/07/2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryItem> get _filteredCategories {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _categories;
    return _categories.where((cat) {
      return cat.name.toLowerCase().contains(query);
    }).toList();
  }

  void _handleDelete(CategoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Category',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete category "${item.name}"?',
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
                _categories.removeWhere((c) => c.id == item.id);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Category "${item.name}" deleted successfully.',
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

  void _handleEdit(CategoryItem item) {
    final editController = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Category',
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
              'Category Name',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: TextField(
                  controller: editController,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
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
              final newName = editController.text.trim();
              if (newName.isNotEmpty) {
                final index = _categories.indexWhere((c) => c.id == item.id);
                if (index != -1) {
                  setState(() {
                    _categories[index] = item.copyWith(name: newName);
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Category updated to "$newName".',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF15803D),
                    behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Product Categories',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Categories'),
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

                // Categories Table Card
                _buildCategoriesCard(context),

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
              'All Categories',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        // + New Category Button
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () {
              Get.to(() => const AddProductCategoryScreen());
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
                    'New Category',
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

  Widget _buildCategoriesCard(BuildContext context) {
    final filtered = _filteredCategories;

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

          SizedBox(height: 2.5.h),

          // Categories Table with Horizontal Scrolling Support
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 700),
              child: DataTable(
                horizontalMargin: 16,
                columnSpacing: 40,
                headingRowHeight: 48,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 68,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFFAFAFA)),
                columns: [
                  DataColumn(
                    label: Text(
                      'Category Name',
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
                                'No categories found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                          ],
                        ),
                      ]
                    : filtered.map((cat) {
                        return DataRow(
                          cells: [
                            // Category Avatar and Name
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Icon(
                                      cat.placeholderIcon,
                                      color: const Color(0xFF475569),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Created At Date
                            DataCell(
                              Text(
                                cat.createdAt,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),

                            // Action Buttons: Edit & Delete
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: Color(0xFF475569),
                                    ),
                                    onPressed: () => _handleEdit(cat),
                                    tooltip: 'Edit Category',
                                    splashRadius: 20,
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                      color: Color(0xFFEF4444),
                                    ),
                                    onPressed: () => _handleDelete(cat),
                                    tooltip: 'Delete Category',
                                    splashRadius: 20,
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
