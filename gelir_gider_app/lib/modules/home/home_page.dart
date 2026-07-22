import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/dashboard/dashboard_page.dart';
import 'package:gelir_gider_app/modules/home/home_controller.dart';
import 'package:gelir_gider_app/modules/profile/profile_page.dart';
import 'package:gelir_gider_app/themes/app_colors.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gelir Gider Uygulaması"),
        actions: [
          IconButton(
            onPressed: () async {
              await controller.cikisYap();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [DashboardPage(), ProfilePage()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToTransaction,
        backgroundColor: AppColors.darkHotPink,
        shape: CircleBorder(),
        child: Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Obx(
        () => AnimatedBottomNavigationBar(
          gapLocation: GapLocation.center,
          backgroundColor: AppColors.darkTiffanyBlue,
          icons: [Icons.dashboard_outlined, Icons.person],
          activeIndex: controller.currentIndex.value,
          splashColor: Colors.white,
          activeColor: Colors.white,
          notchSmoothness: NotchSmoothness.softEdge,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          inactiveColor: Colors.white.withAlpha(100),
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
