import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:state_management/second/second_controller.dart';

class SecondPage extends StatelessWidget {
  SecondPage({super.key});

  var controller = Get.find<SecondController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Obx(() => Text(controller.name.value))),
    );
  }
}
