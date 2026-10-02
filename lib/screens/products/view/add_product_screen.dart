import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';

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

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

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

  // Dropdown states
  String? _selectedCategory;
  String? _selectedBrand;
  String _selectedGstOption = 'Choose GST Option';
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
    'Footwear',
    'Electronics',
  ];

  final List<String> _brands = [
    'Nivia',
    'Force',
    'YRUS',
    'Urban Ladder',
    'Puma',
  ];

  final List<String> _units = [
    'Pcs',
    'Pice',
    'SET',
    'FGDF',
    'Kg',
    'Meter',
  ];

  final List<String> _gstOptions = [
    'Choose GST Option',
    'Without GST',
    'With GST',
  ];

  final List<String> _rentTypes = [
    'Select',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  final List<String> _statuses = [
    'Active',
    'Inactive',
  ];

  final List<String> _stockStatuses = [
    'In Stock',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with 1 variant row
    _variants.add(VariantRowItem());
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
      // Clear values if only 1 row left
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
            constraints: const BoxConstraints(maxWidth: 400),
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

                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: TextField(
                    controller: textController,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA043),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Main Container Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Product Type Selector
                        _buildProductTypeSelector(),

                        const Divider(height: 36, color: Color(0xFFF1F5F9)),

                        // 2. Form Fields Grid based on Selected Product Type
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double width = constraints.maxWidth;
                            final int columns = width > 1100 ? 4 : (width > 700 ? 2 : 1);
                            final double itemWidth = (width - ((columns - 1) * 20)) / columns;

                            return Wrap(
                              spacing: 20,
                              runSpacing: 18,
                              children: _buildFormFields(itemWidth),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // 3. Product Variants Section (Visible for Variant Product)
                        if (_selectedProductType == ProductType.variant) ...[
                          _buildProductVariantsSection(),
                          const SizedBox(height: 24),
                        ],

                        // 4. Submit and Cancel Buttons
                        Row(
                          children: [
                            Material(
                              color: const Color(0xFFFFA043),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Product submitted successfully!',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w > 36 ? 5.w : 36,
                                    vertical: 1.4.h,
                                  ),
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
                            SizedBox(width: 3.w),
                            Material(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => Navigator.maybePop(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w > 36 ? 5.w : 36,
                                    vertical: 1.4.h,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 15.sp,
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

                  SizedBox(height: 12.h),
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

  Widget _buildProductTypeSelector() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3.w,
      runSpacing: 1.5.h,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.all_inbox_rounded,
              color: Color(0xFFFFA043),
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
        _buildRadioOption(
          label: 'Normal Product',
          value: ProductType.normal,
        ),
        _buildRadioOption(
          label: 'Variant Product',
          value: ProductType.variant,
        ),
        _buildRadioOption(
          label: 'Grocery Product',
          value: ProductType.grocery,
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required ProductType value,
  }) {
    final isSelected = _selectedProductType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProductType = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(double itemWidth) {
    if (_selectedProductType == ProductType.variant) {
      return _buildVariantProductFields(itemWidth);
    } else {
      return _buildNormalProductFields(itemWidth);
    }
  }

  /// Fields for Variant Product (matching screenshots 1 & 3)
  List<Widget> _buildVariantProductFields(double itemWidth) {
    return [
      // Row 1: Product Name, Category, Brand, SKU
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'Product Name',
          icon: Icons.inventory_2_outlined,
          isRequired: true,
          controller: _nameController,
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Category',
          icon: Icons.layers_outlined,
          isRequired: true,
          actionLabel: 'Add Category',
          value: _selectedCategory,
          hint: 'Select or Add Category',
          items: _categories,
          onChanged: (val) => setState(() => _selectedCategory = val),
          onActionTap: () => _showAddDialog(
            title: 'Add New Category',
            hintText: 'Enter category name',
            onSaved: (val) {
              setState(() {
                _categories.add(val);
                _selectedCategory = val;
              });
            },
          ),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Brand',
          icon: Icons.local_offer_outlined,
          actionLabel: 'Add Brand',
          value: _selectedBrand,
          hint: 'Select or Add Brand',
          items: _brands,
          onChanged: (val) => setState(() => _selectedBrand = val),
          onActionTap: () => _showAddDialog(
            title: 'Add New Brand',
            hintText: 'Enter brand name',
            onSaved: (val) {
              setState(() {
                _brands.add(val);
                _selectedBrand = val;
              });
            },
          ),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'SKU',
          icon: Icons.view_week_outlined,
          controller: _skuController,
        ),
      ),

      // Row 2: HSN Code, GST Option, Unit, Available for Rent
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'HSN Code',
          icon: Icons.tag_rounded,
          controller: _hsnController,
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'GST Option',
          icon: Icons.percent_rounded,
          value: _selectedGstOption,
          hint: 'Choose GST Option',
          items: _gstOptions,
          onChanged: (val) {
            if (val != null) setState(() => _selectedGstOption = val);
          },
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Unit',
          icon: Icons.straighten_rounded,
          isRequired: true,
          actionLabel: 'Add Unit',
          value: _selectedUnit,
          hint: 'Select or Add Unit',
          items: _units,
          onChanged: (val) => setState(() => _selectedUnit = val),
          onActionTap: () => _showAddDialog(
            title: 'Add New Unit',
            hintText: 'Enter name',
            onSaved: (val) {
              setState(() {
                _units.add(val);
                _selectedUnit = val;
              });
            },
          ),
        ),
      ),
      Container(
        width: itemWidth,
        height: 70,
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            setState(() {
              _availableForRent = !_availableForRent;
            });
          },
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _availableForRent,
                activeColor: const Color(0xFF1E88E5),
                onChanged: (val) {
                  setState(() {
                    _availableForRent = val ?? false;
                  });
                },
              ),
              Flexible(
                child: Text(
                  'Available for Rent',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Dynamic Rent Fields if Available for Rent is checked (Screenshot 3)
      if (_availableForRent) ...[
        SizedBox(
          width: itemWidth,
          child: _buildDropdownField(
            label: 'Rent Type',
            icon: Icons.access_time_rounded,
            value: _selectedRentType,
            hint: 'Select',
            items: _rentTypes,
            onChanged: (val) {
              if (val != null) setState(() => _selectedRentType = val);
            },
          ),
        ),
        SizedBox(
          width: itemWidth,
          child: _buildInputField(
            label: 'Rent Price',
            icon: Icons.currency_rupee_rounded,
            controller: _rentPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],

      // Status & Stock
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Status',
          icon: Icons.radio_button_checked_rounded,
          value: _selectedStatus,
          items: _statuses,
          onChanged: (val) {
            if (val != null) setState(() => _selectedStatus = val);
          },
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Stock',
          icon: Icons.warehouse_outlined,
          value: _selectedStock,
          items: _stockStatuses,
          onChanged: (val) {
            if (val != null) setState(() => _selectedStock = val);
          },
        ),
      ),

      // Description & Product Image
      SizedBox(
        width: itemWidth,
        child: _buildDescriptionField(),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildProductImageSection(),
      ),
    ];
  }

  /// Fields for Normal Product
  List<Widget> _buildNormalProductFields(double itemWidth) {
    return [
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'Product Name',
          icon: Icons.inventory_2_outlined,
          isRequired: true,
          controller: _nameController,
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Category',
          icon: Icons.layers_outlined,
          isRequired: true,
          actionLabel: 'Add Category',
          value: _selectedCategory,
          hint: 'Select or Add Category',
          items: _categories,
          onChanged: (val) => setState(() => _selectedCategory = val),
          onActionTap: () => _showAddDialog(
            title: 'Add New Category',
            hintText: 'Enter category name',
            onSaved: (val) {
              setState(() {
                _categories.add(val);
                _selectedCategory = val;
              });
            },
          ),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Brand',
          icon: Icons.local_offer_outlined,
          actionLabel: 'Add Brand',
          value: _selectedBrand,
          hint: 'Select or Add Brand',
          items: _brands,
          onChanged: (val) => setState(() => _selectedBrand = val),
          onActionTap: () => _showAddDialog(
            title: 'Add New Brand',
            hintText: 'Enter brand name',
            onSaved: (val) {
              setState(() {
                _brands.add(val);
                _selectedBrand = val;
              });
            },
          ),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'SKU',
          icon: Icons.view_week_outlined,
          controller: _skuController,
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'HSN Code',
          icon: Icons.tag_rounded,
          controller: _hsnController,
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'GST Option',
          icon: Icons.percent_rounded,
          value: _selectedGstOption,
          hint: 'Choose GST Option',
          items: _gstOptions,
          onChanged: (val) {
            if (val != null) setState(() => _selectedGstOption = val);
          },
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Unit',
          icon: Icons.straighten_rounded,
          isRequired: true,
          actionLabel: 'Add Unit',
          value: _selectedUnit,
          hint: 'Select or Add Unit',
          items: _units,
          onChanged: (val) => setState(() => _selectedUnit = val),
          onActionTap: () => _showAddDialog(
            title: 'Add New Unit',
            hintText: 'Enter name',
            onSaved: (val) {
              setState(() {
                _units.add(val);
                _selectedUnit = val;
              });
            },
          ),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'Quantity',
          icon: Icons.production_quantity_limits_rounded,
          controller: _quantityController,
          keyboardType: TextInputType.number,
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'Price',
          icon: Icons.currency_rupee_rounded,
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'MRP',
          icon: Icons.currency_rupee_rounded,
          controller: _mrpController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      Container(
        width: itemWidth,
        height: 70,
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            setState(() {
              _availableForRent = !_availableForRent;
            });
          },
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _availableForRent,
                activeColor: const Color(0xFF1E88E5),
                onChanged: (val) {
                  setState(() {
                    _availableForRent = val ?? false;
                  });
                },
              ),
              Flexible(
                child: Text(
                  'Available for Rent',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_availableForRent) ...[
        SizedBox(
          width: itemWidth,
          child: _buildDropdownField(
            label: 'Rent Type',
            icon: Icons.access_time_rounded,
            value: _selectedRentType,
            hint: 'Select',
            items: _rentTypes,
            onChanged: (val) {
              if (val != null) setState(() => _selectedRentType = val);
            },
          ),
        ),
        SizedBox(
          width: itemWidth,
          child: _buildInputField(
            label: 'Rent Price',
            icon: Icons.currency_rupee_rounded,
            controller: _rentPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
      SizedBox(
        width: itemWidth,
        child: _buildInputField(
          label: 'Purchase Price',
          icon: Icons.currency_rupee_rounded,
          controller: _purchasePriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Status',
          icon: Icons.radio_button_checked_rounded,
          value: _selectedStatus,
          items: _statuses,
          onChanged: (val) {
            if (val != null) setState(() => _selectedStatus = val);
          },
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDropdownField(
          label: 'Stock',
          icon: Icons.warehouse_outlined,
          value: _selectedStock,
          items: _stockStatuses,
          onChanged: (val) {
            if (val != null) setState(() => _selectedStock = val);
          },
        ),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildBarcodeField(),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildDescriptionField(),
      ),
      SizedBox(
        width: itemWidth,
        child: _buildProductImageSection(),
      ),
    ];
  }

  /// Product Variants Table Section (Screenshot 2)
  Widget _buildProductVariantsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Product Variants" and "+ Add More" button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Variants',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Material(
                  color: const Color(0xFFFFA043),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: _addVariantRow,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Add More',
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
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Variants Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 920),
              child: Column(
                children: [
                  // Table Header Row
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        _buildTableHeaderCell('Size', 110),
                        _buildTableHeaderCell('Color', 110),
                        _buildTableHeaderCell('Qty', 85),
                        _buildTableHeaderCell('MRP', 105),
                        _buildTableHeaderCell('Purchase Price', 125),
                        _buildTableHeaderCell('Price', 105),
                        _buildTableHeaderCell('Barcode', 210),
                        _buildTableHeaderCell('Action', 65, isCentered: true),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Variant Data Rows
                  ..._variants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final variant = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Size
                          _buildTableInputCell(
                            controller: variant.sizeController,
                            hintText: 'e.g. M',
                            width: 110,
                          ),
                          // Color
                          _buildTableInputCell(
                            controller: variant.colorController,
                            hintText: 'e.g. Red',
                            width: 110,
                          ),
                          // Qty
                          _buildTableInputCell(
                            controller: variant.qtyController,
                            width: 85,
                            keyboardType: TextInputType.number,
                          ),
                          // MRP
                          _buildTableInputCell(
                            controller: variant.mrpController,
                            width: 105,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          // Purchase Price
                          _buildTableInputCell(
                            controller: variant.purchasePriceController,
                            width: 125,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          // Price
                          _buildTableInputCell(
                            controller: variant.priceController,
                            width: 105,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          // Barcode with Auto-generate & Camera icon
                          SizedBox(
                            width: 210,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: variant.barcodeController,
                                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1E293B)),
                                        decoration: InputDecoration(
                                          hintText: 'Auto-generate',
                                          hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Camera icon button
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFFA043)),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Color(0xFFFFA043),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        variant.generateAutoBarcode();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Action: Red Delete Button
                          SizedBox(
                            width: 65,
                            child: Center(
                              child: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE57373),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeVariantRow(index),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, double width, {bool isCentered = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: isCentered ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTableInputCell({
    required TextEditingController controller,
    String? hintText,
    required double width,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldHeader({
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: const Color(0xFFFFA043),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null) ...[
          const SizedBox(width: 6),
          Material(
            color: const Color(0xFFFFA043),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Text(
                  actionLabel,
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
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    bool isRequired = false,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFieldHeader(label: label, icon: icon, isRequired: isRequired),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
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
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? actionLabel,
    VoidCallback? onActionTap,
    String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFieldHeader(
          label: label,
          icon: icon,
          isRequired: isRequired,
          actionLabel: actionLabel,
          onActionTap: onActionTap,
        ),
        const SizedBox(height: 8),
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
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: hint != null
                  ? Text(
                      hint,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : null,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              selectedItemBuilder: (ctx) {
                return items.map((item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList();
              },
              items: items.map((item) {
                final isCurrent = item == value;
                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFFFFA043) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isCurrent ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarcodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFieldHeader(label: 'Barcode', icon: Icons.qr_code_2_rounded),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _barcodeController,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Enter Barcode',
                    hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: const Color(0xFF475569),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            const SizedBox(width: 6),
            Material(
              color: const Color(0xFFFFA043),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: _generateAutoBarcode,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            const SizedBox(width: 6),
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFA043)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFFFA043), size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFieldHeader(label: 'Description', icon: Icons.subject_rounded),
        const SizedBox(height: 8),
        Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1E293B)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 20,
                  color: Color(0xFFFFA043),
                ),
                const SizedBox(width: 8),
                Text(
                  'Product Image',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Material(
              color: const Color(0xFFFFA043),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'AI Image Generation triggered',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Text(
                    'Generate AI Image',
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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 130),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Choose file to upload',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 38,
                    color: Color(0xFFFFA043),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drag and drop a file to upload',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
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
}
