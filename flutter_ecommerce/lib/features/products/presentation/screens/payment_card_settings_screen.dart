import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
// Kendi model ve provider yollarını doğrula
import '../providers/payment_provider.dart';

class PaymentCardSettingsScreen extends ConsumerWidget {
  final String cardId;
  const PaymentCardSettingsScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cards = ref.watch(paymentProvider);
    final cardIndex = cards.indexWhere((c) => c.id == cardId);

    if (cardIndex == -1) {
      Future.delayed(Duration.zero, () => context.pop());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = cards[cardIndex];

    return Scaffold(
      // Arka planı tamamen koyu ve derinlikli yapıyoruz
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Kart Ayarları",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PREMIUM KART GÖRSELİ (Görseldeki Gradient Yapısı)
            _buildPremiumCard(card),

            const SizedBox(height: 40),
            _buildSectionLabel("YÖNETİM"),
            const SizedBox(height: 16),

            // 2. YÖNETİM PANELİ (Gruplanmış Liste)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Varsayılan Yap
                  _buildModernListTile(
                    title: "Varsayılan Ödeme Yöntemi",
                    subtitle: "Hızlı siparişler için öncelikli kullanılır.",
                    icon: card.isDefault
                        ? Ionicons.star
                        : Ionicons.star_outline,
                    iconColor: Colors.amber,
                    trailing: Switch.adaptive(
                      value: card.isDefault,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        if (val)
                          ref
                              .read(paymentProvider.notifier)
                              .setAsDefault(card.id);
                      },
                    ),
                  ),
                  _buildDivider(),
                  // Güncelle
                  _buildModernListTile(
                    title: "Bilgileri Güncelle",
                    subtitle: "İsim veya son kullanım tarihini düzenleyin.",
                    icon: Ionicons.create_outline,
                    onTap: () => context.push('/edit-card', extra: card),
                  ),
                  _buildDivider(),
                  // Sil
                  _buildModernListTile(
                    title: "Ödeme Yöntemini Kaldır",
                    subtitle: "Bu kart hesabınızdan kalıcı olarak silinecek.",
                    icon: Ionicons.trash_outline,
                    iconColor: Colors.redAccent,
                    onTap: () => _showDeleteBottomSheet(context, ref, card.id),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            // Güvenlik Bilgisi
            Center(
              child: Column(
                children: [
                  Icon(
                    Ionicons.shield_checkmark,
                    color: Colors.white.withOpacity(0.3),
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Kart bilgileriniz 256-bit SSL ile uçtan uca\ngüvenle saklanmaktadır.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODERN BİLEŞENLER ---

  Widget _buildPremiumCard(dynamic card) {
    return AspectRatio(
      aspectRatio: 1.58, // Standart kart oranı
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF333399), Color(0xFF663399), Color(0xFFFF00CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF00CC).withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dekoratif Parlama Efekti
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Ionicons.card_outline,
                        color: Colors.white70,
                        size: 32,
                      ),
                      const Text(
                        "VISA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    card.no, // Örn: **** **** **** 4242
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardSmallLabel("KART SAHİBİ", card.holderName),
                      _cardSmallLabel("GEÇERLİLİK", card.exp),
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

  Widget _cardSmallLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildModernListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.white).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
      ),
      trailing:
          trailing ??
          Icon(
            Ionicons.chevron_forward,
            color: Colors.white.withOpacity(0.2),
            size: 16,
          ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, color: Colors.white.withOpacity(0.03), indent: 70);

  // --- SİLME ONAYI (MODERN BOTTOM SHEET) ---
  void _showDeleteBottomSheet(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Ionicons.alert_circle,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Kartı Siliyorsunuz",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Bu ödeme yöntemi kalıcı olarak kaldırılacaktır. Devam etmek istiyor musunuz?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Vazgeç",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(paymentProvider.notifier).deleteCard(id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Evet, Sil",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
