import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/transaction/controllers/category_controller.dart';
import 'package:gelir_gider_app/utils/icon_helper.dart';
import 'package:get/get.dart';

class AddCategoryDialog extends StatelessWidget {
  const AddCategoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<CategoryController>(CategoryController());
    return AlertDialog(
      title: Text(
        "Kategori Ekle",
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Kategori Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              onChanged: (value) => controller.categoryName.value = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori adı boş olamaz';
                }
                return null;
              },
            ),
            SizedBox(
              height: 16,
            ),
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'Kategori Iconu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.emoji_objects_outlined)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'kategori iconu seçiniz';
                  }
                  return null;
                },
                items: icons
                    .map((icon) => DropdownMenuItem(
                          child: Text(icon),
                          value: icon,
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedIcon.value = value;
                  }
                },
                value: controller.selectedIcon.value,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    'Vazgeç',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.createCategory,
                    child: controller.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Kaydet'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
