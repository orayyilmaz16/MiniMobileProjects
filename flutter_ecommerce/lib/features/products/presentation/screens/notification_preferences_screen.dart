import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  // Mock States
  bool _orderPush = true;
  bool _orderSms = true;
  bool _promoPush = false;
  bool _promoEmail = true;
  bool _securityPush = true;
  bool _isLoading = false;
  bool _hasChanges = false;

  void _markChanged() => setState(() => _hasChanges = true);

  void _savePreferences() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // API Save
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tercihleriniz güncellendi!"),
        backgroundColor: Colors.green,
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
          "Bildirim Tercihleri",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionHeader("SİPARİŞ BİLDİRİMLERİ", theme),
              _buildSettingsGroup(
                theme,
                children: [
                  _buildSwitchTile(
                    "Anlık Bildirimler",
                    "Sipariş durumu ve kargo takibi (Önerilir)",
                    _orderPush,
                    (v) {
                      setState(() => _orderPush = v);
                      _markChanged();
                    },
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    "SMS Bildirimleri",
                    "Kurye dağıtıma çıktığında SMS al",
                    _orderSms,
                    (v) {
                      setState(() => _orderSms = v);
                      _markChanged();
                    },
                    theme,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionHeader("KAMPANYA & FIRSATLAR", theme),
              _buildSettingsGroup(
                theme,
                children: [
                  _buildSwitchTile(
                    "Uygulama İçi Bildirimler",
                    "Flaş indirimleri kaçırmamak için bildirim al",
                    _promoPush,
                    (v) {
                      setState(() => _promoPush = v);
                      _markChanged();
                    },
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    "E-Posta Bülteni",
                    "Özel bülten ve indirim kodları gönder",
                    _promoEmail,
                    (v) {
                      setState(() => _promoEmail = v);
                      _markChanged();
                    },
                    theme,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionHeader("GÜVENLİK", theme),
              _buildSettingsGroup(
                theme,
                children: [
                  _buildSwitchTile(
                    "Giriş Uyarıları",
                    "Farklı bir cihazdan giriş yapıldığında uyar",
                    _securityPush,
                    (v) {
                      setState(() => _securityPush = v);
                      _markChanged();
                    },
                    theme,
                    isLocked: true,
                  ), // Kilitli zorunlu ayar örneği
                ],
              ),
            ],
          ),

          // KAYDET BUTONU
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_hasChanges)
                        ? null
                        : _savePreferences,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Tercihleri Kaydet",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    ThemeData theme, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeData theme, {
    bool isLocked = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 12,
          height: 1.4,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: theme.colorScheme.primary,
        onChanged: isLocked
            ? null
            : onChanged, // isLocked true ise tıklanamaz (güvenlik için)
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) => Divider(
    height: 1,
    color: theme.dividerColor.withOpacity(0.05),
    indent: 20,
    endIndent: 20,
  );
}
