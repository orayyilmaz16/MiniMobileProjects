import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/address_provider.dart';

class AddressDetailScreen extends ConsumerWidget {
  final String addressId;
  const AddressDetailScreen({super.key, required this.addressId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addresses = ref.watch(addressProvider);

    // Adresi bul, eğer silindiyse güvenli bir şekilde geri dön
    final addressIndex = addresses.indexWhere((a) => a.id == addressId);
    if (addressIndex == -1) {
      Future.delayed(Duration.zero, () => context.pop());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final addr = addresses[addressIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(addr.title),
        actions: [
          // Sağ üst köşeye hızlı düzenleme ikonu
          IconButton(
            icon: const Icon(Ionicons.create_outline),
            onPressed: () => context.push('/add-address', extra: addr),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ADRES ÖNİZLEME KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Ionicons.location, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        addr.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow("Teslim Alacak", addr.fullName, theme),
                  _buildDetailRow(
                    "Şehir / İlçe",
                    "${addr.city} / ${addr.district}",
                    theme,
                  ),
                  _buildDetailRow("Açık Adres", addr.fullAddress, theme),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // EYLEM BUTONLARI
            _buildActionButton(
              context,
              title: "Adres Bilgilerini Güncelle",
              icon: Ionicons.create_outline,
              color: theme.colorScheme.primary,
              onTap: () => context.push('/add-address', extra: addr),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              title: "Bu Adresi Sil",
              icon: Ionicons.trash_outline,
              color: theme.colorScheme.error,
              onTap: () => _confirmDelete(context, ref, addr.id, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Icon(Ionicons.chevron_forward, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Adresi Sil?"),
        content: const Text(
          "Bu adres kalıcı olarak silinecek. Onaylıyor musunuz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("VAZGEÇ"),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(addressProvider.notifier).deleteAddress(id);
              Navigator.pop(ctx);
              context.pop(); // Detay sayfasından çık
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
