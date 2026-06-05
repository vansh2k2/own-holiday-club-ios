import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../controller/membership_controller.dart';

class MembershipView extends GetView<MembershipController> {
  const MembershipView({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: Stack(
        children: [
          // ── Yellow header ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: top + 100,
            child: Container(color: AppColors.primaryYellow),
          ),

          // ── App bar ────────────────────────────────────────────
          Positioned(
            top: top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Membership',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.normal,
                    color: AppColors.primaryBlack,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Current: Gold',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White scrollable body (overlaps header) ────────────
          Positioned(
            top: top + 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                child: Column(
                  children: [
                    // ── Hero banner ──────────────────────────────
                    FadeInDown(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlack,
                              AppColors.greyText,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.primaryYellow,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gold Member',
                                      style: TextStyle(
                                        color: AppColors.primaryYellow,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    Text(
                                      'Valid until Dec 2025',
                                      style: TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Upgrade to Platinum for more benefits',
                              style: TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: 0.6,
                                minHeight: 8,
                                backgroundColor:
                                    AppColors.primaryWhite.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.primaryYellow),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '3 trips to Platinum',
                                  style: TextStyle(
                                    color: AppColors.primaryWhite
                                        .withOpacity(0.6),
                                    fontSize: 12.0,
                                  ),
                                ),
                                const Text(
                                  '60%',
                                  style: TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose a Plan',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plans
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: AppColors.primaryBlack),
                          ),
                        );
                      }
                      
                      if (controller.tiers.isEmpty) {
                        return const Center(
                          child: Text('No membership plans available.'),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.tiers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final tier = controller.tiers[index];
                          // Simple mapping for demo colors/icons if not provided by backend
                          Color iconColor;
                          IconData icon;
                          
                          if (tier.name.toLowerCase().contains('silver')) {
                            iconColor = const Color(0xFF90A4AE);
                            icon = Icons.workspace_premium_rounded;
                          } else if (tier.name.toLowerCase().contains('gold')) {
                            iconColor = AppColors.primaryYellow;
                            icon = Icons.star_rounded;
                          } else if (tier.name.toLowerCase().contains('platinum')) {
                            iconColor = const Color(0xFF64B5F6);
                            icon = Icons.diamond_rounded;
                          } else {
                            iconColor = AppColors.primaryBlack;
                            icon = Icons.card_membership_rounded;
                          }

                          return _PlanCard(
                            index: index,
                            title: tier.name,
                            price: tier.price,
                            adminFee: tier.adminFee,
                            tagline: tier.description ?? 'Membership plan',
                            iconColor: iconColor,
                            icon: icon,
                            features: tier.features,
                            isActive: false,
                            onPressed: () {
                              Get.toNamed('/membership-form', arguments: tier);
                            },
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan Card Widget ──────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final int index;
  final String title;
  final String price;
  final String? adminFee;
  final String tagline;
  final Color iconColor;
  final IconData icon;
  final List<String> features;
  final bool isActive;
  final VoidCallback onPressed;

  const _PlanCard({
    required this.index,
    required this.title,
    required this.price,
    this.adminFee,
    required this.tagline,
    required this.iconColor,
    required this.icon,
    required this.features,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 120),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(20),
              border: isActive
                  ? Border.all(color: AppColors.primaryYellow, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isActive) const SizedBox(height: 10),
                // Header row — icon + title/tagline on left, price on right ONLY for card 0
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.normal)),
                          Text(tagline,
                              style: const TextStyle(
                                  fontSize: 12.0, color: AppColors.greyText)),
                        ],
                      ),
                    ),
                    // Price shown on right ONLY for index == 0 (OHC Privilege)
                    if (index == 0)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                                color: isActive
                                    ? AppColors.primaryBlack
                                    : iconColor,
                              ),
                            ),
                            const TextSpan(
                              text: '/yr',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // For cards other than OHC Privilege: price + adminFee left-aligned below header
                if (index != 0) ...[
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: price,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            color: isActive ? AppColors.primaryBlack : iconColor,
                          ),
                        ),
                        const TextSpan(
                          text: '/yr',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (adminFee != null && adminFee!.isNotEmpty)
                    Text(
                      'Admin Fee: $adminFee',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.greyText,
                      ),
                    ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderGrey),
                const SizedBox(height: 14),

                // Features
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded,
                              size: 12, color: iconColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(
                                  fontSize: 12.0,
                                  color: AppColors.primaryBlack)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? AppColors.primaryYellow
                          : AppColors.primaryBlack,
                      foregroundColor: isActive
                          ? AppColors.primaryBlack
                          : AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10), // Decreased from 14
                      elevation: 0,
                    ),
                    onPressed: onPressed,
                    child: Text(
                      isActive ? 'Current Plan' : 'Get $title',
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 12.0), // Decreased from 14
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Positioned(
              top: -12,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✦ Current Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
