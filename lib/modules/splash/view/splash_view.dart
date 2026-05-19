import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── White Shiny Glow Effect Background ──────────────────
          const Positioned.fill(child: _ShinyEffect()),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Push Lottie down to center it on screen
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lottie World Tour Animation with speed control
                    _LottieWithSpeed(
                      asset: 'assets/lottie/world Tour.json',
                      width: MediaQuery.of(context).size.width * 0.85,
                      speed: 1.5,
                    ),
                    
                    // App Icon in the center of Lottie - perfectly centered
                    ZoomIn(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 500),
                      child: Transform.translate(
                        offset: const Offset(2, -6), // Micro-shift to top-right
                        child: Container(
                          width: 92, // Slightly decreased size
                          height: 92, // Slightly decreased size
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/icon/ohc_appicon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20), // Reduced height to keep lottie centered
                
                // Branding Logo instead of Text
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 1200),
                  child: Image.asset(
                    'assets/images/own-holiday-club-logo.png',
                    width: 240,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          
          // ── Bottom Determinate Loading Indicator (10 Seconds) ────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 10),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, _) => LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PREPARING YOUR JOURNEY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyText,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Moving White Shiny "Shadow" Glow Painter ──────────────────────────────────
class _ShinyEffect extends StatefulWidget {
  const _ShinyEffect();

  @override
  State<_ShinyEffect> createState() => _ShinyEffectState();
}

class _ShinyEffectState extends State<_ShinyEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _ShinyPainter(_ctrl.value),
        );
      },
    );
  }
}

class _ShinyPainter extends CustomPainter {
  final double progress;
  _ShinyPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Create a bright white "shadow" glow sweep
    final gradient = LinearGradient(
      begin: const Alignment(-2.5, -1.0),
      end: const Alignment(2.5, 1.0),
      stops: [
        0.0,
        progress - 0.2,
        progress,
        progress + 0.2,
        1.0,
      ],
      colors: [
        Colors.white,
        Colors.white,
        const Color(0xFFF0F0F0).withOpacity(0.4), // Subtle greyish shine to stand out on white
        Colors.white,
        Colors.white,
      ],
    );

    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Lottie Speed Helper ───────────────────────────────────────────────────────
class _LottieWithSpeed extends StatefulWidget {
  final String asset;
  final double width;
  final double speed;

  const _LottieWithSpeed({
    required this.asset, 
    required this.width, 
    this.speed = 1.0
  });

  @override
  State<_LottieWithSpeed> createState() => _LottieWithSpeedState();
}

class _LottieWithSpeedState extends State<_LottieWithSpeed> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.asset,
      controller: _controller,
      width: widget.width,
      fit: BoxFit.contain,
      onLoaded: (composition) {
        _controller.duration = composition.duration * (1 / widget.speed);
        _controller.forward().then((_) {
          if (mounted) {
            Get.offAllNamed(Routes.ONBOARDING);
          }
        });
      },
    );
  }
}
