import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/data/repository/auth_repo.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'dart:convert';

class OtpController extends GetxController {
  final AuthRepo authRepo = Get.find();
  final TextEditingController otpController = TextEditingController();
  var isLoading = false.obs;
  var canResend = false.obs;
  var resendSeconds = 60.obs;
  late String phoneNumber;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    phoneNumber = Get.arguments ?? '';
    _startResendTimer();
  }

  void _startResendTimer() {
    canResend.value = false;
    resendSeconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResend.value = true;
        t.cancel();
      }
    });
  }

  void resendOtp() async {
    isLoading.value = true;
    try {
      final response = await authRepo.sendMobileOtp(phoneNumber);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _startResendTimer();
        Get.snackbar(
          'OTP Sent',
          data['message'] ?? 'A new OTP has been sent to +91 $phoneNumber',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primaryYellow,
          colorText: AppColors.primaryBlack,
        );
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to resend OTP',
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void verifyOtp() async {
    if (otpController.text.length < 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the complete 6-digit code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFD32F2F),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepo.verifyMobileOtp(phoneNumber, otpController.text);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['verified'] == true) {
        // Facebook Event - Login
        final facebookAppEvents = FacebookAppEvents();
        await facebookAppEvents.logEvent(name: 'fb_mobile_login');

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.snackbar(
          'Verification Failed',
          data['message'] ?? 'Invalid OTP',
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Verification failed. Please try again.',
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}


