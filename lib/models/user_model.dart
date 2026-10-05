class UserModel {
  final dynamic id;
  final String? clientUuid;
  final dynamic branchId;
  final dynamic planId;
  final String? name;
  final String? companyName;
  final String? customerCode;
  final String? membershipNo;
  final String? customerSince;
  final String? email;
  final String? phone;
  final String? alternatePhone;
  final dynamic creditLimit;
  final dynamic creditDays;
  final String? gstNumber;
  final String? gstinStatus;
  final String? gender;
  final String? accountGroup;
  final String? panNumber;
  final String? panStatus;
  final String? tinNumber;
  final String? stateCode;
  final String? stateName;
  final String? customerCategory;
  final dynamic age;
  final String? dob;
  final String? doa;
  final String? emailVerifiedAt;
  final String? walletBalance;
  final String? faceDescriptor;
  final String? profileImage;
  final String? role;
  final dynamic status;
  final String? accountStatus;
  final dynamic isDeleted;
  final dynamic hasPermission;
  final dynamic createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? profileImageUrl;

  UserModel({
    this.id,
    this.clientUuid,
    this.branchId,
    this.planId,
    this.name,
    this.companyName,
    this.customerCode,
    this.membershipNo,
    this.customerSince,
    this.email,
    this.phone,
    this.alternatePhone,
    this.creditLimit,
    this.creditDays,
    this.gstNumber,
    this.gstinStatus,
    this.gender,
    this.accountGroup,
    this.panNumber,
    this.panStatus,
    this.tinNumber,
    this.stateCode,
    this.stateName,
    this.customerCategory,
    this.age,
    this.dob,
    this.doa,
    this.emailVerifiedAt,
    this.walletBalance,
    this.faceDescriptor,
    this.profileImage,
    this.role,
    this.status,
    this.accountStatus,
    this.isDeleted,
    this.hasPermission,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserModel();
    return UserModel(
      id: json['id'],
      clientUuid: json['client_uuid']?.toString(),
      branchId: json['branch_id'],
      planId: json['plan_id'],
      name: json['name']?.toString(),
      companyName: json['company_name']?.toString(),
      customerCode: json['customer_code']?.toString(),
      membershipNo: json['membership_no']?.toString(),
      customerSince: json['customer_since']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      alternatePhone: json['alternate_phone']?.toString(),
      creditLimit: json['credit_limit'],
      creditDays: json['credit_days'],
      gstNumber: json['gst_number']?.toString(),
      gstinStatus: json['gstin_status']?.toString(),
      gender: json['gender']?.toString(),
      accountGroup: json['account_group']?.toString(),
      panNumber: json['pan_number']?.toString(),
      panStatus: json['pan_status']?.toString(),
      tinNumber: json['tin_number']?.toString(),
      stateCode: json['state_code']?.toString(),
      stateName: json['state_name']?.toString(),
      customerCategory: json['customer_category']?.toString(),
      age: json['age'],
      dob: json['dob']?.toString(),
      doa: json['doa']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      walletBalance: json['wallet_balance']?.toString(),
      faceDescriptor: json['face_descriptor']?.toString(),
      profileImage: json['profile_image']?.toString(),
      role: json['role']?.toString(),
      status: json['status'],
      accountStatus: json['account_status']?.toString(),
      isDeleted: json['isDeleted'],
      hasPermission: json['haspermission'],
      createdBy: json['created_by'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_uuid': clientUuid,
      'branch_id': branchId,
      'plan_id': planId,
      'name': name,
      'company_name': companyName,
      'customer_code': customerCode,
      'membership_no': membershipNo,
      'customer_since': customerSince,
      'email': email,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'credit_limit': creditLimit,
      'credit_days': creditDays,
      'gst_number': gstNumber,
      'gstin_status': gstinStatus,
      'gender': gender,
      'account_group': accountGroup,
      'pan_number': panNumber,
      'pan_status': panStatus,
      'tin_number': tinNumber,
      'state_code': stateCode,
      'state_name': stateName,
      'customer_category': customerCategory,
      'age': age,
      'dob': dob,
      'doa': doa,
      'email_verified_at': emailVerifiedAt,
      'wallet_balance': walletBalance,
      'face_descriptor': faceDescriptor,
      'profile_image': profileImage,
      'role': role,
      'status': status,
      'account_status': accountStatus,
      'isDeleted': isDeleted,
      'haspermission': hasPermission,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile_image_url': profileImageUrl,
    };
  }
}
