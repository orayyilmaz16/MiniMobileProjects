import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Kendi dosya yollarını kontrol et
import '../providers/product_provider.dart';
import '../providers/favorite_provider.dart';
import '../../../cart/presentation/cart_provider.dart';
import '../../domain/models/product_model.dart';
import '../../../../core/theme/theme_provider.dart';

// Kategori yönetimi için provider
final selectedCategoryProvider = StateProvider<String>((ref) => "Tümü");

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartItems = ref.watch(cartProvider);

    // Toplam ürün adedini hesapla
    final int cartItemCount = cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final favoriteList = ref.watch(favoriteProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Responsive grid ayarı
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Keşfet',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          // TEMA DEĞİŞTİRME
          IconButton(
            icon: Icon(isDark ? Ionicons.sunny_outline : Ionicons.moon_outline),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),

          // FAVORİLER
          _buildBadgeIcon(
            icon: Ionicons.heart_outline,
            count: favoriteList.length,
            onTap: () => context.push('/favorites'),
            theme: theme,
          ),

          // SEPET
          _buildBadgeIcon(
            icon: Ionicons.cart_outline,
            count: cartItemCount,
            onTap: () => context.push('/cart'),
            theme: theme,
          ),

          // PROFİL (ASSETS'DEN)
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: const AssetImage('assets/images/oray.png'),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(productsProvider),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // BAŞLIK VE KATEGORİLER
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      "Profesyonel Ekipmanlar",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryChips(ref, selectedCategory, theme),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ÜRÜN LİSTESİ (FİLTRELENMİŞ)
            productsAsyncValue.when(
              data: (products) {
                final filteredProducts = selectedCategory == "Tümü"
                    ? products
                    : products
                          .where((p) => p.category == selectedCategory)
                          .toList();

                if (filteredProducts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text("Bu kategoride ürün bulunamadı."),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio:
                          0.62, // Taşmayı önlemek için oran güncellendi
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ProductCard(product: filteredProducts[index]),
                      childCount: filteredProducts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) =>
                  SliverFillRemaining(child: Center(child: Text('Hata: $err'))),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ), // Bottom bar payı
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildBadgeIcon({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon), onPressed: onTap),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChips(WidgetRef ref, String selected, ThemeData theme) {
    final categories = [
      "Tümü",
      "Makine",
      "Lens",
      "Drone",
      "Aksesuar",
      "Düzenleme",
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = categories[index] == selected;
          return GestureDetector(
            onTap: () => ref.read(selectedCategoryProvider.notifier).state =
                categories[index],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- PRODUCT CARD (GELİŞTİRİLMİŞ) ---
class ProductCard extends ConsumerWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(favoriteProvider).contains(product.id);

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RESİM VE FAVORİ BUTONU
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: _buildProductImage(product.imageUrl),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(favoriteProvider.notifier)
                          .toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                          color: isFavorite ? Colors.red : Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ÜRÜN BİLGİLERİ
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Ionicons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${product.rating} (${product.reviewCount})",
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₺${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} sepete eklendi'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Ionicons.add,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dinamik Resim Yükleyici (Asset veya Network)
  Widget _buildProductImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey[200]),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported),
      ),
    );
  }
}
