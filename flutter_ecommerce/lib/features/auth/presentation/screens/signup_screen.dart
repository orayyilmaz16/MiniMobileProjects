import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/theme/theme_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller yönetimi
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_acceptTerms) {
      _showErrorSnackBar('Lütfen kullanım ve gizlilik koşullarını onaylayın.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simüle edilen kayıt süreci
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isLoading = false);

      context.go('/home');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // AppBar'ı daha temiz ve minimal tuttuk
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Ionicons.chevron_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        actions: [
          _buildThemeToggle(theme, themeMode),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(theme),
                const SizedBox(height: 40),

                // Kayıt Formu Alanları
                _buildFormFields(theme),

                const SizedBox(height: 24),
                _buildTermsSwitch(theme),

                const SizedBox(height: 40),
                _buildSignUpButton(theme),

                const SizedBox(height: 32),
                _buildLoginRedirect(theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI (REFACTOR) ---

  Widget _buildThemeToggle(ThemeData theme, ThemeMode themeMode) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        icon: Icon(
          themeMode == ThemeMode.dark ? Ionicons.sunny : Ionicons.moon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Yeni Hesap",
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Teknoloji dolu dünyamıza katılmak için bilgilerinizi girin.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      children: [
        _buildInputField(
          controller: _nameController,
          label: "Ad Soyad",
          icon: Ionicons.person_outline,
          theme: theme,
          validator: (v) =>
              (v == null || v.length < 3) ? "Geçerli bir ad soyad girin" : null,
        ),
        const SizedBox(height: 18),
        _buildInputField(
          controller: _emailController,
          label: "E-posta",
          icon: Ionicons.mail_outline,
          theme: theme,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (v == null || !v.contains('@'))
              ? "Geçerli bir e-posta girin"
              : null,
        ),
        const SizedBox(height: 18),
        _buildInputField(
          controller: _passwordController,
          label: "Şifre",
          icon: Ionicons.lock_closed_outline,
          theme: theme,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (v) => (v == null || v.length < 6)
              ? "Şifre en az 6 karakter olmalı"
              : null,
        ),
        const SizedBox(height: 18),
        _buildInputField(
          controller: _confirmPasswordController,
          label: "Şifreyi Onayla",
          icon: Ionicons.shield_checkmark_outline,
          theme: theme,
          isPassword: true,
          obscureText: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          validator: (v) =>
              v != _passwordController.text ? "Şifreler uyuşmuyor" : null,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Ionicons.eye_off_outline
                          : Ionicons.eye_outline,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSwitch(ThemeData theme) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.85,
          child: Switch.adaptive(
            value: _acceptTerms,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) => setState(() => _acceptTerms = v),
          ),
        ),
        Expanded(
          child: Text(
            "Kullanım ve Gizlilik Koşullarını kabul ediyorum.",
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Hesabı Oluştur",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget _buildLoginRedirect(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: RichText(
          text: TextSpan(
            text: "Zaten bir hesabın var mı? ",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            children: [
              TextSpan(
                text: "Giriş Yap",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
