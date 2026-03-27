import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

// Kendi auth provider yolunu doğrula
// import '../../../auth/presentation/auth_provider.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: "Oray Yılmaz");
  final _emailController = TextEditingController(
    text: "orayyilmaz16@gmail.com",
  );
  final _phoneController = TextEditingController(text: "555 123 45 67");

  bool _isLoading = false;
  bool _is2FAEnabled = false; // Gerçekte bu veri API'den/Provider'dan gelir
  bool _hasChanges =
      false; // "Kaydet" butonunu sadece değişiklik varsa aktif etmek için

  @override
  void initState() {
    super.initState();
    // Değişiklikleri dinle
    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanged =
        _nameController.text != "Oray Yılmaz" ||
        _phoneController.text != "555 123 45 67";
    if (_hasChanges != hasChanged) {
      setState(() => _hasChanges = hasChanged);
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    // API simülasyonu
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasChanges = false; // Kayıt sonrası butonu pasif yap
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Ionicons.checkmark_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Bilgileriniz başarıyla güncellendi!"),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Hesap Ayarları",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              140,
            ), // Alt bar için boşluk
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. PROFİL FOTOĞRAFI
                  _buildProfileImageAvatar(theme),
                  const SizedBox(height: 40),

                  // 2. KİŞİSEL BİLGİLER FORMU
                  _buildSectionLabel("KİŞİSEL BİLGİLER", theme),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    _nameController,
                    "Ad Soyad",
                    Ionicons.person_outline,
                    theme,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Ad soyad boş bırakılamaz"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    _emailController,
                    "E-Posta Adresi",
                    Ionicons.mail_outline,
                    theme,
                    isReadOnly:
                        true, // E-posta değişimi genelde doğrulama gerektirir, kilitli tutmak en iyisi
                    helpText:
                        "E-posta adresinizi değiştirmek için destekle iletişime geçin.",
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    _phoneController,
                    "Telefon Numarası",
                    Ionicons.call_outline,
                    theme,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    prefixText: "+90  ",
                    validator: (val) => val != null && val.length < 10
                        ? "Geçerli bir telefon numarası girin"
                        : null,
                  ),

                  const SizedBox(height: 40),

                  // 3. GÜVENLİK VE ŞİFRE
                  _buildSectionLabel("GÜVENLİK", theme),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    "Şifreyi Değiştir",
                    "Hesap şifrenizi güncelleyin",
                    Ionicons.lock_closed_outline,
                    theme,
                    onTap: () => _showChangePasswordSheet(context, theme),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    "İki Adımlı Doğrulama (2FA)",
                    _is2FAEnabled
                        ? "Güvenlik aktif durumda"
                        : "Hesap güvenliğinizi arttırın",
                    _is2FAEnabled
                        ? Ionicons.shield_checkmark
                        : Ionicons.shield_outline,
                    theme,
                    iconColor: _is2FAEnabled
                        ? Colors.green
                        : theme.colorScheme.primary,
                    trailing: Switch.adaptive(
                      value: _is2FAEnabled,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() => _is2FAEnabled = val);
                        // Burada 2FA API çağrısı yapılabilir
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 4. TEHLİKE BÖLGESİ (Hesap Silme)
                  _buildSectionLabel(
                    "TEHLİKE BÖLGESİ",
                    theme,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    "Hesabımı Kalıcı Olarak Sil",
                    "Tüm verileriniz ve geçmişiniz silinecektir",
                    Ionicons.trash_outline,
                    theme,
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () => _showDeleteAccountSheet(context, ref, theme),
                  ),
                ],
              ),
            ),
          ),

          // 5. KAYDET BUTONU (Cam Efektli & Dinamik)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingBottomBar(theme),
          ),
        ],
      ),
    );
  }

  // --- BİLEŞENLER VE DİYALOGLAR ---

  Widget _buildProfileImageAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Galeri veya kamera açma mantığı buraya gelecek
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 4,
              ),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/oray.png'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 3,
              ),
            ),
            child: const Icon(Ionicons.camera, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, ThemeData theme, {Color? color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? theme.colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ThemeData theme, {
    bool isReadOnly = false,
    String? helpText,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isReadOnly
                ? theme.colorScheme.surface.withOpacity(0.5)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: TextFormField(
            controller: ctrl,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isReadOnly
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: label,
              prefixText: prefixText,
              prefixStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: isReadOnly
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        if (helpText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                Icon(
                  Ionicons.information_circle_outline,
                  size: 14,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  helpText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme, {
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
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
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor ?? theme.colorScheme.onSurface,
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
            trailing ??
                Icon(
                  Ionicons.chevron_forward,
                  color: theme.colorScheme.secondary,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(ThemeData theme) {
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
            // Sadece değişiklik varsa ve yüklenmiyorsa aktif olur
            onPressed: (_isLoading || !_hasChanges) ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.primary.withOpacity(
                0.3,
              ),
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
                : const Text(
                    "Değişiklikleri Kaydet",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  // --- DİYALOGLAR (BOTTOM SHEETS) ---

  void _showChangePasswordSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Şifreyi Değiştir",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Yeni şifreniz en az 8 karakter olmalıdır.",
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 24),
            _buildModernTextField(
              TextEditingController(),
              "Mevcut Şifre",
              Ionicons.lock_closed_outline,
              theme,
            ),
            const SizedBox(height: 12),
            _buildModernTextField(
              TextEditingController(),
              "Yeni Şifre",
              Ionicons.key_outline,
              theme,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Şifreyi Güncelle",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Ionicons.warning, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Hesabı Silmek Üzeresiniz",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Hesabınızı silmek tüm sipariş geçmişinizi, adreslerinizi ve kayıtlı kartlarınızı kalıcı olarak yok eder. Devam etmek istiyor musunuz?",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.secondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Silme API isteği & Auth çıkışı
                      Navigator.pop(ctx);
                      context.go('/login');
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
                      "Kalıcı Olarak Sil",
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
