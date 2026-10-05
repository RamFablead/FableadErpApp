class AllBrandModal {
  bool? status;
  List<Data>? data;
  Pagination? pagination;

  AllBrandModal({this.status, this.data, this.pagination});

  AllBrandModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? clientUuid;
  int? branchId;
  String? name;
  String? logo;
  String? email;
  Null? phone;
  int? status;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? logoUrl;

  Data(
      {this.id,
        this.clientUuid,
        this.branchId,
        this.name,
        this.logo,
        this.email,
        this.phone,
        this.status,
        this.isDeleted,
        this.createdAt,
        this.updatedAt,
        this.logoUrl});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientUuid = json['client_uuid'];
    branchId = json['branch_id'];
    name = json['name'];
    logo = json['logo'];
    email = json['email'];
    phone = json['phone'];
    status = json['status'];
    isDeleted = json['isDeleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    logoUrl = json['logo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client_uuid'] = this.clientUuid;
    data['branch_id'] = this.branchId;
    data['name'] = this.name;
    data['logo'] = this.logo;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['status'] = this.status;
    data['isDeleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['logo_url'] = this.logoUrl;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  String? nextPageUrl;
  Null? prevPageUrl;

  Pagination(
      {this.currentPage,
        this.lastPage,
        this.perPage,
        this.total,
        this.nextPageUrl,
        this.prevPageUrl});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
    nextPageUrl = json['next_page_url'];
    prevPageUrl = json['prev_page_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['per_page'] = this.perPage;
    data['total'] = this.total;
    data['next_page_url'] = this.nextPageUrl;
    data['prev_page_url'] = this.prevPageUrl;
    return data;
  }
}
