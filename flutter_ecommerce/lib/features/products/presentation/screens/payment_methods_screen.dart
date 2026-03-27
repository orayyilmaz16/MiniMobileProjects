import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
// Kendi model ve provider yollarını doğrula
import '../providers/payment_provider.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cards = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Derin siyah
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. MODERN COLLAPSING APPBAR
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0D0D0D),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Ödeme Yöntemlerim",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Ionicons.chevron_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // 2. KART LİSTESİ VEYA BOŞ DURUM
          cards.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState(theme))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildModernCreditCard(
                          context,
                          cards[index],
                          theme,
                        ),
                      ),
                      childCount: cards.length,
                    ),
                  ),
                ),
        ],
      ),

      // 3. FLOAT ACTION BUTTON (MODERN TASARIM)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Ionicons.add_circle, size: 24),
        label: const Text(
          "Yeni Kart Ekle",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
    );
  }

  // --- MODERN KART BİLEŞENİ ---
  Widget _buildModernCreditCard(
    BuildContext context,
    dynamic card,
    ThemeData theme,
  ) {
    // Kart tipine göre dinamik gradyan seçimi
    bool isVisa = card.type.toLowerCase().contains('visa');
    bool isDefault = card.isDefault;

    return GestureDetector(
      onTap: () => context.push('/payment-details', extra: card.id),
      child: Hero(
        tag: 'card_${card.id}',
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: isVisa
                  ? [const Color(0xFF1a2a6c), const Color(0xFFb21f1f)]
                  : [const Color(0xFF232526), const Color(0xFF414345)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (isVisa ? Colors.red : Colors.black).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Arka plan desen efekti
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    Ionicons.card,
                    size: 200,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Ionicons.aperture_outline,
                            color: Colors.white70,
                            size: 36,
                          ),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Ionicons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "VARSAYILAN",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              card.type.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
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
                          _buildCardLabel("KART SAHİBİ", card.holderName),
                          _buildCardLabel("GEÇERLİLİK", card.exp),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.bold,
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

  // --- BOŞ DURUM TASARIMI ---
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.wallet_outline,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Cüzdanınız Boş",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Hızlı alışveriş yapmak için hemen bir\nödeme yöntemi ekleyin.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
