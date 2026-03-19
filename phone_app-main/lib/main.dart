import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

// ─── THEME ───────────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F6EF7),
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F6EF7),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1021),
  );
}

// ─── STATE ────────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }
}

// ─── APP ──────────────────────────────────────────────────────────────────────

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (_, __) => MaterialApp(
        title: 'PhoneX',
        themeMode: _appState.themeMode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: HomePage(appState: _appState),
      ),
    );
  }
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  final AppState appState;
  const HomePage({super.key, required this.appState});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _navController.reset();
    _navController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      DashboardPage(appState: widget.appState),
      const DialerPage(),
      const MessagesPage(),
      const ContactsPage(),
    ];

    return Scaffold(
      body: FadeTransition(
        opacity: _navController,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _navController, curve: Curves.easeOut),
              ),
          child: pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildNavBar(isDark),
    );
  }

  Widget _buildNavBar(bool isDark) {
    final labels = ['Ana Sayfa', 'Arama', 'Mesajlar', 'Kişiler'];
    final icons = [
      Icons.home_rounded,
      Icons.dialpad_rounded,
      Icons.chat_bubble_rounded,
      Icons.contacts_rounded,
    ];
    final activeIcons = [
      Icons.home_rounded,
      Icons.dialpad_rounded,
      Icons.chat_bubble_rounded,
      Icons.contacts_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2030) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final isSelected = _currentIndex == i;
              return GestureDetector(
                onTap: () => _onTabTapped(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: const Color(0xFF4F6EF7).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? activeIcons[i] : icons[i],
                          color: isSelected
                              ? const Color(0xFF4F6EF7)
                              : (isDark ? Colors.white38 : Colors.black38),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF4F6EF7)
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                        child: Text(labels[i]),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── DASHBOARD PAGE ───────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  final AppState appState;
  const DashboardPage({super.key, required this.appState});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final PageController _bannerController = PageController();
  int _currentBanner = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Yeni Özellik',
      'subtitle': 'HD Görüntülü Arama artık aktif!',
      'icon': Icons.videocam_rounded,
      'gradient': [Color(0xFF4F6EF7), Color(0xFF9B59F5)],
    },
    {
      'title': 'Veri Tasarrufu',
      'subtitle': 'Bu ay %30 daha az veri kullandın',
      'icon': Icons.data_saver_on_rounded,
      'gradient': [Color(0xFF11B5A5), Color(0xFF4F9EF7)],
    },
    {
      'title': 'Güvenlik',
      'subtitle': 'Uçtan uca şifreli aramalar',
      'icon': Icons.security_rounded,
      'gradient': [Color(0xFFF76F4F), Color(0xFFF7B24F)],
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {'icon': Icons.call_rounded, 'label': 'Ara', 'color': Color(0xFF4F6EF7)},
    {'icon': Icons.chat_rounded, 'label': 'Mesaj', 'color': Color(0xFF11B5A5)},
    {
      'icon': Icons.voicemail_rounded,
      'label': 'Sesli Mesaj',
      'color': Color(0xFFF76F4F),
    },
    {
      'icon': Icons.video_call_rounded,
      'label': 'Video',
      'color': Color(0xFF9B59F5),
    },
  ];

  final List<Map<String, dynamic>> _recentCalls = [
    {
      'name': 'Ahmet Yılmaz',
      'type': 'gelen',
      'time': '10 dk önce',
      'avatar': 'AY',
    },
    {
      'name': 'Zeynep Demir',
      'type': 'giden',
      'time': '1 saat önce',
      'avatar': 'ZD',
    },
    {'name': 'Mehmet Kaya', 'type': 'cevapsız', 'time': 'Dün', 'avatar': 'MK'},
    {'name': 'Elif Şahin', 'type': 'gelen', 'time': 'Dün', 'avatar': 'EŞ'},
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Auto-slide banners
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Animation<double> _staggerAnim(int index) {
    final start = index * 0.1;
    final end = (start + 0.5).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1021)
          : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F6EF7), Color(0xFF9B59F5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('PhoneX'),
              ],
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    key: ValueKey(isDark),
                  ),
                ),
                onPressed: widget.appState.toggleTheme,
              ),
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_rounded),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF76F4F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ──
                  FadeTransition(
                    opacity: _staggerAnim(0),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_staggerAnim(0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merhaba, Kullanıcı 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bugün nasıl yardımcı olabilirim?',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Banner Slider ──
                  FadeTransition(
                    opacity: _staggerAnim(1),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: PageView.builder(
                            controller: _bannerController,
                            onPageChanged: (i) =>
                                setState(() => _currentBanner = i),
                            itemCount: _banners.length,
                            itemBuilder: (_, i) {
                              final b = _banners[i];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: List<Color>.from(b['gradient']),
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                b['title'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              b['subtitle'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        b['icon'],
                                        color: Colors.white30,
                                        size: 64,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _banners.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentBanner == i ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentBanner == i
                                    ? const Color(0xFF4F6EF7)
                                    : (isDark
                                          ? Colors.white24
                                          : Colors.black12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Quick Actions ──
                  FadeTransition(
                    opacity: _staggerAnim(2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hızlı Erişim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _quickActions.map((a) {
                            return _QuickActionButton(
                              icon: a['icon'],
                              label: a['label'],
                              color: a['color'],
                              isDark: isDark,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Stats Row ──
                  FadeTransition(
                    opacity: _staggerAnim(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Toplam Arama',
                            value: '128',
                            icon: Icons.call_rounded,
                            color: const Color(0xFF4F6EF7),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Cevapsız',
                            value: '3',
                            icon: Icons.call_missed_rounded,
                            color: const Color(0xFFF76F4F),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Mesajlar',
                            value: '47',
                            icon: Icons.chat_rounded,
                            color: const Color(0xFF11B5A5),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Recent Calls ──
                  FadeTransition(
                    opacity: _staggerAnim(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Son Aramalar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Tümü',
                                style: TextStyle(
                                  color: Color(0xFF4F6EF7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._recentCalls.map(
                          (c) => _RecentCallTile(data: c, isDark: isDark),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QUICK ACTION BUTTON ──────────────────────────────────────────────────────

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STAT CARD ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2030) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RECENT CALL TILE ─────────────────────────────────────────────────────────

class _RecentCallTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _RecentCallTile({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMissed = data['type'] == 'cevapsız';
    final isIncoming = data['type'] == 'gelen';
    final callColor = isMissed
        ? const Color(0xFFF76F4F)
        : (isIncoming ? const Color(0xFF11B5A5) : const Color(0xFF4F6EF7));
    final callIcon = isMissed
        ? Icons.call_missed_rounded
        : (isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2030) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [callColor.withOpacity(0.7), callColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                data['avatar'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(callIcon, size: 12, color: callColor),
                    const SizedBox(width: 4),
                    Text(
                      data['type'],
                      style: TextStyle(
                        fontSize: 11,
                        color: callColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data['time'],
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F6EF7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  size: 14,
                  color: Color(0xFF4F6EF7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── DIALER PAGE ──────────────────────────────────────────────────────────────

class DialerPage extends StatefulWidget {
  const DialerPage({super.key});

  @override
  State<DialerPage> createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage>
    with SingleTickerProviderStateMixin {
  String _number = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _press(String digit) {
    if (_number.length < 15) setState(() => _number += digit);
  }

  void _backspace() {
    if (_number.isNotEmpty) {
      setState(() => _number = _number.substring(0, _number.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1021)
          : const Color(0xFFF4F6FF),
      appBar: AppBar(title: const Text('Tuş Takımı')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Number display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  _number.isEmpty ? 'Numara girin' : _formatNumber(_number),
                  key: ValueKey(_number),
                  style: TextStyle(
                    fontSize: _number.isEmpty ? 20 : 32,
                    fontWeight: FontWeight.w700,
                    color: _number.isEmpty
                        ? (isDark ? Colors.white24 : Colors.black26)
                        : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_number.isNotEmpty)
              Text(
                'Türkiye',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            const SizedBox(height: 40),

            // Dialpad
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['*', '0', '#'],
                    ])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row
                            .map(
                              (d) => _DialKey(
                                digit: d,
                                onTap: () => _press(d),
                                isDark: isDark,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Call + backspace row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 64),
                  // Call button with pulse
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, child) => Transform.scale(
                      scale: 1.0 + _pulseController.value * 0.06,
                      child: child,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Simulate call
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Aranıyor: $_number'),
                            backgroundColor: const Color(0xFF11B5A5),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11B5A5), Color(0xFF4FC36B)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF11B5A5).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _backspace,
                    onLongPress: () => setState(() => _number = ''),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2030) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.backspace_rounded,
                        color: isDark ? Colors.white54 : Colors.black38,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String n) {
    if (n.length <= 4) return n;
    if (n.length <= 7) return '${n.substring(0, 4)} ${n.substring(4)}';
    if (n.length <= 10) {
      return '${n.substring(0, 4)} ${n.substring(4, 7)} ${n.substring(7)}';
    }
    return '${n.substring(0, 4)} ${n.substring(4, 7)} ${n.substring(7, 10)} ${n.substring(10)}';
  }
}

class _DialKey extends StatefulWidget {
  final String digit;
  final VoidCallback onTap;
  final bool isDark;

  const _DialKey({
    required this.digit,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_DialKey> createState() => _DialKeyState();
}

class _DialKeyState extends State<_DialKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E2030) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── MESSAGES PAGE ────────────────────────────────────────────────────────────

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const _conversations = [
    {
      'name': 'Ahmet Yılmaz',
      'last': 'Tamam, görüşürüz!',
      'time': '10:32',
      'unread': 0,
      'avatar': 'AY',
      'color': Color(0xFF4F6EF7),
      'online': true,
    },
    {
      'name': 'Zeynep Demir',
      'last': 'Fotoğrafları attım 📷',
      'time': '09:15',
      'unread': 3,
      'avatar': 'ZD',
      'color': Color(0xFF9B59F5),
      'online': true,
    },
    {
      'name': 'Mehmet Kaya',
      'last': 'Ne zaman döneceksin?',
      'time': 'Dün',
      'unread': 1,
      'avatar': 'MK',
      'color': Color(0xFF11B5A5),
      'online': false,
    },
    {
      'name': 'Elif Şahin',
      'last': 'Harika! 🎉',
      'time': 'Dün',
      'unread': 0,
      'avatar': 'EŞ',
      'color': Color(0xFFF76F4F),
      'online': false,
    },
    {
      'name': 'Can Öztürk',
      'last': 'Evet, uygun olurum.',
      'time': 'Pzt',
      'unread': 0,
      'avatar': 'CÖ',
      'color': Color(0xFFF7B24F),
      'online': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1021)
          : const Color(0xFFF4F6FF),
      appBar: AppBar(
        title: const Text('Mesajlar'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2030) : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Mesajlarda ara...',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                final c = _conversations[i];
                final hasUnread = (c['unread'] as int) > 0;
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2030) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (c['color'] as Color).withOpacity(0.7),
                                c['color'] as Color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              c['avatar'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (c['online'] as bool)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC36B),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E2030)
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      c['name'] as String,
                      style: TextStyle(
                        fontWeight: hasUnread
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    subtitle: Text(
                      c['last'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasUnread
                            ? (isDark ? Colors.white70 : Colors.black87)
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          c['time'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread
                                ? const Color(0xFF4F6EF7)
                                : (isDark ? Colors.white38 : Colors.black38),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F6EF7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${c['unread']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 18),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4F6EF7),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }
}

// ─── CONTACTS PAGE ────────────────────────────────────────────────────────────

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  static const _contacts = [
    {
      'name': 'Ahmet Yılmaz',
      'phone': '0532 123 45 67',
      'avatar': 'AY',
      'color': Color(0xFF4F6EF7),
    },
    {
      'name': 'Can Öztürk',
      'phone': '0541 234 56 78',
      'avatar': 'CÖ',
      'color': Color(0xFFF7B24F),
    },
    {
      'name': 'Elif Şahin',
      'phone': '0555 987 65 43',
      'avatar': 'EŞ',
      'color': Color(0xFFF76F4F),
    },
    {
      'name': 'Mehmet Kaya',
      'phone': '0541 987 65 43',
      'avatar': 'MK',
      'color': Color(0xFF11B5A5),
    },
    {
      'name': 'Selin Arslan',
      'phone': '0531 876 54 32',
      'avatar': 'SA',
      'color': Color(0xFF9B59F5),
    },
    {
      'name': 'Zeynep Demir',
      'phone': '0507 555 33 22',
      'avatar': 'ZD',
      'color': Color(0xFF9B59F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1021)
          : const Color(0xFFF4F6FF),
      appBar: AppBar(
        title: const Text('Kişiler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2030) : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Kişi ara...',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                final c = _contacts[i];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2030) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (c['color'] as Color).withOpacity(0.7),
                            c['color'] as Color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          c['avatar'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      c['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    subtitle: Text(
                      c['phone'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconBtn(
                          Icons.chat_rounded,
                          const Color(0xFF4F6EF7),
                          isDark,
                        ),
                        const SizedBox(width: 8),
                        _iconBtn(
                          Icons.call_rounded,
                          const Color(0xFF11B5A5),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
