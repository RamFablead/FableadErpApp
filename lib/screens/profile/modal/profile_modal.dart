class ProfileModal {
  bool? status;
  ProfileData? data;
  String? message;

  ProfileModal({this.status, this.data, this.message});

  ProfileModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message']?.toString();
    if (json['data'] != null) {
      data = ProfileData.fromJson(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    if (message != null) dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class ProfileData {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? profileImage;
  String? role;

  ProfileData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.role,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    email = json['email']?.toString();
    phone = json['phone']?.toString();
    profileImage = json['profile_image']?.toString();
    role = json['role']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    dataMap['name'] = name;
    dataMap['email'] = email;
    dataMap['phone'] = phone;
    dataMap['profile_image'] = profileImage;
    dataMap['role'] = role;
    return dataMap;
  }
}
