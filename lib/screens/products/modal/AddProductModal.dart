class AddProductModal {
  bool? status;
  String? message;
  Product? product;

  AddProductModal({this.status, this.message, this.product});

  AddProductModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    return data;
  }
}

class Product {
  int? id;
  String? clientUuid;
  int? branchId;
  int? vendorId;
  int? categoryId;
  int? brandId;
  int? unitId;
  String? name;
  String? sKU;
  Null? productCode;
  Null? supplierCode;
  Null? internationalCode;
  Null? serialNoStatus;
  Null? nonInventoryType;
  Null? stockValidationStatus;
  String? itemType;
  Null? packingType;
  Null? baseUnit;
  Null? discountPrintStatus;
  Null? itemCreatedOn;
  Null? hsnCode;
  String? barcode;
  Null? description;
  String? price;
  String? mrp;
  String? purchasePrice;
  int? isRentAvailable;
  Null? rentPeriod;
  Null? rentPrice;
  Null? costPrice;
  Null? landingCost;
  String? quantity;
  Null? imeiNo;
  String? images;
  String? gstOption;
  Null? productGst;
  String? availablility;
  String? status;
  String? availability;
  int? isDeleted;
  Null? createBy;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? imageUrl;
  List<dynamic>? variants;

  Product(
      {this.id,
        this.clientUuid,
        this.branchId,
        this.vendorId,
        this.categoryId,
        this.brandId,
        this.unitId,
        this.name,
        this.sKU,
        this.productCode,
        this.supplierCode,
        this.internationalCode,
        this.serialNoStatus,
        this.nonInventoryType,
        this.stockValidationStatus,
        this.itemType,
        this.packingType,
        this.baseUnit,
        this.discountPrintStatus,
        this.itemCreatedOn,
        this.hsnCode,
        this.barcode,
        this.description,
        this.price,
        this.mrp,
        this.purchasePrice,
        this.isRentAvailable,
        this.rentPeriod,
        this.rentPrice,
        this.costPrice,
        this.landingCost,
        this.quantity,
        this.imeiNo,
        this.images,
        this.gstOption,
        this.productGst,
        this.availablility,
        this.status,
        this.availability,
        this.isDeleted,
        this.createBy,
        this.createdAt,
        this.updatedAt,
        this.imageUrl,
        this.variants});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientUuid = json['client_uuid'];
    branchId = json['branch_id'];
    vendorId = json['vendor_id'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    unitId = json['unit_id'];
    name = json['name'];
    sKU = json['SKU'];
    productCode = json['product_code'];
    supplierCode = json['supplier_code'];
    internationalCode = json['international_code'];
    serialNoStatus = json['serial_no_status'];
    nonInventoryType = json['non_inventory_type'];
    stockValidationStatus = json['stock_validation_status'];
    itemType = json['item_type'];
    packingType = json['packing_type'];
    baseUnit = json['base_unit'];
    discountPrintStatus = json['discount_print_status'];
    itemCreatedOn = json['item_created_on'];
    hsnCode = json['hsn_code'];
    barcode = json['barcode'];
    description = json['description'];
    price = json['price'];
    mrp = json['mrp'];
    purchasePrice = json['purchase_price'];
    isRentAvailable = json['is_rent_available'];
    rentPeriod = json['rent_period'];
    rentPrice = json['rent_price'];
    costPrice = json['cost_price'];
    landingCost = json['landing_cost'];
    quantity = json['quantity'];
    imeiNo = json['imei_no'];
    images = json['images'];
    gstOption = json['gst_option'];
    productGst = json['product_gst'];
    availablility = json['availablility'];
    status = json['status'];
    availability = json['availability'];
    isDeleted = json['isDeleted'];
    createBy = json['create_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['image_url'] != null) {
      imageUrl = [];
      json['image_url'].forEach((v) {
        imageUrl!.add(v);
      });
    }
    if (json['variants'] != null) {
      variants = [];
      json['variants'].forEach((v) {
        variants!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client_uuid'] = this.clientUuid;
    data['branch_id'] = this.branchId;
    data['vendor_id'] = this.vendorId;
    data['category_id'] = this.categoryId;
    data['brand_id'] = this.brandId;
    data['unit_id'] = this.unitId;
    data['name'] = this.name;
    data['SKU'] = this.sKU;
    data['product_code'] = this.productCode;
    data['supplier_code'] = this.supplierCode;
    data['international_code'] = this.internationalCode;
    data['serial_no_status'] = this.serialNoStatus;
    data['non_inventory_type'] = this.nonInventoryType;
    data['stock_validation_status'] = this.stockValidationStatus;
    data['item_type'] = this.itemType;
    data['packing_type'] = this.packingType;
    data['base_unit'] = this.baseUnit;
    data['discount_print_status'] = this.discountPrintStatus;
    data['item_created_on'] = this.itemCreatedOn;
    data['hsn_code'] = this.hsnCode;
    data['barcode'] = this.barcode;
    data['description'] = this.description;
    data['price'] = this.price;
    data['mrp'] = this.mrp;
    data['purchase_price'] = this.purchasePrice;
    data['is_rent_available'] = this.isRentAvailable;
    data['rent_period'] = this.rentPeriod;
    data['rent_price'] = this.rentPrice;
    data['cost_price'] = this.costPrice;
    data['landing_cost'] = this.landingCost;
    data['quantity'] = this.quantity;
    data['imei_no'] = this.imeiNo;
    data['images'] = this.images;
    data['gst_option'] = this.gstOption;
    data['product_gst'] = this.productGst;
    data['availablility'] = this.availablility;
    data['status'] = this.status;
    data['availability'] = this.availability;
    data['isDeleted'] = this.isDeleted;
    data['create_by'] = this.createBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.imageUrl != null) {
      data['image_url'] = this.imageUrl;
    }
    if (this.variants != null) {
      data['variants'] = this.variants;
    }
    return data;
  }
}
