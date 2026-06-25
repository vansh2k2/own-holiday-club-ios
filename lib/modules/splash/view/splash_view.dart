import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ZoomIn(
          duration: const Duration(seconds: 3),
          child: Image.asset(
            'assets/images/own-holiday-club-logo.png',
            width: 240,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
