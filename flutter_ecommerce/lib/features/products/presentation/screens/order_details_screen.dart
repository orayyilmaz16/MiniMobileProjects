import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
// Provider ve Model Importları (Kendi proje yollarına göre doğrula)
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Geçmiş siparişler listesinden ilgili siparişi bul
    final order = ref.watch(orderProvider).firstWhere((o) => o.id == orderId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Sipariş #${order.id}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARGO TAKİP ÇİZELGESİ
            _buildOrderTracker(order.status, theme),

            const SizedBox(height: 32),
            _buildSectionTitle("Sipariş İçeriği", theme),
            const SizedBox(height: 16),

            // 2. ÜRÜN LİSTESİ
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildProductItem(order.items[index], theme),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle("Teslimat & Ödeme", theme),
            const SizedBox(height: 16),

            // 3. ADRES VE ÖDEME BİLGİSİ
            _buildInfoCard(
              icon: Ionicons.location_outline,
              title: order.addressTitle,
              subtitle: "Teslimat Adresi",
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Ionicons.card_outline,
              title:
                  "**** 4242", // Mock (Siparişteki gerçek karta göre değişmeli)
              subtitle: "Ödeme Yöntemi",
              theme: theme,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle("Sipariş Özeti", theme),
            const SizedBox(height: 16),

            // 4. FİYAT ÖZETİ
            _buildPriceSummary(order, theme),

            const SizedBox(height: 40),

            // 5. TEKRAR SİPARİŞ ET BUTONU (Düzeltildi)
            _buildReorderButton(theme, ref, order, context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- ÖZEL BİLEŞENLER ---

  Widget _buildOrderTracker(OrderStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStep(Ionicons.checkmark_circle, "Alındı", true, theme),
              _buildStep(
                Ionicons.cube_outline,
                "Hazırlanıyor",
                status.index >= OrderStatus.preparing.index,
                theme,
              ),
              _buildStep(
                Ionicons.airplane_outline,
                "Kargoda",
                status.index >= OrderStatus.shipping.index,
                theme,
              ),
              _buildStep(
                Ionicons.home_outline,
                "Teslim Edildi",
                status.index >= OrderStatus.delivered.index,
                theme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (status.index + 1) / 4,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    IconData icon,
    String label,
    bool isActive,
    ThemeData theme,
  ) {
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary.withOpacity(0.3);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(OrderItem item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // GÖRSEL
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: item.image.startsWith('http')
                  ? Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                    )
                  : _buildPlaceholderIcon(),
            ),
          ),
          const SizedBox(width: 16),

          // BİLGİLER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.quantity} Adet",
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // FİYAT
          const SizedBox(width: 8),
          Text(
            "\$${(item.price * item.quantity).toStringAsFixed(2)}", // Toplam ürün fiyatı
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.image_not_supported, color: Colors.white24),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(OrderModel order, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _row(
            "Ara Toplam",
            "\$${(order.totalAmount - 10).toStringAsFixed(2)}",
            theme,
          ), // Sabit kargo düşülmüş mock
          const SizedBox(height: 12),
          _row("Teslimat Ücreti", "\$10.00", theme),
          const Divider(height: 32),
          _row(
            "Ödenen Tutar",
            "\$${order.totalAmount.toStringAsFixed(2)}",
            theme,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold
                ? theme.colorScheme.onSurface
                : theme.colorScheme.secondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: isGreen ? Colors.green : theme.colorScheme.onSurface,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // --- DÜZELTİLEN TEKRAR SİPARİŞ BUTONU ---
  Widget _buildReorderButton(
    ThemeData theme,
    WidgetRef ref,
    OrderModel order,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 64, // Biraz daha premium boyut
      child: ElevatedButton.icon(
        onPressed: () {
          // DOĞRU ÇAĞRI: 'initReorder' metodunu kullanıyoruz
          ref.read(reorderProvider.notifier).initReorder(order.items);

          // Yapılandırma sayfasına yönlendir
          context.push('/reorder-config');
        },
        icon: const Icon(Ionicons.refresh, color: Colors.black),
        label: const Text(
          "Tekrar Sipariş Et",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Görseldeki o ikonik beyaz buton
          foregroundColor: Colors.grey, // Tıklama efekti rengi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          shadowColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}
