import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import 'sales_screen.dart';

class SalesDetailScreen extends StatefulWidget {
  final dynamic orderId;
  final OrderItemModel? initialOrder;

  const SalesDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  final OrderService _orderService = OrderService();

  bool _isLoading = true;
  String? _errorMessage;
  SalesDetailResponseModel? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchSalesDetails();
  }

  Future<void> _fetchSalesDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _orderService.getSalesById(widget.orderId);
      if (mounted) {
        setState(() {
          _detailData = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final dec = parts[1];
    final reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    final formatted = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₹$formatted.$dec';
  }

  void _confirmDeleteOrder(int orderId, String orderNumber) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 26),
            SizedBox(width: 8),
            Text(
              'Delete Order',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete order "$orderNumber"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              _performDeleteOrder(orderId, orderNumber);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteOrder(int orderId, String orderNumber) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B2C)),
      ),
      barrierDismissible: false,
    );

    try {
      final res = await _orderService.deleteOrder(orderId);
      if (Get.isDialogOpen ?? false) Get.back();

      if (res.status) {
        Get.snackbar(
          'Deleted',
          res.message.isNotEmpty
              ? res.message
              : 'Order $orderNumber deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        Navigator.pop(context, true); // Pop back to All Sales Screen
      } else {
        Get.snackbar(
          'Delete Failed',
          res.message.isNotEmpty ? res.message : 'Could not delete order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
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

  @override
  Widget build(BuildContext context) {
    final sales = _detailData?.sales;
    final orderNumber = sales?.orderNumber ??
        (widget.initialOrder?.orderNumber ?? '#${widget.orderId}');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderNumber,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Sales Bill Details',
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (sales != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6B2C)),
              tooltip: 'Edit Order',
              onPressed: () {
                Get.to(() => SalesScreen(editOrderId: sales.id));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444)),
              tooltip: 'Delete Order',
              onPressed: () {
                _confirmDeleteOrder(sales.id, sales.orderNumber);
              },
            ),
          ],

        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: sales != null ? _buildBottomStickyBar(sales) : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading && _detailData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF6B2C)),
            SizedBox(height: 14),
            Text(
              'Loading sales details...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _detailData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 54, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              const Text(
                'Failed to load order details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _fetchSalesDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final sales = _detailData!.sales!;
    final items = _detailData!.orderItems.isNotEmpty
        ? _detailData!.orderItems
        : sales.orderItems;
    final company = _detailData!.companyInfo;

    return RefreshIndicator(
      color: const Color(0xFFFF6B2C),
      onRefresh: _fetchSalesDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Status & Header Card
            _buildOrderHeaderCard(sales),
            const SizedBox(height: 16),

            // 2. Customer Information Card
            _buildCustomerCard(sales),
            const SizedBox(height: 16),

            // 3. Ordered Items List Card
            _buildOrderedItemsCard(items, sales),
            const SizedBox(height: 16),

            // 4. Financial Calculation Summary Card
            _buildFinancialSummaryCard(sales, items),
            const SizedBox(height: 16),

            // 5. Payment & Order Logistics Details
            _buildPaymentAndLogisticsCard(sales),
            const SizedBox(height: 16),

            // 6. Company Information Card
            if (company != null) ...[
              _buildCompanyInfoCard(company),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  // --- 1. Order Status & Header Card ---
  Widget _buildOrderHeaderCard(SalesDetailHeaderModel sales) {
    final isWithGst = sales.gstOption?.toLowerCase() == 'with_gst';
    final isPaid = sales.paymentStatus?.toLowerCase() == 'completed' ||
        sales.paidAmount >= sales.totalAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFFFF6B2C),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sales.orderNumber,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sales.createdAt ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Grand Total preview in header
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(sales.totalAmount),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B2C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Grand Total',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Status Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Payment Status
              _buildBadge(
                label: isPaid ? 'Paid' : 'Payment Pending',
                icon: isPaid
                    ? Icons.check_circle_outline_rounded
                    : Icons.hourglass_top_rounded,
                bgColor: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                textColor: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                borderColor:
                    isPaid ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
              ),

              // GST Option
              _buildBadge(
                label: isWithGst ? 'With GST' : 'Without GST',
                icon: Icons.shield_outlined,
                bgColor: isWithGst
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFF8FAFC),
                textColor: isWithGst
                    ? const Color(0xFFEA580C)
                    : const Color(0xFF64748B),
                borderColor: isWithGst
                    ? const Color(0xFFFED7AA)
                    : const Color(0xFFE2E8F0),
              ),

              // Quotation/Order Status
              if (sales.quotationStatus != null)
                _buildBadge(
                  label: sales.quotationStatus!.toUpperCase(),
                  icon: Icons.label_outline_rounded,
                  bgColor: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF1D4ED8),
                  borderColor: const Color(0xFFBFDBFE),
                ),

              // Order Type
              if (sales.orderType != null)
                _buildBadge(
                  label: sales.orderType!.replaceAll('_', ' ').capitalizeFirst ??
                      sales.orderType!,
                  icon: Icons.store_mall_directory_outlined,
                  bgColor: const Color(0xFFF8FAFC),
                  textColor: const Color(0xFF334155),
                  borderColor: const Color(0xFFE2E8F0),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Customer Information Card ---
  Widget _buildCustomerCard(SalesDetailHeaderModel sales) {
    final userName = sales.user?.name ?? sales.userName ?? 'Customer';
    final userPhone = sales.user?.phone ?? sales.userPhone;
    final userEmail = sales.user?.email ?? sales.userEmail;
    final userGst = sales.user?.gstNumber ?? sales.userGstNumber;
    final userPan = sales.user?.panNumber ?? sales.userPanNumber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFFF6B2C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFFF6B2C).withValues(alpha: 0.12),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF6B2C),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (userPhone != null && userPhone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            userPhone,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (userEmail != null && userEmail.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: userEmail,
            ),
          ],

          if (userGst != null && userGst.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.assignment_outlined,
              label: 'GST Number',
              value: userGst,
              highlight: true,
            ),
          ],

          if (userPan != null && userPan.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.badge_outlined,
              label: 'PAN Number',
              value: userPan,
            ),
          ],
        ],
      ),
    );
  }

  // --- 3. Ordered Items List Card ---
  Widget _buildOrderedItemsCard(
      List<SalesDetailItemModel> items, SalesDetailHeaderModel sales) {
    final isWithGst = sales.gstOption?.toLowerCase() == 'with_gst';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFFFF6B2C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Order Items (${items.length})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.fold<double>(0, (s, i) => s + i.quantity).toStringAsFixed(0)} units',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No items found in this order',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (ctx, i) =>
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, index) {
                final item = items[index];
                return _buildOrderItemRow(item, isWithGst);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(SalesDetailItemModel item, bool isWithGst) {
    final subtotal = item.price * item.quantity;
    final unitName = item.product?.unit?.unitName ?? 'Pcs';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${item.quantity.toStringAsFixed(0)} $unitName × ${_formatCurrency(item.price)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.product?.sku != null &&
                          item.product!.sku!.isNotEmpty) ...[
                        const Text(' • ',
                            style: TextStyle(color: Color(0xFFCBD5E1))),
                        Text(
                          'SKU: ${item.product!.sku}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(item.totalAmount > 0 ? item.totalAmount : subtotal),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (item.discountAmount > 0)
                  Text(
                    '-${_formatCurrency(item.discountAmount)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // GST Breakdown Chips when With GST
        if (isWithGst && item.productGstDetails.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
              border: const Border(
                left: BorderSide(color: Color(0xFF10B981), width: 3),
              ),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: item.productGstDetails.map((tax) {
                return Text(
                  '${tax.taxName} (${tax.taxRate.toStringAsFixed(1)}%): ${_formatCurrency(tax.taxAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // --- 4. Financial Calculation Summary Card ---
  Widget _buildFinancialSummaryCard(
      SalesDetailHeaderModel sales, List<SalesDetailItemModel> items) {
    final double itemsSubtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final isWithGst = sales.gstOption?.toLowerCase() == 'with_gst';

    double totalGstFromItems = 0;
    for (final it in items) {
      totalGstFromItems += it.productGstTotal;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Color(0xFFFF6B2C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Financial Breakdown',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildBreakdownRow('Items Subtotal', _formatCurrency(itemsSubtotal)),

          if (isWithGst) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'GST (18% Total)',
              '+${_formatCurrency(totalGstFromItems > 0 ? totalGstFromItems : (itemsSubtotal * 0.18))}',
              valueColor: const Color(0xFF16A34A),
            ),
          ],

          if (sales.shipping > 0) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'Shipping & Delivery',
              '+${_formatCurrency(sales.shipping)}',
              valueColor: const Color(0xFF2563EB),
            ),
          ],

          if (sales.discount > 0 || sales.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'Discount (${sales.discountPercentage > 0 ? "${sales.discountPercentage.toStringAsFixed(0)}%" : ""})',
              '-${_formatCurrency(sales.discountAmount > 0 ? sales.discountAmount : sales.discount)}',
              valueColor: const Color(0xFFEF4444),
            ),
          ],

          if (sales.tdsAmount > 0 || sales.tdsPercentage > 0) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'TDS (${sales.tdsPercentage.toStringAsFixed(0)}%)',
              '-${_formatCurrency(sales.tdsAmount)}',
              valueColor: const Color(0xFFEF4444),
            ),
          ],

          const SizedBox(height: 12),
          _buildDashedLine(),
          const SizedBox(height: 12),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                _formatCurrency(sales.totalAmount),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B2C),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Paid & Pending Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paid Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(sales.paidAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Pending Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(sales.pendingAmount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: sales.pendingAmount > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
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
  }

  // --- 5. Payment & Order Logistics Details ---
  Widget _buildPaymentAndLogisticsCard(SalesDetailHeaderModel sales) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Color(0xFFFF6B2C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Payment & Logistics Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildDetailRow(
            icon: Icons.payments_outlined,
            label: 'Payment Method',
            value: (sales.paymentMethod ?? 'Cash').toUpperCase(),
          ),
          const SizedBox(height: 8),

          _buildDetailRow(
            icon: Icons.local_shipping_outlined,
            label: 'Delivery Status',
            value: (sales.deliveryStatus ?? 'Pending').capitalizeFirst ?? 'Pending',
          ),
          const SizedBox(height: 8),

          _buildDetailRow(
            icon: Icons.store_mall_directory_outlined,
            label: 'Order Type',
            value: (sales.orderType ?? 'Self Pickup').replaceAll('_', ' ').capitalizeFirst ??
                'Self Pickup',
          ),

          if (sales.remarks != null && sales.remarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.notes_rounded,
              label: 'Remarks',
              value: sales.remarks!,
              highlight: true,
            ),
          ],
        ],
      ),
    );
  }

  // --- 6. Company Information Card ---
  Widget _buildCompanyInfoCard(SalesDetailCompanyModel company) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: Color(0xFFFF6B2C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Company & Billing Information',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (company.name != null)
            Text(
              company.name!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          const SizedBox(height: 6),

          if (company.address != null)
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: company.address!.replaceAll('\r\n', ', '),
            ),

          if (company.gstNum != null) ...[
            const SizedBox(height: 6),
            _buildDetailRow(
              icon: Icons.verified_outlined,
              label: 'GSTIN',
              value: company.gstNum!,
            ),
          ],

          if (company.bankName != null) ...[
            const SizedBox(height: 6),
            _buildDetailRow(
              icon: Icons.account_balance_outlined,
              label: 'Bank Account',
              value:
                  '${company.bankName} • ${company.branch ?? ""} (A/C: ${company.acNo ?? ""} | IFSC: ${company.ifscCode ?? ""})',
            ),
          ],
        ],
      ),
    );
  }

  // --- Sticky Bottom Bar ---
  Widget _buildBottomStickyBar(SalesDetailHeaderModel sales) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Amount display
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatCurrency(sales.totalAmount),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // Edit Order Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B2C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Get.to(() => SalesScreen(editOrderId: sales.id));
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(
              'Edit Order',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
              color: highlight
                  ? const Color(0xFFEA580C)
                  : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }
}
