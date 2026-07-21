import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/utils/app_colors.dart';

import 'package:own_holiday_app/routes/app_pages.dart';
import '../controller/account_controller.dart';
import 'package:own_holiday_app/modules/auth/member_details/view/member_details_view.dart';
import 'package:own_holiday_app/modules/auth/member_details/controller/member_details_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoggedIn.value) {
        if (!Get.isRegistered<MemberDetailsController>()) {
          Get.put(MemberDetailsController());
        }
        return const MemberDetailsView();
      }
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
            onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
          ),
          title: Text(
            'Account',
            style: GoogleFonts.poppins(
              color: AppColors.primaryBlack, 
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          actions: const [],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Image & Name
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryYellow, width: 3),
                        color: const Color(0xFFF8F9FA),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(Icons.person_outline_rounded, size: 55, color: Color(0xFF0D1321)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Guest User',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF0D1321),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Login to access your premium membership benefits', 
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600], 
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Member Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => Get.toNamed(Routes.MEMBER_LOGIN),
                      child: Text(
                        'MEMBER LOGIN',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, 
                          fontSize: 12.5, 
                          letterSpacing: 0.8
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        Icons.security_rounded, 
                        'Privacy & Security', 
                        'Manage your data and biometrics',
                        onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                      ),
                      _buildMenuItem(
                        Icons.info_outline_rounded, 
                        'About Own Holiday', 
                        'Learn more about our services',
                        onTap: () => Get.toNamed(Routes.ABOUT_US),
                      ),
                      _buildMenuItem(
                        Icons.help_outline_rounded, 
                        'Help & FAQ', 
                        'Common questions & support', 
                        onTap: () => Get.toNamed(Routes.FAQ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color.fromRGBO(27, 31, 35, 0.15),
              offset: Offset(0, 0),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF0D1321), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF0D1321), 
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle, 
                    style: GoogleFonts.poppins(
                      fontSize: 10.5, 
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
