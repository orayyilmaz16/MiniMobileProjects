import 'package:flutter/material.dart';
import 'package:gelir_gider_app/services/storage_service.dart';
import 'package:get/get.dart';

class ThemeService extends GetxService {
  late final StorageService _storageService;
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    loadThemeMode();
  }

  void loadThemeMode() {
    final savedTheme = _storageService.getValue<String>(StorageKeys.themeMode);
    if (savedTheme != null) {
      _isDarkMode.value = savedTheme == 'dark';
      Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } else {
      final brightness = Get.theme.brightness;
      _isDarkMode.value = brightness == Brightness.dark;
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    await _storageService.setValue<String>(
      StorageKeys.themeMode,
      _isDarkMode.value ? 'dark' : 'light',
    );
  }
}
