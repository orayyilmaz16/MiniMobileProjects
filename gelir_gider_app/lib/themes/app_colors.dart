import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler - Light
  static const Color yellow = Color(0xFFFBE7C6);
  static const Color mint = Color(0xFFB4F8C8);
  static const Color tiffanyBlue = Color(0xFFA0E7E5);
  static const Color hotPink = Color(0xFFFFAEBC);

  // Ana renkler - Dark
  static const Color darkYellow = Color(0xFFE5C088);
  static const Color darkMint = Color(0xFF8AD69E);
  static const Color darkTiffanyBlue = Color(0xFF7CBFBD);
  static const Color darkHotPink = Color(0xFFE58E9C);

  // Gölgeler
  static const Color tiffanyBlue80 = Color(0xCCA0E7E5);
  static const Color tiffanyBlue60 = Color(0x99A0E7E5);
  static const Color tiffanyBlue40 = Color(0x66A0E7E5);
  static const Color tiffanyBlue20 = Color(0x33A0E7E5);

  // İşlem renkleri - Light
  static const Color income = Color(0xFFB4F8C8); // Mint for income
  static const Color expense = Color(0xFFFFAEBC); // Hot Pink for expense
  static const Color balance = Color(0xFFA0E7E5); // Tiffany Blue for balance

  // İşlem renkleri - Dark
  static const Color darkIncome = Color(0xFF8AD69E);
  static const Color darkExpense = Color(0xFFE58E9C);
  static const Color darkBalance = Color(0xFF7CBFBD);

  // Arka plan renkleri - Light
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFF5F5F5); // Daha soft bir divider rengi

  // Arka plan renkleri - Dark
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF404040);

  // Metin renkleri - Light
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textHint = Color(0xFF9B9B9B);

  // Metin renkleri - Dark
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFE0E0E0);
  static const Color darkTextHint = Color(0xFFB0B0B0);

  // Gradient renkler - Light
  static const List<Color> incomeGradient = [
    Color(0xFFB4F8C8),
    Color(0xFF95E6A9),
  ];

  static const List<Color> expenseGradient = [
    Color(0xFFFFAEBC),
    Color(0xFFFF8FA1),
  ];

  static const List<Color> balanceGradient = [
    Color(0xFFA0E7E5),
    Color(0xFF7FD5D3),
  ];

  // Gradient renkler - Dark
  static const List<Color> darkIncomeGradient = [
    Color(0xFF8AD69E),
    Color(0xFF6BB47F),
  ];

  static const List<Color> darkExpenseGradient = [
    Color(0xFFE58E9C),
    Color(0xFFC67181),
  ];

  static const List<Color> darkBalanceGradient = [
    Color(0xFF7CBFBD),
    Color(0xFF5D9F9D),
  ];
}
