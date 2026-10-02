import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../products/view/add_product_screen.dart';

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

  // Search & Calculator
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  // Customer Details
  String _selectedCustomer = 'Select Customer';
  final TextEditingController _phoneController = TextEditingController();
  DateTime _orderDate = DateTime(2026, 10, 2);
  String _assignedStaff = 'Select Staff (Optional)';
  String _orderType = 'Self Pickup';

  // Charges, Discounts, & Deposit
  final TextEditingController _deliveryCostController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _tdsPercentController =
      TextEditingController(text: '0');
  final TextEditingController _discountPercentController =
      TextEditingController(text: '0');

  // Product Inventory Data
  final List<SalesProductItem> _allProducts = [
    const SalesProductItem(
      id: '1',
      name: 'Basmati Rice',
      category: 'Food',
      unit: 'Liter',
      price: 180.00,
      icon: Icons.rice_bowl_outlined,
    ),
    const SalesProductItem(
      id: '2',
      name: 'Sandwitch',
      category: 'Food',
      unit: 'Pcs',
      price: 250.00,
      icon: Icons.fastfood_outlined,
    ),
    const SalesProductItem(
      id: '3',
      name: 'Organic Milk',
      category: 'Drinks',
      unit: 'Liter',
      price: 65.00,
      icon: Icons.local_drink_outlined,
    ),
    const SalesProductItem(
      id: '4',
      name: 'Office Chair',
      category: 'Furniture',
      unit: 'Pcs',
      price: 3200.00,
      icon: Icons.chair_outlined,
    ),
  ];

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

  final List<String> _categories = [
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
    _searchController.dispose();
    _phoneController.dispose();
    _deliveryCostController.dispose();
    _depositController.dispose();
    _tdsPercentController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  // Calculations
  int get _totalItems => _cart.values.fold(0, (sum, qty) => sum + qty);

  double get _productSubtotal {
    double total = 0.0;
    _cart.forEach((id, qty) {
      final product = _allProducts.firstWhereOrNull((p) => p.id == id);
      if (product != null) {
        total += product.price * qty;
      }
    });
    return total;
  }

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

  double get _grandTotal {
    double total = _productSubtotal + _deliveryCost - _discountAmount + _tdsAmount;
    if (_selectedGstMode == 'With GST') {
      total += (_productSubtotal * 0.18); // 18% GST calculation
    }
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

  void _addProductToCart(SalesProductItem item) {
    setState(() {
      _cart[item.id] = (_cart[item.id] ?? 0) + 1;
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

  void _clearAll() {
    setState(() {
      _cart.clear();
      _selectedCustomer = 'Select Customer';
      _phoneController.clear();
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
                          setState(() {
                            _customerList.add(name);
                            _selectedCustomer = name;
                            if (phone.isNotEmpty) {
                              _phoneController.text = phone;
                            }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopAppBar(),
                const SizedBox(height: 12),
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
                _buildDeliveryCostCard(),
                const SizedBox(height: 16),
                _buildPaymentModesBar(),
                const SizedBox(height: 16),
                _buildSaveDraftButton(),
              ],
            ),
          ),

          // Sticky Bottom Bar: Total Amount & Generate Bill / Quote / Advance / Rental
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomBar(),
          ),

          // Floating Calculator Widget overlay
          if (_isCalculatorOpen)
            Positioned(
              right: 16,
              bottom: 80,
              child: CalculatorWidget(
                onClose: () => setState(() => _isCalculatorOpen = false),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          heroTag: 'sales_bills_fab',
          onPressed: () {
            setState(() {
              _isCalculatorOpen = !_isCalculatorOpen;
            });
          },
          backgroundColor: const Color(0xFF1E1B4B),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.calculate_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  // --- 1. Top Bar: Back Button, Title ("Bill 1"), Plus Circle button ---
  Widget _buildTopAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 14),
            Text(
              'Bill 1',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        // Dark Navy "+" Button in AppBar opening "Create New Bill" modal
        Material(
          color: const Color(0xFF1E1B4B),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _showCreateNewBillDialog,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(7),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
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
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
    final query = _searchController.text.trim().toLowerCase();
    final items = _allProducts.where((p) {
      final matchesQuery = query.isEmpty || p.name.toLowerCase().contains(query);
      final matchesCat = _selectedCategory == 'All Products' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
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
              onPressed: () => setState(() => _selectedCategory = 'All Products'),
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

    // Horizontal Product Cards (Screenshots 1, 2)
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((product) {
          final quantity = _cart[product.id] ?? 0;
          return Container(
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
                  padding: const EdgeInsets.all(10),
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
                            border: Border.all(color: const Color(0xFFFED7AA)),
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
                        child: Icon(
                          product.icon,
                          size: 40,
                          color: const Color(0xFF64748B),
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
                        product.unit,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(product.price),
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
          );
        }).toList(),
      ),
    );
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
            itemCount: _gridCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
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
                  fontSize: 15.sp,
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
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Icon(
                  Icons.crop_free_rounded,
                  color: Color(0xFF1E293B),
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: const Color(0xFFFF6B2C),
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Get.back();
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          'Back',
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

          const SizedBox(height: 14),

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
                        Text(
                          'Customer name',
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCustomer,
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
                          items: _customerList.map((c) {
                            return DropdownMenuItem<String>(
                              value: c,
                              child: Text(
                                c,
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
                              setState(() => _selectedCustomer = val);
                            }
                          },
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
                        Text(
                          'Customer phone',
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Customer number',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

          const SizedBox(height: 12),

          // Total Items & Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total items : $_totalItems',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              InkWell(
                onTap: _clearAll,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

              // Action pills: Other Charges +, Labour +, Remarks + / T&C
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSmallAddPill('Other Charges +', () {}),
                      const SizedBox(width: 6),
                      _buildSmallAddPill('Labour +', () {}),
                      const SizedBox(width: 6),
                      if (_activeBillType == 'Sales')
                        _buildSmallAddPill('T&C and Remarks', () {},
                            icon: Icons.edit_outlined)
                      else
                        _buildSmallAddPill('Remarks +', () {}),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _deliveryCostController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Delivery Cost.',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF94A3B8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: TextField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Deposit Amount',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _tdsPercentController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(fontSize: 14.sp),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _discountPercentController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(fontSize: 14.sp),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

          // Total (Product) row
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
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          // TDS row (Screenshot 1, 4)
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TDS (0.00%)',
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

          // Grand Total line
          const SizedBox(height: 4),
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

  // --- 11. Sticky Bottom Bar: Total Amount & Dynamic Generate Button ---
  Widget _buildStickyBottomBar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            onTap: () {
              Get.snackbar(
                'Success',
                '$_dynamicGenerateButtonLabel successful with total ${_formatCurrency(_grandTotal)}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF22C55E),
                colorText: Colors.white,
                margin: const EdgeInsets.all(12),
              );
            },
            child: Row(
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
}
