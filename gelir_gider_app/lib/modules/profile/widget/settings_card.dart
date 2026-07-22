import 'package:flutter/material.dart';
import 'package:gelir_gider_app/services/theme_service.dart';
import 'package:get/get.dart';

class SettingsCard extends StatelessWidget {
  SettingsCard({super.key});
  final ThemeService themeService = Get.find<ThemeService>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.brightness_6),
        title: Text('Theme'),
        trailing: Obx(
          () => Switch(
            value: themeService.isDarkMode,
            onChanged: (value) => themeService.toggleTheme(),
          ),
        ),
      ),
    );
  }
}
