import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/transaction/controllers/transaction_controller.dart';
import 'package:gelir_gider_app/themes/app_colors.dart';
import 'package:get/get.dart';

class TransactionTypeSelector extends GetView<TransactionController> {
  const TransactionTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SegmentedButton(
        segments: [
          ButtonSegment(
            value: "expense",
            label: Text("Gider"),
            icon: Icon(Icons.remove_circle_outlined),
          ),
          ButtonSegment(
            value: "income",
            label: Text("Gelir"),
            icon: Icon(Icons.add_circle_outlined),
          ),
        ],
        selected: {controller.transactionType.value},
        onSelectionChanged: (selection) {
          controller.transactionType.value = selection.first;
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkTiffanyBlue;
            } else {
              return Colors.transparent;
            }
          }),
        ),
      ),
    );
  }
}
