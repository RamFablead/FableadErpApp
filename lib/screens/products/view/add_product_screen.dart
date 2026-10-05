import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';
import '../controller/product_controller.dart';
import '../modal/AllproductViewLIstModal.dart' as product_modal;

enum ProductType {
  normal,
  variant,
  grocery,
}

/// Model for a row in the Product Variants table.
class VariantRowItem {
  final TextEditingController sizeController;
  final TextEditingController colorController;
  final TextEditingController qtyController;
  final TextEditingController mrpController;
  final TextEditingController purchasePriceController;
  final TextEditingController priceController;
  final TextEditingController barcodeController;

  VariantRowItem({
    String size = '',
    String color = '',
    String qty = '0',
    String mrp = '0.00',
    String purchasePrice = '0.00',
    String price = '0.00',
    String barcode = '',
  })  : sizeController = TextEditingController(text: size),
        colorController = TextEditingController(text: color),
        qtyController = TextEditingController(text: qty),
        mrpController = TextEditingController(text: mrp),
        purchasePriceController = TextEditingController(text: purchasePrice),
        priceController = TextEditingController(text: price),
        barcodeController = TextEditingController(text: barcode);

  void dispose() {
    sizeController.dispose();
    colorController.dispose();
    qtyController.dispose();
    mrpController.dispose();
    purchasePriceController.dispose();
    priceController.dispose();
    barcodeController.dispose();
  }

  void generateAutoBarcode() {
    final rand = 10000000 + Random().nextInt(90000000);
    barcodeController.text = rand.toString();
  }
}

/// Model for a row in the Grocery Packing Details table.
class GroceryPackingRowItem {
  String packingType;
  final TextEditingController packSizeController;
  String unit;
  final TextEditingController qtyController;
  final TextEditingController mrpController;
  final TextEditingController purchasePriceController;
  final TextEditingController priceController;
  final TextEditingController barcodeController;

  GroceryPackingRowItem({
    this.packingType = 'Packet',
    String packSize = '',
    this.unit = 'G',
    String qty = '0',
    String mrp = '0.00',
    String purchasePrice = '0.00',
    String price = '0.00',
    String barcode = '',
  })  : packSizeController = TextEditingController(text: packSize),
        qtyController = TextEditingController(text: qty),
        mrpController = TextEditingController(text: mrp),
        purchasePriceController = TextEditingController(text: purchasePrice),
        priceController = TextEditingController(text: price),
        barcodeController = TextEditingController(text: barcode);

  void dispose() {
    packSizeController.dispose();
    qtyController.dispose();
    mrpController.dispose();
    purchasePriceController.dispose();
    priceController.dispose();
    barcodeController.dispose();
  }

  void generateAutoBarcode() {
    final rand = 10000000 + Random().nextInt(90000000);
    barcodeController.text = rand.toString();
  }
}

class AddProductScreen extends StatefulWidget {
  final product_modal.Data? editProduct;
  const AddProductScreen({super.key, this.editProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController = Get.put(ProductController());

  // Product Type
  ProductType _selectedProductType = ProductType.normal;

  // Controllers for general fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _hsnController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController(text: '0.00');
  final TextEditingController _purchasePriceController = TextEditingController(text: '0.00');
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variant Rows
  final List<VariantRowItem> _variants = [];

  // Grocery Packing Rows
  final List<GroceryPackingRowItem> _groceryPackings = [];

  // Dropdown states
  String? _selectedCategory;
  String? _selectedBrand;
  String _selectedGstOption = 'Without GST';
  String? _selectedUnit;
  String _selectedRentType = 'Select';
  String _selectedStatus = 'Active';
  String _selectedStock = 'In Stock';

  // Checkbox
  bool _availableForRent = false;

  // Calculator Overlay state
  bool _isCalculatorOpen = false;

  // Available options
  final List<String> _categories = [
    'Clothing',
    'Furniture',
    'Grains & Pulses',
    'Sports',
    'Footwear',
  ];

  final List<String> _brands = [
    'Nivia',
    'Force',
    'YRUS',
    'Urban Ladder',
    'SG',
  ];

  final List<String> _gstOptions = [
    'Without GST',
    'With GST',
  ];

  final List<String> _units = [
    'Pcs',
    'Pice',
    'SET',
    'FGDF',
    'Kg',
    'Box',
  ];

  final List<String> _rentTypes = [
    'Select',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  final List<String> _statuses = [
    'Active',
    'Inactive',
  ];

  final List<String> _stockStatuses = [
    'In Stock',
    'Out of Stock',
  ];

  final List<String> _packingTypes = [
    'Packet',
    'Loose',
    'Box',
    'Bottle',
    'Pouch',
    'Can',
    'Bag',
    'Jar',
  ];

  final List<String> _groceryUnits = [
    'G',
    'Kg',
    'Ml',
    'L',
    'Pcs',
  ];

  @override
  void initState() {
    super.initState();
    _variants.add(VariantRowItem());
    _groceryPackings.add(GroceryPackingRowItem());

    if (widget.editProduct != null) {
      final p = widget.editProduct!;
      _nameController.text = p.name ?? '';
      _skuController.text = p.sKU ?? '';
      _priceController.text = p.price?.toString() ?? '0';
      _mrpController.text = p.mrp?.toString() ?? '0.00';
      _quantityController.text = p.quantity?.toString() ?? '0';
      _selectedCategory = p.category?.name;
      _selectedBrand = p.brand?.name;
      _selectedUnit = p.unit?.unitName;
      _barcodeController.text = p.barcode ?? '';
      if (p.gstOption == 'with_gst') {
        _selectedGstOption = 'With GST';
      } else {
        _selectedGstOption = 'Without GST';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _hsnController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _purchasePriceController.dispose();
    _rentPriceController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    for (final g in _groceryPackings) {
      g.dispose();
    }
    super.dispose();
  }

  void _addVariantRow() {
    setState(() {
      _variants.add(VariantRowItem());
    });
  }

  void _removeVariantRow(int index) {
    if (_variants.length > 1) {
      setState(() {
        _variants[index].dispose();
        _variants.removeAt(index);
      });
    } else {
      setState(() {
        _variants[0].sizeController.clear();
        _variants[0].colorController.clear();
        _variants[0].qtyController.text = '0';
        _variants[0].mrpController.text = '0.00';
        _variants[0].purchasePriceController.text = '0.00';
        _variants[0].priceController.text = '0.00';
        _variants[0].barcodeController.clear();
      });
    }
  }

  void _addGroceryPackingRow() {
    setState(() {
      _groceryPackings.add(GroceryPackingRowItem());
    });
  }

  void _removeGroceryPackingRow(int index) {
    if (_groceryPackings.length > 1) {
      setState(() {
        _groceryPackings[index].dispose();
        _groceryPackings.removeAt(index);
      });
    } else {
      setState(() {
        _groceryPackings[0].packingType = 'Packet';
        _groceryPackings[0].packSizeController.clear();
        _groceryPackings[0].unit = 'G';
        _groceryPackings[0].qtyController.text = '0';
        _groceryPackings[0].mrpController.text = '0.00';
        _groceryPackings[0].purchasePriceController.text = '0.00';
        _groceryPackings[0].priceController.text = '0.00';
        _groceryPackings[0].barcodeController.clear();
      });
    }
  }

  void _generateAutoBarcode() {
    final randomDigits = 10000000 + Random().nextInt(90000000);
    setState(() {
      _barcodeController.text = randomDigits.toString();
    });
  }

  void _showAddDialog({
    required String title,
    required String hintText,
    required ValueChanged<String> onSaved,
  }) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
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
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B2C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {
                          if (textController.text.trim().isNotEmpty) {
                            onSaved(textController.text.trim());
                            Navigator.pop(ctx);
                          }
                        },
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> get _dynamicCategories {
    final rawList = [
      ..._productController.categoriesList
          .map((c) => c.name ?? '')
          .where((n) => n.isNotEmpty),
      ..._categories,
    ];
    return rawList.toSet().toList();
  }

  List<String> get _dynamicBrands {
    final rawList = [
      ..._productController.brandsList
          .map((b) => b.name ?? '')
          .where((n) => n.isNotEmpty),
      ..._brands,
    ];
    return rawList.toSet().toList();
  }

  List<String> get _dynamicUnits {
    final rawList = [
      ..._productController.unitsList
          .map((u) => u.unitName ?? '')
          .where((n) => n.isNotEmpty),
      ..._units,
    ];
    return rawList.toSet().toList();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter a product name.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
        );
        return;
      }

      int categoryId = 1;
      if (_selectedCategory != null) {
        final cat = _productController.categoriesList.firstWhereOrNull(
          (c) => c.name?.toLowerCase() == _selectedCategory?.toLowerCase(),
        );
        if (cat?.id != null) categoryId = cat!.id!;
      }

      int brandId = 1;
      if (_selectedBrand != null) {
        final br = _productController.brandsList.firstWhereOrNull(
          (b) => b.name?.toLowerCase() == _selectedBrand?.toLowerCase(),
        );
        if (br?.id != null) brandId = br!.id!;
      }

      int unitId = 1;
      if (_selectedUnit != null) {
        final un = _productController.unitsList.firstWhereOrNull(
          (u) => u.unitName?.toLowerCase() == _selectedUnit?.toLowerCase(),
        );
        if (un?.id != null) unitId = un!.id!;
      }

      final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final double mrp = double.tryParse(_mrpController.text.trim()) ?? 0.0;
      final double purchasePrice = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
      final int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final String formattedGstOption =
          (_selectedGstOption == 'With GST' || _selectedGstOption == 'with_gst')
              ? 'with_gst'
              : 'without_gst';

      bool success = false;
      if (widget.editProduct != null) {
        success = await _productController.updateProduct(
          id: widget.editProduct!.id!,
          name: _nameController.text.trim(),
          categoryId: categoryId,
          brandId: brandId,
          unitId: unitId,
          price: price,
          mrp: mrp,
          purchasePrice: purchasePrice,
          quantity: quantity,
          sku: _skuController.text.trim().isEmpty ? 'SKU-001' : _skuController.text.trim(),
          itemType: _selectedProductType.name,
          status: _selectedStatus.toLowerCase(),
          availability: _selectedStock == 'In Stock' ? 'in_stock' : 'out_of_stock',
          gstOption: formattedGstOption,
          branchId: 1,
        );
      } else {
        success = await _productController.createProduct(
          name: _nameController.text.trim(),
          categoryId: categoryId,
          brandId: brandId,
          unitId: unitId,
          price: price,
          mrp: mrp,
          purchasePrice: purchasePrice,
          quantity: quantity,
          sku: _skuController.text.trim().isEmpty ? 'SKU-001' : _skuController.text.trim(),
          itemType: _selectedProductType.name,
          status: _selectedStatus.toLowerCase(),
          availability: _selectedStock == 'In Stock' ? 'in_stock' : 'out_of_stock',
          gstOption: formattedGstOption,
          branchId: 1,
        );
      }

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Add Product',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 2.h),

                  // 1. Top Card: Product Type Selector
                  _buildProductTypeCard(),

                  SizedBox(height: 2.h),

                  // 2. Main Form Card with All Fields and Orange Icons
                  _buildMainFormCard(),

                  // 3. Product Variants Card (Visible for Variant Product)
                  if (_selectedProductType == ProductType.variant) ...[
                    SizedBox(height: 2.h),
                    _buildProductVariantsSection(),
                  ],

                  // 4. Grocery Packing Details Card (Visible for Grocery Product)
                  if (_selectedProductType == ProductType.grocery) ...[
                    SizedBox(height: 2.h),
                    _buildGroceryPackingSection(),
                  ],

                  SizedBox(height: 3.h),

                  // 4. Save and Cancel Buttons
                  _buildBottomActionButtons(),

                  SizedBox(height: 10.h),
                ],
              ),
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



  // --- 1. Product Type Card ---
  Widget _buildProductTypeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: Color(0xFFFF6B2C),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Product Type',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRadioOption('Normal Product', ProductType.normal),
                const SizedBox(width: 16),
                _buildRadioOption('Variant Product', ProductType.variant),
                const SizedBox(width: 16),
                _buildRadioOption('Grocery Product', ProductType.grocery),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, ProductType type) {
    final isSelected = _selectedProductType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProductType = type;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF6B2C) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF6B2C),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Main Form Card matching reference structure with orange icons ---
  Widget _buildMainFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name Field (Full Width)
          _buildFieldLabel(
            icon: Icons.shopping_bag_outlined,
            label: 'Product Name',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _nameController,
            hintText: 'Enter product name',
          ),

          const SizedBox(height: 16),

          // Row 1: Category & Brand (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.layers_outlined,
                      label: 'Category',
                      isRequired: true,
                      trailing: _buildMiniOrangeButton(
                        label: 'Add Category',
                        onTap: () {
                          _showAddDialog(
                            title: 'Add New Category',
                            hintText: 'Enter category name',
                            onSaved: (val) {
                              setState(() {
                                if (!_categories.contains(val)) _categories.add(val);
                                _selectedCategory = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => _buildDropdownField(
                      value: _selectedCategory,
                      hintText: 'Select or Add Category',
                      items: _dynamicCategories,
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.local_offer_outlined,
                      label: 'Brand',
                      trailing: _buildMiniOrangeButton(
                        label: 'Add Brand',
                        onTap: () {
                          _showAddDialog(
                            title: 'Add New Brand',
                            hintText: 'Enter brand name',
                            onSaved: (val) {
                              setState(() {
                                if (!_brands.contains(val)) _brands.add(val);
                                _selectedBrand = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => _buildDropdownField(
                      value: _selectedBrand,
                      hintText: 'Select or Add Brand',
                      items: _dynamicBrands,
                      onChanged: (val) => setState(() => _selectedBrand = val),
                    )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: SKU & HSN Code (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.reorder_rounded,
                      label: 'SKU',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _skuController,
                      hintText: 'Enter SKU',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.tag_rounded,
                      label: 'HSN Code',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _hsnController,
                      hintText: 'Enter HSN Code',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 3: GST Option & Unit (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.percent_rounded,
                      label: 'GST Option',
                    ),
                    const SizedBox(height: 6),
                    _buildDropdownField(
                      value: _selectedGstOption,
                      hintText: 'Choose GST Option',
                      items: _gstOptions,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGstOption = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.square_foot_rounded,
                      label: 'Unit',
                      isRequired: true,
                      trailing: _buildMiniOrangeButton(
                        label: 'Add Unit',
                        onTap: () {
                          _showAddDialog(
                            title: 'Add New Unit',
                            hintText: 'Enter unit name',
                            onSaved: (val) {
                              setState(() {
                                if (!_units.contains(val)) _units.add(val);
                                _selectedUnit = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => _buildDropdownField(
                      value: _selectedUnit,
                      hintText: 'Select or Add Unit',
                      items: _dynamicUnits,
                      onChanged: (val) => setState(() => _selectedUnit = val),
                    )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 4: Quantity & Price (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.widgets_outlined,
                      label: 'Quantity',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _quantityController,
                      hintText: 'Enter quantity',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Price',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _priceController,
                      hintText: 'Enter price',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 5: MRP (with Available for Rent) & Purchase Price (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.currency_rupee_rounded,
                      label: 'MRP',
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _mrpController,
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _availableForRent = !_availableForRent;
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _availableForRent,
                                    onChanged: (val) {
                                      setState(() {
                                        _availableForRent = val ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFFFF6B2C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Available for Rent',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Purchase Price',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _purchasePriceController,
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dynamic Rent Fields (Revealed when Available for Rent is checked)
          if (_availableForRent) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(
                          icon: Icons.calendar_today_outlined,
                          label: 'Rent Type',
                        ),
                        const SizedBox(height: 6),
                        _buildDropdownField(
                          value: _selectedRentType,
                          hintText: 'Select Rent Type',
                          items: _rentTypes,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRentType = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(
                          icon: Icons.currency_rupee_rounded,
                          label: 'Rent Price',
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _rentPriceController,
                          hintText: 'Enter rent price',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Row 6: Status & Stock (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.toggle_on_outlined,
                      label: 'Status',
                    ),
                    const SizedBox(height: 6),
                    _buildDropdownField(
                      value: _selectedStatus,
                      hintText: 'Status',
                      items: _statuses,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.warehouse_outlined,
                      label: 'Stock',
                    ),
                    const SizedBox(height: 6),
                    _buildDropdownField(
                      value: _selectedStock,
                      hintText: 'Stock',
                      items: _stockStatuses,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStock = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 7: Barcode & Description (Side-by-side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBarcodeField(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.subject_rounded,
                      label: 'Description',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Enter product description',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 8: Product Image Dropzone with AI Generate Image Button
          _buildProductImageSection(),
        ],
      ),
    );
  }

  // --- Field Label with Orange Icon ---
  Widget _buildFieldLabel({
    required IconData icon,
    required String label,
    bool isRequired = false,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFFFF6B2C),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isRequired) ...[
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
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing,
        ],
      ],
    );
  }

  // --- Mini Orange Button (Add Category, Add Brand, Add Unit, AI Generate Image) ---
  Widget _buildMiniOrangeButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFFF6B2C),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable Input Text Field ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF6B2C), width: 1.5),
        ),
      ),
    );
  }

  // --- Reusable Dropdown Field ---
  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final uniqueItems = items.toSet().toList();
    final selectValue = uniqueItems.contains(value) ? value : null;

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
          value: selectValue,
          hint: Text(
            hintText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF0F172A),
          ),
          items: uniqueItems.map((String itm) {
            return DropdownMenuItem<String>(
              value: itm,
              child: Text(
                itm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF0F172A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- Barcode Input with Add, Auto, and Camera buttons ---
  Widget _buildBarcodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.qr_code_2_rounded,
          label: 'Barcode',
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _barcodeController,
                hintText: 'Enter Barcode',
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () {
                  if (_barcodeController.text.trim().isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Barcode ${_barcodeController.text} added!',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: const Color(0xFFFF6B2C),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: _generateAutoBarcode,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  child: Text(
                    'Auto',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFF6B2C)),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFFFF6B2C)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Camera barcode scanner opened',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                padding: const EdgeInsets.all(7),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Product Image Dropzone Section ---
  Widget _buildProductImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          icon: Icons.image_outlined,
          label: 'Product Image',
          trailing: _buildMiniOrangeButton(
            label: 'Generate AI Image',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'AI Image Generator launched...',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Select image from gallery or camera',
                  style: TextStyle(fontSize: 14.sp),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 95),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 32,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to add product image',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Product Variants Section (Visible for Variant Product) ---
  Widget _buildProductVariantsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Variants',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addVariantRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: Text(
                  'Add More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columnSpacing: 16,
              columns: [
                DataColumn(
                  label: Text(
                    'Size',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Color',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Qty',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'MRP',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Purchase Price',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Price',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Barcode',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              rows: _variants.asMap().entries.map((entry) {
                final idx = entry.key;
                final v = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 85,
                        child: _buildVariantCellField(v.sizeController, 'e.g. M'),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 85,
                        child: _buildVariantCellField(v.colorController, 'e.g. Red'),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 65,
                        child: _buildVariantCellField(v.qtyController, '0', isNumber: true),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 95,
                        child: _buildMrpVariantCellField(v.mrpController),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: _buildVariantCellField(v.purchasePriceController, '0.00', isNumber: true),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: _buildVariantCellField(v.priceController, '0.00', isNumber: true),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: _buildVariantCellField(v.barcodeController, 'Auto-ger...'),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Camera Button (Orange)
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Upload image for variant ${idx + 1}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFF6B2C)),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFFFF6B2C),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Trash Delete Button (Red)
                          InkWell(
                            onTap: () => _removeVariantRow(idx),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFEF4444)),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 16,
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
        ],
      ),
    );
  }

  // --- Grocery Packing Details Section (Visible for Grocery Product) ---
  Widget _buildGroceryPackingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grocery Packing Details',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addGroceryPackingRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: Text(
                  'Add More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columnSpacing: 14,
              columns: [
                DataColumn(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Packing Type', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      Text(' *', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
                    ],
                  ),
                ),
                DataColumn(
                  label: Text('Pack Size', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
                DataColumn(
                  label: Text('Unit', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
                DataColumn(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Qty', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      Text(' *', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
                    ],
                  ),
                ),
                DataColumn(
                  label: Text('MRP', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
                DataColumn(
                  label: Text('Purchase Price', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
                DataColumn(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Price', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      Text(' *', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
                    ],
                  ),
                ),
                DataColumn(
                  label: Text('Barcode', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
                DataColumn(
                  label: Text('Action', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
              ],
              rows: _groceryPackings.asMap().entries.map((entry) {
                final idx = entry.key;
                final g = entry.value;
                return DataRow(
                  cells: [
                    // 1. Packing Type Dropdown
                    DataCell(
                      SizedBox(
                        width: 105,
                        child: _buildSmallDropdownField(
                          value: g.packingType,
                          items: _packingTypes,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => g.packingType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    // 2. Pack Size
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: _buildVariantCellField(g.packSizeController, 'e.g. 100'),
                      ),
                    ),
                    // 3. Unit Dropdown
                    DataCell(
                      SizedBox(
                        width: 75,
                        child: _buildSmallDropdownField(
                          value: g.unit,
                          items: _groceryUnits,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => g.unit = val);
                            }
                          },
                        ),
                      ),
                    ),
                    // 4. Qty *
                    DataCell(
                      SizedBox(
                        width: 65,
                        child: _buildVariantCellField(g.qtyController, '0', isNumber: true),
                      ),
                    ),
                    // 5. MRP
                    DataCell(
                      SizedBox(
                        width: 95,
                        child: _buildMrpVariantCellField(g.mrpController),
                      ),
                    ),
                    // 6. Purchase Price
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: _buildVariantCellField(g.purchasePriceController, '0.00', isNumber: true),
                      ),
                    ),
                    // 7. Price *
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: _buildVariantCellField(g.priceController, '0.00', isNumber: true),
                      ),
                    ),
                    // 8. Barcode
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: _buildVariantCellField(g.barcodeController, 'Auto-ger...'),
                      ),
                    ),
                    // 9. Action
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Camera Button (Orange)
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Upload image for packing item ${idx + 1}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFF6B2C)),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFFFF6B2C),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Delete Button (Red)
                          InkWell(
                            onTap: () => _removeGroceryPackingRow(idx),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFEF4444)),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 16,
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
        ],
      ),
    );
  }

  Widget _buildSmallDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final uniqueItems = items.toSet().toList();
    final selectValue = uniqueItems.contains(value) ? value : (uniqueItems.isNotEmpty ? uniqueItems.first : null);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectValue,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
            size: 16,
          ),
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF0F172A),
          ),
          items: uniqueItems.map((String itm) {
            return DropdownMenuItem<String>(
              value: itm,
              child: Text(
                itm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF0F172A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- Variant / Grocery Cell Field with Up/Down Stepper Arrows for MRP ---
  Widget _buildMrpVariantCellField(TextEditingController controller) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  final val = double.tryParse(controller.text) ?? 0.0;
                  controller.text = (val + 1.0).toStringAsFixed(2);
                },
                child: const Icon(Icons.arrow_drop_up_rounded, size: 14, color: Color(0xFF64748B)),
              ),
              InkWell(
                onTap: () {
                  final val = double.tryParse(controller.text) ?? 0.0;
                  if (val >= 1.0) {
                    controller.text = (val - 1.0).toStringAsFixed(2);
                  }
                },
                child: const Icon(Icons.arrow_drop_down_rounded, size: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCellField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  // --- Bottom Action Buttons ---
  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: const Color(0xFFFF6B2C),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _submitForm,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15.sp,
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
          child: OutlinedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.back();
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
