import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';

import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import 'product_list_screen.dart'; // ProductCard'ı kullanabilmek için

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Favori ID'lerini ve Tüm Ürünleri dinle
    final favoriteIds = ref.watch(favoriteProvider);
    final productsAsyncValue = ref.watch(productsProvider);

    // TEMA VERİSİNİ ALIYORUZ
    final theme = Theme.of(context);

    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Scaffold(
      // SABİT RENK YERİNE TEMANIN ARKA PLANINI KULLANIYORUZ
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Favorilerim',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: favoriteIds.isEmpty
          ? _buildEmptyFavorites(theme)
          : productsAsyncValue.when(
              data: (products) {
                // Sadece favori ID'lerine sahip ürünleri filtrele
                final favoriteProducts = products
                    .where((p) => favoriteIds.contains(p.id))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    // ProductCard zaten temaya duyarlı olduğu için direkt kullanıyoruz
                    return ProductCard(product: favoriteProducts[index]);
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Hata: $error',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
    );
  }

  // BOŞ DURUM TASARIMI (Temaya Duyarlı)
  Widget _buildEmptyFavorites(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.heart_dislike_outline,
            size: 80,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz favori ürününüz yok",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Beğendiğiniz ürünlerdeki kalp ikonuna\ntıklayarak buraya ekleyebilirsiniz.",
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.secondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
