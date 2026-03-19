import 'package:color_selecter/pages/colorpicker_page.dart';
import 'package:color_selecter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ColorPickerPage(), theme: AppTheme.theme);
  }
}
