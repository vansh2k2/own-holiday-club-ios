import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../membership/view/membership_form_view.dart';
import '../../membership/model/membership_tier.dart';
import '../../../routes/app_pages.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/widgets/membership_bottom_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.pages[controller.currentIndex.value],
          )),
      bottomNavigationBar: Container(
        height: 95,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background Navbar (Full width, CustomPaint Notch, light background)
            CustomPaint(
              size: const Size(double.infinity, 60),
              painter: NotchPainter(),
              child: Container(
                height: 60,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Home'),
                    const SizedBox(width: 60), 
                    _buildNavItem(2, Icons.person_rounded, 'Account'),
                  ],
                ),
              ),
            ),

            // Overlapping Middle Icon (Membership) - Shifted upward (bottom: 29) & Size increased to 62
            Positioned(
              bottom: 29,
              child: GestureDetector(
                onTap: () => MembershipBottomSheet.show(context),
                child: Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryYellow.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.card_membership_rounded,
                    size: 28,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ),
            
            // Middle Label
            Positioned(
              bottom: 6,
              child: const Text(
                'Membership',
                style: TextStyle(
                  color: AppColors.primaryBlack,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return InkWell(
      onTap: () => controller.changeIndex(index),
      child: Obx(() {
        bool isSelected = controller.currentIndex.value == index;
        // Brand logo's signature Burgundy/Red-Purple color
        const activeColor = Color(0xFF9D0B51);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : AppColors.greyText,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.greyText,
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

}

class NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Beautiful soft bottom nav shadows matching the shape perfectly
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path();
    final notchRadius = 36.0; // Button size is 62 (radius 31) + 5px margin = 36px
    final middle = size.width / 2;

    path.moveTo(0, 0);
    // Left shoulder line
    path.lineTo(middle - notchRadius, 0);

    // Perfect semicircular arc cut-out
    path.arcToPoint(
      Offset(middle + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Right shoulder line to end
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw bottom shadow shifted up slightly
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
    // Draw the white filled notched shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
