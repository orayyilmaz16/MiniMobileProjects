import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderStatus { ordered, preparing, shipping, delivered, cancelled }

// 1. ÜRÜN MODELİ (CRUD için güncellendi)
class OrderItem {
  final String id; // Ürünü ayırt etmek için şart
  final String productName;
  final String image;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.productName,
    required this.image,
    required this.price,
    required this.quantity,
  });

  // Reorder sırasında miktar güncellemek için gerekli
  OrderItem copyWith({int? quantity}) {
    return OrderItem(
      id: id,
      productName: productName,
      image: image,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

// 2. SİPARİŞ MODELİ
class OrderModel {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final List<OrderItem> items;
  final String addressTitle;

  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.addressTitle,
  });

  // Toplam tutarı her seferinde içindeki item'lardan hesaplar (Dinamik)
  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

// 3. SİPARİŞ LİSTESİNİ YÖNETEN NOTIFIER (Geçmiş Siparişler)
class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier()
    : super([
        OrderModel(
          id: "ORD-9923",
          status: OrderStatus.preparing,
          addressTitle: "Ev Adresi",
          date: DateTime.now(),
          items: [
            OrderItem(
              id: "p1",
              productName: "Kablosuz Kulaklık",
              image:
                  "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200",
              price: 120.0,
              quantity: 1,
            ),
            OrderItem(
              id: "p2",
              productName: "Akıllı Saat",
              image:
                  "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200",
              price: 250.0,
              quantity: 2,
            ),
          ],
        ),
      ]);

  // Yeni tamamlanan siparişi geçmişe ekler
  void addOrder(OrderModel order) {
    state = [order, ...state];
  }
}

// 4. PROVIDER TANIMLARI
final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((
  ref,
) {
  return OrderNotifier();
});

// --- TEKRAR SİPARİŞ (REORDER) İÇİN ÖZEL NOTIFIER ---
// Bu notifier, mevcut bir siparişi alıp üzerinde değişiklik yapmamızı sağlar.
class ReorderNotifier extends StateNotifier<List<OrderItem>> {
  ReorderNotifier() : super([]);

  // Mevcut sipariş ürünlerini düzenleme moduna sokar
  void initReorder(List<OrderItem> items) {
    state = items.map((e) => e.copyWith()).toList();
  }

  // CRUD: Miktar Güncelle
  void updateQty(String id, int delta) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(quantity: (item.quantity + delta).clamp(1, 99))
        else
          item,
    ];
  }

  // CRUD: Ürün Sil
  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final reorderProvider = StateNotifierProvider<ReorderNotifier, List<OrderItem>>(
  (ref) {
    return ReorderNotifier();
  },
);
