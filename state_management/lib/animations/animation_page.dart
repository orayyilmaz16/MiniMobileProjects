import "package:get/get.dart";
import "package:flutter/material.dart";
import "package:state_management/animations/animation_controller.dart";

class AnimationPage extends GetView<AnimationControllers> {
  const AnimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Animasyonlar')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Animated Container Örnek'),
              SizedBox(height: 8),
              Obx(
                () => AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  width: controller.containerWidth.value,
                  height: controller.containerHeight.value,
                  decoration: BoxDecoration(
                    color: controller.containerColor.value,
                    borderRadius: BorderRadius.circular(
                      controller.containerRadius.value,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: controller.boyutDegis,
                    child: Text('Boyut değiştir'),
                  ),
                  ElevatedButton(
                    onPressed: controller.sekilDegis,
                    child: Text('Şekil değiştir'),
                  ),
                  ElevatedButton(
                    onPressed: controller.renkDegis,
                    child: Text('Renk değiştir'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: controller.animasyonlariSifirla,
                child: Text('Animasyonları Sıfırla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
