import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../login/model/user_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../account/controller/account_controller.dart';
import '../../../../data/repository/auth_repo.dart';
import 'package:own_holiday_app/utils/app_colors.dart';

class MemberDetailsController extends GetxController {
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isBooking = false.obs;
  final RxInt expandedSection = (-1).obs;

  void toggleSection(int index) {
    if (expandedSection.value == index) {
      expandedSection.value = -1;
    } else {
      expandedSection.value = index;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    // Sync with AccountController which has the freshest data
    final accountController = Get.find<AccountController>();
    user.value = accountController.userData.value;
    
    // Listen for updates
    ever(accountController.userData, (newData) {
      user.value = newData;
    });
  }

  Future<void> requestHolidayBooking(int slot, int year) async {
    try {
      isBooking.value = true;
      
      final data = {
        "userId": user.value?.id,
        "name": user.value?.name,
        "phone": user.value?.mobile, // Changed from 'mobile' to 'phone' based on backend requirements
        "email": user.value?.email,
        "membershipId": user.value?.membershipId,
        "contextType": "holiday-booking",
        "contextName": "Slot $slot ($year)",
        "message": "Member requested holiday booking for Year $year (Slot $slot)",
        "source": "app-member-dashboard",
        "adults": 2, // Defaults
        "kids": 0,
      };

      final response = await authRepo.bookHoliday(data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Request Submitted', 
          'Your holiday request for slot $slot has been received. Our team will contact you within 12 hours.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        Get.find<AccountController>().refreshProfile();
      } else {
        throw 'Failed to submit request';
      }
    } catch (e) {
      Get.snackbar(
        'Submission Error', 
        'We encountered an issue submitting your request. Please check your network or try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
    } finally {
      isBooking.value = false;
    }
  }

  Future<String?> submitHolidayActivation(Map<String, dynamic> data) async {
    final userId = user.value?.id ?? '';
    final url = 'https://api.ownholidayclub.com/api/profile/$userId/holiday-bookings';
    print('\n--- 🚀 [API REQUEST] POST HOLIDAY BOOKING ---');
    print('🔗 URL: $url');
    print('📦 REQUEST BODY: $data');

    try {
      isBooking.value = true;
      if (userId.isEmpty) throw 'User ID is missing';
      final response = await authRepo.submitSlotBooking(userId, data);
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('--------------------------------------------\n');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.find<AccountController>().refreshProfile();
        return null;
      } else {
        final error = response.body;
        print('Activation Error: $error');
        try {
          final errJson = jsonDecode(error);
          return errJson['message'] ?? 'Failed to book holiday';
        } catch (_) {
          return error.isNotEmpty ? error : 'Failed to book holiday';
        }
      }
    } catch (e) {
      print('Activation Exception: $e');
      return e.toString();
    } finally {
      isBooking.value = false;
    }
  }

  void logout() {
    Get.find<AccountController>().logout();
    Get.offAllNamed(Routes.MEMBER_LOGIN);
  }
}
