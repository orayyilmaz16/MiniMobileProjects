import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/payment_provider.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  final CreditCardModel? editCard; // Düzenlenecek kart (Boşsa "Yeni Kayıt")

  const AddPaymentMethodScreen({super.key, this.editCard});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller'ları geç başlatıyoruz (late)
  late TextEditingController _nameCtrl;
  late TextEditingController _noCtrl;
  late TextEditingController _expCtrl;
  late TextEditingController _cvvCtrl;

  @override
  void initState() {
    super.initState();
    // EĞER editCard dolu gelirse, controller'ları o verilerle başlatıyoruz
    _nameCtrl = TextEditingController(text: widget.editCard?.holderName ?? "");
    _noCtrl = TextEditingController(text: widget.editCard?.no ?? "");
    _expCtrl = TextEditingController(text: widget.editCard?.exp ?? "");
    // CVV güvenlik gereği genelde dolu getirilmez ama istersen ekleyebilirsin
    _cvvCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedCard = CreditCardModel(
        id: widget.editCard?.id ?? DateTime.now().toString(),
        holderName: _nameCtrl.text.toUpperCase(),
        no: _noCtrl.text,
        exp: _expCtrl.text,
        type: _noCtrl.text.startsWith('4') ? 'Visa' : 'Mastercard',
        isDefault: widget.editCard?.isDefault ?? false,
      );

      if (widget.editCard != null) {
        // GÜNCELLEME
        ref.read(paymentProvider.notifier).updateCard(updatedCard);
        _showSnackBar("Kart başarıyla güncellendi!");
      } else {
        // YENİ EKLEME
        ref.read(paymentProvider.notifier).addCard(updatedCard);
        _showSnackBar("Yeni kart eklendi!");
      }

      Navigator.pop(context);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.editCard != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(isEdit ? "Kartı Düzenle" : "Yeni Kart Ekle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                "Kart Üzerindeki İsim",
                Ionicons.person_outline,
                _nameCtrl,
              ),
              const SizedBox(height: 16),

              // Kart Numarası (Düzenleme modunda genelde kart no değiştirilmez ama biz açık bıraktık)
              _buildField(
                "Kart Numarası",
                Ionicons.card_outline,
                _noCtrl,
                kType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      "AA/YY",
                      Ionicons.calendar_outline,
                      _expCtrl,
                      kType: TextInputType.number,
                      formatters: [LengthLimitingTextInputFormatter(5)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      "CVV",
                      Ionicons.lock_closed_outline,
                      _cvvCtrl,
                      kType: TextInputType.number,
                      formatters: [LengthLimitingTextInputFormatter(3)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // KAYDET BUTONU
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEdit ? "Değişiklikleri Kaydet" : "Kartı Kaydet",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? kType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: kType,
      inputFormatters: formatters,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      validator: (v) => v!.isEmpty ? "Boş bırakılamaz" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
