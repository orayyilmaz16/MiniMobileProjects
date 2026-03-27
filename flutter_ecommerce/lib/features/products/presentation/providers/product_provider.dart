import 'package:flutter_ecommerce/features/products/data/product_repository.dart';
import 'package:flutter_ecommerce/features/products/domain/models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository'i sağlayan provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Ürün listesini asenkron olarak çeken FutureProvider
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProducts();
});
