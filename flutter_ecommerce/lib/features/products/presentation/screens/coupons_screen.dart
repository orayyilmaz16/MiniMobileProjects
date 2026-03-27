import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeCoupons = [
    {
      'title': 'Bahar İndirimi',
      'code': 'BAHAR20',
      'discount': '%20',
      'desc': 'Tüm giyim ürünlerinde geçerlidir.',
      'expire': '2 Gün Kaldı',
      'color': const Color(0xFFFF00CC),
    },
    {
      'title': 'Kargo Bedava',
      'code': 'FREESHIP',
      'discount': 'KARGO',
      'desc': '150 TL ve üzeri alışverişlerde kargo bizden.',
      'expire': '30 Nisan 2026',
      'color': const Color(0xFF00C9FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Kupon kodu kopyalandı: $code",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "İndirim Kuponlarım",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.secondary,
          tabs: const [
            Tab(text: "Aktif Kuponlar"),
            Tab(text: "Geçmiş Kuponlar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCouponList(_activeCoupons, theme, isActive: true),
          _buildCouponList(
            [],
            theme,
            isActive: false,
          ), // Boş geçmiş liste simülasyonu
        ],
      ),
    );
  }

  Widget _buildCouponList(
    List<Map<String, dynamic>> coupons,
    ThemeData theme, {
    required bool isActive,
  }) {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.ticket_outline,
              size: 80,
              color: theme.colorScheme.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? "Aktif kuponunuz bulunmuyor."
                  : "Geçmiş kuponunuz bulunmuyor.",
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Sol İndirim Kısmı
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: coupon['color'].withOpacity(0.1),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    coupon['discount'],
                    style: TextStyle(
                      color: coupon['color'],
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              // Sağ Detay Kısmı
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon['desc'],
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Ionicons.time_outline,
                                size: 14,
                                color: Colors.orange.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                coupon['expire'],
                                style: TextStyle(
                                  color: Colors.orange.shade400,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard(coupon['code']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "KOPYALA",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
