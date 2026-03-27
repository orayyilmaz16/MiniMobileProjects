class CardValidator {
  // 1. Kart Numarası - Luhn Algoritması (Gerçek kart mı kontrolü)
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Kart numarası gerekli';
    String cleanValue = value.replaceAll(
      RegExp(r'\s+\b|\b\s'),
      '',
    ); // Boşlukları temizle
    if (cleanValue.length < 13 || cleanValue.length > 19)
      return 'Geçersiz numara uzunluğu';

    // Luhn Check
    int sum = 0;
    bool alternate = false;
    for (int i = cleanValue.length - 1; i >= 0; i--) {
      int n = int.parse(cleanValue[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0) ? null : 'Geçersiz kart numarası';
  }

  // 2. Son Kullanma Tarihi (Gelecek tarih kontrolü)
  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Tarih gerekli';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value))
      return 'Format: MM/YY';

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    final now = DateTime.now();
    final cardDate = DateTime(year, month);

    if (cardDate.isBefore(DateTime(now.year, now.month)))
      return 'Kartın süresi dolmuş';
    return null;
  }

  // 3. CVV Kontrolü
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'CVV gerekli';
    if (value.length < 3 || value.length > 4) return '3 veya 4 rakam olmalı';
    return null;
  }

  // 4. İsim Kontrolü
  static String? validateHolderName(String? value) {
    if (value == null || value.isEmpty) return 'İsim gerekli';
    if (value.trim().split(' ').length < 2) return 'Ad ve Soyad giriniz';
    return null;
  }
}
