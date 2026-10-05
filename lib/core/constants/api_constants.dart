class ApiConstants {
  static const String baseUrl = 'https://erp-demo.fableadtech.com';
  
  // Auth Endpoints
  static const String loginEndpoint = '/api/loginapi';
  
  // Product, Category & Order Endpoints
  static const String getAllProductEndpoint = '/api/getAllProduct';
  static const String getAllCategoryEndpoint = '/api/getAllCategory';
  static const String getAllCustomerEndpoint = '/api/getAllCustomer';
  static const String getOrdersEndpoint = '/api/get_orders';
  static const String orderSaleEndpoint = '/api/order_sale';
  static String deleteOrderEndpoint(dynamic orderId) => '/api/delete/$orderId';
  
  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyRememberMe = 'remember_me';
  static const String keySavedEmail = 'saved_email';
  static const String keySavedPassword = 'saved_password';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
