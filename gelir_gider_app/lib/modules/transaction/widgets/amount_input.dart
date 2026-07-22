import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/transaction/controllers/transaction_controller.dart';
import 'package:get/get.dart';

class AmountInput extends GetView<TransactionController> {
  const AmountInput({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Miktar",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.money_outlined),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        controller.amount.value =
            double.tryParse(value) ?? controller.amount.value;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir miktar girin';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Lütfen geçerli bir miktar girin';
        }
        return null;
      },
    );
  }
}
