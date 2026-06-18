import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/widgets/general_enquiry_form.dart';
import 'package:own_holiday_app/widgets/membership_bottom_sheet.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      // ── Right-side Drawer ─────────────────────────────────
      endDrawer: _buildRightDrawer(context),
      body: Builder(builder: (scaffoldCtx) {
        return Column(
          children: [
            // ─── Sticky Top Bar ──────────────────────────────
            Container(
              color: AppColors.primaryWhite,
              padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 0),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  // Own Holiday Logo
                  Transform.scale(
                    scale: 1.45,
                    child: Image.asset(
                      'assets/images/own-holiday-club-logo.png',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          'Since 2012',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile Icon → opens right drawer
                  GestureDetector(
                    onTap: () => Scaffold.of(scaffoldCtx).openEndDrawer(),
                    child: Obx(() {
                      final u = accountController.userData.value;
                      final isLoggedIn = accountController.isLoggedIn.value;
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          shape: BoxShape.circle,
                          border: isLoggedIn && u?.profileImage != null ? Border.all(color: AppColors.primaryYellow, width: 1.5) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isLoggedIn && u?.profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: u!.profileImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Icon(Icons.person_rounded, color: AppColors.primaryYellow, size: 22),
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: AppColors.primaryYellow,
                                size: 22,
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            // ─── Scrollable Content ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                // ─── Hero + Services Overlap Section ──────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Background Hero Carousel (Height 440)
                    Obx(() {
                      final slides = controller.heroSlides;
                      if (slides.isEmpty) {
                        return const SizedBox(
                          height: 440,
                          width: double.infinity,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryYellow,
                            ),
                          ),
                        );
                      }
                      return _HeroCarousel(slides: slides.toList());
                    }),

                    // 2. Foreground Content (Starts with overlap)
                    Column(
                      children: [
                        const SizedBox(height: 360),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(50, 50, 93, 0.25),
                                        offset: const Offset(0, 2),
                                        blurRadius: 5,
                                        spreadRadius: -1,
                                      ),
                                      BoxShadow(
                                        color: const Color.fromRGBO(0, 0, 0, 0.3),
                                        offset: const Offset(0, 1),
                                        blurRadius: 3,
                                        spreadRadius: -1,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Club Spotlight',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // 4 Static Quick-Access Cards in Blinkit spotlight style (Compact size, Richer colors)
                                      GridView.count(
                                        crossAxisCount: 2,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 1.22, // decreased height for smaller, sleek cards
                                        children: [
                                          _QuickAccessCard(
                                            title: 'OHC\nPrivilege',
                                            imagePath: 'assets/images/ohc_privilege.png',
                                            bgColor: const Color(0xFFFFF3CD), // Soft light pastel gold
                                            textColor: const Color(0xFF5C4300), // Dark gold/bronze
                                            onTap: () => MembershipBottomSheet.show(context),
                                          ),
                                          _QuickAccessCard(
                                            title: 'Book\nHoliday',
                                            imagePath: 'assets/images/book_holiday_3d.png',
                                            bgColor: const Color(0xFFD4EDDA), // Soft light pastel green
                                            textColor: const Color(0xFF0F472A), // Dark emerald green
                                            onTap: () {
                                              Get.bottomSheet(
                                                const GeneralEnquiryForm(),
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                              );
                                            },
                                          ),
                                          _QuickAccessCard(
                                            title: 'Plan Wedding/\nEvent',
                                            imagePath: 'assets/images/plan_event.png',
                                            bgColor: const Color(0xFFD1ECF1), // Soft light pastel blue
                                            textColor: const Color(0xFF072A52), // Dark royal blue
                                            onTap: () => Get.toNamed(Routes.SERVICES_REEL),
                                          ),
                                          _QuickAccessCard(
                                            title: 'OHC\nMembership',
                                            imagePath: 'assets/images/membership_3d.png',
                                            bgColor: const Color(0xFFF3E5F5), // Soft light pastel lavender
                                            textColor: const Color(0xFF4A148C), // Dark indigo purple
                                            onTap: () => Get.toNamed(Routes.MEMBERSHIP_INFO),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // ─── Top Destinations Horizontal Scroll ───────────
              Container(
                width: double.infinity,
                color: const Color(0xFFF5F7FA),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Top Destinations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(Routes.DESTINATIONS_REEL),
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 265,
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: 4,
                            itemBuilder: (context, i) => Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 14, bottom: 4),
                              child: Skeleton(borderRadius: 20.0),
                            ),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: (controller.destinations.length >= 5 ? 6 : controller.destinations.length + 1),
                          itemBuilder: (context, i) {
                            final bool isExploreMore = (controller.destinations.length >= 5 && i == 5) || 
                                                    (controller.destinations.length < 5 && i == controller.destinations.length);
                            
                            if (isExploreMore) {
                              return GestureDetector(
                                onTap: () => Get.toNamed(Routes.DESTINATIONS_REEL),
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 14, bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryWhite,
                                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryYellow, size: 30),
                                      SizedBox(height: 10),
                                      Text(
                                        'Explore All',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final dest = controller.destinations[i];
                            return FadeInRight(
                              delay: Duration(milliseconds: i * 80),
                              child: GestureDetector(
                                onTap: () => controller.goToDestinationDetails(dest),
                                child: Container(
                                  width: 160,
                                  height: 255,
                                  margin: const EdgeInsets.only(right: 14, bottom: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.zero,
                                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDynamicImage(
                                        dest['image'] ?? '',
                                        height: 150,
                                        width: 160,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    dest['name'] ?? dest['title'] ?? '',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                      color: AppColors.primaryBlack,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  dest['category']?.toString().toUpperCase() ?? '',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primaryYellow,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dest['tagline'] ?? dest['shortDescription'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.greyText,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryYellow,
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'BOOK NOW',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.primaryBlack,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.primaryBlack),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
            ),

            const SizedBox(height: 16),

              // ─── Banner Carousel ──────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _BannerCarousel(
                  images: [
                    'assets/images/slide1.png',
                    'assets/images/slide2.png',
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Our Services Horizontal Scroll (Blinkit-style) ─
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Our Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.SERVICES_REEL),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 188,
                child: Obx(() {
                  final svcs = controller.services;
                  if (controller.isLoading.value && svcs.isEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 5,
                      itemBuilder: (_, i) => Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        child: const Skeleton(borderRadius: 12.0),
                      ),
                    );
                  }
                  final totalCount = svcs.length + 1; // +1 for Explore All card
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: totalCount,
                    itemBuilder: (context, i) {
                      if (i == svcs.length) {
                        // Explore All Services card wrapped to match height/padding perfectly
                        return GestureDetector(
                          onTap: () => Get.toNamed(Routes.SERVICES_REEL),
                          child: Container(
                            width: 136,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGrey, width: 2),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: AppColors.borderGrey, width: 1),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.grid_view_rounded, color: AppColors.primaryYellow, size: 30),
                                  SizedBox(height: 10),
                                  Text(
                                    'Explore All\nServices',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlack,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      final svc = svcs[i];
                      return GestureDetector(
                        onTap: () => Get.toNamed(Routes.SERVICE_DETAILS, arguments: svc),
                        child: _BlinklitServiceCard(service: svc, index: i),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 28),

              // ─── Featured Experiences ─────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Text(
                  'Featured Experiences',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              SizedBox(
                height: 340,
                child: Obx(() {
                  if (controller.isLoading.value && controller.featuredExperiences.isEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20, right: 8),
                      itemCount: 2,
                      itemBuilder: (_, i) => Container(
                        width: screenWidth * 0.88,
                        margin: const EdgeInsets.only(right: 12),
                        child: Skeleton(borderRadius: 12.0),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    itemCount: controller.featuredExperiences.length,
                    itemBuilder: (_, i) =>
                        _ExperienceCard(exp: controller.featuredExperiences[i], width: screenWidth * 0.88),
                  );
                }),
              ),

              const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Right-side Drawer ─────────────────────────────────────────────────────
  Widget _buildRightDrawer(BuildContext context) {
    final accountController = Get.find<AccountController>();
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: AppColors.primaryWhite,
      child: Column(
        children: [
          // Header
          Obx(() => Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            color: AppColors.primaryBlack,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryYellow, width: 2),
                  ),
                  child: accountController.userData.value?.profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: CachedNetworkImage(
                          imageUrl: accountController.userData.value!.profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person_rounded, size: 40, color: AppColors.primaryBlack),
                ),
                const SizedBox(height: 16),
                Text(
                  accountController.isLoggedIn.value 
                    ? (accountController.userData.value?.name ?? 'Member')
                    : 'Guest User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellow,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accountController.isLoggedIn.value 
                    ? (accountController.userData.value?.mobile ?? '')
                    : 'Login to explore more',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ],
            ),
          )),
          // Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              children: [
                _DrawerItem(Icons.home_rounded, 'Home', () => Get.back()),
                _DrawerItem(Icons.card_membership_rounded, 'Membership', () {
                  Get.back();
                  final user = accountController.userData.value;
                  if (accountController.isLoggedIn.value && user?.membership?.tierId != null) {
                    Get.toNamed(Routes.MEMBER_DETAILS);
                  } else {
                    MembershipBottomSheet.show(context);
                  }
                }),
                _DrawerItem(Icons.bookmark_rounded, 'My Bookings', () {
                  Get.back();
                  if (accountController.isLoggedIn.value) {
                    Get.toNamed(Routes.MY_BOOKINGS);
                  } else {
                    Get.toNamed(Routes.MEMBER_LOGIN);
                  }
                }),
                _DrawerItem(Icons.help_outline_rounded, 'Help & FAQ', () {
                  Get.back();
                  Get.toNamed(Routes.FAQ);
                }),
                const Divider(indent: 20, endIndent: 20),
                _DrawerItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {
                  Get.back();
                  Get.toNamed(Routes.PRIVACY_POLICY);
                }),
                _DrawerItem(Icons.info_outline_rounded, 'About Us', () {
                  Get.back();
                  Get.toNamed(Routes.ABOUT_US);
                }),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => Column(
                    children: [
                      if (!accountController.isLoggedIn.value)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.primaryBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () {
                            Get.back(); // Close drawer
                            Get.toNamed(Routes.MEMBER_LOGIN);
                          },
                          child: const Text('MEMBER LOGIN',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.0)),
                        ),
                      ),
                      if (accountController.isLoggedIn.value)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.primaryBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () {
                            Get.back(); // Close drawer
                            Get.toNamed(Routes.MEMBER_DETAILS);
                          },
                          child: const Text('MY PROFILE',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.0)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlack,
                            side: const BorderSide(color: AppColors.primaryBlack),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () {
                            Get.back(); // Close drawer
                            Get.bottomSheet(
                              const GeneralEnquiryForm(),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          child: const Text('ENQUIRY',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.0)),
                        ),
                      ),
                      if (accountController.isLoggedIn.value) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              Get.back();
                              accountController.logout();
                            },
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Logout',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ],
                  )),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── Experience Card Widget ────────────────────────────────────────────────────
class _ExperienceCard extends StatefulWidget {
  final Map<String, dynamic> exp;
  final double width;
  const _ExperienceCard({required this.exp, required this.width});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.exp['gallery'] ?? []);
    if (_images.isEmpty) {
      _images = [widget.exp['image'] ?? '']; // Fallback
    }
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (_images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _currentPage = (_currentPage + 1) % _images.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            SizedBox(
              height: 340,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Only auto scroll
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return _buildDynamicImage(
                    _images[index],
                    height: 340,
                    width: double.infinity,
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'PORTFOLIO',
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exp['serviceTitle'] ?? widget.exp['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.exp['shortDescription'] ?? widget.exp['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 2,
                    ),
                    onPressed: () => Get.toNamed(Routes.GALLERY),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore More',
                             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDynamicImage(String path, {double? height, double? width}) {
  if (path.isEmpty) return const Skeleton();
  if (path.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: path,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Skeleton(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
  return Image.asset(
    path,
    height: height,
    width: width,
    fit: BoxFit.cover,
  );
}

class _HeroCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> slides;
  const _HeroCarousel({required this.slides});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.slides.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = (_currentPage + 1) % widget.slides.length;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = widget.slides.isNotEmpty ? widget.slides[_currentPage] : <String, dynamic>{};
    final title1 = currentSlide['title1'] ?? '';
    final title2 = currentSlide['title2'] ?? '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 440,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              final imageUrl = slide['image'] ?? '';
              return imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(color: Colors.black87),
                    errorWidget: (ctx, url, e) => Image.asset('assets/images/maldives_private_shore.png', fit: BoxFit.cover),
                  )
                : Image.asset(imageUrl.isEmpty ? 'assets/images/maldives_private_shore.png' : imageUrl, fit: BoxFit.cover);
            },
          ),
        ),
        // Gradient overlay — added elegant overlay for text readability
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Hero text — identical layout to original, but dynamic and matching website styles
        Positioned(
          top: 190,
          left: 20,
          right: 20,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  key: ValueKey('sub_$_currentPage'),
                  child: Transform.translate(
                    offset: const Offset(0, 20), // Shifting 'For' downwards
                    child: Text(
                      _stripHtml(currentSlide['subtitle'] ?? 'Welcome to Luxury'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.greatVibes(
                        color: _extractColor(currentSlide['subtitle'] ?? '') ?? const Color(0xFFF59E0B),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInLeft(
                  key: ValueKey('title_$_currentPage'),
                  delay: const Duration(milliseconds: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (title1.isNotEmpty)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _stripHtml(title1).toUpperCase().replaceAll('STAY & CELEBRATION', 'STAY\u00A0&\u00A0CELEBRATION'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: _extractColor(title1) ?? Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                      if (title2.isNotEmpty)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _stripHtml(title2).toUpperCase().replaceAll('STAY & CELEBRATION', 'STAY\u00A0&\u00A0CELEBRATION'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: _extractColor(title2) ?? const Color(0xFFF59E0B),
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeInLeft(
                  key: ValueKey('desc_$_currentPage'),
                  delay: const Duration(milliseconds: 250),
                  child: Text(
                    _stripHtml(currentSlide['description'] ?? ''),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Slide indicator dots
        if (widget.slides.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _currentPage == i ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppColors.primaryYellow : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
      ],
    );
  }

  String _stripHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  Color? _extractColor(String htmlString) {
    if (htmlString.isEmpty) return null;
    final match = RegExp(r'color\s*[:=]\s*["\u0027]?(#[0-9a-fA-F]{3,8}|rgb(?:a)?\([^)]+\))').firstMatch(htmlString);
    if (match != null) {
      final colorStr = match.group(1)!;
      if (colorStr.startsWith('#')) {
        String hex = colorStr.replaceAll('#', '');
        if (hex.length == 3) {
          hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
        }
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        try {
          return Color(int.parse(hex, radix: 16));
        } catch (_) {
          return null;
        }
      } else if (colorStr.startsWith('rgb')) {
        final rgbMatch = RegExp(r'rgb(?:a)?\((\d+),\s*(\d+),\s*(\d+)').firstMatch(colorStr);
        if (rgbMatch != null) {
          return Color.fromRGBO(
            int.parse(rgbMatch.group(1)!),
            int.parse(rgbMatch.group(2)!),
            int.parse(rgbMatch.group(3)!),
            1.0,
          );
        }
      }
    }
    return null;
  }
}

// ── Drawer Item ────────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: AppColors.primaryBlack, size: 22),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primaryBlack)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: AppColors.greyText),
      onTap: onTap,
    );
  }
}

// ── Banner Carousel Widget ──────────────────────────────────────────────────
class _BannerCarousel extends StatefulWidget {
  final List<String> images;
  const _BannerCarousel({required this.images});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _pageCtrl = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || widget.images.length <= 1) return;
      final next = (_currentPage + 1) % widget.images.length;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210, // Increased height
          width: double.infinity,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: GestureDetector(
                  onTap: () => MembershipBottomSheet.show(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentPage == i ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentPage == i ? AppColors.primaryYellow : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick Access Card ─────────────────────────────────────────────────────────
class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;
  const _QuickAccessCard({
    required this.title,
    required this.imagePath,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(50, 50, 93, 0.25),
              offset: Offset(0, 2),
              blurRadius: 5,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: -1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Title text at Top-Left (shorter size)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              // High-quality 3D render illustration positioned at the Bottom-Right Corner without any spacing/padding
              Positioned(
                bottom: 0,
                right: 0,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Blinkit-style Service Card (horizontal scroll) ────────────────────────────
class _BlinklitServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final int index;
  const _BlinklitServiceCard({required this.service, required this.index});

  @override
  Widget build(BuildContext context) {
    // Curated Harmonious Bold/Dark Accent Colors matching Blinkit's Featured this week borders
    const borderColor = Color(0xFFD4AF37); // Luxury Gold

    return Container(
      width: 136,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(4), // thoda sa card se space/padding
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2), // outer bold dynamic border
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(50, 50, 93, 0.25),
              offset: Offset(0, 2),
              blurRadius: 5,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width image fills top of card
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: _buildDynamicImage(
                  service['image'] ?? '',
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
            // Title label below image
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Text(
                service['title'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlack,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
