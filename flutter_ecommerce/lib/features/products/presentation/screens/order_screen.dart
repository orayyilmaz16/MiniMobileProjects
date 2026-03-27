import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/order_provider.dart'; // Daha önce oluşturduğumuz Provider

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Siparişleri provider'dan alıyoruz
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Siparişlerim",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // --- ÇÖZÜM BURADA: Manuel Geri Butonu ---
        leading: IconButton(
          icon: Icon(
            Ionicons.chevron_back, // Senin Ionicons kütüphanene uygun
            color: theme.colorScheme.primary,
            size: 26,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop(); // Eğer geri gidebilecek bir yer varsa geri git
            } else {
              context.go(
                '/home',
              ); // Yoksa (direkt linkle gelindiyse) ana sayfaya dön
            }
          },
        ),
        // ---------------------------------------
      ),
      body: orders.isEmpty
          ? _buildEmptyState(theme)
          : RefreshIndicator(
              onRefresh: () async {
                // Burada API'den tekrar veri çekme işlemi simüle edilebilir
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: orders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _OrderCard(order: orders[index]);
                },
              ),
            ),
    );
  }

  // SİPARİŞ YOKSA GÖSTERİLECEK EKRAN
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.bag_handle_outline,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Henüz siparişiniz yok",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "En yeni ürünleri keşfetmeye ne dersiniz?",
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {}, // Ana sayfaya yönlendirilebilir
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Alışverişe Başla"),
          ),
        ],
      ),
    );
  }
}

// --- ALT BİLEŞEN: SİPARİŞ KARTI ---
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      // OrdersScreen içindeki _OrderCard widget'ında:
      onTap: () => context.push('/order-detail', extra: order.id),
      // Artık ID'yi URL'e yazmıyoruz, güvenli bir şekilde arkadan gönderiyoruz.
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.2 : 0.03,
              ),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sipariş No: ${order.id}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "22 Mart 2026", // Dinamik tarih eklenebilir
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            Divider(
              height: 32,
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  "Ürün Sayısı",
                  "${order.items.length} Ürün",
                  theme,
                ),
                _buildInfoColumn(
                  "Toplam",
                  "\$${order.totalAmount}",
                  theme,
                  isPrice: true,
                ),
                Icon(
                  Ionicons.chevron_forward,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
    ThemeData theme, {
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: isPrice ? FontWeight.w900 : FontWeight.w600,
            fontSize: isPrice ? 16 : 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.preparing:
        color = Colors.orange;
        text = "Hazırlanıyor";
        break;
      case OrderStatus.shipping:
        color = Colors.blue;
        text = "Kargoda";
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = "Teslim Edildi";
        break;
      default:
        color = Colors.grey;
        text = "Belirsiz";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
