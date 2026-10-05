import 'product_model.dart';

class OrderListResponseModel {
  final bool status;
  final String message;
  final String currencySymbol;
  final String currencyPosition;
  final bool financialYearEnabled;
  final double totalAmount;
  final double totalPendingAmount;
  final double totalPaidAmount;
  final List<OrderItemModel> data;
  final OrderPaginationModel? pagination;

  OrderListResponseModel({
    required this.status,
    this.message = '',
    this.currencySymbol = '₹',
    this.currencyPosition = 'left',
    this.financialYearEnabled = true,
    this.totalAmount = 0.0,
    this.totalPendingAmount = 0.0,
    this.totalPaidAmount = 0.0,
    required this.data,
    this.pagination,
  });

  factory OrderListResponseModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'];
    List<OrderItemModel> orders = [];
    if (rawList is List) {
      orders = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    return OrderListResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      currencySymbol: json['currency_symbol']?.toString() ?? '₹',
      currencyPosition: json['currency_position']?.toString() ?? 'left',
      financialYearEnabled: json['financial_year_enabled'] == true,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      totalPendingAmount:
          double.tryParse(json['total_pending_amount']?.toString() ?? '0') ??
              0.0,
      totalPaidAmount:
          double.tryParse(json['total_paid_amount']?.toString() ?? '0') ??
              0.0,
      data: orders,
      pagination: json['pagination'] is Map<String, dynamic>
          ? OrderPaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class OrderItemModel {
  final int id;
  final String? clientUuid;
  final int? branchId;
  final String orderNumber;
  final int? userId;
  final int? createdBy;
  final int? staffId;
  final String? orderType;
  final double discount;
  final double discountPercentage;
  final double discountAmount;
  final double shipping;
  final String? gstOption;
  final double tdsPercentage;
  final double tdsAmount;
  final double totalAmount;
  final double depositAmount;
  final double remainingAmount;
  final String? paymentStatus;
  final String? rentalStatus;
  final String? returnStatus;
  final String? deliveryStatus;
  final String? paymentMethod;
  final String? orderInvoice;
  final String? quotationStatus;
  final String? remarks;
  final String? termsCondition;
  final String? createdAtRaw;
  final DateTime? createdAt;
  final double? totalPaid;
  final String? createdDate;
  final String? biller;
  final String? invoicePdfUrl;
  final String? staffName;
  final OrderUserModel? user;
  final OrderCreatorModel? creator;
  final OrderStaffModel? staff;
  final List<dynamic> orderItems;

  OrderItemModel({
    required this.id,
    this.clientUuid,
    this.branchId,
    required this.orderNumber,
    this.userId,
    this.createdBy,
    this.staffId,
    this.orderType,
    this.discount = 0.0,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.shipping = 0.0,
    this.gstOption,
    this.tdsPercentage = 0.0,
    this.tdsAmount = 0.0,
    this.totalAmount = 0.0,
    this.depositAmount = 0.0,
    this.remainingAmount = 0.0,
    this.paymentStatus,
    this.rentalStatus,
    this.returnStatus,
    this.deliveryStatus,
    this.paymentMethod,
    this.orderInvoice,
    this.quotationStatus,
    this.remarks,
    this.termsCondition,
    this.createdAtRaw,
    this.createdAt,
    this.totalPaid,
    this.createdDate,
    this.biller,
    this.invoicePdfUrl,
    this.staffName,
    this.user,
    this.creator,
    this.staff,
    this.orderItems = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['created_at']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(rawDate);
      } catch (_) {}
    }

    return OrderItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      clientUuid: json['client_uuid']?.toString(),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? ''),
      orderNumber: json['order_number']?.toString() ?? 'ORD-${json['id'] ?? ''}',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      createdBy: json['created_by'] is int
          ? json['created_by']
          : int.tryParse(json['created_by']?.toString() ?? ''),
      staffId: json['staff_id'] is int
          ? json['staff_id']
          : int.tryParse(json['staff_id']?.toString() ?? ''),
      orderType: json['order_type']?.toString(),
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      discountPercentage:
          double.tryParse(json['discount_percentage']?.toString() ?? '0') ??
              0.0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      shipping: double.tryParse(json['shipping']?.toString() ?? '0') ?? 0.0,
      gstOption: json['gst_option']?.toString(),
      tdsPercentage:
          double.tryParse(json['tds_percentage']?.toString() ?? '0') ?? 0.0,
      tdsAmount: double.tryParse(json['tds_amount']?.toString() ?? '0') ?? 0.0,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      depositAmount:
          double.tryParse(json['deposit_amount']?.toString() ?? '0') ?? 0.0,
      remainingAmount:
          double.tryParse(json['remaining_amount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['payment_status']?.toString(),
      rentalStatus: json['rental_status']?.toString(),
      returnStatus: json['return_status']?.toString(),
      deliveryStatus: json['delivery_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      orderInvoice: json['order_invoice']?.toString(),
      quotationStatus: json['quotation_status']?.toString(),
      remarks: json['remarks']?.toString(),
      termsCondition: json['terms_condition']?.toString(),
      createdAtRaw: rawDate,
      createdAt: parsedDate,
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? ''),
      createdDate: json['created_date']?.toString(),
      biller: json['biller']?.toString(),
      invoicePdfUrl: json['invoice_pdf_url']?.toString(),
      staffName: json['staff_name']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? OrderUserModel.fromJson(json['user'])
          : null,
      creator: json['creator'] is Map<String, dynamic>
          ? OrderCreatorModel.fromJson(json['creator'])
          : null,
      staff: json['staff'] is Map<String, dynamic>
          ? OrderStaffModel.fromJson(json['staff'])
          : null,
      orderItems: json['order_items'] is List
          ? json['order_items'] as List
          : const [],
    );
  }

  // --- Convenience Helpers ---
  String get customerName {
    if (user != null && user!.name != null && user!.name!.trim().isNotEmpty) {
      return user!.name!.trim();
    }
    return 'Default Customer';
  }

  String get customerPhone => user?.phone?.trim() ?? '';

  String get effectiveStaffName {
    if (staffName != null && staffName!.trim().isNotEmpty) {
      return staffName!.trim();
    }
    if (staff?.name != null && staff!.name!.trim().isNotEmpty) {
      return staff!.name!.trim();
    }
    if (biller != null && biller!.trim().isNotEmpty) {
      return biller!.trim();
    }
    return 'Admin';
  }

  bool get isWithGst => gstOption?.toLowerCase() == 'with_gst';

  String get displayOrderType {
    if (orderType == null || orderType!.isEmpty) return 'Self Pickup';
    final lower = orderType!.toLowerCase();
    if (lower == 'delivery') return 'Home Delivery';
    if (lower == 'self_pickup') return 'Self Pickup';
    if (lower == 'courier') return 'Courier Delivery';
    return lower
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }

  String get displayPaymentStatus {
    if (paymentStatus == null || paymentStatus!.isEmpty) return 'Pending';
    final lower = paymentStatus!.toLowerCase();
    if (lower == 'completed' || lower == 'paid') return 'Paid';
    if (lower == 'partially') return 'Partially Paid';
    return 'Pending';
  }

  bool get isPaid => displayPaymentStatus == 'Paid';

  DateTime get effectiveDate => createdAt ?? DateTime.now();
}

class OrderUserModel {
  final int id;
  final String? name;
  final String? phone;
  final String? profileImageUrl;

  OrderUserModel({
    required this.id,
    this.name,
    this.phone,
    this.profileImageUrl,
  });

  factory OrderUserModel.fromJson(Map<String, dynamic> json) {
    return OrderUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }
}

class OrderCreatorModel {
  final int id;
  final String? name;
  final String? role;
  final String? profileImageUrl;

  OrderCreatorModel({
    required this.id,
    this.name,
    this.role,
    this.profileImageUrl,
  });

  factory OrderCreatorModel.fromJson(Map<String, dynamic> json) {
    return OrderCreatorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }
}

class OrderStaffModel {
  final int id;
  final String? name;
  final String? profileImageUrl;

  OrderStaffModel({
    required this.id,
    this.name,
    this.profileImageUrl,
  });

  factory OrderStaffModel.fromJson(Map<String, dynamic> json) {
    return OrderStaffModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }
}

class OrderPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  OrderPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory OrderPaginationModel.fromJson(Map<String, dynamic> json) {
    return OrderPaginationModel(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '10') ?? 10,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Request model for POST /api/order_sale
class CreateOrderSaleRequestModel {
  final String customerId;
  final String customerPhone;
  final String? gstOption; // 'without_gst' or 'with_gst'
  final String orderDate;
  final String quotationStatus; // 'sale'
  final String paymentMethod; // 'cash', 'card', 'upi', etc.
  final String paidType; // 'cash_fully', etc.
  final double subtotal;
  final double amount;
  final double paymentAmount;
  final double pendingAmount;
  final double cashAmount;
  final double total;
  final double discount;
  final String? remarks;
  final List<CreateOrderItemRequestModel> items;

  CreateOrderSaleRequestModel({
    required this.customerId,
    required this.customerPhone,
    this.gstOption = 'without_gst',
    required this.orderDate,
    this.quotationStatus = 'sale',
    this.paymentMethod = 'cash',
    this.paidType = 'cash_fully',
    required this.subtotal,
    required this.amount,
    required this.paymentAmount,
    this.pendingAmount = 0.0,
    required this.cashAmount,
    required this.total,
    this.discount = 0.0,
    this.remarks,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_phone': customerPhone,
      if (gstOption != null && gstOption!.isNotEmpty) 'gst_option': gstOption,
      'order_date': orderDate,
      'quotation_status': quotationStatus,
      'payment_method': paymentMethod,
      'paid_type': paidType,
      'subtotal': subtotal,
      'amount': amount,
      'payment_amount': paymentAmount,
      'pending_amount': pendingAmount,
      'cash_amount': cashAmount,
      'total': total,
      'discount': discount,
      if (remarks != null && remarks!.isNotEmpty) 'remarks': remarks,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Order item in CreateOrderSaleRequestModel
class CreateOrderItemRequestModel {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  CreateOrderItemRequestModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

/// Response model for POST /api/order_sale
class CreateOrderSaleResponseModel {
  final bool status;
  final String message;
  final int? orderId;
  final bool mailSent;
  final SalesInvoiceModel? salesInvoice;

  CreateOrderSaleResponseModel({
    required this.status,
    required this.message,
    this.orderId,
    this.mailSent = false,
    this.salesInvoice,
  });

  factory CreateOrderSaleResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderSaleResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? ''),
      mailSent: json['mail_sent'] == true,
      salesInvoice: json['sales_invoice'] is Map<String, dynamic>
          ? SalesInvoiceModel.fromJson(json['sales_invoice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'order_id': orderId,
      'mail_sent': mailSent,
      'sales_invoice': salesInvoice?.toJson(),
    };
  }
}

/// Sales Invoice details returned from /api/order_sale
class SalesInvoiceModel {
  final bool status;
  final String? fileUrl;
  final String? fileName;
  final String? relativePath;

  SalesInvoiceModel({
    required this.status,
    this.fileUrl,
    this.fileName,
    this.relativePath,
  });

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceModel(
      status: json['status'] == true,
      fileUrl: json['file_url']?.toString(),
      fileName: json['file_name']?.toString(),
      relativePath: json['relative_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'file_url': fileUrl,
      'file_name': fileName,
      'relative_path': relativePath,
    };
  }
}

class DeleteOrderResponseModel {
  final bool status;
  final String message;

  DeleteOrderResponseModel({
    required this.status,
    required this.message,
  });

  factory DeleteOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteOrderResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}

class SalesDetailResponseModel {
  final bool status;
  final SalesDetailHeaderModel? sales;
  final List<SalesDetailItemModel> orderItems;
  final SalesDetailCompanyModel? companyInfo;
  final String currencySymbol;
  final String currencyPosition;

  SalesDetailResponseModel({
    required this.status,
    this.sales,
    this.orderItems = const [],
    this.companyInfo,
    this.currencySymbol = '₹',
    this.currencyPosition = 'left',
  });

  factory SalesDetailResponseModel.fromJson(Map<String, dynamic> json) {
    SalesDetailHeaderModel? salesHeader;
    if (json['sales'] is Map<String, dynamic>) {
      salesHeader = SalesDetailHeaderModel.fromJson(json['sales']);
    }

    List<SalesDetailItemModel> items = [];
    final rawItems = json['order_items'] ?? json['sales']?['order_items'];
    if (rawItems is List) {
      items = rawItems
          .whereType<Map<String, dynamic>>()
          .map((i) => SalesDetailItemModel.fromJson(i))
          .toList();
    }

    SalesDetailCompanyModel? company;
    if (json['company_info'] is Map<String, dynamic>) {
      company = SalesDetailCompanyModel.fromJson(json['company_info']);
    }

    return SalesDetailResponseModel(
      status: json['status'] == true,
      sales: salesHeader,
      orderItems: items,
      companyInfo: company,
      currencySymbol: json['currency_symbol']?.toString() ?? '₹',
      currencyPosition: json['currency_position']?.toString() ?? 'left',
    );
  }
}

class SalesDetailCompanyModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? gstNum;
  final String? cinNo;
  final String? address;
  final String? bankName;
  final String? branch;
  final String? acNo;
  final String? ifscCode;
  final String? logoUrl;
  final String? qrCodeUrl;

  SalesDetailCompanyModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gstNum,
    this.cinNo,
    this.address,
    this.bankName,
    this.branch,
    this.acNo,
    this.ifscCode,
    this.logoUrl,
    this.qrCodeUrl,
  });

  factory SalesDetailCompanyModel.fromJson(Map<String, dynamic> json) {
    return SalesDetailCompanyModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      gstNum: json['gst_num']?.toString(),
      cinNo: json['cin_no']?.toString(),
      address: json['address']?.toString(),
      bankName: json['bank_name']?.toString(),
      branch: json['branch']?.toString(),
      acNo: json['ac_no']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      qrCodeUrl: json['qr_code_url']?.toString(),
    );
  }
}

class SalesDetailHeaderModel {
  final int id;
  final String orderNumber;
  final String? quotationStatus;
  final String? rentalStatus;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? deliveryStatus;
  final String? gstOption;
  final String? orderType;
  final double discount;
  final double discountPercentage;
  final double discountAmount;
  final double shipping;
  final double tdsPercentage;
  final double tdsAmount;
  final double totalAmount;
  final double depositAmount;
  final double remainingAmount;
  final double paidAmount;
  final double pendingAmount;
  final String? remarks;
  final String? createdAt;
  final int? userId;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  final String? userGstNumber;
  final String? userPanNumber;
  final SalesDetailUserModel? user;
  final List<SalesDetailItemModel> orderItems;

  SalesDetailHeaderModel({
    required this.id,
    required this.orderNumber,
    this.quotationStatus,
    this.rentalStatus,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryStatus,
    this.gstOption,
    this.orderType,
    this.discount = 0.0,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.shipping = 0.0,
    this.tdsPercentage = 0.0,
    this.tdsAmount = 0.0,
    this.totalAmount = 0.0,
    this.depositAmount = 0.0,
    this.remainingAmount = 0.0,
    this.paidAmount = 0.0,
    this.pendingAmount = 0.0,
    this.remarks,
    this.createdAt,
    this.userId,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.userGstNumber,
    this.userPanNumber,
    this.user,
    this.orderItems = const [],
  });

  factory SalesDetailHeaderModel.fromJson(Map<String, dynamic> json) {
    List<SalesDetailItemModel> items = [];
    if (json['order_items'] is List) {
      items = (json['order_items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => SalesDetailItemModel.fromJson(i))
          .toList();
    }

    SalesDetailUserModel? userModel;
    if (json['user'] is Map<String, dynamic>) {
      userModel = SalesDetailUserModel.fromJson(json['user']);
    }

    return SalesDetailHeaderModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      quotationStatus: json['quotation_status']?.toString(),
      rentalStatus: json['rental_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      deliveryStatus: json['delivery_status']?.toString(),
      gstOption: json['gst_option']?.toString(),
      orderType: json['order_type']?.toString(),
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      discountPercentage: double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      shipping: double.tryParse(json['shipping']?.toString() ?? '0') ?? 0.0,
      tdsPercentage: double.tryParse(json['tds_percentage']?.toString() ?? '0') ?? 0.0,
      tdsAmount: double.tryParse(json['tds_amount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      depositAmount: double.tryParse(json['deposit_amount']?.toString() ?? '0') ?? 0.0,
      remainingAmount: double.tryParse(json['remaining_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      pendingAmount: double.tryParse(json['pending_amount']?.toString() ?? '0') ?? 0.0,
      remarks: json['remarks']?.toString(),
      createdAt: json['created_at']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      userName: json['user_name']?.toString() ?? userModel?.name,
      userPhone: json['user_phone']?.toString() ?? userModel?.phone,
      userEmail: userModel?.email,
      userGstNumber: json['user_gst_number']?.toString() ?? userModel?.gstNumber,
      userPanNumber: json['user_pan_number']?.toString() ?? userModel?.panNumber,
      user: userModel,
      orderItems: items,
    );
  }
}

class SalesDetailUserModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? panNumber;
  final String? profileImageUrl;

  SalesDetailUserModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.gstNumber,
    this.panNumber,
    this.profileImageUrl,
  });

  factory SalesDetailUserModel.fromJson(Map<String, dynamic> json) {
    return SalesDetailUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      panNumber: json['pan_number']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }
}

class SalesDetailItemModel {
  final int id;
  final int? productId;
  final String productName;
  final double price;
  final double quantity;
  final double discountPercentage;
  final double discountAmount;
  final double productGstTotal;
  final double totalAmount;
  final String? description;
  final String? date;
  final ProductItemModel? product;
  final List<SalesDetailTaxModel> productGstDetails;

  SalesDetailItemModel({
    required this.id,
    this.productId,
    required this.productName,
    this.price = 0.0,
    this.quantity = 1.0,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.productGstTotal = 0.0,
    this.totalAmount = 0.0,
    this.description,
    this.date,
    this.product,
    this.productGstDetails = const [],
  });

  factory SalesDetailItemModel.fromJson(Map<String, dynamic> json) {
    ProductItemModel? prod;
    if (json['product'] is Map<String, dynamic>) {
      prod = ProductItemModel.fromJson(json['product']);
    }

    List<SalesDetailTaxModel> taxes = [];
    final rawTaxes = json['product_gst_details'] ?? json['product_tax'];
    if (rawTaxes is List) {
      taxes = rawTaxes
          .whereType<Map<String, dynamic>>()
          .map((t) => SalesDetailTaxModel.fromJson(t))
          .toList();
    }

    return SalesDetailItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id']
          : (prod?.id ?? int.tryParse(json['product_id']?.toString() ?? '')),
      productName: json['product_name']?.toString() ?? (prod?.name ?? ''),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? (prod?.numericPrice ?? 0.0),
      quantity: double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      discountPercentage: double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      productGstTotal: double.tryParse(json['product_gst_total']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      product: prod,
      productGstDetails: taxes,
    );
  }
}

class SalesDetailTaxModel {
  final String taxName;
  final double taxRate;
  final double taxAmount;

  SalesDetailTaxModel({
    required this.taxName,
    required this.taxRate,
    required this.taxAmount,
  });

  factory SalesDetailTaxModel.fromJson(Map<String, dynamic> json) {
    return SalesDetailTaxModel(
      taxName: json['tax_name']?.toString() ?? '',
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
