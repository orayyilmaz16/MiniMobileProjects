import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Sınıfın dışarıdan instance alınmasını engeller

  // Yüksek kontrastlı, modern ve minimalist (Siyah & Beyaz ağırlıklı) palet
  static const Color primaryBackground = Color(0xFFFAFAFA);
  static const Color primaryText = Color(0xFF111111);
  static const Color secondaryText = Color(0xFF757575);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}
