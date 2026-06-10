import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../controller/member_login_controller.dart';

class MemberLoginView extends GetView<MemberLoginController> {
  const MemberLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSlitHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: const Text(
                      'Welcome Back, Member',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        color: AppColors.primaryBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Login to access your exclusive holiday benefits and manage your bookings.',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form Fields
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildTextField(
                      textController: controller.memberIdController,
                      label: 'Member ID',
                      icon: Icons.badge_outlined,
                      hint: 'Enter your member ID',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildTextField(
                      textController: controller.passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      hint: 'Enter your password',
                      isPassword: true,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontWeight: FontWeight.normal,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Login Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          foregroundColor: AppColors.primaryYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primaryBlack.withOpacity(0.3),
                        ),
                        onPressed: controller.isLoading.value ? null : () => controller.login(),
                        child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: AppColors.primaryYellow)
                          : const Text(
                              'LOGIN TO ACCOUNT',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1.2,
                              ),
                            ),
                      ),
                    )),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member yet? ',
                          style: TextStyle(color: AppColors.greyText, fontSize: 12.0),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Become a Member',
                            style: TextStyle(
                              color: AppColors.primaryBlack,
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlitHeader(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.38;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryBlack.withOpacity(0.3),
                    Colors.transparent,
                    AppColors.primaryWhite,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Logo in top left of header
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.circular(35),
              ),
              child: Image.asset(
                'assets/images/own-holiday-club-logo.png',
                height: 70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    final loginCtrl = Get.find<MemberLoginController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGrey.withOpacity(0.5)),
          ),
          child: Obx(() {
            final isVisible = loginCtrl.isPasswordVisible.value;
            return TextField(
              controller: textController,
              obscureText: isPassword && !isVisible,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.greyText.withOpacity(0.6), fontSize: 12.0),
                prefixIcon: Icon(icon, color: AppColors.primaryBlack, size: 20),
                suffixIcon: isPassword 
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.greyText,
                        size: 20,
                      ),
                      onPressed: () => loginCtrl.isPasswordVisible.toggle(),
                    )
                  : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            );
          }),
        ),
      ],
    );
  }
}
