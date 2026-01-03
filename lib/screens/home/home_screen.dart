import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../components/bottom_nav_bar.dart';

/// Home Screen
/// Main screen with bottom navigation - 100% dumb UI
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  HomeController get controller {
    try {
      return Get.find<HomeController>();
    } catch (e) {
      return Get.put(HomeController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Scaffold(
        body: Obx(() => controller.currentPage),
        bottomNavigationBar: Obx(
          () => CustomBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTabChange: controller.changeTab,
          ),
        ),
      ),
    );
  }
}
