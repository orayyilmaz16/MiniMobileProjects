class AddressValidator {
  // 1. Adres Başlığı (Örn: Evim, Ofis)
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Adres başlığı gerekli';
    if (value.trim().length < 2) return 'Başlık çok kısa';
    if (value.trim().length > 20) return 'Başlık 20 karakteri geçmemeli';
    return null;
  }

  // 2. Ad Soyad (En az 2 kelime ve sadece harf)
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ad soyad gerekli';

    final nameParts = value.trim().split(' ');
    if (nameParts.length < 2) return 'Lütfen adınızı ve soyadınızı tam girin';

    // Sadece harf ve boşluk kontrolü (Türkçe karakterler dahil)
    final nameRegExp = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegExp.hasMatch(value))
      return 'İsim sadece harflerden oluşmalıdır';

    return null;
  }

  // 3. Şehir ve İlçe
  static String? validateLocation(String? value, String label) {
    if (value == null || value.trim().isEmpty)
      return '$label alanı boş bırakılamaz';
    if (value.trim().length < 2) return 'Geçerli bir $label girin';
    return null;
  }

  // 4. Tam Adres (Detaylı kontrol)
  static String? validateFullAddress(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Açık adresinizi yazmalısınız';
    if (value.trim().length < 10)
      return 'Lütfen daha detaylı bir adres tarifi verin';
    if (value.trim().length > 250) return 'Adres çok uzun, lütfen sadeleştirin';
    return null;
  }
}
