import 'package:flutter/material.dart';

class AppTheme {
  // AYDINLIK TEMA (Eski AppColors paletimiz)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA), // primaryBackground
      colorScheme: const ColorScheme.light(
        primary: Colors.black, // Siyah butonlar vb.
        onPrimary: Colors.white, // Siyah üstündeki yazılar
        surface: Colors.white, // Kart arkaplanları
        onSurface: Color(0xFF111111), // Metin rengi
        secondary: Colors.grey, // Alt metinler
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // KARANLIK TEMA
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212), // Koyu arka plan
      colorScheme: const ColorScheme.dark(
        primary: Colors.white, // Dark modda butonlar beyaz olsun
        onPrimary: Colors.black, // Beyaz buton üstü siyah yazı
        surface: Color(0xFF1E1E1E), // Koyu kart arkaplanı
        onSurface: Colors.white, // Beyaz metin
        secondary: Color(0xFFAAAAAA), // Açık gri alt metinler
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
