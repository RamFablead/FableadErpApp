class ProductListResponseModel {
  final bool status;
  final List<ProductItemModel> data;
  final String currencySymbol;
  final String currencyPosition;
  final int lowStockThreshold;

  ProductListResponseModel({
    required this.status,
    required this.data,
    this.currencySymbol = '₹',
    this.currencyPosition = 'left',
    this.lowStockThreshold = 5,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'];
    List<ProductItemModel> products = [];
    if (rawList is List) {
      products = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => ProductItemModel.fromJson(item))
          .toList();
    }

    return ProductListResponseModel(
      status: json['status'] == true,
      data: products,
      currencySymbol: json['currencySymbol']?.toString() ?? '₹',
      currencyPosition: json['currencyPosition']?.toString() ?? 'left',
      lowStockThreshold: json['lowStockThreshold'] is int
          ? json['lowStockThreshold']
          : int.tryParse(json['lowStockThreshold']?.toString() ?? '5') ?? 5,
    );
  }
}

class ProductItemModel {
  final int id;
  final String name;
  final String? sku;
  final String? price;
  final String? mrp;
  final String? quantity;
  final int? unitId;
  final int? categoryId;
  final int? brandId;
  final int? branchId;
  final String? barcode;
  final int? isRentAvailable;
  final String? rentPeriod;
  final String? rentPrice;
  final List<String> imageUrl;
  final ProductCategoryModel? category;
  final ProductBrandModel? brand;
  final ProductUnitModel? unit;
  final List<ProductVariantModel> variants;

  ProductItemModel({
    required this.id,
    required this.name,
    this.sku,
    this.price,
    this.mrp,
    this.quantity,
    this.unitId,
    this.categoryId,
    this.brandId,
    this.branchId,
    this.barcode,
    this.isRentAvailable,
    this.rentPeriod,
    this.rentPrice,
    this.imageUrl = const [],
    this.category,
    this.brand,
    this.unit,
    this.variants = const [],
  });

  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    // Parse image_url which can be a List or null
    List<String> images = [];
    if (json['image_url'] is List) {
      images = (json['image_url'] as List)
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();
    }

    // Parse variants
    List<ProductVariantModel> variantList = [];
    if (json['variants'] is List) {
      variantList = (json['variants'] as List)
          .whereType<Map<String, dynamic>>()
          .map((v) => ProductVariantModel.fromJson(v))
          .toList();
    }

    return ProductItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['SKU']?.toString() ?? json['sku']?.toString(),
      price: json['price']?.toString(),
      mrp: json['mrp']?.toString(),
      quantity: json['quantity']?.toString(),
      unitId: json['unit_id'] is int ? json['unit_id'] : int.tryParse(json['unit_id']?.toString() ?? ''),
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? ''),
      brandId: json['brand_id'] is int ? json['brand_id'] : int.tryParse(json['brand_id']?.toString() ?? ''),
      branchId: json['branch_id'] is int ? json['branch_id'] : int.tryParse(json['branch_id']?.toString() ?? ''),
      barcode: json['barcode']?.toString(),
      isRentAvailable: json['is_rent_available'] is int ? json['is_rent_available'] : int.tryParse(json['is_rent_available']?.toString() ?? '0'),
      rentPeriod: json['rent_period']?.toString(),
      rentPrice: json['rent_price']?.toString(),
      imageUrl: images,
      category: json['category'] is Map<String, dynamic>
          ? ProductCategoryModel.fromJson(json['category'])
          : null,
      brand: json['brand'] is Map<String, dynamic>
          ? ProductBrandModel.fromJson(json['brand'])
          : null,
      unit: json['unit'] is Map<String, dynamic>
          ? ProductUnitModel.fromJson(json['unit'])
          : null,
      variants: variantList,
    );
  }

  // --- Convenience Helpers ---
  double get numericPrice => double.tryParse(price ?? '0') ?? 0.0;
  double get numericMrp => double.tryParse(mrp ?? '0') ?? 0.0;
  double get numericQuantity => double.tryParse(quantity ?? '0') ?? 0.0;
  String get categoryName => category?.name?.trim().isNotEmpty == true ? category!.name! : 'General';
  String get unitName => unit?.unitName?.trim().isNotEmpty == true ? unit!.unitName! : 'Pcs';
  String get brandName => brand?.name?.trim().isNotEmpty == true ? brand!.name! : '';

  String? get validImageUrl {
    if (imageUrl.isNotEmpty) {
      final first = imageUrl.first;
      if (first.startsWith('http://') || first.startsWith('https://')) {
        return first;
      }
    }
    return null;
  }
}

class ProductCategoryModel {
  final int id;
  final String name;
  final String? imageUrl;

  ProductCategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class ProductBrandModel {
  final int id;
  final String name;
  final String? logoUrl;

  ProductBrandModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory ProductBrandModel.fromJson(Map<String, dynamic> json) {
    return ProductBrandModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
    );
  }
}

class ProductUnitModel {
  final int id;
  final String unitName;

  ProductUnitModel({
    required this.id,
    required this.unitName,
  });

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      unitName: json['unit_name']?.toString() ?? 'Pcs',
    );
  }
}

class ProductVariantModel {
  final int id;
  final int productId;
  final String? barcode;
  final String? size;
  final String? color;
  final int? qty;
  final String? price;
  final String? mrp;
  final String? purchasePrice;

  ProductVariantModel({
    required this.id,
    required this.productId,
    this.barcode,
    this.size,
    this.color,
    this.qty,
    this.price,
    this.mrp,
    this.purchasePrice,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      barcode: json['barcode']?.toString(),
      size: json['size']?.toString(),
      color: json['color']?.toString(),
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? ''),
      price: json['price']?.toString(),
      mrp: json['mrp']?.toString(),
      purchasePrice: json['purchase_price']?.toString(),
    );
  }
}
