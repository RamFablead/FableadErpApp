class CustomerListResponseModel {
  final bool status;
  final List<CustomerItemModel> data;
  final CustomerPaginationModel? pagination;

  CustomerListResponseModel({
    required this.status,
    required this.data,
    this.pagination,
  });

  factory CustomerListResponseModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'];
    List<CustomerItemModel> list = [];
    if (rawList is List) {
      list = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => CustomerItemModel.fromJson(item))
          .toList();
    }

    return CustomerListResponseModel(
      status: json['status'] == true,
      data: list,
      pagination: json['pagination'] is Map<String, dynamic>
          ? CustomerPaginationModel.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((item) => item.toJson()).toList(),
      if (pagination != null) 'pagination': pagination!.toJson(),
    };
  }
}

class CustomerPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  CustomerPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory CustomerPaginationModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaginationModel(
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
      from: json['from'] is int
          ? json['from']
          : int.tryParse(json['from']?.toString() ?? ''),
      to: json['to'] is int
          ? json['to']
          : int.tryParse(json['to']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
    };
  }
}

class CustomerItemModel {
  final int id;
  final String name;
  final String? customerCode;
  final String? email;
  final String? phone;
  final String? gstNumber;
  final String? panNumber;
  final String? profileImage;
  final String? profileImageUrl;
  final String? country;
  final String? city;

  CustomerItemModel({
    required this.id,
    required this.name,
    this.customerCode,
    this.email,
    this.phone,
    this.gstNumber,
    this.panNumber,
    this.profileImage,
    this.profileImageUrl,
    this.country,
    this.city,
  });

  factory CustomerItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      customerCode: json['customer_code']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      panNumber: json['pan_number']?.toString(),
      profileImage: json['profile_image']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'customer_code': customerCode,
      'email': email,
      'phone': phone,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'country': country,
      'city': city,
    };
  }

  /// Initial letter for avatar circle
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  /// Formatted subtitle (phone, city or customer code)
  String get displaySubtitle {
    final parts = <String>[];
    if (phone != null && phone!.trim().isNotEmpty) {
      parts.add(phone!.trim());
    }
    if (city != null && city!.trim().isNotEmpty) {
      parts.add(city!.trim());
    } else if (customerCode != null && customerCode!.trim().isNotEmpty) {
      parts.add(customerCode!.trim());
    }
    return parts.join(' • ');
  }

  /// Checks if customer profile image is a valid remote URL
  bool get hasValidImage {
    return profileImageUrl != null &&
        profileImageUrl!.isNotEmpty &&
        (profileImageUrl!.startsWith('http://') ||
            profileImageUrl!.startsWith('https://')) &&
        !profileImageUrl!.contains('customer5.jpg'); // default generic placeholder
  }
}
