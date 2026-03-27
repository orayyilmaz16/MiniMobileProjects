import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product_model.dart';
import '../../../cart/presentation/cart_provider.dart';
import '../providers/favorite_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  void _showReviewsBottomSheet(
    BuildContext context,
    ProductModel product,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // DİNAMİK ARKA PLAN
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Yorumlar (${product.reviewCount})",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Ionicons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: product.reviews.isEmpty
                    ? Center(
                        child: Text(
                          "Henüz yorum yapılmamış.",
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: product.reviews.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 32,
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final review = product.reviews[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Ionicons.person_circle,
                                        size: 40,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        review.userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    review.date,
                                    style: TextStyle(
                                      color: theme.colorScheme.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < review.rating.floor()
                                        ? Ionicons.star
                                        : Ionicons.star_outline,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review.comment,
                                style: TextStyle(
                                  height: 1.5,
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteList = ref.watch(favoriteProvider);
    final isFavorite = favoriteList.contains(product.id);

    // TEMA VERİSİNİ ALIYORUZ
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // DİNAMİK
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450.0,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                  color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
                  size: 28,
                ),
                onPressed: () {
                  ref
                      .read(favoriteProvider.notifier)
                      .toggleFavorite(product.id);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // DİNAMİK KART RENGİ
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Ionicons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${product.reviewCount} Değerlendirme)",
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildBadge("Stokta Var", theme),
                      const SizedBox(width: 8),
                      _buildBadge("Ücretsiz Kargo", theme),
                      const SizedBox(width: 8),
                      _buildBadge("Premium", theme, isDark: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Açıklama",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.secondary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Ionicons.chatbubble_outline),
                    color: theme.colorScheme.onSurface,
                    onPressed: () =>
                        _showReviewsBottomSheet(context, product, theme),
                  ),
                ),
                if (product.reviewCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        product.reviewCount > 99
                            ? '99+'
                            : product.reviewCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sepete eklendi!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary, // DİNAMİK BUTON RENGİ
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Sepete Ekle",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, ThemeData theme, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary
            : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isDark
            ? null
            : Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
