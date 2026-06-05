import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;
  Timer? _timer;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboarding_new_1.jpg',
      'title': 'Smart Booking',
      'description': 'Experience the future of travel with our fast and secure 3D booking engine.',
    },
    {
      'image': 'assets/images/onboarding_new_2.jpg',
      'title': 'Elite Getaways',
      'description': 'Escape to the world\'s most secluded and beautiful private shores.',
    },
    {
      'image': 'assets/images/onboarding_new_3.jpg',
      'title': 'Heritage Stays',
      'description': 'Live like royalty in our handpicked selection of exotic palace hotels.',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentPage.value < onboardingData.length - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skip() {
    Get.offAllNamed(Routes.DASHBOARD);
  }

  void next() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    } else {
      skip();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
