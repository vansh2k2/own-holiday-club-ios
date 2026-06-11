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
              child: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.isForgotPassword.value 
                  ? _buildForgotPasswordForm(context)
                  : _buildLoginForm(context),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      key: const ValueKey('login_form'),
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
              onPressed: () => controller.toggleForgotPassword(),
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
      ],
    );
  }

  Widget _buildForgotPasswordForm(BuildContext context) {
    return Obx(() {
      final fpStep = controller.fpStep.value;
      return Column(
        key: const ValueKey('forgot_password_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: const Text(
              'ACCOUNT RECOVERY',
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935), // Red color from screenshot
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 50),
            child: const Text(
              'Forgot password',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              fpStep == 0 
                ? 'We\'ll help you restore access in a few quick steps.'
                : fpStep == 1
                  ? 'Enter the OTP sent to your registered email to proceed.'
                  : 'Create a strong new password to restore full access to your account.',
              style: TextStyle(
                fontSize: 13.0,
                color: AppColors.greyText,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          if (fpStep == 0) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildTextField(
                textController: controller.fpIdentifierController,
                label: 'MEMBERSHIP ID / EMAIL',
                icon: Icons.person_outline,
                hint: 'Enter Membership ID or Email',
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black, // Red text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading.value ? null : () => controller.sendForgotPasswordOtp(),
                  child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SEND OTP',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                ),
              )),
            ),
          ] else if (fpStep == 1) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildTextField(
                textController: controller.fpIdentifierController,
                label: 'MEMBERSHIP ID / EMAIL',
                icon: Icons.person_outline,
                hint: 'Enter Membership ID or Email',
                readOnly: true,
                borderColor: const Color(0xFFE53935), // Red border
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildTextField(
                textController: controller.fpOtpController,
                label: 'OTP CODE',
                icon: Icons.mail_outline,
                hint: 'Enter 6-digit OTP',
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935), // Red button
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading.value ? null : () => controller.verifyForgotPasswordOtp(),
                  child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'VERIFY OTP',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                ),
              )),
            ),

          ] else ...[
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildTextField(
                textController: controller.fpIdentifierController,
                label: 'MEMBERSHIP ID / EMAIL',
                icon: Icons.person_outline,
                hint: 'Enter Membership ID or Email',
                readOnly: true,
                borderColor: const Color(0xFFE53935), // Red border
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildTextField(
                textController: controller.fpOtpController,
                label: 'OTP CODE',
                icon: Icons.mail_outline,
                hint: 'Enter 6-digit OTP',
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: _buildTextField(
                textController: controller.fpNewPasswordController,
                label: 'NEW PASSWORD',
                icon: Icons.lock_outline,
                hint: 'Enter new password',
                isPassword: true,
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935), // Red button
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading.value ? null : () => controller.resetPassword(),
                  child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'UPDATE PASSWORD',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check, size: 16),
                        ],
                      ),
                ),
              )),
            ),
          ],
          
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: GestureDetector(
              onTap: () => controller.toggleForgotPassword(),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 14, color: Color(0xFFE53935)),
                  SizedBox(width: 4),
                  Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
          const SizedBox(height: 20),
          
          
          const SizedBox(height: 20),
        ],
      );
    });
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
    bool readOnly = false,
    Color? borderColor,
  }) {
    final loginCtrl = Get.find<MemberLoginController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? AppColors.primaryWhite : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor ?? AppColors.borderGrey.withOpacity(0.5)),
          ),
          child: Obx(() {
            final isVisible = loginCtrl.isPasswordVisible.value;
            return TextField(
              controller: textController,
              obscureText: isPassword && !isVisible,
              readOnly: readOnly,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.greyText.withOpacity(0.6), fontSize: 13.0),
                prefixIcon: Icon(icon, color: readOnly ? Colors.grey : AppColors.primaryBlack, size: 20),
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
