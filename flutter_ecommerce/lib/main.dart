import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/theme/app_theme.dart';
import 'package:flutter_ecommerce/core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    // Riverpod'u başlatmak için ProviderScope sarıcısı şarttır
    const ProviderScope(child: ECommerceApp()),
  );
}

class ECommerceApp extends ConsumerWidget {
  const ECommerceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter sağlayıcısını okuyoruz
    final router = ref.watch(routerProvider);

    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Modern E-Ticaret',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
