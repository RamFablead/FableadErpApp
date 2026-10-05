class AllproductViewLIstModal {
  bool? status;
  List<Data>? data;
  Null? pagination;
  String? currencySymbol;
  String? currencyPosition;
  int? lowStockThreshold;

  AllproductViewLIstModal(
      {this.status,
        this.data,
        this.pagination,
        this.currencySymbol,
        this.currencyPosition,
        this.lowStockThreshold});

  AllproductViewLIstModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    pagination = json['pagination'];
    currencySymbol = json['currencySymbol'];
    currencyPosition = json['currencyPosition'];
    lowStockThreshold = json['lowStockThreshold'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['pagination'] = this.pagination;
    data['currencySymbol'] = this.currencySymbol;
    data['currencyPosition'] = this.currencyPosition;
    data['lowStockThreshold'] = this.lowStockThreshold;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? sKU;
  String? price;
  String? mrp;
  String? quantity;
  int? unitId;
  int? categoryId;
  int? brandId;
  int? branchId;
  String? images;
  String? barcode;
  String? gstOption;
  int? isRentAvailable;
  String? rentPeriod;
  String? rentPrice;
  List<String>? imageUrl;
  Category? category;
  Brand? brand;
  Unit? unit;
  List<Variants>? variants;

  Data(
      {this.id,
        this.name,
        this.sKU,
        this.price,
        this.mrp,
        this.quantity,
        this.unitId,
        this.categoryId,
        this.brandId,
        this.branchId,
        this.images,
        this.barcode,
        this.gstOption,
        this.isRentAvailable,
        this.rentPeriod,
        this.rentPrice,
        this.imageUrl,
        this.category,
        this.brand,
        this.unit,
        this.variants});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sKU = json['SKU'];
    price = json['price'];
    mrp = json['mrp'];
    quantity = json['quantity'];
    unitId = json['unit_id'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    branchId = json['branch_id'];
    images = json['images'];
    barcode = json['barcode'];
    gstOption = json['gst_option'];
    isRentAvailable = json['is_rent_available'];
    rentPeriod = json['rent_period'];
    rentPrice = json['rent_price'];
    imageUrl = json['image_url'] != null ? List<String>.from(json['image_url']) : null;
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    brand = json['brand'] != null ? new Brand.fromJson(json['brand']) : null;
    unit = json['unit'] != null ? new Unit.fromJson(json['unit']) : null;
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['SKU'] = this.sKU;
    data['price'] = this.price;
    data['mrp'] = this.mrp;
    data['quantity'] = this.quantity;
    data['unit_id'] = this.unitId;
    data['category_id'] = this.categoryId;
    data['brand_id'] = this.brandId;
    data['branch_id'] = this.branchId;
    data['images'] = this.images;
    data['barcode'] = this.barcode;
    data['gst_option'] = this.gstOption;
    data['is_rent_available'] = this.isRentAvailable;
    data['rent_period'] = this.rentPeriod;
    data['rent_price'] = this.rentPrice;
    data['image_url'] = this.imageUrl;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.brand != null) {
      data['brand'] = this.brand!.toJson();
    }
    if (this.unit != null) {
      data['unit'] = this.unit!.toJson();
    }
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? imageUrl;

  Category({this.id, this.name, this.imageUrl});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image_url'] = this.imageUrl;
    return data;
  }
}

class Brand {
  int? id;
  String? name;
  String? logoUrl;

  Brand({this.id, this.name, this.logoUrl});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logoUrl = json['logo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['logo_url'] = this.logoUrl;
    return data;
  }
}

class Unit {
  int? id;
  String? unitName;

  Unit({this.id, this.unitName});

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unitName = json['unit_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['unit_name'] = this.unitName;
    return data;
  }
}

class Variants {
  int? id;
  int? productId;
  String? barcode;
  String? size;
  String? color;
  int? qty;
  String? price;
  String? mrp;
  String? purchasePrice;

  Variants(
      {this.id,
        this.productId,
        this.barcode,
        this.size,
        this.color,
        this.qty,
        this.price,
        this.mrp,
        this.purchasePrice});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    barcode = json['barcode'];
    size = json['size'];
    color = json['color'];
    qty = json['qty'];
    price = json['price'];
    mrp = json['mrp'];
    purchasePrice = json['purchase_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['barcode'] = this.barcode;
    data['size'] = this.size;
    data['color'] = this.color;
    data['qty'] = this.qty;
    data['price'] = this.price;
    data['mrp'] = this.mrp;
    data['purchase_price'] = this.purchasePrice;
    return data;
  }
}
