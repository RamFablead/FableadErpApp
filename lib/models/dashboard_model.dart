/// Dashboard API Response Models for /api/dashboard-api
class DashboardResponseModel {
  final bool status;
  final int? branchId;
  final DashboardDataModel? data;

  DashboardResponseModel({
    required this.status,
    this.branchId,
    this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      status: json['status'] == true,
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? ''),
      data: json['data'] is Map<String, dynamic>
          ? DashboardDataModel.fromJson(json['data'])
          : null,
    );
  }
}

class DashboardDataModel {
  final DashboardTotalsModel totals;
  final DashboardCountsModel counts;
  final List<DashboardProductModel> recentProducts;
  final List<DashboardSaleItemModel> latestSales;
  final List<DashboardPurchaseItemModel> latestPurchases;
  final DashboardChartsModel? charts;
  final String currencySymbol;
  final String currencyPosition;

  DashboardDataModel({
    required this.totals,
    required this.counts,
    this.recentProducts = const [],
    this.latestSales = const [],
    this.latestPurchases = const [],
    this.charts,
    this.currencySymbol = '₹',
    this.currencyPosition = 'left',
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    DashboardTotalsModel totalsModel = DashboardTotalsModel();
    if (json['totals'] is Map<String, dynamic>) {
      totalsModel = DashboardTotalsModel.fromJson(json['totals']);
    }

    DashboardCountsModel countsModel = DashboardCountsModel();
    if (json['counts'] is Map<String, dynamic>) {
      countsModel = DashboardCountsModel.fromJson(json['counts']);
    }

    List<DashboardProductModel> products = [];
    if (json['recentProducts'] is List) {
      products = (json['recentProducts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => DashboardProductModel.fromJson(p))
          .toList();
    }

    List<DashboardSaleItemModel> sales = [];
    if (json['latestSales'] is List) {
      sales = (json['latestSales'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => DashboardSaleItemModel.fromJson(s))
          .toList();
    }

    List<DashboardPurchaseItemModel> purchases = [];
    if (json['latestPurchases'] is List) {
      purchases = (json['latestPurchases'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => DashboardPurchaseItemModel.fromJson(p))
          .toList();
    }

    DashboardChartsModel? chartsModel;
    if (json['charts'] is Map<String, dynamic>) {
      chartsModel = DashboardChartsModel.fromJson(json['charts']);
    }

    String currSymbol = '₹';
    String currPos = 'left';
    if (json['currency'] is Map<String, dynamic>) {
      currSymbol = json['currency']['symbol']?.toString() ?? '₹';
      currPos = json['currency']['position']?.toString() ?? 'left';
    }

    return DashboardDataModel(
      totals: totalsModel,
      counts: countsModel,
      recentProducts: products,
      latestSales: sales,
      latestPurchases: purchases,
      charts: chartsModel,
      currencySymbol: currSymbol,
      currencyPosition: currPos,
    );
  }
}

class DashboardTotalsModel {
  final double purchase;
  final double sales;
  final double expense;

  DashboardTotalsModel({
    this.purchase = 0.0,
    this.sales = 0.0,
    this.expense = 0.0,
  });

  factory DashboardTotalsModel.fromJson(Map<String, dynamic> json) {
    return DashboardTotalsModel(
      purchase: double.tryParse(json['purchase']?.toString() ?? '0') ?? 0.0,
      sales: double.tryParse(json['sales']?.toString() ?? '0') ?? 0.0,
      expense: double.tryParse(json['expense']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DashboardCountsModel {
  final int customers;
  final int vendors;
  final int purchaseInvoices;
  final int salesInvoices;

  DashboardCountsModel({
    this.customers = 0,
    this.vendors = 0,
    this.purchaseInvoices = 0,
    this.salesInvoices = 0,
  });

  factory DashboardCountsModel.fromJson(Map<String, dynamic> json) {
    return DashboardCountsModel(
      customers: int.tryParse(json['customers']?.toString() ?? '0') ?? 0,
      vendors: int.tryParse(json['vendors']?.toString() ?? '0') ?? 0,
      purchaseInvoices:
          int.tryParse(json['purchaseInvoices']?.toString() ?? '0') ?? 0,
      salesInvoices:
          int.tryParse(json['salesInvoices']?.toString() ?? '0') ?? 0,
    );
  }
}

class DashboardProductModel {
  final int id;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double quantity;
  final String? gstOption;
  final String? availability;
  final List<String> imageUrl;

  DashboardProductModel({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.price = 0.0,
    this.quantity = 0.0,
    this.gstOption,
    this.availability,
    this.imageUrl = const [],
  });

  factory DashboardProductModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['image_url'] is List) {
      images = (json['image_url'] as List)
          .map((i) => i?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return DashboardProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Product #${json['id']}',
      sku: json['SKU']?.toString(),
      barcode: json['barcode']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      gstOption: json['gst_option']?.toString(),
      availability: json['availability']?.toString() ?? json['availablility']?.toString(),
      imageUrl: images,
    );
  }
}

class DashboardSaleItemModel {
  final int id;
  final int? orderId;
  final String productName;
  final String orderNumber;
  final double price;
  final double quantity;
  final double totalAmount;
  final double productGstTotal;
  final String orderDate;
  final String? paymentMethod;
  final String? categoryName;
  final String? brandName;
  final List<String> imageUrl;

  DashboardSaleItemModel({
    required this.id,
    this.orderId,
    required this.productName,
    required this.orderNumber,
    this.price = 0.0,
    this.quantity = 1.0,
    this.totalAmount = 0.0,
    this.productGstTotal = 0.0,
    required this.orderDate,
    this.paymentMethod,
    this.categoryName,
    this.brandName,
    this.imageUrl = const [],
  });

  factory DashboardSaleItemModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['image_url'] is List) {
      images = (json['image_url'] as List)
          .map((i) => i?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return DashboardSaleItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? ''),
      productName: json['product_name']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      productGstTotal:
          double.tryParse(json['product_gst_total']?.toString() ?? '0') ?? 0.0,
      orderDate: json['order_date']?.toString() ??
          (json['created_at']?.toString() ?? ''),
      paymentMethod: json['payment_method']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      imageUrl: images,
    );
  }
}

class DashboardPurchaseItemModel {
  final int? invoiceId;
  final String invoiceNumber;
  final String? productName;
  final String? categoryName;
  final String? brandName;
  final double amountTotal;
  final double grandTotal;
  final String purchaseDate;
  final List<String> imageUrl;

  DashboardPurchaseItemModel({
    this.invoiceId,
    required this.invoiceNumber,
    this.productName,
    this.categoryName,
    this.brandName,
    this.amountTotal = 0.0,
    this.grandTotal = 0.0,
    required this.purchaseDate,
    this.imageUrl = const [],
  });

  factory DashboardPurchaseItemModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['image_url'] is List) {
      images = (json['image_url'] as List)
          .map((i) => i?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return DashboardPurchaseItemModel(
      invoiceId: json['invoice_id'] is int
          ? json['invoice_id']
          : int.tryParse(json['invoice_id']?.toString() ?? ''),
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      productName: json['product_name']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      amountTotal:
          double.tryParse(json['amount_total']?.toString() ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      purchaseDate: json['purchase_date']?.toString() ?? '',
      imageUrl: images,
    );
  }
}

class DashboardChartsModel {
  final List<double> sales;
  final List<double> purchases;
  final List<double> salesThisYear;
  final List<double> salesPreviousYear;
  final List<double> purchaseThisYear;
  final List<double> purchasePreviousYear;
  final List<double> salesThisMonth;
  final List<double> purchaseThisMonth;

  DashboardChartsModel({
    this.sales = const [],
    this.purchases = const [],
    this.salesThisYear = const [],
    this.salesPreviousYear = const [],
    this.purchaseThisYear = const [],
    this.purchasePreviousYear = const [],
    this.salesThisMonth = const [],
    this.purchaseThisMonth = const [],
  });

  factory DashboardChartsModel.fromJson(Map<String, dynamic> json) {
    List<double> parseNumList(dynamic raw) {
      if (raw is List) {
        return raw
            .map((v) => double.tryParse(v?.toString() ?? '0') ?? 0.0)
            .toList();
      }
      return [];
    }

    return DashboardChartsModel(
      sales: parseNumList(json['sales']),
      purchases: parseNumList(json['purchases']),
      salesThisYear: parseNumList(json['salesThisYear']),
      salesPreviousYear: parseNumList(json['salesPreviousYear']),
      purchaseThisYear: parseNumList(json['purchaseThisYear']),
      purchasePreviousYear: parseNumList(json['purchasePreviousYear']),
      salesThisMonth: parseNumList(json['salesThisMonth']),
      purchaseThisMonth: parseNumList(json['purchaseThisMonth']),
    );
  }
}
