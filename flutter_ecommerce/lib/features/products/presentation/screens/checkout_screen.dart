import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Teslimat Controllerları
  final _addressNameController = TextEditingController();
  final _addressDetailController = TextEditingController();
  final _cityController = TextEditingController();

  // Kredi Kartı Controllerları
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Kupon Controller
  final _couponController = TextEditingController();

  bool _isLoading = false;
  bool _isApplyingCoupon = false;

  // Seçim State'leri
  String _selectedPaymentMethod = 'default_card';
  String _selectedAddressId = 'address_1';

  // Kupon State'leri
  String? _appliedCouponCode;
  double _discountAmount = 0.0;

  // Mock Kayıtlı Adresler
  final List<Map<String, dynamic>> _savedAddresses = [
    {
      'id': 'address_1',
      'title': 'Ev Adresi',
      'name': 'Oray Yılmaz',
      'detail': 'Atatürk Mah. Cumhuriyet Cad. No:12 D:4',
      'city': 'Kadıköy / İstanbul',
      'icon': Ionicons.home,
    },
    {
      'id': 'address_2',
      'title': 'İş Adresi',
      'name': 'Oray Yılmaz',
      'detail': 'Plazalar Mevkii, Teknoloji Sk. No:3 Kat:5',
      'city': 'Şişli / İstanbul',
      'icon': Ionicons.business,
    },
  ];

  // Kullanıcının Sahip Olduğu Mevcut Kuponlar (Gerçekte API'den veya Provider'dan gelir)
  final List<Map<String, dynamic>> _availableCoupons = [
    {
      'title': 'Bahar İndirimi',
      'code': 'BAHAR20',
      'discountAmount': 50.0,
      'desc': 'Seçili ürünlerde anında 50\$ indirim sağlar.',
      'color': const Color(0xFFFF00CC),
    },
    {
      'title': 'Kargo Bedava',
      'code': 'FREESHIP',
      'discountAmount': 10.0,
      'desc': '10\$ değerindeki kargo ücretini sıfırlar.',
      'color': const Color(0xFF00C9FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardNameController.addListener(_updateUI);
    _cardNumberController.addListener(_updateUI);
    _expiryController.addListener(_updateUI);
  }

  void _updateUI() => setState(() {});

  @override
  void dispose() {
    _cardNameController.removeListener(_updateUI);
    _cardNumberController.removeListener(_updateUI);
    _expiryController.removeListener(_updateUI);

    _addressNameController.dispose();
    _addressDetailController.dispose();
    _cityController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  // --- KUPON MANTIĞI ---

  // Elle Kupon Girme
  void _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isApplyingCoupon = true);
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Girilen kod mevcut kuponlarda var mı diye kontrol et
    final matchedCoupon = _availableCoupons
        .where((c) => c['code'] == code)
        .firstOrNull;

    if (matchedCoupon != null) {
      _setCouponActive(matchedCoupon);
    } else {
      setState(() => _isApplyingCoupon = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geçersiz veya süresi dolmuş kupon kodu."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Listeden Kupon Seçme (Bottom Sheet'ten tetiklenir)
  void _setCouponActive(Map<String, dynamic> coupon) {
    setState(() {
      _appliedCouponCode = coupon['code'];
      _discountAmount = coupon['discountAmount'];
      _couponController.text = coupon['code'];
      _isApplyingCoupon = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Ionicons.checkmark_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text("${coupon['title']} başarıyla uygulandı!"),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = 0.0;
      _couponController.clear();
    });
  }

  // --- SİPARİŞİ TAMAMLA ---
  void _processOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // API Simülasyonu (Gerçekte burada ödeme çekilir)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // KRİTİK NOKTA: Ödeme başarılı oldu, sepeti tamamen boşaltıyoruz!
    ref.read(cartProvider.notifier).clearCart();

    // Başarı ekranına yönlendir
    context.go('/success');
  }

  String _getCardType(String number) {
    if (number.startsWith('4')) return "VISA";
    if (number.startsWith('5')) return "MASTERCARD";
    if (number.startsWith('3')) return "AMEX";
    return "CARD";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- FİYAT HESAPLAMALARI ---
    final double subTotal = 370.0; // Mock Ara Toplam
    final double shipping = 10.0; // Mock Kargo (İndirimle sıfırlanabilir)

    // Toplam Tutar eksiye düşmemeli (math.max ile koruma)
    final double finalTotal = math.max(
      0,
      (subTotal + shipping) - _discountAmount,
    );

    final defaultCard = {'type': 'VISA', 'no': '**** **** **** 4242'};
    if (defaultCard == null && _selectedPaymentMethod == 'default_card') {
      _selectedPaymentMethod = 'new_card';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                stretch: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Güvenli Ödeme",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Ionicons.chevron_back,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. TESLİMAT BİLGİLERİ ---
                        _buildSectionHeader("Teslimat Adresi", theme),
                        const SizedBox(height: 16),
                        _buildAddressSelector(theme),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  child: child,
                                ),
                              ),
                          child: _selectedAddressId == 'new_address'
                              ? _buildNewAddressForm(theme)
                              : const SizedBox.shrink(
                                  key: ValueKey('empty_address'),
                                ),
                        ),

                        const SizedBox(height: 40),

                        // --- 2. ÖDEME YÖNTEMİ ---
                        _buildSectionHeader("Ödeme Yöntemi", theme),
                        const SizedBox(height: 16),
                        _buildPaymentOptions(theme, defaultCard),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  child: child,
                                ),
                              ),
                          child: _buildDynamicPaymentContent(theme),
                        ),

                        const SizedBox(height: 40),

                        // --- 3. İNDİRİM KUPONU (GELİŞTİRİLDİ) ---
                        _buildSectionHeader("İndirim Kuponu", theme),
                        const SizedBox(height: 16),
                        _buildCouponSection(theme),

                        const SizedBox(height: 40),

                        // --- 4. SİPARİŞ ÖZETİ ---
                        _buildOrderSummary(
                          subTotal,
                          shipping,
                          _discountAmount,
                          finalTotal,
                          theme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- ALT BAR ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingBottomBar(theme, finalTotal),
          ),
        ],
      ),
    );
  }

  // --- KUPON BİLEŞENİ (LİSTE SEÇİMİ EKLENDİ) ---
  Widget _buildCouponSection(ThemeData theme) {
    if (_appliedCouponCode != null) {
      // Kupon Uygulandıysa Çıkan Yeşil Kutu
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Ionicons.ticket, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kupon Uygulandı",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$_appliedCouponCode kodu ile \$${_discountAmount.toStringAsFixed(2)} indirim sağlandı.",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Ionicons.close_circle, color: Colors.redAccent),
              onPressed: _removeCoupon,
              tooltip: "Kuponu Kaldır",
            ),
          ],
        ),
      );
    }

    // Kupon Girilmediyse Çıkan İnput ve Liste Butonu
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _couponController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: "Kupon Kodu Girin",
              hintStyle: TextStyle(
                color: theme.colorScheme.secondary,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                Ionicons.ticket_outline,
                color: theme.colorScheme.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _isApplyingCoupon
                    ? const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: _applyCoupon,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Uygula",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Kuponları Listeleme Butonu
        GestureDetector(
          onTap: () => _showAvailableCouponsSheet(theme),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Ionicons.gift_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Kayıtlı Kuponlarımı Gör",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Ionicons.chevron_forward,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KUPON SEÇİM BOTTOM SHEET ---
  void _showAvailableCouponsSheet(ThemeData theme) {
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Mevcut Kuponlarınız",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (_availableCoupons.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Şu an hesabınıza tanımlı aktif bir kupon bulunmuyor.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
              )
            else
              ..._availableCoupons.map(
                (coupon) => _buildBottomSheetCouponCard(coupon, theme, ctx),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetCouponCard(
    Map<String, dynamic> coupon,
    ThemeData theme,
    BuildContext ctx,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx); // Sheet'i kapat
        _setCouponActive(coupon); // Kuponu onayla ve uygula
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: coupon['color'].withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                color: coupon['color'].withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(Ionicons.ticket, color: coupon['color'], size: 32),
              ),
            ),
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon['desc'],
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Ionicons.chevron_forward_circle,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ADRES SEÇİCİ BİLEŞENLERİ (Aynı Kaldı) ---
  Widget _buildAddressSelector(ThemeData theme) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          ..._savedAddresses.map((addr) => _buildAddressCard(addr, theme)),
          _buildAddNewAddressCard(theme),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, ThemeData theme) {
    bool isSelected = _selectedAddressId == address['id'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedAddressId = address['id']);
        FocusScope.of(context).unfocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      address['icon'],
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Icon(
                    Ionicons.checkmark_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              address['detail'],
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              address['city'],
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddressCard(ThemeData theme) {
    bool isSelected = _selectedAddressId == 'new_address';
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = 'new_address'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.1),
            width: isSelected ? 2 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.add_circle,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              "Farklı Bir\nAdres Gir",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAddressForm(ThemeData theme) {
    return Column(
      key: const ValueKey('new_address_form'),
      children: [
        const SizedBox(height: 20),
        _buildModernField(
          _addressNameController,
          "Alıcı Ad Soyad",
          Ionicons.person_outline,
          theme,
          validator: (val) {
            if (val == null || val.trim().isEmpty)
              return "Alıcı adı zorunludur";
            if (val.trim().split(' ').length < 2)
              return "Lütfen ad ve soyadı tam girin";
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildModernField(
          _addressDetailController,
          "Adres Detayı",
          Ionicons.location_outline,
          theme,
          maxLines: 2,
          validator: (val) {
            if (val == null || val.trim().length < 10)
              return "Lütfen açık adresinizi girin";
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildModernField(
          _cityController,
          "Şehir / İlçe",
          Ionicons.map_outline,
          theme,
          validator: (val) => val == null || val.trim().isEmpty
              ? "Şehir/İlçe zorunludur"
              : null,
        ),
      ],
    );
  }

  // --- ÖDEME BİLEŞENLERİ (Aynı Kaldı) ---
  Widget _buildPaymentOptions(ThemeData theme, dynamic defaultCard) {
    return Column(
      children: [
        if (defaultCard != null) ...[
          _buildPaymentOptionTile(
            value: 'default_card',
            title:
                '${defaultCard['type']} Sonu ${defaultCard['no'].substring(defaultCard['no'].length - 4)}',
            subtitle: 'Varsayılan Hızlı Ödeme Kartınız',
            icon: Ionicons.star,
            iconColor: Colors.amber,
            theme: theme,
          ),
          const SizedBox(height: 12),
        ],
        _buildPaymentOptionTile(
          value: 'new_card',
          title: 'Yeni Kart Ekle',
          subtitle: 'Kredi veya Banka Kartı',
          icon: Ionicons.card_outline,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildPaymentOptionTile(
          value: 'cash',
          title: 'Kapıda Ödeme',
          subtitle: 'Teslimatta Nakit / Kart',
          icon: Ionicons.cash_outline,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    Color? iconColor,
  }) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
          if (value != 'new_card') _formKey.currentState?.validate();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.05),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withOpacity(
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Ionicons.checkmark_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicPaymentContent(ThemeData theme) {
    if (_selectedPaymentMethod == 'new_card')
      return _buildCreditCardSection(theme);
    if (_selectedPaymentMethod == 'cash') return _buildCashInfo(theme);
    return const SizedBox.shrink(key: ValueKey('empty_payment'));
  }

  Widget _buildCreditCardSection(ThemeData theme) {
    return Column(
      key: const ValueKey('card_form'),
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Ionicons.aperture,
                    color: Colors.white60,
                    size: 40,
                  ),
                  Text(
                    _getCardType(_cardNumberController.text),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                _cardNumberController.text.isEmpty
                    ? "**** **** **** ****"
                    : _cardNumberController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "KART SAHİBİ",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cardNameController.text.isEmpty
                              ? "AD SOYAD"
                              : _cardNameController.text.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "GEÇERLİLİK",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _expiryController.text.isEmpty
                            ? "AA/YY"
                            : _expiryController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildModernField(
          _cardNameController,
          "Kart Üzerindeki İsim",
          Ionicons.person_outline,
          theme,
          validator: (val) {
            if (val == null || val.trim().isEmpty)
              return "Kart sahibi adı zorunludur";
            if (val.trim().split(' ').length < 2)
              return "Lütfen ad ve soyadı tam girin";
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildModernField(
          _cardNumberController,
          "Kart Numarası",
          Ionicons.card_outline,
          theme,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          validator: (val) {
            if (val == null || val.isEmpty) return "Kart numarası girin";
            if (val.replaceAll(' ', '').length != 16)
              return "Geçersiz kart numarası";
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernField(
                _expiryController,
                "AA/YY",
                Ionicons.calendar_outline,
                theme,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateFormatter(),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return "Tarih girin";
                  if (val.length != 5) return "Geçersiz tarih";
                  final parts = val.split('/');
                  if (parts.length == 2) {
                    final month = int.tryParse(parts[0]) ?? 0;
                    if (month < 1 || month > 12) return "Geçersiz ay";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernField(
                _cvvController,
                "CVV",
                Ionicons.lock_closed_outline,
                theme,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return "CVV girin";
                  if (val.length < 3) return "Eksik CVV";
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCashInfo(ThemeData theme) {
    return Container(
      key: const ValueKey('cash_info'),
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Ionicons.information_circle, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Sipariş ücretini teslimat sırasında nakit veya kartla ödeyebilirsiniz.",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // --- SİPARİŞ ÖZETİ (GÜNCELLENDİ) ---
  Widget _buildOrderSummary(
    double subTotal,
    double shipping,
    double discount,
    double total,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _summaryRow("Ara Toplam", "\$${subTotal.toStringAsFixed(2)}", theme),
          const SizedBox(height: 12),
          _summaryRow(
            "Kargo",
            shipping == 0 ? "Ücretsiz" : "\$${shipping.toStringAsFixed(2)}",
            theme,
            isGreen: shipping == 0,
          ),

          // Eğer indirim varsa ekranda belirgin şekilde göster
          if (discount > 0) ...[
            const SizedBox(height: 12),
            _summaryRow(
              "İndirim Kazancı",
              "-\$${discount.toStringAsFixed(2)}",
              theme,
              isGreen: true,
            ),
          ],

          const Divider(height: 32),
          _summaryRow(
            "Ödenecek Tutar",
            "\$${total.toStringAsFixed(2)}",
            theme,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isGreen ? Colors.green : theme.colorScheme.onSurface,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  // --- ORTAK BİLEŞENLER ---
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModernField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ThemeData theme, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontWeight: FontWeight.w600),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.secondary),
          prefixIcon: Icon(icon, size: 22, color: theme.colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(ThemeData theme, double total) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _processOrder,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    "Siparişi Tamamla (\$${total.toStringAsFixed(2)})",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != text.length) buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if ((i + 1) % 2 == 0 && (i + 1) != newText.length && i < 2)
        buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
