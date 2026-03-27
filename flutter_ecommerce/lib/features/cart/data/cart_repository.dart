import '../../../core/network/dio_client.dart';

class CartRepository {
  final DioClient _api = DioClient();

  // Sepeti Satın Alma İsteği (Checkout)
  Future<bool> checkoutCart(
    List<Map<String, dynamic>> cartItems,
    double totalAmount,
  ) async {
    try {
      final response = await _api.dio.post(
        '/order/checkout',
        data: {
          'items': cartItems,
          'total_amount': totalAmount,
          'payment_method': 'credit_card',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
