import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/transaction/controllers/transaction_controller.dart';
import 'package:get/get.dart';

class SaveButton extends GetView<TransactionController> {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await controller.createTransaction();
      },
      label: Text("Kaydet"),
      icon: Icon(Icons.save_rounded),
    );
  }
}
