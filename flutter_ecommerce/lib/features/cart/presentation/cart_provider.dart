import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/domain/models/product_model.dart';

// --- 1. SEPET ÜRÜN MODELİ (Immutable) ---
class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Getter'lar: Null safety koruması ile doğrudan ürün özelliklerine erişim
  String get id => product.id;
  String get name => product.name ?? "İsimsiz Ürün";
  String get image => product.image ?? "";
  double get price => product.price ?? 0.0;

  // Toplam Tutar: Bu üründen elde edilen toplam gelir (Fiyat * Miktar)
  double get totalPrice => price * quantity;

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// --- 2. SEPET YÖNETİCİSİ (CartNotifier) ---
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// Sepeti tamamen boşaltır (Sipariş sonrasında kullanılır)
  void clearCart() => state = [];

  /// Sepete ürün ekler. Aynı üründen varsa miktarını artırır.
  /// [quantityToAdd] parametresi, ürün detay sayfasından tek seferde birden fazla eklenebilmesini sağlar.
  void addToCart(ProductModel product, {int quantityToAdd = 1}) {
    final isExisting = state.any((item) => item.id == product.id);

    if (isExisting) {
      state = state.map((item) {
        if (item.id == product.id) {
          return item.copyWith(quantity: item.quantity + quantityToAdd);
        }
        return item;
      }).toList();
    } else {
      state = [...state, CartItem(product: product, quantity: quantityToAdd)];
    }
  }

  /// Ürün miktarını 1 azaltır. Miktar 1 ise ürünü sepetten tamamen siler.
  void decrementQuantity(String productId) {
    final existingItem = state
        .where((item) => item.id == productId)
        .firstOrNull;

    if (existingItem != null) {
      if (existingItem.quantity > 1) {
        state = state.map((item) {
          if (item.id == productId) {
            return item.copyWith(quantity: item.quantity - 1);
          }
          return item;
        }).toList();
      } else {
        removeItem(productId);
      }
    }
  }

  /// Ürünü miktarına bakmaksızın sepetten tamamen çıkarır (Çöp kutusu butonu)
  void removeItem(String productId) {
    state = state.where((item) => item.id != productId).toList();
  }
}

// --- 3. DİNAMİK PROVIDER TANIMLAMALARI ---

/// Ana sepet state'i
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Sepetin Genel Toplam Tutarı (Örn: $370.0)
/// UI tarafında ref.watch(cartTotalProvider) ile dinlenir, sepet değiştikçe otomatik güncellenir.
final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0.0, (total, item) => total + item.totalPrice);
});

/// Sepetteki Toplam Ürün Adedi
/// UI tarafında Badge (Rozet) veya Sepet ikonunda sayıyı göstermek için kullanılır.
final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (count, item) => count + item.quantity);
});
