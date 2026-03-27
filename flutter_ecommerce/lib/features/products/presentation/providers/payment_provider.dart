import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditCardModel {
  final String id;
  final String holderName;
  final String no;
  final String exp;
  final String type;
  final bool isDefault;

  CreditCardModel({
    required this.id,
    required this.holderName,
    required this.no,
    required this.exp,
    required this.type,
    this.isDefault = false,
  });

  // Güncelleme yaparken mevcut verileri korumak için copyWith
  CreditCardModel copyWith({
    String? holderName,
    String? no,
    String? exp,
    String? type,
    bool? isDefault,
  }) {
    return CreditCardModel(
      id: id,
      holderName: holderName ?? this.holderName,
      no: no ?? this.no,
      exp: exp ?? this.exp,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentNotifier extends StateNotifier<List<CreditCardModel>> {
  PaymentNotifier()
    : super([
        CreditCardModel(
          id: '1',
          holderName: 'ORAY YILMAZ',
          no: '**** 4242',
          exp: '12/28',
          type: 'Visa',
          isDefault: true,
        ),
      ]);

  void addCard(CreditCardModel card) => state = [...state, card];

  void deleteCard(String id) => state = state.where((c) => c.id != id).toList();

  void updateCard(CreditCardModel updatedCard) {
    state = [
      for (final card in state)
        if (card.id == updatedCard.id) updatedCard else card,
    ];
  }

  // Sadece bir kart varsayılan olabilir mantığı
  void setAsDefault(String id) {
    state = [for (final card in state) card.copyWith(isDefault: card.id == id)];
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<CreditCardModel>>(
      (ref) => PaymentNotifier(),
    );
