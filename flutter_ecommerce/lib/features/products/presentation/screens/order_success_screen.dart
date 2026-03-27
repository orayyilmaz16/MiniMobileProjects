import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // İkon için tatlı bir zıplama (bounce) efekti
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Metinler ve butonlar için gecikmeli yumuşak geçiş (fade in)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Gerçek senaryoda bu ID'yi state'ten veya parametreden alabilirsin
    final orderId =
        "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    // PopScope'u Scaffold'un dışına alarak tüm geri dönüş denemelerini (Android back butonu dahil) engelliyoruz
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // 1. Zıplayan Başarı İkonu
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSuccessIcon(theme),
                ),

                const SizedBox(height: 40),

                // 2. Metinler ve Sipariş Rozeti (Gecikmeli Gelen Kısım)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildSuccessTexts(theme),
                      const SizedBox(height: 32),
                      _buildOrderBadge(orderId, theme),
                    ],
                  ),
                ),

                const Spacer(),

                // 3. Aksiyon Butonları (Gecikmeli Gelen Kısım)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildActionButtons(context, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- MODÜLER WIDGET PARÇALARI ---

  Widget _buildSuccessIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors
              .green, // İstersen gradient de verebilirsin: gradient: LinearGradient(...)
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Ionicons.checkmark_sharp,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildSuccessTexts(ThemeData theme) {
    return Column(
      children: [
        const Text(
          "Siparişiniz Alındı!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Teşekkür ederiz. Siparişiniz başarıyla oluşturuldu ve en kısa sürede kargoya teslim edilmek üzere hazırlanıyor.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.secondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderBadge(String orderId, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Ionicons.receipt_outline,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            "Sipariş No:",
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 8),
          Text(
            orderId,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // SİPARİŞİ TAKİP ET -> /orders rotasına gider
        SizedBox(
          width: double.infinity,
          height: 64, // Daha premium bir yükseklik
          child: ElevatedButton(
            onPressed: () {
              // Ödeme akışını sıfırlayıp siparişlerim sayfasına atarız
              context.go('/orders');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Siparişi Takip Et",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ALIŞVERİŞE DEVAM ET -> /home rotasına gider
        SizedBox(
          width: double.infinity,
          height: 64,
          child: TextButton(
            onPressed: () => context.go('/home'),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Alışverişe Devam Et",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
