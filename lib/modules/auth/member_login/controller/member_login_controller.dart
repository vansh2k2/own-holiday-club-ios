import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import 'package:own_holiday_app/data/repository/auth_repo.dart';
import 'package:own_holiday_app/modules/auth/login/model/user_model.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'dart:convert';

class MemberLoginController extends GetxController {
  final AuthRepo authRepo = Get.find();
  final memberIdController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  
  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // If already logged in, redirect to details
    final accountController = Get.find<AccountController>();
    if (accountController.isLoggedIn.value) {
      Future.delayed(Duration.zero, () {
        Get.offNamed(Routes.MEMBER_DETAILS);
      });
    }
  }

  void login() async {
    if (memberIdController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Member ID and Password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepo.login(
        memberIdController.text,
        passwordController.text,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['user'] != null) {
          user.value = UserModel.fromJson(data['user']);
        }
        
        final accountController = Get.find<AccountController>();
        if (user.value != null) {
          accountController.saveUser(user.value!);
        }
        
        // Dynamically fetch full profile details (including membership details)
        await accountController.fetchProfile();

        Get.snackbar(
          'Success',
          data['message'] ?? 'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.MEMBER_DETAILS); // Navigate to member details page
      } else {
        Get.snackbar(
          'Login Failed',
          data['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    memberIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
