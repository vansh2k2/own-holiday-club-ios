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
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';

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
          decoration: const BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                          color: AppColors.primaryBlack.withOpacity(0.24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: AppColors.primaryBlack.withOpacity(0.7), size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack.withOpacity(0.1),
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
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
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
                      fontSize: 12.0,
                      color: AppColors.primaryBlack.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
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
                                baseColor: AppColors.borderGrey,
                                highlightColor: AppColors.lightGrey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
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
    final planColors = _getPlanColors(plan.name, index);

    // Get the exact features list matching the image mockup
    final cardFeatures = _getCardFeatures(plan.name, plan.features);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: planColors.bgGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: planColors.primary.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: planColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Soft translucent decorative circle in background
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: planColors.primary.withOpacity(0.10),
                ),
              ),
            ),
            
            Column(
              children: [
                // Top Border / Stripe representing the plan
                Container(
                  height: 8,
                  width: double.infinity,
                  color: planColors.primary,
                ),
                
                // Header Section (Icon + Plan Title + Subtitle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: planColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: planColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: planColors.primary,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              planColors.subtitle,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryBlack.withOpacity(0.65),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: planColors.primary.withOpacity(0.15), height: 1, thickness: 1.0),
                ),
                
                // Pricing Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (plan.name.toLowerCase().contains('privilege')) ...[
                          // Strikethrough Original Price
                          const Text(
                            '₹ 52,789',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red,
                              decorationThickness: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Pay ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryBlack,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '₹ 1',
                                      style: TextStyle(
                                        fontSize: 26.0,
                                        fontWeight: FontWeight.w900,
                                        color: planColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 11.0, color: AppColors.primaryBlack),
                                  children: [
                                    TextSpan(text: 'Admin Fee: '),
                                    TextSpan(
                                      text: '₹ 0',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2), width: 1),
                                ),
                                child: const Text(
                                  'LIMITED',
                                  style: TextStyle(
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Standard plans pricing
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                plan.name.toLowerCase().contains('memorable')
                                    ? '₹ 2,10,789'
                                    : plan.name.toLowerCase().contains('golden') || plan.name.toLowerCase().contains('gold')
                                        ? '₹ 4,20,789'
                                        : '₹ 6,30,789',
                                style: TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.w900,
                                  color: planColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 11.0, color: AppColors.primaryBlack),
                                  children: [
                                    TextSpan(text: 'Admin Fee: '),
                                    TextSpan(
                                      text: '₹ 5,789',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: planColors.primary.withOpacity(0.15), height: 1, thickness: 1.0),
                ),
                
                // Benefits List (Scrollable list inside card)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INCLUDED BENEFITS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack.withOpacity(0.4),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(
                          cardFeatures.length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: planColors.primary,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cardFeatures[i],
                                    style: const TextStyle(
                                      fontSize: 11.0,
                                      color: AppColors.primaryBlack,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
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
                
                // Filled CTA Button (Solid theme color of the card with white text)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: planColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: planColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(Get.context!);
                        Get.toNamed(Routes.MEMBERSHIP_FORM, arguments: plan);
                      },
                      child: Text(
                        ((Get.isRegistered<AccountController>() && Get.find<AccountController>().userData.value?.membership != null)
                            ? 'UPDATE NOW'
                            : 'SELECT TIER >'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 12.0,
                          color: Colors.white,
                        ),
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

  // --- Static Private Helpers for Mockup Alignment ---

  static _PlanColors _getPlanColors(String? name, int index) {
    final lowercase = name?.toLowerCase() ?? '';
    if (lowercase.contains('privilege')) {
      return _PlanColors(
        primary: const Color(0xFF1E88E5), // Sky Blue
        bgGradient: [const Color(0xFFF4FAFF), const Color(0xFFE3F2FD)], // Extremely light blue
        subtitle: "Special 5-year introductory offer for your luxury journey.",
      );
    } else if (lowercase.contains('memorable')) {
      return _PlanColors(
        primary: const Color(0xFFC27D38), // Bronze/Gold
        bgGradient: [const Color(0xFFFFFDF5), const Color(0xFFFFF9E6)], // Super soft cream/gold
        subtitle: "Create memorable vacations for a full decade.",
      );
    } else if (lowercase.contains('golden') || lowercase.contains('gold')) {
      return _PlanColors(
        primary: const Color(0xFF0F9D58), // Emerald Green
        bgGradient: [const Color(0xFFF5FBF6), const Color(0xFFE8F5E9)], // Super soft mint green
        subtitle: "Two decades of elevated luxury experiences.",
      );
    } else if (lowercase.contains('diamond')) {
      return _PlanColors(
        primary: const Color(0xFF7B1FA2), // Royal Purple
        bgGradient: [const Color(0xFFFAF6FC), const Color(0xFFF3E5F5)], // Super soft light lavender
        subtitle: "Three decades of ultimate luxury and exclusive global access.",
      );
    }
    
    // Fallback based on index
    final fallbacks = [
      _PlanColors(primary: const Color(0xFF1E88E5), bgGradient: [const Color(0xFFF4FAFF), const Color(0xFFE3F2FD)], subtitle: "Experience luxury journey."),
      _PlanColors(primary: const Color(0xFFC27D38), bgGradient: [const Color(0xFFFFFDF5), const Color(0xFFFFF9E6)], subtitle: "Vacations for a full decade."),
      _PlanColors(primary: const Color(0xFF0F9D58), bgGradient: [const Color(0xFFF5FBF6), const Color(0xFFE8F5E9)], subtitle: "Elevated luxury experiences."),
      _PlanColors(primary: const Color(0xFF7B1FA2), bgGradient: [const Color(0xFFFAF6FC), const Color(0xFFF3E5F5)], subtitle: "Ultimate luxury global access."),
    ];
    return fallbacks[index % fallbacks.length];
  }

  static List<String> _getCardFeatures(String? name, List<String> apiFeatures) {
    final lowercase = name?.toLowerCase() ?? '';
    if (lowercase.contains('privilege')) {
      return [
        "3 Nights / 4 Days for 3 Years",
        "4 Nights / 5 Days for 2 Years",
        "Valid for 5 Years",
        "Standard Concierge",
      ];
    } else if (lowercase.contains('memorable')) {
      return [
        "6 nights / 7 days for 10 years",
        "Valid for 10 Years",
        "Special Offer 2 Year Extra",
        "Transferable to Family",
        "Access to Premium Resorts",
        "Priority Booking",
      ];
    } else if (lowercase.contains('golden') || lowercase.contains('gold')) {
      return [
        "6 nights / 7 days for 20 years",
        "Valid for 20 Years",
        "Special Offer 3 Year Extra",
        "Transferable to Family",
        "All Premium Luxury Resorts",
        "Dedicated VIP Concierge",
      ];
    } else if (lowercase.contains('diamond')) {
      return [
        "6 nights / 7 days for 30 years",
        "Valid for 30 Years",
        "Special Offer 5 Years Extra",
        "Transferable to Family",
        "All Golden Benefits Included",
        "Personalized Travel Planning",
        "Access to Elite Global Resorts",
      ];
    }
    return apiFeatures;
  }
}

class _PlanColors {
  final Color primary;
  final List<Color> bgGradient;
  final String subtitle;
  _PlanColors({required this.primary, required this.bgGradient, required this.subtitle});
}
