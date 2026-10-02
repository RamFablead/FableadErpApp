import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import 'import_financers_screen.dart';

/// Model representing a Financer record
class FinancerItem {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String status;
  final String? email;
  final String? creditLimit;
  final String? pan;
  final String? gstin;

  const FinancerItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    this.status = 'Active',
    this.email,
    this.creditLimit,
    this.pan,
    this.gstin,
  });

  FinancerItem copyWith({
    String? name,
    String? phone,
    String? city,
    String? status,
    String? email,
    String? creditLimit,
    String? pan,
    String? gstin,
  }) {
    return FinancerItem(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      status: status ?? this.status,
      email: email ?? this.email,
      creditLimit: creditLimit ?? this.creditLimit,
      pan: pan ?? this.pan,
      gstin: gstin ?? this.gstin,
    );
  }
}

/// Screen displaying all financers with search, filters, add, and import options
/// Located at lib/screens/financers/view/financers_screen.dart
class FinancersScreen extends StatefulWidget {
  const FinancersScreen({super.key});

  @override
  State<FinancersScreen> createState() => _FinancersScreenState();
}

class _FinancersScreenState extends State<FinancersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCalculatorOpen = false;

  late List<FinancerItem> _financers;

  @override
  void initState() {
    super.initState();
    _financers = [
      const FinancerItem(
        id: '1',
        name: 'Ram Financer',
        phone: '09428618514',
        city: 'Surat',
        status: 'Active',
        email: 'ram.financer@example.com',
        creditLimit: '₹ 5,00,000',
        pan: 'ABCDE1234F',
        gstin: '24ABCDE1234F1Z5',
      ),
      const FinancerItem(
        id: '2',
        name: 'test-financer',
        phone: '1235647854',
        city: 'N/A',
        status: 'Active',
        email: 'test@financer.com',
        creditLimit: '₹ 2,00,000',
        pan: 'BCDEF2345G',
        gstin: '24BCDEF2345G1Z6',
      ),
      const FinancerItem(
        id: '3',
        name: 'Test',
        phone: '6654321234',
        city: 'Surat',
        status: 'Active',
        email: 'test.surat@example.com',
        creditLimit: '₹ 3,50,000',
        pan: 'CDEFG3456H',
        gstin: '24CDEFG3456H1Z7',
      ),
      const FinancerItem(
        id: '4',
        name: 'Bhavik',
        phone: 'N/A',
        city: 'N/A',
        status: 'Active',
        email: 'bhavik@example.com',
        creditLimit: '₹ 1,00,000',
        pan: 'DEFGH4567I',
        gstin: '24DEFGH4567I1Z8',
      ),
      const FinancerItem(
        id: '5',
        name: 'sneha makvana',
        phone: 'N/A',
        city: 'N/A',
        status: 'Active',
        email: 'sneha@example.com',
        creditLimit: '₹ 1,50,000',
        pan: 'EFGHI5678J',
        gstin: '24EFGHI5678J1Z9',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FinancerItem> get _filteredFinancers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _financers;
    return _financers.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.phone.toLowerCase().contains(query) ||
          item.city.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query);
    }).toList();
  }

  Color _getAvatarBgColor(int index) {
    const colors = [
      Color(0xFFFFE8DC), // Soft orange/peach
      Color(0xFFF3E8FF), // Soft purple
      Color(0xFFE0F2FE), // Soft blue
      Color(0xFFDCFCE7), // Soft green
      Color(0xFFFFE4E6), // Soft pink/rose
    ];
    return colors[index % colors.length];
  }

  Color _getAvatarTextColor(int index) {
    const colors = [
      Color(0xFFEA580C), // Deep orange
      Color(0xFF9333EA), // Deep purple
      Color(0xFF0284C7), // Deep blue
      Color(0xFF16A34A), // Deep green
      Color(0xFFE11D48), // Deep pink
    ];
    return colors[index % colors.length];
  }

  void _showAddFinancerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final cityController = TextEditingController();
    final emailController = TextEditingController();
    String status = 'Active';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Financer',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFE2E8F0)),

                      // Financer Name *
                      _buildDialogFieldLabel('Financier Name', isRequired: true),
                      const SizedBox(height: 6),
                      _buildDialogTextField(nameController, 'Enter financier name'),

                      const SizedBox(height: 14),

                      // Phone
                      _buildDialogFieldLabel('Phone Number'),
                      const SizedBox(height: 6),
                      _buildDialogTextField(phoneController, 'Enter phone number', keyboardType: TextInputType.phone),

                      const SizedBox(height: 14),

                      // City
                      _buildDialogFieldLabel('City / Town'),
                      const SizedBox(height: 6),
                      _buildDialogTextField(cityController, 'Enter city'),

                      const SizedBox(height: 14),

                      // Email
                      _buildDialogFieldLabel('Email Address'),
                      const SizedBox(height: 6),
                      _buildDialogTextField(emailController, 'Enter email address', keyboardType: TextInputType.emailAddress),

                      const SizedBox(height: 14),

                      // Status Dropdown
                      _buildDialogFieldLabel('Status'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: status,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Active', child: Text('Active')),
                              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => status = val);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Buttons Row
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Material(
                              color: const Color(0xFFFF7A1A),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  if (nameController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Validation Error',
                                      'Please enter financier name.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFEF4444),
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _financers.insert(
                                      0,
                                      FinancerItem(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        name: nameController.text.trim(),
                                        phone: phoneController.text.trim().isEmpty ? 'N/A' : phoneController.text.trim(),
                                        city: cityController.text.trim().isEmpty ? 'N/A' : cityController.text.trim(),
                                        status: status,
                                        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                      ),
                                    );
                                  });

                                  Navigator.pop(ctx);
                                  Get.snackbar(
                                    'Success',
                                    'Financier added successfully.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFF10B981),
                                    colorText: Colors.white,
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Save Financer',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
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
                            flex: 4,
                            child: Material(
                              color: const Color(0xFF475569),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => Navigator.pop(ctx),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showFinancerDetailsModal(FinancerItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Financer Details',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  _buildDetailRow('Name', item.name),
                  const SizedBox(height: 10),
                  _buildDetailRow('Status', item.status),
                  const SizedBox(height: 10),
                  _buildDetailRow('Phone', item.phone),
                  const SizedBox(height: 10),
                  _buildDetailRow('City', item.city),
                  if (item.email != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('Email', item.email!),
                  ],
                  if (item.creditLimit != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('Credit Limit', item.creditLimit!),
                  ],
                  if (item.pan != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('PAN', item.pan!),
                  ],
                  if (item.gstin != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('GSTIN', item.gstin!),
                  ],
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A1A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(ctx),
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
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
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
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14.5.sp, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF7A1A), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredFinancers;
    final topPadding = MediaQuery.of(context).padding.top;

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
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding > 0 ? topPadding + 12 : 20,
              left: 16,
              right: 16,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Back button + All Financers + [+ Add] + [Import]
                _buildHeader(),

                const SizedBox(height: 16),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 16),

                // List of Financer Cards
                if (list.isEmpty)
                  _buildEmptyState()
                else
                  ...list.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildFinancerCard(item, index);
                  }),
              ],
            ),
          ),

          // Floating Calculator Dialog Overlay
          if (_isCalculatorOpen)
            CalculatorWidget(
              onClose: () {
                setState(() {
                  _isCalculatorOpen = false;
                });
              },
            ),
        ],
      ),
    );
  }

  // --- Header: Back Arrow + All Financers + Add & Import Buttons ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          tooltip: 'Back',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'All Financers',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),

        // "+ Add" Button
        Material(
          color: const Color(0xFFFF7A1A),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: _showAddFinancerDialog,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Add',
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

        const SizedBox(width: 8),

        // "Import" Button
        Material(
          color: const Color(0xFFFF7A1A),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => Get.to(() => const ImportFinancersScreen()),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.file_upload_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Import',
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

  // --- Search Bar matching reference ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
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
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  // --- Financer Card matching reference ---
  Widget _buildFinancerCard(FinancerItem item, int index) {
    final initial = item.name.isNotEmpty ? item.name[0].toUpperCase() : 'F';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showFinancerDetailsModal(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Circular Avatar + Financer Name + Active Badge + Three-dots Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circle Avatar with Initial
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getAvatarBgColor(index),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: _getAvatarTextColor(index),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Financer Name
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Active Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Three dots menu button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onSelected: (val) {
                          if (val == 'view') {
                            _showFinancerDetailsModal(item);
                          } else if (val == 'delete') {
                            setState(() {
                              _financers.removeWhere((p) => p.id == item.id);
                            });
                            Get.snackbar(
                              'Deleted',
                              '${item.name} removed successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFEF4444),
                              colorText: Colors.white,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Text(
                              'View Details',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2: Phone & City Details (indented past avatar)
                Row(
                  children: [
                    // Indentation matching avatar width (44 + 12 = 56)
                    const SizedBox(width: 56),

                    // Phone column
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      height: 26,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    // City column
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'City',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
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
          ),
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
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
              Icons.search_off_rounded,
              size: 44,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 10),
            Text(
              'No financers found.',
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
}
