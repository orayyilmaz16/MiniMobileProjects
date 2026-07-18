import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:state_management/home_page/sayac_controller.dart';
import 'package:state_management/home_page/sayi_controller.dart';
import 'package:state_management/main.dart';

void main() {
  Get.put(SayiController());
  runApp(const MyApp());
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Getx kullanimi"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/second');
              },
              child: const Text('Go to Second Page'),
            ),
            GetBuilder<SayacController>(
              builder: (controller) => Text(
                controller.sayac.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const Text('Üretilen Rastgele Sayı: '),
            Obx(
              () => Text(
                Get.find<SayiController>().randomSayi.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MyFloatingActionButton(),
          SizedBox(height: 10),
          RastgeleSayiButton(),
        ],
      ),
    );
  }
}

class RastgeleSayiButton extends GetView<SayiController> {
  const RastgeleSayiButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: '1',
      onPressed: () {
        controller.uret();
      },
      child: const Icon(Icons.refresh),
    );
  }
}

class MyFloatingActionButton extends GetView<SayacController> {
  const MyFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: '2',
      onPressed: () {
        controller.arttir();
      },
      child: const Icon(Icons.add),
    );
  }
}
