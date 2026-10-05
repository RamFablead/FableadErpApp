class CategoryListResponseModel {
  final bool status;
  final List<CategoryItemModel> data;
  final CategoryPaginationModel? pagination;

  CategoryListResponseModel({
    required this.status,
    required this.data,
    this.pagination,
  });

  factory CategoryListResponseModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'];
    List<CategoryItemModel> list = [];
    if (rawList is List) {
      list = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => CategoryItemModel.fromJson(item))
          .toList();
    }

    return CategoryListResponseModel(
      status: json['status'] == true,
      data: list,
      pagination: json['pagination'] is Map<String, dynamic>
          ? CategoryPaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class CategoryPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  CategoryPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory CategoryPaginationModel.fromJson(Map<String, dynamic> json) {
    return CategoryPaginationModel(
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
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }
}

class CategoryItemModel {
  final int id;
  final String? clientUuid;
  final int? branchId;
  final String name;
  final String? image;
  final int? isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final String? imageUrl;

  CategoryItemModel({
    required this.id,
    this.clientUuid,
    this.branchId,
    required this.name,
    this.image,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      clientUuid: json['client_uuid']?.toString(),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? '1'),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      isDeleted: json['isDeleted'] is int
          ? json['isDeleted']
          : int.tryParse(json['isDeleted']?.toString() ?? '0'),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  /// Returns valid remote image URL or null if fallback/missing
  String? get validImageUrl {
    if (imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) &&
        !imageUrl!.contains('noimage.png')) {
      return imageUrl;
    }
    return null;
  }
}
