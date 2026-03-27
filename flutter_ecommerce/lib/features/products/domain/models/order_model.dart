enum OrderStatus { received, preparing, onWay, delivered }

class OrderItem {
  final String id;
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

  // CRUD işlemleri için nesneyi kopyalamamızı sağlar
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

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final String addressTitle;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.items,
    required this.status,
    required this.addressTitle,
    required this.date,
  });

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
