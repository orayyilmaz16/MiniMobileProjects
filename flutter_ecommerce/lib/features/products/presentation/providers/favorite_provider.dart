import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sadece favoriye alınan ürünlerin ID'lerini tutan bir liste state'i
class FavoriteNotifier extends StateNotifier<List<String>> {
  FavoriteNotifier() : super([]);

  // Favoriye ekle veya çıkar (Toggle mantığı)
  void toggleFavorite(String productId) {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
  }

  // Ürün favorilerde mi kontrolü
  bool isFavorite(String productId) {
    return state.contains(productId);
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<String>>((
  ref,
) {
  return FavoriteNotifier();
});
