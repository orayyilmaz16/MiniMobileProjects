import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/theme/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  // SOSYAL GİRİŞ VE HESAP BAĞLAMA SİMÜLASYONU
  void _handleSocialLogin(String platform) async {
    setState(() => _isLoading = true);

    // Platforma özel mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$platform hesabı ile güvenli bağlantı kuruluyor..."),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 1),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/home');
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dekoratif Arka Plan (Soft Aura)
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst Bar: Tema ve Dil (Opsiyonel)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        IconButton(
                          onPressed: () =>
                              ref.read(themeProvider.notifier).toggleTheme(),
                          icon: Icon(
                            themeMode == ThemeMode.dark
                                ? Ionicons.sunny
                                : Ionicons.moon,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Hoşgeldin Bölümü
                    Text(
                      "Premium'a Dönüş",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kişiselleştirilmiş deneyiminize kaldığınız yerden devam etmek için oturum açın.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // STANDART GİRİŞ ALANLARI
                    _buildCustomField(
                      controller: _emailController,
                      label: "E-posta Adresiniz",
                      hint: "ornek@mail.com",
                      icon: Ionicons.mail_unread_outline,
                      theme: theme,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? "Geçerli bir e-posta girin"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildCustomField(
                      controller: _passwordController,
                      label: "Şifreniz",
                      hint: "••••••••",
                      icon: Ionicons.shield_outline,
                      isPassword: true,
                      obscureText: _obscureText,
                      theme: theme,
                      onToggleVisibility: () =>
                          setState(() => _obscureText = !_obscureText),
                      validator: (v) => (v == null || v.length < 6)
                          ? "Şifre 6 karakterden az olamaz"
                          : null,
                    ),

                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Şifremi Unuttum",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ANA GİRİŞ BUTONU
                    _buildPrimaryButton(theme),

                    const SizedBox(height: 40),

                    // AYIRICI ÇİZGİ
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "HIZLI BAĞLANTI",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.secondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SOSYAL HESAP BAĞLAMA BUTONLARI (GELİŞMİŞ)
                    Column(
                      children: [
                        _buildSocialAuthButton(
                          label: "Google Hesabı ile Bağlan",
                          icon: Ionicons.logo_google,
                          color: const Color(0xFFEA4335),
                          theme: theme,
                          onPressed: () => _handleSocialLogin("Google"),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialAuthButton(
                          label: "Apple ID ile Giriş Yap",
                          icon: Ionicons.logo_apple,
                          color: theme.colorScheme.onSurface,
                          theme: theme,
                          onPressed: () => _handleSocialLogin("Apple"),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialAuthButton(
                          label: "Microsoft Hesabını Kullan",
                          icon: Ionicons.logo_microsoft,
                          color: const Color(0xFF00A4EF),
                          theme: theme,
                          onPressed: () => _handleSocialLogin("Microsoft"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // KAYIT OLMA YÖNLENDİRMESİ
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Henüz üye değil misiniz? ",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: "Yeni Hesap Oluştur",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // GLOBAL LOADING OVERLAY
          if (_isLoading)
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ÖZEL INPUT TASARIMI
  Widget _buildCustomField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Ionicons.eye_off_outline
                          : Ionicons.eye_outline,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ANA GİRİŞ BUTONU
  Widget _buildPrimaryButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Hesaba Giriş Yap",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  // YENİ: GELİŞMİŞ SOSYAL BAĞLANTI BUTONU
  Widget _buildSocialAuthButton({
    required String label,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
          backgroundColor: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
