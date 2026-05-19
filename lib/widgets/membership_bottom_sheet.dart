import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/modules/dashboard/controller/dashboard_controller.dart';
import 'package:own_holiday_app/modules/membership/model/membership_tier.dart';

class MembershipBottomSheet {
  static void show(BuildContext context) {
    final controller = Get.find<DashboardController>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: BoxDecoration(
            color: AppColors.primaryBlack.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                const SizedBox(height: 15),
                // Top Bar with Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'CLUB MEMBERSHIPS',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Exclusive travel privileges for elite members.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                Obx(() => Expanded(
                  child: controller.isLoading.value 
                    ? Stack(
                        children: [
                          PageView.builder(
                            controller: PageController(viewportFraction: 0.82),
                            itemCount: 3,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.black.withOpacity(0.5),
                                highlightColor: Colors.black.withOpacity(0.2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryYellow),
                          ),
                        ],
                      )
                    : PageView.builder(
                        controller: PageController(viewportFraction: 0.82),
                        itemCount: controller.membershipTiers.length,
                        itemBuilder: (context, index) {
                          final plan = controller.membershipTiers[index];
                          return _buildDarkPlanCard(controller, plan, index);
                        },
                      ),
                )),
                const SizedBox(height: 20),
                // Pagination indicator
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.membershipTiers.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryYellow.withOpacity(0.4),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDarkPlanCard(DashboardController controller, MembershipTier plan, int index) {
    final planColor = controller.getPlanColor(plan.name, index);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark card color
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            // Background Gradient Glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      planColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Plan Icon Header
                Container(
                  height: 100, // Increased from 60
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        planColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 50, // Increased from 30
                      color: planColor,
                    ),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plan.name ?? 'Plan',
                                style: const TextStyle(
                                  fontSize: 15, 
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: planColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                plan.adminFee != null ? 'Admin Fee: ${plan.adminFee}' : 'Admin Fee: N/A',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: planColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${plan.price}', // Removed ₹
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: planColor,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'BENEFITS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (plan.features != null)
                          ...List.generate(
                            plan.features.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: Row(
                                children: [
                                  Icon(Icons.verified_rounded, color: planColor, size: 18),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      plan.features[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Buy Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: planColor,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        shadowColor: planColor.withOpacity(0.4),
                      ),
                      onPressed: () {
                        Navigator.pop(Get.context!);
                        Get.toNamed(Routes.MEMBERSHIP_FORM, arguments: plan);
                      },
                      child: const Text(
                        'BUY NOW',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
