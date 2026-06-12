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

  // Forgot Password States
  final isForgotPassword = false.obs;
  final fpStep = 0.obs; // 0: send-otp, 1: verify-otp, 2: reset
  final fpIdentifierController = TextEditingController();
  final fpOtpController = TextEditingController();
  final fpNewPasswordController = TextEditingController();
  final isFpPasswordVisible = false.obs;

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
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    // --- Google Play Reviewer Dummy Login Bypass ---
    if (memberIdController.text == 'google_review' && passwordController.text == 'Test@123') {
      final dummyUser = UserModel(
        id: 'dummy_reviewer_id',
        name: 'Google Reviewer',
        email: 'google_review@example.com',
        mobile: '1234567890',
        membershipId: 'google_review',
        isActive: true,
        membership: UserMembershipModel(
           status: 'Active',
           name: 'Premium',
        ),
      );
      
      final accountController = Get.find<AccountController>();
      user.value = dummyUser;
      accountController.saveUser(dummyUser);
      
      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.primaryYellow,
        colorText: Colors.white,
      );
      
      Get.offAllNamed(Routes.MEMBER_DETAILS);
      return;
    }
    // ------------------------------------------------

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
          snackPosition: SnackPosition.TOP,
        borderRadius: 4,
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.MEMBER_DETAILS); // Navigate to member details page
      } else {
        Get.snackbar(
          'Login Failed',
          data['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.TOP,
        borderRadius: 4,
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password Methods
  void toggleForgotPassword() {
    isForgotPassword.value = !isForgotPassword.value;
    fpStep.value = 0;
    fpIdentifierController.clear();
    fpOtpController.clear();
    fpNewPasswordController.clear();
  }

  void sendForgotPasswordOtp() async {
    if (fpIdentifierController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Membership ID or Email',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepo.forgotPasswordSendOtp(fpIdentifierController.text);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        fpStep.value = 1;
        Get.snackbar(
          'Success',
          data['message'] ?? 'OTP sent successfully to your registered email/mobile',
          snackPosition: SnackPosition.TOP,
        borderRadius: 4,
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to send OTP',
          snackPosition: SnackPosition.TOP,
        borderRadius: 4,
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void verifyForgotPasswordOtp() async {
    if (fpOtpController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepo.verifyForgotPasswordOtp(
        fpIdentifierController.text,
        fpOtpController.text,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        fpStep.value = 2;
        Get.snackbar(
          'Success',
          data['message'] ?? 'OTP verified successfully. Set a new password now.',
          snackPosition: SnackPosition.TOP,
        borderRadius: 4,
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to verify OTP',
          snackPosition: SnackPosition.TOP,
        borderRadius: 4,
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetPassword() async {
    if (fpOtpController.text.isEmpty || fpNewPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter OTP and New Password',
        snackPosition: SnackPosition.TOP,
        borderRadius: 4,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepo.resetPassword(
        fpIdentifierController.text,
        fpOtpController.text,
        fpNewPasswordController.text,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        toggleForgotPassword();
        Get.snackbar(
          'Success',
          data['message'] ?? 'Password reset successfully. Please login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to reset password',
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
    fpIdentifierController.dispose();
    fpOtpController.dispose();
    fpNewPasswordController.dispose();
    super.onClose();
  }
}
