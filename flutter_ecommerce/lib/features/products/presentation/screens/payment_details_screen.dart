import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
// Kendi provider ve model yollarını buraya ekle
import '../providers/payment_provider.dart';

class PaymentDetailsScreen extends ConsumerWidget {
  final String
  cardId; // Map yerine sadece ID alıyoruz, veriyi provider'dan anlık çekeceğiz

  const PaymentDetailsScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Kart listesini dinle ve ilgili kartı bul
    final cards = ref.watch(paymentProvider);
    final cardIndex = cards.indexWhere((c) => c.id == cardId);

    // Güvenlik kontrolü: Kart silindiyse ekrandan çık
    if (cardIndex == -1) {
      Future.delayed(Duration.zero, () => context.pop());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = cards[cardIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Derin siyah arka plan
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PREMIUM DİNAMİK KART ÖNİZLEME
            _buildPremiumCard(card),

            const SizedBox(height: 48),
            _buildSectionLabel("YÖNETİM PANELİ"),
            const SizedBox(height: 16),

            // 2. İŞLEM BLOĞU (Modern Glassmorphism Etkisi)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Varsayılan Yap Switch
                  _buildActionTile(
                    title: "Varsayılan Ödeme Yöntemi",
                    subtitle: "Hızlı siparişler için öncelikli kullanılır.",
                    icon: card.isDefault
                        ? Ionicons.star
                        : Ionicons.star_outline,
                    iconColor: Colors.amber,
                    theme: theme,
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
                  // Düzenle
                  _buildActionTile(
                    title: "Kart Bilgilerini Güncelle",
                    subtitle: "İsim veya son kullanım tarihini düzenleyin.",
                    icon: Ionicons.create_outline,
                    theme: theme,
                    onTap: () => context.push('/edit-card', extra: card),
                  ),
                  _buildDivider(),
                  // Sil
                  _buildActionTile(
                    title: "Bu Kartı Sistemden Kaldır",
                    subtitle: "Kart bilgileriniz kalıcı olarak silinecektir.",
                    icon: Ionicons.trash_outline,
                    iconColor: Colors.redAccent,
                    theme: theme,
                    onTap: () => _showModernDeleteSheet(context, ref, card.id),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // 3. GÜVENLİK ROZETİ
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  children: [
                    const Icon(
                      Ionicons.shield_checkmark_sharp,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Uçtan uca şifrelenmiş ödeme altyapısı ile\nbilgileriniz %100 güvendedir.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODERN COMPONENTLER ---

  Widget _buildPremiumCard(dynamic card) {
    bool isVisa = card.type.toLowerCase().contains('visa');

    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isVisa
                ? [
                    const Color(0xFF1a2a6c),
                    const Color(0xFFb21f1f),
                    const Color(0xFFfdbb2d),
                  ]
                : [const Color(0xFF232526), const Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVisa ? Colors.red : Colors.black).withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Ionicons.aperture_outline,
                  color: Colors.white70,
                  size: 40,
                ),
                Text(
                  card.type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,

                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            Text(
              card.no, // Dinamik kart numarası
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
                _cardInfoColumn("KART SAHİBİ", card.holderName),
                _cardInfoColumn("GEÇERLİLİK", card.exp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.white).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.white70, size: 22),
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
            size: 18,
          ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, color: Colors.white.withOpacity(0.03), indent: 76);

  // --- MODERN BOTTOM SHEET ONAYI ---
  void _showModernDeleteSheet(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Ionicons.alert_circle,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              "Kartı Silmek Üzeresiniz",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Bu ödeme yöntemini kaldırdığınızda gelecekteki hızlı ödemelerde kullanamayacaksınız.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Evet, Sil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
