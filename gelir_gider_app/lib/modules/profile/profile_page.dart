import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/profile/profile_controller.dart';
import 'package:gelir_gider_app/modules/profile/widget/info_card.dart';
import 'package:gelir_gider_app/modules/profile/widget/settings_card.dart';
import 'package:gelir_gider_app/services/theme_service.dart';
import 'package:get/get.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                controller.user.value?.profilePhoto ?? '',
              ),
            ),
            SizedBox(height: 24),
            InfoCard(
              title: 'First Name',
              value: controller.user.value?.firstName ?? '',
            ),
            InfoCard(
              title: 'Last Name',
              value: controller.user.value?.lastName ?? '',
            ),
            InfoCard(title: 'Email', value: controller.user.value?.email ?? ''),
            SettingsCard(),
          ],
        ),
      ),
    );
  }
}
