import 'package:flutter_ecommerce/features/products/domain/models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart'; // ProductModel ve mockProducts'ın olduğu dosya

// 1. O an hangi kategorinin seçili olduğunu tutan sağlayıcı
// Başlangıçta "Tümü" seçili gelir.
final selectedCategoryProvider = StateProvider<String>((ref) => "Tümü");

// 2. Filtrelenmiş ürün listesini dönen sağlayıcı
// Bu sağlayıcı hem seçili kategoriyi hem de tüm ürün listesini dinler.
final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);

  // mockProducts listesini senin tanımladığın yerden çekiyoruz
  final allProducts = mockProducts;

  if (selectedCategory == "Tümü") {
    return allProducts;
  }

  // Ürünün 'category' alanı, seçilen kategoriyle aynı olanları filtrele
  return allProducts
      .where((product) => product.category == selectedCategory)
      .toList();
});
