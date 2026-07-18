import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:state_management/core/initialBinding.dart';
import 'package:state_management/home_page/home_binding.dart';
import 'package:state_management/home_page/home_page.dart';
import 'package:state_management/second/second_binding.dart';
import 'package:state_management/second/second_page.dart';
import 'package:state_management/splash/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      getPages: [
        GetPage(
          name: '/home',
          page: () => MyHomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/second',
          page: () => SecondPage(),
          binding: SecondBinding(),
        ),
        GetPage(name: '/splash', page: () => const SplashPage()),
      ],
      initialRoute: '/splash',
      initialBinding: InitialBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
