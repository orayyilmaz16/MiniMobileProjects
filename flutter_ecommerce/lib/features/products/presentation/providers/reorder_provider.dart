import 'package:flutter_ecommerce/features/products/presentation/providers/order_provider.dart'
    hide OrderItem;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ecommerce/features/products/domain/models/order_model.dart';

class ReorderNotifier extends StateNotifier<List<OrderItem>> {
  ReorderNotifier() : super([]);

  // 1. Eski siparişi yükle (Create/Initialize)
  void loadFromOrder(List<OrderItem> items) {
    state = items.map((e) => e.copyWith()).toList();
  }

  // 2. Miktarı Güncelle (Update)
  void updateQuantity(String itemId, int delta) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(quantity: (item.quantity + delta).clamp(1, 99))
        else
          item,
    ];
  }

  // 3. Ürünü Çıkar (Delete)
  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  // Toplam Fiyat Hesapla
  double get total =>
      state.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

final reorderProvider = StateNotifierProvider<ReorderNotifier, List<OrderItem>>(
  (ref) {
    return ReorderNotifier();
  },
);
