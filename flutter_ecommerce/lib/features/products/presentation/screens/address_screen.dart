import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/address_provider.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Adreslerim")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-address'),
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(Ionicons.add, color: theme.colorScheme.onPrimary),
        label: Text(
          "Yeni Adres Ekle",
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: addresses.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return _buildAddressCard(context, ref, addr, theme);
              },
            ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    WidgetRef ref,
    AddressModel addr,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Ionicons.location_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          addr.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${addr.district}, ${addr.city}\n${addr.fullAddress}",
            style: TextStyle(color: theme.colorScheme.secondary, fontSize: 13),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Ionicons.create_outline, size: 20),
              onPressed: () => context.push('/add-address', extra: addr),
            ),
            IconButton(
              icon: Icon(
                Ionicons.trash_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: () => _confirmDelete(context, ref, addr.id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adresi Sil?"),
        content: const Text("Bu adres kalıcı olarak kaldırılacaktır."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressProvider.notifier).deleteAddress(id);
              Navigator.pop(ctx);
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.map_outline,
            size: 64,
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text("Kayıtlı adres bulunamadı."),
        ],
      ),
    );
  }
}
