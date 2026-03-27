class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.senineticaretprojen.com/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Product Endpoints
  static const String getProducts = '/products';
  static const String getProductDetails = '/products/'; // + id
}
