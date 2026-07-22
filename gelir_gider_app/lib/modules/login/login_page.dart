import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/login/login_controller.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await controller.googleIleGirisYap();
          },
          child: Text("Google ile Giriş Yap"),
        ),
      ),
    );
  }
}
