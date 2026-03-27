// models/payment_method_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethod {
  final String id;
  final String cardHolderName;
  final String cardNumber; // Örn: **** 4242
  final String expiryDate;
  final bool isDefault;
  final String cardType; // Visa, Mastercard vb.

  PaymentMethod({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    this.isDefault = false,
    required this.cardType,
  });

  PaymentMethod copyWith({bool? isDefault}) {
    return PaymentMethod(
      id: id,
      cardHolderName: cardHolderName,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      isDefault: isDefault ?? this.isDefault,
      cardType: cardType,
    );
  }
}

// providers/payment_provider.dart
class PaymentNotifier extends StateNotifier<List<PaymentMethod>> {
  PaymentNotifier()
    : super([
        PaymentMethod(
          id: "card_1",
          cardHolderName: "ORAY YILMAZ",
          cardNumber: "**** 4242",
          expiryDate: "12/28",
          cardType: "VISA",
          isDefault: true,
        ),
        // Diğer kartlar...
      ]);

  void setDefault(String cardId) {
    state = [
      for (final card in state) card.copyWith(isDefault: card.id == cardId),
    ];
  }

  PaymentMethod? get defaultCard => state.firstWhere((e) => e.isDefault);
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<PaymentMethod>>(
      (ref) => PaymentNotifier(),
    );
