import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/features/products/presentation/providers/order_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

// Kendi model ve provider yollarını buraya ekle
// import '../models/order_model.dart';
// import '../providers/order_provider.dart'; // reorderProvider'ın olduğu dosya

class ReorderConfigScreen extends ConsumerWidget {
  const ReorderConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // reorderProvider'ı dinliyoruz (Kullanıcının düzenlediği geçici sepet)
    final items = ref.watch(reorderProvider);

    // Toplam tutarı hesaplıyoruz
    final totalAmount = items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Siparişi Düzenle",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Ionicons.chevron_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState(theme, context)
          : Stack(
              children: [
                // 1. ÜRÜN LİSTESİ
                ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    140,
                  ), // Alt bar için boşluk
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildReorderItemCard(item, theme, ref);
                  },
                ),

                // 2. CAM EFEKTLİ (GLASSMORPHISM) ALT BAR
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFloatingBottomBar(theme, totalAmount, context),
                ),
              ],
            ),
    );
  }

  // --- MODERN ÜRÜN KARTI (CRUD İŞLEMLERİ) ---
  Widget _buildReorderItemCard(dynamic item, ThemeData theme, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ürün Görseli
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Ionicons.image_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Ürün Bilgileri ve Kontroller
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
                const SizedBox(height: 8),
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Miktar Kontrolü ve Silme Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Arttır / Azalt Row'u
                    Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildQtyButton(
                            icon: Ionicons.remove,
                            onTap: () => ref
                                .read(reorderProvider.notifier)
                                .updateQty(item.id, -1),
                            theme: theme,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "${item.quantity}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildQtyButton(
                            icon: Ionicons.add,
                            onTap: () => ref
                                .read(reorderProvider.notifier)
                                .updateQty(item.id, 1),
                            theme: theme,
                          ),
                        ],
                      ),
                    ),

                    // Silme İkonu
                    IconButton(
                      icon: const Icon(
                        Ionicons.trash_outline,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      onPressed: () => ref
                          .read(reorderProvider.notifier)
                          .removeItem(item.id),
                      tooltip: "Ürünü Çıkar",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Miktar Butonları (Yuvarlak ve Şık)
  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
      ),
    );
  }

  // Tüm Ürünler Silinirse Çıkacak Boş Ekran
  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.cart_outline,
            size: 80,
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            "Sipariş Listeniz Boş",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Tekrar sipariş etmek istediğiniz\ntüm ürünleri listeden çıkardınız.",
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.secondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              "Geri Dön",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Alt Bar (Ödemeye Geçiş)
  Widget _buildFloatingBottomBar(
    ThemeData theme,
    double total,
    BuildContext context,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              // Ödeme ekranına yönlendir
              context.push('/checkout');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              "Ödemeye Geç (\$${total.toStringAsFixed(2)})",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
