import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Yardım ve Destek",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arama Çubuğu
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Nasıl yardımcı olabiliriz?",
                        hintStyle: TextStyle(
                          color: theme.colorScheme.secondary,
                        ),
                        prefixIcon: Icon(
                          Ionicons.search,
                          color: theme.colorScheme.secondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Hızlı İletişim Kanalları
                  Text(
                    "Bize Ulaşın",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactCard(
                          Ionicons.chatbubble_ellipses_outline,
                          "Canlı Destek",
                          Colors.blueAccent,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildContactCard(
                          Ionicons.call_outline,
                          "Müşteri Hiz.",
                          Colors.green,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // SSS (Sıkça Sorulan Sorular)
                  Text(
                    "Sıkça Sorulan Sorular",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFaqGroup(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqGroup(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildFaqItem(
            "Siparişim ne zaman kargoya verilir?",
            "Siparişleriniz genellikle 24 saat içinde işleme alınır ve kargoya teslim edilir. Yoğun kampanya dönemlerinde bu süre 48 saate çıkabilir.",
            theme,
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
          _buildFaqItem(
            "İade sürecini nasıl başlatabilirim?",
            "Siparişlerim sayfasına giderek iade etmek istediğiniz ürünün yanındaki 'İade Talebi' butonuna basmanız yeterlidir. Ücretsiz kargo kodu alacaksınız.",
            theme,
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
          _buildFaqItem(
            "Kapıda ödeme seçeneği var mı?",
            "Evet, belirli bölgeler için kapıda nakit veya kredi kartı ile ödeme seçeneğimiz mevcuttur. Ödeme adımından seçebilirsiniz.",
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, ThemeData theme) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      iconColor: theme.colorScheme.primary,
      collapsedIconColor: theme.colorScheme.secondary,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: TextStyle(
            color: theme.colorScheme.secondary,
            height: 1.5,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
