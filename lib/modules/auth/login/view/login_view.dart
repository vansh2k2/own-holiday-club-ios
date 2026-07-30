import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ─── Top Destination Image with Brand Curve ──────────
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.58,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/santorini_experience.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryBlack.withOpacity(0.1),
                        AppColors.primaryBlack.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: Obx(() => controller.isOtpSent.value
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                        onPressed: () => controller.resetLogin(),
                      )
                    : const SizedBox.shrink()),
              ),
            ],
          ),

          // ─── Bottom Content (Phone or OTP) ──────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Obx(() {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                    
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: controller.isOtpSent.value
                      ? _buildOtpContent()
                      : _buildPhoneContent(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phone Input UI ────────────────────────────────────────────────────────
  Widget _buildPhoneContent() {
    return Column(
      key: const ValueKey('PhoneUI'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: AppColors.primaryBlack,
          ),
        ),
        Text(
          'Enter your mobile number to get started.',
          style: TextStyle(
            fontSize: 12.0,
            color: AppColors.greyText,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 35),
        
        // Input Field
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGrey.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlack.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Text(
                  '🇮🇳 +91',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 2,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      color: AppColors.greyText,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 35),
        
        // Send OTP Button
        Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: AppColors.primaryBlack.withOpacity(0.3),
                ),
                onPressed: controller.isLoading.value ? null : () => controller.sendOtp(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'Continue with OTP',
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
                      ),
              ),
            )),
            
        const SizedBox(height: 25),
        Center(
          child: Text(
            'By continuing, you agree to our Terms & Conditions',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.0, color: AppColors.greyText),
          ),
        ),
      ],
    );
  }

  // ── OTP Verification UI ───────────────────────────────────────────────────
  Widget _buildOtpContent() {
    return Column(
      key: const ValueKey('OtpUI'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Verification',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: AppColors.primaryBlack,
          ),
        ),
        RichText(
          text: TextSpan(
            text: 'We have sent a code to ',
            style: TextStyle(
              fontSize: 12.0,
              color: AppColors.greyText,
              fontWeight: FontWeight.normal,
            ),
            children: [
              TextSpan(
                text: '+91 ${controller.phoneController.text}',
                style: const TextStyle(
                  color: AppColors.primaryBlack,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 35),
        
        // Custom OTP Boxes
        _OtpBoxes(controller: controller),
        
        const SizedBox(height: 35),
        
        // Verify Button
        Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: AppColors.primaryBlack.withOpacity(0.3),
                ),
                onPressed: controller.isLoading.value ? null : () => controller.verifyOtp(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
                      ),
              ),
            )),
            
        const SizedBox(height: 25),
        Obx(() => Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive code? ",
                style: TextStyle(color: AppColors.greyText),
              ),
              GestureDetector(
                onTap: controller.timerSeconds.value == 0 ? () => controller.sendOtp() : null,
                child: Text(
                  controller.timerSeconds.value > 0
                      ? 'Resend in ${controller.timerSeconds.value}s'
                      : 'Resend Now',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

// ── Improved Animated OTP Boxes ─────────────────────────────────────────────
class _OtpBoxes extends StatefulWidget {
  final LoginController controller;
  const _OtpBoxes({required this.controller});

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  static const int length = 6;
  final List<TextEditingController> _ctrls = List.generate(length, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(length, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _ctrls) {
      c.dispose();
    }
    for (var n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(String val, int i) {
    if (val.length == 1) {
      if (i < length - 1) {
        _nodes[i + 1].requestFocus();
      } else {
        _nodes[i].unfocus();
      }
    } else if (val.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    widget.controller.otpController.text = _ctrls.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        return _OtpSingleBox(
          controller: _ctrls[i],
          focusNode: _nodes[i],
          onChanged: (v) => _onChanged(v, i),
        );
      }),
    );
  }
}

class _OtpSingleBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpSingleBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpSingleBox> createState() => _OtpSingleBoxState();
}

class _OtpSingleBoxState extends State<_OtpSingleBox> with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45,
        height: 60,
        decoration: BoxDecoration(
          color: _isFocused ? AppColors.primaryYellow.withOpacity(0.05) : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _isFocused ? AppColors.primaryYellow : AppColors.borderGrey.withOpacity(0.3),
            width: _isFocused ? 2.5 : 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primaryYellow.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: (val) {
              widget.onChanged(val);
              if (val.isNotEmpty) {
                _anim.forward().then((_) => _anim.reverse());
              }
            },
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.normal),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
