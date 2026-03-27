import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. MODERN APPBAR VE KULLANICI BİLGİSİ
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage('assets/images/oray.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Oray Yılmaz",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "orayyilmaz16@gmail.com",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. İÇERİK BÖLÜMÜ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ALIŞVERİŞ GRUBU ---
                  _buildSectionLabel("ALIŞVERİŞ", theme),
                  _buildSettingsGroup(
                    theme,
                    children: [
                      _buildProfileItem(
                        context,
                        "Siparişlerim",
                        Ionicons.bag_check_outline,
                        theme,
                        onTap: () => context.push('/orders'),
                      ),
                      _buildDivider(theme),
                      _buildProfileItem(
                        context,
                        "Favorilerim",
                        Ionicons.heart_outline,
                        theme,
                        iconColor: Colors.pinkAccent,
                        onTap: () => context.push('/favorites'),
                      ),
                      _buildDivider(theme),
                      _buildProfileItem(
                        context,
                        "İndirim Kuponlarım",
                        Ionicons.ticket_outline,
                        theme,
                        iconColor: Colors.orange,
                        onTap: () => context.push('/coupons'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- HESAP VE FİNANS GRUBU ---
                  _buildSectionLabel("HESAP & FİNANS", theme),
                  _buildSettingsGroup(
                    theme,
                    children: [
                      _buildProfileItem(
                        context,
                        "Hesap Ayarları",
                        Ionicons.person_circle_outline,
                        theme,
                        onTap: () => context.push('/account-settings'),
                      ), // YENİ EKLENEN ROTA
                      _buildDivider(theme),
                      _buildProfileItem(
                        context,
                        "Adres Bilgilerim",
                        Ionicons.location_outline,
                        theme,
                        onTap: () => context.push('/addresses'),
                      ),
                      _buildDivider(theme),
                      _buildProfileItem(
                        context,
                        "Ödeme Yöntemleri",
                        Ionicons.card_outline,
                        theme,
                        onTap: () => context.push('/payments'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- UYGULAMA AYARLARI ---
                  _buildSectionLabel("UYGULAMA", theme),
                  _buildSettingsGroup(
                    theme,
                    children: [
                      // Karanlık Mod (Dinamik Switch)
                      ListTile(
                        leading: _buildIconBox(
                          themeMode == ThemeMode.dark
                              ? Ionicons.moon
                              : Ionicons.sunny,
                          themeMode == ThemeMode.dark
                              ? Colors.indigo
                              : Colors.amber,
                          theme,
                        ),
                        title: const Text(
                          "Karanlık Mod",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Switch.adaptive(
                          value: themeMode == ThemeMode.dark,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (value) =>
                              ref.read(themeProvider.notifier).toggleTheme(),
                        ),
                      ),
                      _buildDivider(theme),
                      _buildProfileItem(
                        context,
                        "Bildirim Tercihleri",
                        Ionicons.notifications_outline,
                        theme,
                        onTap: () => context.push('/notifications'),
                      ),
                      _buildDivider(theme),
                      _buildProfileItem(
                        context,
                        "Yardım ve Destek",
                        Ionicons.help_buoy_outline,
                        theme,
                        onTap: () => context.push('/help-support'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- ÇIKIŞ YAP BUTONU ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context, ref),
                      icon: const Icon(Ionicons.log_out_outline),
                      label: const Text(
                        "Hesaptan Çıkış Yap",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Sürüm 1.0.0",
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN YARDIMCI BİLEŞENLER ---

  Widget _buildSectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Ayarları içine alan kutu (Gruplandırma)
  Widget _buildSettingsGroup(
    ThemeData theme, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    IconData icon,
    ThemeData theme, {
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIconBox(
        icon,
        iconColor ?? theme.colorScheme.primary,
        theme,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Icon(
        Ionicons.chevron_forward,
        color: theme.colorScheme.secondary,
        size: 18,
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.dividerColor.withOpacity(0.05),
      indent: 60,
      endIndent: 16,
    );
  }

  // --- ÇIKIŞ ONAY DİYALOĞU ---
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Ionicons.log_out, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Çıkış Yapıyorsunuz",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
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
                      "Evet, Çıkış Yap",
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
