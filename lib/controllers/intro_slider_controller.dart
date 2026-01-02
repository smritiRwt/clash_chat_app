import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntroSliderController extends GetxController {
  final PageController pageController = PageController();

  final currentIndex = 0.obs;

  final pages = const [
    IntroPageData(
      title: 'Chat Instantly',
      description: 'Connect with friends and family in real time.',
      icon: Constants.introImgOne,
    ),
    IntroPageData(
      title: 'Secure Messages',
      description: 'Your conversations are encrypted and private.',
      icon: Constants.introImgTwo,
    ),
    IntroPageData(
      title: 'Stay Connected',
      description: 'Online & offline status with instant delivery.',
      icon: Constants.introImgThree,
    ),
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void next() {
    if (currentIndex.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      goToHome();
    }
  }

  void skip() {
    goToHome();
  }

  void goToHome() {
    Get.toNamed('/signup');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

/// --------------------
/// Data Model
/// --------------------
class IntroPageData {
  final String title;
  final String description;
  final String icon;

  const IntroPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
