import 'user_model.dart';

class LoginResponseModel {
  final bool status;
  final String? message;
  final String? token;
  final UserModel? user;
  final String? redirect;
  final List<dynamic>? permissions;
  final bool? showAppointments;

  LoginResponseModel({
    required this.status,
    this.message,
    this.token,
    this.user,
    this.redirect,
    this.permissions,
    this.showAppointments,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString(),
      token: json['token']?.toString(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
      redirect: json['redirect']?.toString(),
      permissions: json['permissions'] is List ? json['permissions'] : [],
      showAppointments: json['showAppointments'] is bool
          ? json['showAppointments']
          : (json['showAppointments'] == 1 || json['showAppointments'] == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'token': token,
      'user': user?.toJson(),
      'redirect': redirect,
      'permissions': permissions,
      'showAppointments': showAppointments,
    };
  }
}
