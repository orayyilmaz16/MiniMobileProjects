import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

// Kendi cart provider yolunu doğrula
import '../cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // DİNAMİK PROVIDER BAĞLANTILARI
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: theme
          .scaffoldBackgroundColor, // background yerine scaffoldBackgroundColor
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Sepetim',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            if (cartItems.isNotEmpty)
              Text(
                '${cartItems.length} Ürün',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          if (cartItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Ionicons.trash_outline,
                  color: Colors.redAccent,
                  size: 22,
                ),
                onPressed: () => _showClearCartDialog(context, ref, theme),
                tooltip: "Sepeti Boşalt",
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(theme, context)
          : Stack(
              children: [
                // 1. SEPET ÜRÜNLERİ LİSTESİ
                ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildDismissibleCartItem(context, item, ref, theme);
                  },
                ),

                // 2. CAM EFEKTLİ ALT BAR (ÖDEME KISMI)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildGlassmorphismCheckout(
                    context,
                    totalAmount,
                    theme,
                  ),
                ),
              ],
            ),
    );
  }

  // --- KAYDIRARAK SİLME (SWIPE TO DELETE) ---
  Widget _buildDismissibleCartItem(
    BuildContext context,
    dynamic item,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.red],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Ionicons.trash, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        ref.read(cartProvider.notifier).removeItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Ionicons.checkmark_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("${item.name} sepetten çıkarıldı.")),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: _buildCartItemCard(item, ref, theme),
    );
  }

  // --- MODERN KART TASARIMI ---
  Widget _buildCartItemCard(dynamic item, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ürün Görseli Kutusu
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor, // background yerine
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              // HATA ÇÖZÜMÜ: Eğer item.image boşsa, item.product.imageUrl'i deniyoruz.
              child: _buildSmartImage(
                item.product.imageUrl ?? item.image,
                theme,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Detaylar ve Kontroller
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name ?? 'İsimsiz Ürün',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${(item.price ?? 0.0).toStringAsFixed(2)}",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                // Miktar Kontrol Bloğu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildQtyButton(
                            icon: Ionicons.remove,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .decrementQuantity(item.id),
                            theme: theme,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            alignment: Alignment.center,
                            child: Text(
                              "${item.quantity ?? 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildQtyButton(
                            icon: Ionicons.add,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .addToCart(item.product),
                            theme: theme,
                            isAdd: true,
                          ),
                        ],
                      ),
                    ),
                    // Satır Fiyatı
                    Text(
                      "\$${(item.totalPrice ?? 0.0).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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

  // YENİ: Hem Assets Hem Network destekleyen Akıllı Resim Widget'ı (GÜÇLENDİRİLDİ)
  Widget _buildSmartImage(dynamic imagePath, ThemeData theme) {
    // String'in başındaki sonundaki gereksiz boşlukları sil (Bazen API'den boşluklu gelebiliyor)
    final String path = imagePath?.toString().trim() ?? '';

    if (path.isEmpty) {
      return _buildImageFallback(theme);
    }

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildImageFallback(theme),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFallback(theme),
      );
    }

    return _buildImageFallback(theme);
  }

  // Resim yüklenemediğinde gösterilecek şık yer tutucu
  Widget _buildImageFallback(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.05),
      child: Center(
        child: Icon(
          Ionicons.image_outline,
          color: theme.colorScheme.primary.withOpacity(0.4),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isAdd = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: isAdd
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // --- BOŞ SEPET EKRANI ---
  Widget _buildEmptyCart(ThemeData theme, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.bag_handle_outline,
                size: 100,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Sepetiniz Bomboş",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Harika ürünler keşfetmek için\nmağazamıza göz atın.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Alışverişe Başla",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ALT ÖDEME ÇUBUĞU (GLASSMORPHISM) ---
  Widget _buildGlassmorphismCheckout(
    BuildContext context,
    double totalAmount,
    ThemeData theme,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(
              0.85,
            ), // surface yerine
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Toplam Tutar",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ödeme Yap",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Ionicons.arrow_forward_outline,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SEPETİ BOŞALT ONAY DİYALOĞU ---
  void _showClearCartDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.trash_outline,
                color: Colors.redAccent,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Sepeti Boşalt",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Sepetinizdeki tüm ürünler silinecektir.\nBu işlem geri alınamaz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Evet, Sil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
