import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../models/category_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/order_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/customer_service.dart';
import '../../../services/order_service.dart';
import '../../../services/product_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../products/view/add_product_screen.dart';
import 'all_sales_screen.dart';

/// Product item model for Sales & Bills
class SalesProductItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double price;
  final IconData icon;

  const SalesProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    required this.icon,
  });
}

/// Category metadata model for Category Grid View
class SalesCategoryItem {
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const SalesCategoryItem({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

/// Custom painter for dashed borders around description input
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    this.color = const Color(0xFFCBD5E1),
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
    this.borderRadius = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) => false;
}

/// Data model for dynamic Other Charges rows (Screenshot 2)
class OtherChargeItem {
  final TextEditingController nameController;
  final TextEditingController amountController;

  OtherChargeItem({String name = '', double? amount})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(
            text: amount != null && amount > 0
                ? amount.toStringAsFixed(2)
                : '');

  String get name => nameController.text.trim();
  double get amount => double.tryParse(amountController.text.trim()) ?? 0.0;

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

/// Active cart item model with editable fields matching ERP billing card design
class SalesCartItem {
  final ProductItemModel product;
  int quantity;
  double price;
  double discountPercent;
  double discountAmount;
  String description;
  final TextEditingController descController;
  final TextEditingController priceController;
  final TextEditingController discPercentController;
  final TextEditingController discAmountController;

  SalesCartItem({
    required this.product,
    this.quantity = 1,
    required this.price,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.description = '',
  })  : descController = TextEditingController(text: description),
        priceController = TextEditingController(text: price.toStringAsFixed(2)),
        discPercentController = TextEditingController(
            text: discountPercent > 0
                ? discountPercent.toStringAsFixed(0)
                : '0'),
        discAmountController = TextEditingController(
            text: discountAmount > 0
                ? discountAmount.toStringAsFixed(0)
                : '0');

  double get subtotal => price * quantity;

  double get netAmount {
    double total = subtotal;
    if (discountAmount > 0) {
      total -= discountAmount;
    } else if (discountPercent > 0) {
      total -= (total * discountPercent / 100);
    }
    return total > 0 ? total : 0.0;
  }

  double get finalTotal => netAmount;

  // Proper GST Calculations (18% Total = 9% CGST + 9% SGST)
  double get cgstAmount => netAmount * 0.09;
  double get sgstAmount => netAmount * 0.09;
  double get gstTotal => netAmount * 0.18;
  double get withGstTotal => netAmount + gstTotal;

  void dispose() {
    descController.dispose();
    priceController.dispose();
    discPercentController.dispose();
    discAmountController.dispose();
  }
}

/// Helper to format currency
String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final whole = parts[0];
  final dec = parts[1];
  final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
  final formatted = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$formatted.$dec';
}

/// Helper to format date
String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString();
  return '$d/$m/$y';
}

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // Mode & Bill Type
  String _activeBillType = 'Quotation';
  String _selectedGstMode = 'Without GST';
  String _selectedCategory = 'All Products';
  String _selectedPaymentMode = 'Cash';

  // Toggle between Horizontal Product Cards and Category Grid View (Screenshot 4)
  bool _isCategoryGridView = false;
  bool _isBottomPanelExpanded = true;

  // Search
  final TextEditingController _searchController = TextEditingController();

  // Customer Details (Live API integration via CustomerService)
  final CustomerService _customerService = CustomerService();
  bool _isLoadingCustomers = false;
  String? _customersError;
  String _selectedCustomer = 'Select Customer';
  CustomerItemModel? _selectedCustomerModel;
  String? _selectedCustomerId;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customerGstController = TextEditingController();
  DateTime _orderDate = DateTime(2026, 10, 2);
  String _assignedStaff = 'Select Staff (Optional)';
  String _orderType = 'Self Pickup';

  List<CustomerItemModel> _liveCustomers = [
    CustomerItemModel(id: 1, name: 'Default Customer', phone: '9876543210'),
    CustomerItemModel(id: 104, name: 'damodar', phone: '0000078454'),
    CustomerItemModel(id: 103, name: 'disha lakhani', phone: '9824781385', city: 'surat'),
    CustomerItemModel(id: 92, name: 'VATSAL PATEL', phone: '8899777445', city: 'Surat'),
    CustomerItemModel(id: 90, name: 'Hiren Pravinbhai Chandaliya', phone: '9428618514', city: 'Surat'),
  ];

  // Charges, Discounts, Remarks & Other Charges
  final TextEditingController _deliveryCostController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _tdsPercentController =
      TextEditingController(text: '0');
  final TextEditingController _discountPercentController =
      TextEditingController(text: '0');
  final TextEditingController _remarksController = TextEditingController();
  final List<OtherChargeItem> _otherCharges = [];

  // Product Inventory Data (Live API integration via ProductService)
  final ProductService _productService = ProductService();
  bool _isLoadingProducts = false;
  String? _productsError;

  List<ProductItemModel> _allProducts = [
    ProductItemModel(
      id: 1,
      name: 'Basmati Rice',
      price: '180.00',
      category: ProductCategoryModel(id: 1, name: 'Food'),
      unit: ProductUnitModel(id: 1, unitName: 'Liter'),
    ),
    ProductItemModel(
      id: 2,
      name: 'Sandwitch',
      price: '250.00',
      category: ProductCategoryModel(id: 1, name: 'Food'),
      unit: ProductUnitModel(id: 2, unitName: 'Pcs'),
    ),
    ProductItemModel(
      id: 3,
      name: 'Organic Milk',
      price: '65.00',
      category: ProductCategoryModel(id: 2, name: 'Drinks'),
      unit: ProductUnitModel(id: 1, unitName: 'Liter'),
    ),
    ProductItemModel(
      id: 4,
      name: 'Office Chair',
      price: '3200.00',
      category: ProductCategoryModel(id: 3, name: 'Furniture'),
      unit: ProductUnitModel(id: 2, unitName: 'Pcs'),
    ),
  ];

  // Category Inventory Data (Live API integration via CategoryService)
  final CategoryService _categoryService = CategoryService();
  bool _isLoadingCategories = false;
  String? _categoriesError;
  List<CategoryItemModel> _liveCategories = [];

  // Order Placement (Live API integration via OrderService)
  final OrderService _orderService = OrderService();
  bool _isSubmittingOrder = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
      _customersError = null;
    });
    try {
      final list = await _customerService.getAllCustomers();
      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            _liveCustomers = list;
          }
          _isLoadingCustomers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCustomers = false;
          _customersError = e.toString();
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });
    try {
      final list = await _categoryService.getAllCategories();
      if (mounted) {
        setState(() {
          _liveCategories = list;
          _isLoadingCategories = false;
          if (_liveCategories.isNotEmpty) {
            _categories = [
              'All Products',
              ..._liveCategories
                  .map((c) => c.name.trim())
                  .where((n) => n.isNotEmpty)
            ];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          _categoriesError = e.toString();
        });
      }
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });
    try {
      final res = await _productService.getAllProducts();
      if (mounted) {
        setState(() {
          if (res.data.isNotEmpty) {
            _allProducts = res.data;
          }
          _isLoadingProducts = false;

          // If categories haven't loaded from category API yet, extract from products
          if (_liveCategories.isEmpty) {
            final dynamicCats = <String>{'All Products'};
            for (final p in _allProducts) {
              final c = p.categoryName.trim();
              if (c.isNotEmpty && c != 'General') {
                dynamicCats.add(c);
              }
            }
            if (dynamicCats.length > 1) {
              _categories = dynamicCats.toList();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _productsError = e.toString();
        });
      }
    }
  }

  // 8 Categories for the Grid View (Screenshot 4)
  final List<SalesCategoryItem> _gridCategories = [
    const SalesCategoryItem(
      name: 'Male1',
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFFFBEB),
    ),
    const SalesCategoryItem(
      name: 'Test Category...',
      icon: Icons.diversity_3_outlined,
      iconColor: Color(0xFF9333EA),
      bgColor: Color(0xFFFAF5FF),
    ),
    const SalesCategoryItem(
      name: 'Drinks',
      icon: Icons.local_drink_outlined,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
    ),
    const SalesCategoryItem(
      name: 'Food',
      icon: Icons.restaurant_outlined,
      iconColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFF7ED),
    ),
    const SalesCategoryItem(
      name: 'Furniture',
      icon: Icons.weekend_outlined,
      iconColor: Color(0xFF475569),
      bgColor: Color(0xFFF8FAFC),
    ),
    const SalesCategoryItem(
      name: 'Grocery',
      icon: Icons.shopping_basket_outlined,
      iconColor: Color(0xFF16A34A),
      bgColor: Color(0xFFF0FDF4),
    ),
    const SalesCategoryItem(
      name: 'Electronics',
      icon: Icons.devices_other_outlined,
      iconColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    const SalesCategoryItem(
      name: 'Clothing',
      icon: Icons.checkroom_outlined,
      iconColor: Color(0xFFE11D48),
      bgColor: Color(0xFFFFF1F2),
    ),
  ];

  // Bill Line Items (product id -> quantity)
  final Map<String, int> _cart = {};
  final Map<String, SalesCartItem> _cartItems = {};

  List<String> _categories = [
    'All Products',
    'Male1',
    'Test Category 15',
    'Drinks',
    'Food',
    'Furniture',
    'Grocery',
    'Electronics',
    'Clothing',
  ];

  final List<String> _billTypes = [
    'Quotation',
    'Advance Receipt',
    'Rental',
    'Sales Return'
  ];

  final List<String> _customerList = [
    'Select Customer',
    'Default Customer',
    'KETANKUMAR SURESHCHANDRA LAKDAWALA',
    'Bhavik',
    'Sneha Makvana',
    'Vatsal Patel'
  ];

  final List<String> _staffList = [
    'Select Staff (Optional)',
    'Admin',
    'Vatsal',
    'Akshay',
    'Rahul'
  ];

  final List<String> _orderTypes = [
    'Self Pickup',
    'Home Delivery',
    'Courier Delivery'
  ];

  @override
  void dispose() {
    for (final it in _cartItems.values) {
      it.dispose();
    }
    for (final c in _otherCharges) {
      c.dispose();
    }
    _searchController.dispose();
    _phoneController.dispose();
    _customerGstController.dispose();
    _remarksController.dispose();
    _deliveryCostController.dispose();
    _depositController.dispose();
    _tdsPercentController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  // Calculations
  int get _totalItems =>
      _cartItems.values.fold(0, (sum, item) => sum + item.quantity);

  double get _productSubtotal {
    double total = 0.0;
    _cartItems.forEach((id, item) {
      total += item.netAmount;
    });
    return total;
  }

  double get _totalGstAmount {
    if (_selectedGstMode != 'With GST') return 0.0;
    double total = 0.0;
    _cartItems.forEach((id, item) {
      total += item.gstTotal;
    });
    return total;
  }

  double get _otherChargesTotal =>
      _otherCharges.fold(0.0, (sum, c) => sum + c.amount);

  double get _deliveryCost =>
      double.tryParse(_deliveryCostController.text) ?? 0.0;

  double get _tdsAmount {
    final pct = double.tryParse(_tdsPercentController.text) ?? 0.0;
    return (_productSubtotal * pct) / 100;
  }

  double get _discountAmount {
    final pct = double.tryParse(_discountPercentController.text) ?? 0.0;
    return (_productSubtotal * pct) / 100;
  }

  double get _subtotalAmount {
    double sub = _productSubtotal +
        _deliveryCost +
        _otherChargesTotal -
        _discountAmount;
    if (_selectedGstMode == 'With GST') {
      sub += _totalGstAmount;
    }
    return sub > 0 ? sub : 0.0;
  }

  double get _grandTotal {
    double total = _subtotalAmount - _tdsAmount;
    return total > 0 ? total : 0.0;
  }

  // Dynamic reference numbers based on mode
  String get _dynamicOrderBadge {
    switch (_activeBillType) {
      case 'Quotation':
        return 'Quotation No: Q-13';
      case 'Advance Receipt':
        return 'Advance Receipt No: ADV-3';
      case 'Rental':
        return 'Rental No: RO-000018';
      case 'Sales Return':
        return 'Return No: SR-0091';
      case 'Sales':
      default:
        return 'Order No: SI/HO/148';
    }
  }

  // Dynamic bottom action button label based on mode
  String get _dynamicGenerateButtonLabel {
    switch (_activeBillType) {
      case 'Quotation':
        return 'Generate Quote';
      case 'Advance Receipt':
        return 'Generate Advance Receipt';
      case 'Rental':
        return 'Generate Rental';
      case 'Sales Return':
        return 'Process Return';
      case 'Sales':
      default:
        return 'Generate Bill';
    }
  }

  void _addProductToCart(ProductItemModel item) {
    setState(() {
      final key = item.id.toString();
      _cart[key] = (_cart[key] ?? 0) + 1;
      if (_cartItems.containsKey(key)) {
        _cartItems[key]!.quantity++;
      } else {
        _cartItems[key] = SalesCartItem(
          product: item,
          quantity: 1,
          price: item.numericPrice,
        );
      }
    });
    Get.snackbar(
      'Item Added',
      '${item.name} added to bill',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(12),
    );
  }

  void _decrementCartItem(ProductItemModel item) {
    setState(() {
      final key = item.id.toString();
      if (_cartItems.containsKey(key)) {
        if (_cartItems[key]!.quantity > 1) {
          _cartItems[key]!.quantity--;
          _cart[key] = _cartItems[key]!.quantity;
        } else {
          _cartItems[key]?.dispose();
          _cartItems.remove(key);
          _cart.remove(key);
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final it in _cartItems.values) {
        it.dispose();
      }
      _cartItems.clear();
      _cart.clear();
      _selectedCustomer = 'Select Customer';
      _selectedCustomerModel = null;
      _selectedCustomerId = null;
      _phoneController.clear();
      _customerGstController.clear();
      _remarksController.clear();
      for (final c in _otherCharges) {
        c.dispose();
      }
      _otherCharges.clear();
      _deliveryCostController.clear();
      _depositController.clear();
      _tdsPercentController.text = '0';
      _discountPercentController.text = '0';
    });
    Get.snackbar(
      'Cleared',
      'All fields and cart items reset',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> _pickOrderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B2C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _orderDate = picked);
    }
  }

  // --- "Create New Bill" Dialog Modal (Screenshot 1) ---
  void _showCreateNewBillDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                    color: const Color(0xFF94A3B8),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x2EFF6B2C),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFFFF6B2C),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Create New Bill',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose bill type for this new entry.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildBillTypeOption(
                        color: const Color(0xFF22C55E),
                        icon: Icons.shopping_cart_outlined,
                        label: 'Sales',
                        onTap: () {
                          setState(() => _activeBillType = 'Sales');
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBillTypeOption(
                        color: const Color(0xFFFF6B2C),
                        icon: Icons.article_outlined,
                        label: 'Quotation',
                        onTap: () {
                          setState(() => _activeBillType = 'Quotation');
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildBillTypeOption(
                        color: const Color(0xFF8B5CF6),
                        icon: Icons.receipt_long_outlined,
                        label: 'Advance Receipt',
                        onTap: () {
                          setState(() => _activeBillType = 'Advance Receipt');
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBillTypeOption(
                        color: const Color(0xFFEAB308),
                        icon: Icons.calendar_month_outlined,
                        label: 'Rental',
                        onTap: () {
                          setState(() => _activeBillType = 'Rental');
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillTypeOption({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  // --- Add Customer Modal ---
  void _showAddCustomerDialog() {
    final nameCtl = TextEditingController();
    final phoneCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Customer',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
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
                Text(
                  'Customer Name',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtl,
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter customer name',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneCtl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final name = nameCtl.text.trim();
                        final phone = phoneCtl.text.trim();
                        if (name.isNotEmpty) {
                          final newCust = CustomerItemModel(
                            id: DateTime.now().millisecondsSinceEpoch % 100000,
                            name: name,
                            phone: phone.isNotEmpty ? phone : null,
                          );
                          setState(() {
                            _liveCustomers.insert(0, newCust);
                            _selectCustomer(newCust);
                          });
                          Navigator.pop(ctx);
                          Get.snackbar(
                            'Customer Added',
                            'Customer $name registered successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF0F172A),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                          );
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectCustomer(CustomerItemModel cust) {
    setState(() {
      _selectedCustomer = cust.name;
      _selectedCustomerModel = cust;
      _selectedCustomerId = cust.id.toString();
      if (cust.phone != null && cust.phone!.trim().isNotEmpty) {
        _phoneController.text = cust.phone!.trim();
      }
      if (cust.gstNumber != null && cust.gstNumber!.trim().isNotEmpty) {
        _customerGstController.text = cust.gstNumber!.trim();
      }
    });
  }

  void _handleCustomerSearchSubmit(
      String query, List<CustomerItemModel> currentFiltered) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Check if exact match exists in _liveCustomers
    CustomerItemModel? exact;
    for (final c in _liveCustomers) {
      if (c.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        exact = c;
        break;
      }
    }
    if (exact != null) {
      _selectCustomer(exact);
      return;
    }

    // Check if only 1 match in current filtered list
    if (currentFiltered.length == 1) {
      _selectCustomer(currentFiltered.first);
      return;
    }

    // Otherwise, create and select new customer
    final newCust = CustomerItemModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      name: trimmed,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
    );

    setState(() {
      _liveCustomers.insert(0, newCust);
      _selectCustomer(newCust);
    });

    Get.snackbar(
      'Customer Added',
      'Added "$trimmed" to customer list',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
    );
  }

  void _showCustomerSearchPicker() {
    final searchController = TextEditingController();
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final trimmed = query.trim().toLowerCase();
            final filtered = _liveCustomers.where((c) {
              if (trimmed.isEmpty) return true;
              final nameMatch = c.name.toLowerCase().contains(trimmed);
              final phoneMatch = c.phone != null && c.phone!.contains(trimmed);
              final codeMatch = c.customerCode != null &&
                  c.customerCode!.toLowerCase().contains(trimmed);
              final cityMatch =
                  c.city != null && c.city!.toLowerCase().contains(trimmed);
              return nameMatch || phoneMatch || codeMatch || cityMatch;
            }).toList();

            bool hasExactMatch = false;
            for (final c in _liveCustomers) {
              if (c.name.trim().toLowerCase() == trimmed) {
                hasExactMatch = true;
                break;
              }
            }

            return Material(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.80,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_rounded,
                                  color: Color(0xFFEA580C),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Select Customer',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (_liveCustomers.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFFED7AA)),
                                    ),
                                    child: Text(
                                      '${_liveCustomers.length}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFEA580C),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(sheetCtx);
                                  _showAddCustomerDialog();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFFED7AA)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add_rounded,
                                          size: 13, color: Color(0xFFEA580C)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add New',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFEA580C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                icon: const Icon(Icons.close_rounded),
                                color: const Color(0xFF64748B),
                                onPressed: () => Navigator.pop(sheetCtx),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Search Bar Input
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search customer name, phone, code...',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFFEA580C),
                            size: 20,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  color: const Color(0xFF64748B),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() => query = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setModalState(() => query = val);
                        },
                        onSubmitted: (val) {
                          final typed = val.trim();
                          if (typed.isEmpty) return;
                          _handleCustomerSearchSubmit(typed, filtered);
                          Navigator.pop(sheetCtx);
                        },
                      ),
                    ),
                  ),

                  // Add New Customer Action Tile (When search query has no exact match)
                  if (query.trim().isNotEmpty && !hasExactMatch)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: InkWell(
                        onTap: () {
                          _handleCustomerSearchSubmit(query.trim(), filtered);
                          Navigator.pop(sheetCtx);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEA580C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add "${query.trim()}"',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFEA580C),
                                      ),
                                    ),
                                    Text(
                                      'Press Enter or tap to add & select customer',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF9A3412),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_return_rounded,
                                size: 18,
                                color: Color(0xFFEA580C),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Customers List
                  Expanded(
                    child: _isLoadingCustomers && _liveCustomers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                    color: Color(0xFFEA580C)),
                                SizedBox(height: 12),
                                Text(
                                  'Loading customers...',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          )
                        : filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_search_rounded,
                                        size: 48,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        query.isEmpty
                                            ? 'No customers found'
                                            : 'No customer matching "$query"',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      if (query.trim().isNotEmpty)
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _handleCustomerSearchSubmit(
                                                query.trim(), filtered);
                                            Navigator.pop(sheetCtx);
                                          },
                                          icon: const Icon(Icons.add_rounded,
                                              size: 18),
                                          label: Text('Add "${query.trim()}"'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFEA580C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        )
                                      else
                                        TextButton.icon(
                                          onPressed: () {
                                            _fetchCustomers();
                                            setModalState(() {});
                                          },
                                          icon: const Icon(
                                              Icons.refresh_rounded,
                                              size: 18),
                                          label:
                                              const Text('Reload Customers'),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFEA580C),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFF1F5F9),
                                ),
                                itemBuilder: (context, index) {
                                  final cust = filtered[index];
                                  final isSelected = _selectedCustomerId ==
                                          cust.id.toString() ||
                                      _selectedCustomer.toLowerCase() ==
                                          cust.name.toLowerCase();

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected
                                          ? const Color(0xFFEA580C)
                                          : const Color(0xFFFFF7ED),
                                      backgroundImage: cust.hasValidImage
                                          ? NetworkImage(
                                              cust.profileImageUrl!)
                                          : null,
                                      child: cust.hasValidImage
                                          ? null
                                          : Text(
                                              cust.initials,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFFEA580C),
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      cust.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFFEA580C)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    subtitle: cust.displaySubtitle.isNotEmpty
                                        ? Text(
                                            cust.displaySubtitle,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          )
                                        : null,
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFFEA580C),
                                            size: 20,
                                          )
                                        : null,
                                    onTap: () {
                                      _selectCustomer(cust);
                                      Navigator.pop(sheetCtx);
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Sales & Bills',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Sales'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              _isBottomPanelExpanded ? 250 : 95,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillModePills(),
                const SizedBox(height: 10),
                _buildGstModePills(),
                const SizedBox(height: 12),
                _buildSearchAndAddRow(),
                const SizedBox(height: 12),
                if (!_isCategoryGridView) ...[
                  _buildCategoryPills(),
                  const SizedBox(height: 14),
                  _buildProductSection(),
                ] else ...[
                  _buildCategoryGridView(),
                ],
                const SizedBox(height: 16),
                _buildCustomerDetailsCard(),
                const SizedBox(height: 16),
                _buildCartItemsSection(),
                const SizedBox(height: 16),
                _buildDeliveryCostCard(),
              ],
            ),
          ),

          // Fixed Bottom Panel matching screenshot design (Drag Handle, Payment Modes, Save Draft, & Sticky Bottom Bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFixedBottomPanel(),
          ),
        ],
      ),
    );
  }



  // --- 2. Bill Mode Filter Pills: Quotation | Advance Receipt | Rental | Sales Return ---
  Widget _buildBillModePills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _billTypes.map((type) {
          final isSelected = _activeBillType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected ? const Color(0xFFFF6B2C) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFF6B2C)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: InkWell(
                onTap: () => setState(() => _activeBillType = type),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 3. GST Mode Filter Pills: Without GST | With GST ---
  Widget _buildGstModePills() {
    return Row(
      children: ['Without GST', 'With GST'].map((gst) {
        final isSelected = _selectedGstMode == gst;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: isSelected ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFED7AA)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedGstMode = gst),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  gst,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFEA580C)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- 4. Search Product + QR/Barcode button + Grid/List switch + "+ Add Product" button ---
  Widget _buildSearchAndAddRow() {
    return Row(
      children: [
        // Barcode / Grid view toggle icon box
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isCategoryGridView
                  ? const Color(0xFFFF6B2C)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: IconButton(
            icon: Icon(
              _isCategoryGridView
                  ? Icons.grid_view_rounded
                  : Icons.qr_code_scanner_rounded,
              color: _isCategoryGridView
                  ? const Color(0xFFFF6B2C)
                  : const Color(0xFF1E293B),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isCategoryGridView = !_isCategoryGridView;
              });
            },
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),

        // Search Input
        Expanded(
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search product...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // "+ Add Product" Orange Button
        Material(
          color: const Color(0xFFFF6B2C),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => Get.to(() => const AddProductScreen()),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Add Product',
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

  // --- 5. Category Pills (Horizontal) ---
  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFED7AA)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 6. Product Section (Shows cards or Empty State from Screenshot 3) ---
  Widget _buildProductSection() {
    if (_isLoadingProducts && _allProducts.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2C)),
            ),
            SizedBox(height: 12),
            Text(
              'Loading products...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final query = _searchController.text.trim().toLowerCase();
    final items = _allProducts.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          (p.sku != null && p.sku!.toLowerCase().contains(query)) ||
          (p.barcode != null && p.barcode!.toLowerCase().contains(query));
      final matchesCat = _selectedCategory == 'All Products' ||
          p.categoryName.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesQuery && matchesCat;
    }).toList();

    // If no products found in category (Screenshot 3: Male1 selected)
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Open Carton Icon
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x2EFF6B2C),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.all_inbox_rounded,
                color: Color(0xFFEA580C),
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No products found in this category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () =>
                  setState(() => _selectedCategory = 'All Products'),
              child: Text(
                'View All Products',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF6B2C),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // High-Performance Virtualized Product Section with Header Counter & Grid Browser
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Products (${items.length})',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => _showAllProductsModal(items),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.grid_view_rounded,
                        size: 15,
                        color: Color(0xFFFF6B2C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View All (Grid)',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B2C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemExtent: 167,
            itemBuilder: (context, index) {
              final product = items[index];
              final quantity = _cart[product.id.toString()] ?? 0;
              return RepaintBoundary(
                child: Container(
                  width: 155,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: quantity > 0
                          ? const Color(0xFFFF6B2C)
                          : const Color(0xFFFED7AA),
                      width: quantity > 0 ? 1.5 : 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _addProductToCart(product),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFFED7AA)),
                                ),
                                child: const Icon(
                                  Icons.edit_note_rounded,
                                  size: 16,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                            Container(
                              width: 72,
                              height: 60,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: product.validImageUrl != null
                                  ? Image.network(
                                      product.validImageUrl!,
                                      cacheWidth: 150,
                                      cacheHeight: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 38,
                                        color: Color(0xFF64748B),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 38,
                                      color: Color(0xFF64748B),
                                    ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.unitName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(product.numericPrice),
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                            if (quantity > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B2C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Qty: $quantity',
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Modal to browse all products in a smooth 2-column grid with pagination ---
  void _showAllProductsModal(List<ProductItemModel> currentItems) {
    int modalCurrentPage = 1;
    int modalPageSize = 10;
    final ScrollController modalScrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final modalQuery = _searchController.text.trim().toLowerCase();
            final filtered = _allProducts.where((p) {
              final matchQuery = modalQuery.isEmpty ||
                  p.name.toLowerCase().contains(modalQuery) ||
                  (p.sku != null && p.sku!.toLowerCase().contains(modalQuery)) ||
                  (p.barcode != null &&
                      p.barcode!.toLowerCase().contains(modalQuery));
              final matchCat = _selectedCategory == 'All Products' ||
                  p.categoryName.toLowerCase() ==
                      _selectedCategory.toLowerCase();
              return matchQuery && matchCat;
            }).toList();

            final totalItems = filtered.length;
            final totalPages =
                (totalItems / modalPageSize).ceil().clamp(1, 999999);
            if (modalCurrentPage > totalPages) {
              modalCurrentPage = totalPages;
            }
            final startIndex = (modalCurrentPage - 1) * modalPageSize;
            final endIndex =
                (startIndex + modalPageSize).clamp(0, totalItems);
            final pageItems = totalItems > 0
                ? filtered.sublist(startIndex, endIndex)
                : <ProductItemModel>[];

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Browse All Products',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${filtered.length} products available (Page $modalCurrentPage of $totalPages)',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Search TextField with vertically centered hint
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (_) {
                          setState(() {});
                          setModalState(() {
                            modalCurrentPage = 1;
                          });
                        },
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Search product, SKU or barcode...',
                          hintStyle: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    setModalState(() {
                                      modalCurrentPage = 1;
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product Grid for current page
                  Expanded(
                    child: pageItems.isEmpty
                        ? Center(
                            child: Text(
                              'No products match your search',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : GridView.builder(
                            controller: modalScrollController,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: pageItems.length,
                            itemBuilder: (context, index) {
                              final product = pageItems[index];
                              final key = product.id.toString();
                              final qty = _cart[key] ?? 0;
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () {
                                    _addProductToCart(product);
                                    setModalState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: qty > 0
                                            ? const Color(0xFFFF6B2C)
                                            : const Color(0xFFE2E8F0),
                                        width: qty > 0 ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: product.validImageUrl != null
                                                ? Image.network(
                                                    product.validImageUrl!,
                                                    cacheWidth: 150,
                                                    cacheHeight: 120,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (c, e, s) =>
                                                            const Icon(
                                                      Icons
                                                          .inventory_2_outlined,
                                                      size: 36,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .inventory_2_outlined,
                                                    size: 36,
                                                    color: Color(0xFF64748B),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          product.unitName,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatCurrency(
                                                  product.numericPrice),
                                              style: TextStyle(
                                                fontSize: 13.5.sp,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    const Color(0xFFEA580C),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: qty > 0
                                                    ? const Color(0xFFFF6B2C)
                                                    : const Color(
                                                        0xFFFFF7ED),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                qty > 0
                                                    ? 'Qty: $qty'
                                                    : '+ Add',
                                                style: TextStyle(
                                                  fontSize: 11.5.sp,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: qty > 0
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFFEA580C),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // --- Bottom Pagination Controls Bar ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          totalItems == 0
                              ? '0 products'
                              : '${startIndex + 1}-$endIndex of $totalItems',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Previous Page Button
                            Material(
                              color: modalCurrentPage > 1
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              child: InkWell(
                                onTap: modalCurrentPage > 1
                                    ? () {
                                        setModalState(() {
                                          modalCurrentPage--;
                                          if (modalScrollController
                                              .hasClients) {
                                            modalScrollController.animateTo(
                                              0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        });
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    size: 20,
                                    color: modalCurrentPage > 1
                                        ? const Color(0xFFFF6B2C)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Page Number Pills
                            ..._buildPaginationPills(
                              currentPage: modalCurrentPage,
                              totalPages: totalPages,
                              onPageSelected: (p) {
                                setModalState(() {
                                  modalCurrentPage = p;
                                  if (modalScrollController.hasClients) {
                                    modalScrollController.animateTo(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 4),

                            // Next Page Button
                            Material(
                              color: modalCurrentPage < totalPages
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              child: InkWell(
                                onTap: modalCurrentPage < totalPages
                                    ? () {
                                        setModalState(() {
                                          modalCurrentPage++;
                                          if (modalScrollController
                                              .hasClients) {
                                            modalScrollController.animateTo(
                                              0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        });
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: modalCurrentPage < totalPages
                                        ? const Color(0xFFFF6B2C)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper to build numbered pagination pills ---
  List<Widget> _buildPaginationPills({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageSelected,
  }) {
    final List<Widget> pills = [];

    // Select which page numbers to display
    final Set<int> pagesToShow = {};
    pagesToShow.add(1);
    pagesToShow.add(totalPages);
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i >= 1 && i <= totalPages) {
        pagesToShow.add(i);
      }
    }

    final sortedPages = pagesToShow.toList()..sort();
    int? lastPage;

    for (final page in sortedPages) {
      if (lastPage != null && page - lastPage > 1) {
        pills.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '...',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
        );
      }

      final isCurrent = page == currentPage;
      pills.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: isCurrent ? const Color(0xFFFF6B2C) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => onPageSelected(page),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                constraints: const BoxConstraints(minWidth: 28),
                height: 28,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFFFF6B2C)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      lastPage = page;
    }

    return pills;
  }

  // --- 6B. Category Grid View (Screenshot 4) ---
  Widget _buildCategoryGridView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Browse Categories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _isCategoryGridView = false),
                child: Text(
                  'Show Products View',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B2C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _liveCategories.isNotEmpty
                ? _liveCategories.length
                : _gridCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              if (_liveCategories.isNotEmpty) {
                final cat = _liveCategories[index];
                final isSelected = _selectedCategory == cat.name;
                final pastelColors = [
                  const Color(0xFFFFFBEB),
                  const Color(0xFFFAF5FF),
                  const Color(0xFFF0F9FF),
                  const Color(0xFFFFF7ED),
                  const Color(0xFFF8FAFC),
                  const Color(0xFFF0FDF4),
                  const Color(0xFFEFF6FF),
                  const Color(0xFFFFF1F2),
                ];
                final iconColors = [
                  const Color(0xFFD97706),
                  const Color(0xFF9333EA),
                  const Color(0xFF0284C7),
                  const Color(0xFFEA580C),
                  const Color(0xFF475569),
                  const Color(0xFF16A34A),
                  const Color(0xFF2563EB),
                  const Color(0xFFE11D48),
                ];
                final bgColor = pastelColors[index % pastelColors.length];
                final iconColor = iconColors[index % iconColors.length];

                return Material(
                  color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFFF6B2C)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat.name;
                        _isCategoryGridView = false; // Switch to see filtered products
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: cat.validImageUrl != null
                                ? Image.network(
                                    cat.validImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Icon(
                                      Icons.category_outlined,
                                      color: iconColor,
                                      size: 24,
                                    ),
                                  )
                                : Icon(
                                    Icons.category_outlined,
                                    color: iconColor,
                                    size: 24,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFFFF6B2C)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final cat = _gridCategories[index];
              final isSelected = _selectedCategory == cat.name;
              return Material(
                color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFFF6B2C)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat.name;
                      _isCategoryGridView = false; // Switch to see filtered products
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cat.bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(cat.icon, color: cat.iconColor, size: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFFF6B2C)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 7. Customer Details Card ---
  Widget _buildCustomerDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Customer details + Add button + Fullscreen + Dynamic Order No + Back
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                color: Color(0xFFEA580C),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Customer details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: _showAddCustomerDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFFEA580C),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      _dynamicOrderBadge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Orange bordered customer card (Screenshot 4)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFF9800), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Customer name & Customer phone
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  size: 15, color: Color(0xFFEA580C)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Customer name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _showCustomerSearchPicker,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 42,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedCustomer != 'Select Customer'
                                      ? const Color(0xFFEA580C)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedCustomer,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: _selectedCustomer ==
                                                'Select Customer'
                                            ? FontWeight.normal
                                            : FontWeight.w600,
                                        color: _selectedCustomer ==
                                                'Select Customer'
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (_isLoadingCustomers)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFEA580C),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF64748B),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 15, color: Color(0xFFEA580C)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Customer phone',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textAlignVertical: TextAlignVertical.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Customer number',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Row 2: Customer GST no - ONLY shown when 'With GST' mode is active
                if (_selectedGstMode == 'With GST') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 15, color: Color(0xFFEA580C)),
                      const SizedBox(width: 4),
                      Text(
                        'Customer GST no',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: TextField(
                      controller: _customerGstController,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter GST to auto-fill',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Row 2: Order Date | Assign Staff | Order Type
          Row(
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickOrderDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF64748B),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDate(_orderDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF64748B),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign Staff',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _assignedStaff,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                  size: 18,
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                                items: _staffList.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s,
                                    child: Text(
                                      s,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _assignedStaff = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Type',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _orderType,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                  size: 18,
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                                items: _orderTypes.map((ot) {
                                  return DropdownMenuItem<String>(
                                    value: ot,
                                    child: Text(
                                      ot,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _orderType = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  // --- 7. Cart Items Section (Pill + Clear All + Product Billing Cards) ---
  Widget _buildCartItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Items & Clear All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total items : $_totalItems',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            InkWell(
              onTap: _clearAll,
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),

        // Product Cards (Screenshot ERP billing card design)
        if (_cartItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._cartItems.values.map((cartItem) => _buildCartItemCard(cartItem)),
        ],
      ],
    );
  }

  // --- Cart Item Card matching ERP billing card design (Screenshot) ---
  Widget _buildCartItemCard(SalesCartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Product Name + Orange Edit Icon + Remove Button
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: Color(0xFFFF8A00),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    final key = item.product.id.toString();
                    item.dispose();
                    _cartItems.remove(key);
                    _cart.remove(key);
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),

          // Green GST Breakdown Card when With GST (Screenshot 5)
          if (_selectedGstMode == 'With GST') ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(6),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFF10B981),
                    width: 3.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CGST: 9.00% (${_formatCurrency(item.cgstAmount)})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SGST: 9.00% (${_formatCurrency(item.sgstAmount)})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Product GST Total:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    _formatCurrency(item.gstTotal),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Product GST WITH Total: ${_formatCurrency(item.withGstTotal)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 2. Dashed Border Box for Product Description
          CustomPaint(
            painter: DashedBorderPainter(
              color: const Color(0xFFCBD5E1),
              strokeWidth: 1.0,
              dashWidth: 4.0,
              dashSpace: 3.0,
              borderRadius: 6.0,
            ),
            child: Container(
              width: double.infinity,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: item.descController,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Product description...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  item.description = val;
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. Row with Thumbnail, Qty [-] 1 [+], Price Box, Disc %, Disc Amt, Sub Total, Final Total
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: item.product.validImageUrl != null &&
                            !item.product.validImageUrl!.contains('noimage')
                        ? Image.network(
                            item.product.validImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                  ),
                ),
                const SizedBox(width: 8),

                // Qty Selector: [-]  qty  [+]
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _decrementCartItem(item.product),
                        child: Container(
                          width: 28,
                          height: 34,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.remove,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Container(
                        width: 32,
                        height: 34,
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: const Color(0xFFE2E8F0),
                      ),
                      InkWell(
                        onTap: () => _addProductToCart(item.product),
                        child: Container(
                          width: 28,
                          height: 34,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Price Box (Editable TextField)
                Container(
                  height: 34,
                  width: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: TextField(
                    controller: item.priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      setState(() {
                        item.price = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Disc %
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Disc %',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 44,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: item.discPercentController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          setState(() {
                            final pct = double.tryParse(val) ?? 0.0;
                            item.discountPercent = pct;
                            if (pct > 0) {
                              item.discountAmount =
                                  (item.subtotal * pct) / 100;
                              item.discAmountController.text =
                                  item.discountAmount.toStringAsFixed(0);
                            } else {
                              item.discountAmount = 0.0;
                              item.discAmountController.text = '0';
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),

                // Disc Amt
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Disc Amt',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 48,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: item.discAmountController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          setState(() {
                            final amt = double.tryParse(val) ?? 0.0;
                            item.discountAmount = amt;
                            if (item.subtotal > 0 && amt > 0) {
                              item.discountPercent =
                                  (amt / item.subtotal) * 100;
                              item.discPercentController.text =
                                  item.discountPercent.toStringAsFixed(0);
                            } else {
                              item.discountPercent = 0.0;
                              item.discPercentController.text = '0';
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // Sub Total & GST & Final Total Column matching Screenshot 5
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Row 1: Sub Total
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sub Total: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                        Text(
                          _formatCurrency(item.subtotal),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 2: GST Inc box (if With GST) + Delete trash icon (Screenshot 5)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedGstMode == 'With GST') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF0EA5E9),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'GST Inc: ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatCurrency(item.gstTotal),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        InkWell(
                          onTap: () {
                            setState(() {
                              final key = item.product.id.toString();
                              item.dispose();
                              _cartItems.remove(key);
                              _cart.remove(key);
                            });
                          },
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 3: Final Total
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Final Total: ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        Text(
                          _formatCurrency(_selectedGstMode == 'With GST'
                              ? item.withGstTotal
                              : item.finalTotal),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Sheet: Other Charges (Screenshot 2) ---
  void _showOtherChargesBottomSheet() {
    if (_otherCharges.isEmpty) {
      _otherCharges.add(OtherChargeItem());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              margin: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header: "Other Charges" + Orange "+" button (Screenshot 2)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Other Charges',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setModalState(() {
                              _otherCharges.add(OtherChargeItem());
                            });
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0xFFFED7AA)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFFEA580C),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // List of rows: [Charge Name] [Amount] [Trash Icon] (Screenshot 2)
                  Flexible(
                    child: _otherCharges.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No other charges added.',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      _otherCharges.add(OtherChargeItem());
                                    });
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Charge'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEA580C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            itemCount: _otherCharges.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _otherCharges[index];
                              return Row(
                                children: [
                                  // Charge Name
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: TextField(
                                        controller: item.nameController,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Charge Name',
                                          hintStyle: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (_) {
                                          setModalState(() {});
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Amount
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: TextField(
                                        controller: item.amountController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Amount',
                                          hintStyle: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (_) {
                                          setModalState(() {});
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Red Trash Icon Button (Screenshot 2)
                                  InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        item.dispose();
                                        _otherCharges.removeAt(index);
                                      });
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFEF4444)),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  // Bottom Total & Apply Action
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Other Charges:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            Text(
                              _formatCurrency(_otherChargesTotal),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(sheetContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Apply & Close',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Bottom Sheet: Remarks (Optional) (Screenshot 3) ---
  void _showRemarksBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Container(
          margin: EdgeInsets.only(bottom: bottomInset),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title matching Screenshot 3: "Remarks (Optional)"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remarks (Optional)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(sheetContext),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Orange Bordered Box matching Screenshot 3
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF9800),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _remarksController,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter remarks...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Remarks',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 8. Delivery Cost Card (with dynamic Deposit for Rental & Price Lock for Advance) ---
  Widget _buildDeliveryCostCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF0F172A),
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Delivery Cost',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Action pills: Other Charges +, Remarks + (Labour removed per request)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSmallAddPill(
                        _otherCharges.isNotEmpty
                            ? 'Other Charges (${_otherCharges.length}) +'
                            : 'Other Charges +',
                        _showOtherChargesBottomSheet,
                      ),
                      const SizedBox(width: 6),
                      _buildSmallAddPill(
                        _remarksController.text.trim().isNotEmpty
                            ? 'Remarks (Added)'
                            : 'Remarks +',
                        _showRemarksBottomSheet,
                        icon: _remarksController.text.trim().isNotEmpty
                            ? Icons.check
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Delivery Cost Input
          Container(
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _deliveryCostController,
              keyboardType: TextInputType.number,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Delivery Cost.',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF94A3B8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: InputBorder.none,
              ),
            ),
          ),

          // Deposit / Advance Field ONLY in Rental Mode (Screenshot 3)
          if (_activeBillType == 'Rental') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Deposit / Advance',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: TextField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Enter Deposit Amount',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // TDS Percentage (%) & TDS Amount
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TDS Percentage (%)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _tdsPercentController,
                        keyboardType: TextInputType.number,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TDS Amount',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        _tdsAmount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Discount (%) & Discount Amount
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount (%)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _discountPercentController,
                        keyboardType: TextInputType.number,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount Amount',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        _discountAmount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Price Locked notice for Advance Receipt Mode (Screenshot 2)
          if (_activeBillType == 'Advance Receipt') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF9333EA),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Product price will be locked at current price when advance is paid.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B21A8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Summary Rows matching Screenshot / Image 2
          // Total (Product) row (always shown)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (Product)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                _formatCurrency(_productSubtotal),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          // Total GST Amount - shown only when With GST is active & GST > 0
          if (_selectedGstMode == 'With GST' && _totalGstAmount > 0) ...[
            _buildDashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total GST Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                Text(
                  _formatCurrency(_totalGstAmount),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],

          // Delivery Cost breakdown line - shown only when > 0
          if (_deliveryCost > 0) ...[
            _buildDashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Cost',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                Text(
                  '+ ${_formatCurrency(_deliveryCost)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],

          // Other Charges breakdown line - shown only when > 0
          if (_otherChargesTotal > 0) ...[
            _buildDashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Other Charges',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                Text(
                  '+ ${_formatCurrency(_otherChargesTotal)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],

          // Discount Amount breakdown line - shown only when > 0
          if (_discountAmount > 0) ...[
            _buildDashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                Text(
                  _formatCurrency(_discountAmount),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],

          // SubTotal row - shown only when adjustments exist (matching Image 2)
          if ((_selectedGstMode == 'With GST' && _totalGstAmount > 0) ||
              _deliveryCost > 0 ||
              _otherChargesTotal > 0 ||
              _discountAmount > 0) ...[
            _buildDashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SubTotal',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _formatCurrency(_subtotalAmount),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],

          // TDS row - shown ONLY when TDS is actually added (> 0) per user request
          if (_tdsAmount > 0) ...[
            _buildDashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TDS (${(double.tryParse(_tdsPercentController.text) ?? 0).toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '- ${_formatCurrency(_tdsAmount)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],

          // Grand Total line
          _buildDashedDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                _formatCurrency(_grandTotal),
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Subtle dashed divider for breakdown rows matching Image 2
  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 4.0;
          const dashSpace = 3.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          if (dashCount <= 0) {
            return const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0));
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSmallAddPill(String label, VoidCallback onTap, {IconData? icon}) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Color(0xFFFED7AA)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEA580C),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 14, color: const Color(0xFFEA580C)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- 9. Payment Method Selector Bar ---
  Widget _buildPaymentModesBar() {
    final modes = [
      {'label': 'Pay Later', 'icon': Icons.history_rounded},
      {'label': 'Cash', 'icon': Icons.payments_outlined},
      {'label': 'Debit', 'icon': Icons.credit_card_outlined},
      {'label': 'Cash+Online', 'icon': Icons.account_balance_wallet_outlined},
      {'label': 'Scan', 'icon': Icons.qr_code_2_rounded},
      {'label': 'EMI', 'icon': Icons.calendar_view_month_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: modes.map((m) {
          final isSelected = _selectedPaymentMode == m['label'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFF6B2C)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: InkWell(
                onTap: () =>
                    setState(() => _selectedPaymentMode = m['label'] as String),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? const Color(0xFFFF6B2C)
                            : const Color(0xFF1E293B),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFFF6B2C)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 10. Save Draft Button ---
  Widget _buildSaveDraftButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B2C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Get.snackbar(
            'Draft Saved',
            'Bill draft for $_activeBillType saved successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF0F172A),
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
        },
        child: Text(
          'Save Draft',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- Combined Fixed Bottom Panel matching screenshot ---
  Widget _buildFixedBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag / Tap Handle Header (↑ drag to reveal products ↓)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isBottomPanelExpanded = !_isBottomPanelExpanded;
                });
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! > 80) {
                    setState(() => _isBottomPanelExpanded = false);
                  } else if (details.primaryVelocity! < -80) {
                    setState(() => _isBottomPanelExpanded = true);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF94A3B8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isBottomPanelExpanded
                          ? '↑ drag to reveal products ↓'
                          : '↓ tap to show payment options ↑',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Expandable Body: Payment Methods Bar & Save Draft Button
            AnimatedCrossFade(
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildPaymentModesBar(),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildSaveDraftButton(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _isBottomPanelExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),

            // 3. Navy Bottom Bar: Total Amount & Dynamic Generate Button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _buildStickyBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 11. Sticky Bottom Bar: Total Amount & Dynamic Generate Button ---
  Widget _buildStickyBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Total Amount : ${_formatCurrency(_grandTotal)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: _isSubmittingOrder ? null : _submitOrderSale,
            child: _isSubmittingOrder
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dynamicGenerateButtonLabel,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // --- Submit Order Sale to /api/order_sale ---
  Future<void> _submitOrderSale() async {
    if (_cartItems.isEmpty) {
      Get.snackbar(
        'Empty Bill',
        'Please add at least one product before generating bill.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (_isSubmittingOrder) return;

    setState(() => _isSubmittingOrder = true);

    try {
      final formattedDate =
          "${_orderDate.year}-${_orderDate.month.toString().padLeft(2, '0')}-${_orderDate.day.toString().padLeft(2, '0')}";

      final items = _cartItems.values.map((cartItem) {
        return CreateOrderItemRequestModel(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          quantity: cartItem.quantity,
          price: cartItem.price,
          total: _selectedGstMode == 'With GST'
              ? cartItem.withGstTotal
              : cartItem.finalTotal,
        );
      }).toList();

      final customerIdToUse = _selectedCustomerId ??
          (_selectedCustomerModel?.id.toString() ?? "1");
      final customerPhoneToUse = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : (_selectedCustomerModel?.phone ?? "9876543210");

      final gstOption =
          _selectedGstMode == 'With GST' ? 'with_gst' : 'without_gst';

      final request = CreateOrderSaleRequestModel(
        customerId: customerIdToUse,
        customerPhone: customerPhoneToUse,
        gstOption: gstOption,
        orderDate: formattedDate,
        quotationStatus: "sale",
        paymentMethod: _selectedPaymentMode.toLowerCase(),
        paidType: "cash_fully",
        subtotal: _productSubtotal,
        amount: _grandTotal,
        paymentAmount: _grandTotal,
        pendingAmount: 0.0,
        cashAmount: _grandTotal,
        total: _grandTotal,
        discount: _discountAmount,
        remarks: _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : "Sale order placed from mobile app",
        items: items,
      );

      if (kDebugMode) {
        debugPrint(
            '\n==================== [SALES SCREEN: SUBMITTING SALE ORDER] ====================');
        debugPrint(
            'JSON Payload:\n${const JsonEncoder.withIndent('  ').convert(request.toJson())}');
        debugPrint(
            '=================================================================================\n');
      }

      final response = await _orderService.createOrderSale(request);

      if (kDebugMode) {
        debugPrint('🏁 [SALES SCREEN] Order Response: status=${response.status}, order_id=${response.orderId}, message="${response.message}"');
      }

      setState(() => _isSubmittingOrder = false);

      if (response.status) {
        // Clear active cart upon successful sale
        setState(() {
          _cart.clear();
          _cartItems.clear();
        });

        if (mounted) {
          _showOrderSuccessDialog(response);
        }
      } else {
        Get.snackbar(
          'Order Failed',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to place order sale. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      setState(() => _isSubmittingOrder = false);
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // --- Show Order Success Dialog ---
  void _showOrderSuccessDialog(CreateOrderSaleResponseModel response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final invoice = response.salesInvoice;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  response.orderId != null
                      ? 'Order #${response.orderId} created successfully.'
                      : response.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (invoice != null && invoice.fileUrl != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            invoice.fileName ?? 'Invoice PDF',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'New Sale',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.off(() => const AllSalesScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B2C),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'View All Sales',
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
              ],
            ),
          ),
        );
      },
    );
  }
}
