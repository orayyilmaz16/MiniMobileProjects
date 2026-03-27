import '../../../core/network/dio_client.dart';
import '../domain/models/product_model.dart';
import '../../../core/utils/logger.dart';

class ProductRepository {
  final DioClient _api = DioClient();

  Future<List<ProductModel>> getProducts() async {
    try {
      logger.i("API'den ürünler çekiliyor...");
      // Gerçek senaryoda: final response = await _api.dio.get(ApiConstants.getProducts);
      // return (response.data as List).map((x) => ProductModel.fromJson(x)).toList();

      // Şimdilik API gecikmesini simüle edip mock veriyi dönüyoruz
      await Future.delayed(const Duration(seconds: 1));
      return mockProducts; // domain/models/product_model.dart içindeki veri
    } catch (e) {
      logger.e("Ürünler getirilirken hata oluştu: $e");
      throw Exception('Ürünler yüklenemedi');
    }
  }
}
