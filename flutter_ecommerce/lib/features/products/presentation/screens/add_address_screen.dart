import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/utils/address_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/address_provider.dart';
// Validator dosyanın yolu

class AddAddressScreen extends ConsumerStatefulWidget {
  final AddressModel? editAddress;
  const AddAddressScreen({super.key, this.editAddress});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller'ları geç başlatıyoruz (late) ve dispose ediyoruz
  late TextEditingController _titleCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak mevcut verileri, değilse boş string atıyoruz
    _titleCtrl = TextEditingController(text: widget.editAddress?.title ?? "");
    _nameCtrl = TextEditingController(text: widget.editAddress?.fullName ?? "");
    _cityCtrl = TextEditingController(text: widget.editAddress?.city ?? "");
    _districtCtrl = TextEditingController(
      text: widget.editAddress?.district ?? "",
    );
    _descCtrl = TextEditingController(
      text: widget.editAddress?.fullAddress ?? "",
    );
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları kapatıyoruz
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ADRESİ KAYDETME VEYA GÜNCELLEME MANTIĞI
  void _save() {
    if (_formKey.currentState!.validate()) {
      final addressData = AddressModel(
        id:
            widget.editAddress?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        fullAddress: _descCtrl.text.trim(),
      );

      if (widget.editAddress != null) {
        // GÜNCELLEME
        ref.read(addressProvider.notifier).updateAddress(addressData);
        _showFeedback("Adres başarıyla güncellendi");
      } else {
        // YENİ EKLEME
        ref.read(addressProvider.notifier).addAddress(addressData);
        _showFeedback("Yeni adres kaydedildi");
      }

      context.pop(); // İşlem bitince bir önceki sayfaya dön
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.editAddress != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? "Adresi Düzenle" : "Yeni Adres"),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(
                Ionicons.trash_outline,
                color: theme.colorScheme.error,
              ),
              onPressed: () => _confirmDelete(ref, widget.editAddress!.id),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Genel Bilgiler", theme),
                const SizedBox(height: 16),
                _buildField(
                  label: "Adres Başlığı (Örn: Evim, Ofis)",
                  icon: Ionicons.bookmark_outline,
                  controller: _titleCtrl,
                  validator: AddressValidator.validateTitle,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: "Teslim Alacak Kişi (Ad Soyad)",
                  icon: Ionicons.person_outline,
                  controller: _nameCtrl,
                  validator: AddressValidator.validateFullName,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("Konum Bilgileri", theme),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildField(
                        label: "Şehir",
                        icon: Ionicons.map_outline,
                        controller: _cityCtrl,
                        validator: (v) =>
                            AddressValidator.validateLocation(v, "Şehir"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        label: "İlçe",
                        icon: Ionicons.business_outline,
                        controller: _districtCtrl,
                        validator: (v) =>
                            AddressValidator.validateLocation(v, "İlçe"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: "Açık Adres",
                  icon: Ionicons.home_outline,
                  controller: _descCtrl,
                  maxLines: 3,
                  validator: AddressValidator.validateFullAddress,
                ),
                const SizedBox(height: 48),
                _buildSaveButton(theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.primary.withOpacity(0.7),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontSize: 14,
        ),
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Adresi Kaydet",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _confirmDelete(WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adresi Sil?"),
        content: const Text("Bu işlem geri alınamaz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("VAZGEÇ"),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressProvider.notifier).deleteAddress(id);
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text(
              "SİL",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
