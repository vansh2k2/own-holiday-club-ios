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
  HomeView({super.key});

  final ScrollController _servicesScrollController = ScrollController();

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

              Obx(() {
                final destList = controller.destinations.toList();
                final isLoading = controller.isLoading.value;
                return TopDestinationsSection(
                  destinations: destList.map((d) => Destination(
                    name: d['name'] ?? d['title'] ?? '',
                    image: d['image'] ?? '',
                    rawData: d,
                  )).toList(),
                  isLoading: isLoading && destList.isEmpty,
                  onViewAll: () => Get.toNamed(Routes.DESTINATIONS_REEL),
                  onDestinationTap: (dest) {
                    if (dest.rawData != null) {
                      controller.goToDestinationDetails(dest.rawData!);
                    }
                  },
                );
              }),

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
              Obx(() {
                final svcs = controller.services;
                if (controller.isLoading.value && svcs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: 4,
                      itemBuilder: (_, i) => const Skeleton(borderRadius: 16.0),
                    ),
                  );
                }

                if (svcs.length <= 4) {
                  // No gap on the right, no arrows, vertical grid
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: svcs.length,
                      itemBuilder: (context, i) {
                        final svc = svcs[i];
                        return _AnimatedVisibleCard(
                          index: i,
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.SERVICE_DETAILS, arguments: svc),
                            child: _BlinklitServiceCard(service: svc, index: i),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  // More than 4 cards: horizontal scroll, arrows, partial card view
                  return Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: GridView.builder(
                          controller: _servicesScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0, 
                          ),
                          itemCount: svcs.length,
                          itemBuilder: (context, i) {
                            final svc = svcs[i];
                            return _AnimatedVisibleCard(
                              index: i,
                              child: GestureDetector(
                                onTap: () => Get.toNamed(Routes.SERVICE_DETAILS, arguments: svc),
                                child: _BlinklitServiceCard(service: svc, index: i),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ── Next & Previous Arrows ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                final offset = _servicesScrollController.offset;
                                final newOffset = offset - 150.0;
                                _servicesScrollController.animateTo(
                                  newOffset < 0 ? 0 : newOffset,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primaryBlack),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                final offset = _servicesScrollController.offset;
                                final maxScroll = _servicesScrollController.position.maxScrollExtent;
                                final newOffset = offset + 150.0;
                                _servicesScrollController.animateTo(
                                  newOffset > maxScroll ? maxScroll : newOffset,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }),

              const SizedBox(height: 28),
              
              // ─── Trending Stories ──────────────────────────────
              Obx(() => _TrendingStoriesSection(stories: controller.stories.toList())),

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
              Obx(() {
                return _FeaturedExperiencesLayout(
                  experiences: controller.featuredExperiences,
                  isLoading: controller.isLoading.value,
                );
              }),

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
    final String title = service['title'] ?? '';
    final String firstLetter = title.isNotEmpty ? title[0].toUpperCase() : 'S';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            _buildDynamicImage(
              service['image'] ?? '',
              height: double.infinity,
              width: double.infinity,
            ),
            // Dark Gradient Overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Top Left Logo Placeholder
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Left Text
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated Visible Card (Scroll Triggered) ──────────────────────────────
class _AnimatedVisibleCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedVisibleCard({required this.child, required this.index});

  @override
  State<_AnimatedVisibleCard> createState() => _AnimatedVisibleCardState();
}

class _AnimatedVisibleCardState extends State<_AnimatedVisibleCard> {
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      _checkVisibility();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkVisibility() {
    if (_isVisible || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final position = renderObject.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      // Trigger only when it comes well into the screen (100px above bottom edge)
      if (position.dy < screenHeight - 100) { 
        setState(() {
          _isVisible = true;
        });
        _timer?.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return Opacity(opacity: 0.0, child: widget.child);
    }
    
    Widget animated;
    switch (widget.index % 4) {
      case 0:
        animated = SlideInLeft(duration: const Duration(milliseconds: 700), child: widget.child);
        break;
      case 1:
        animated = SlideInRight(duration: const Duration(milliseconds: 700), child: widget.child);
        break;
      case 2:
        animated = SlideInUp(duration: const Duration(milliseconds: 700), child: widget.child);
        break;
      case 3:
      default:
        animated = ZoomIn(duration: const Duration(milliseconds: 700), child: widget.child);
        break;
    }
    return animated;
  }
}

// ── Custom Masonry Layout for Featured Experiences ──────────────────────────
class _FeaturedExperiencesLayout extends StatelessWidget {
  final List<dynamic> experiences;
  final bool isLoading;

  const _FeaturedExperiencesLayout({
    required this.experiences,
    required this.isLoading,
  });

  Widget _buildItem(int index, {double? width, double? height, bool isCircle = false}) {
    if (isLoading || index >= experiences.length) {
      if (isCircle) {
        return Container(
          width: width, height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Skeleton(borderRadius: 100),
        );
      }
      return Skeleton(width: width, height: height, borderRadius: 8.0);
    }

    final exp = experiences[index];
    final title = exp['title'] ?? exp['serviceTitle'] ?? '';
    final imageUrl = exp['image'] ?? exp['imageUrl'] ?? '';

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: (context, url) => Skeleton(width: width, height: height, borderRadius: isCircle ? 100 : 8.0),
      errorWidget: (context, url, error) => Container(color: Colors.grey.shade300, width: width, height: height),
    );

    if (isCircle) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipOval(child: imageWidget),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(width: width, height: height, child: imageWidget),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top Row (2 images)
          Row(
            children: [
              Expanded(child: SizedBox(height: 110, child: _buildItem(0))),
              const SizedBox(width: 8),
              Expanded(child: SizedBox(height: 110, child: _buildItem(1))),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom Area
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left tall image (takes roughly 40% width)
                Expanded(
                  flex: 40,
                  child: _buildItem(2, height: double.infinity),
                ),
                const SizedBox(width: 8),
                // Right grid area (takes roughly 60% width)
                Expanded(
                  flex: 60,
                  child: AspectRatio(
                    aspectRatio: 1.0, // Ensures the right container is a perfect square, making the 4 images squares too
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(child: _buildItem(3)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildItem(4)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(child: _buildItem(5)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildItem(6)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Center overlapping circle
                        Center(
                          child: _buildItem(7, width: 80, height: 80, isCircle: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // View Full Gallery Button
          Container(
            width: double.infinity,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(23),
                onTap: () => Get.toNamed('/gallery'),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'View Full Gallery',
                        style: TextStyle(
                          color: AppColors.primaryBlack,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryBlack, size: 18),
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

// ── Trending Stories Section ────────────────────────────────────────────────
class _TrendingStoriesSection extends StatelessWidget {
  final List<dynamic> stories;
  
  const _TrendingStoriesSection({required this.stories});

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trending Shorts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                const Text(
                  'Powered By ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.play_circle_fill, color: Colors.red.shade600, size: 14),
                const SizedBox(width: 2),
                const Text(
                  'Shorts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlack,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return FadeInRight(
                delay: Duration(milliseconds: 300 + (index * 100)),
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Container(
                      width: 135,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: story['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Skeleton(),
                              errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
                            ),
                            // Dark gradient at bottom
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              height: 80,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                            // Views chip
                            Positioned(
                              top: 8, left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      story['views'] ?? '',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Title
                            Positioned(
                              bottom: 12, left: 10, right: 10,
                              child: Text(
                                story['title'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Author info
                    SizedBox(
                      width: 135,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundImage: CachedNetworkImageProvider(story['authorImageUrl'] ?? ''),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              story['author'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ],
    );
  }
}

// ─── Destination Model ─────────────────────────────────────────────────────────
class Destination {
  final String name;
  final String image;
  final Map<String, dynamic>? rawData;
  const Destination({required this.name, required this.image, this.rawData});
}

// ─── Top Destinations Section Widget ──────────────────────────────────────────
class TopDestinationsSection extends StatelessWidget {
  final List<Destination> destinations;
  final bool isLoading;
  final VoidCallback? onViewAll;
  final void Function(Destination dest)? onDestinationTap;

  const TopDestinationsSection({
    super.key,
    required this.destinations,
    this.isLoading = false,
    this.onViewAll,
    this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF9F0),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Decorated Title ──
          _buildTitle(),
          const SizedBox(height: 6),

          // ── Subtitle ──
          Text(
            'Discover the most unique destinations curated just for you!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // ── Cards Row ──
          SizedBox(
            height: 168,
            child: isLoading ? _buildSkeletonRow() : _buildCardsRow(),
          ),

          // ── View All ──
          _buildViewAll(),
        ],
      ),
    );
  }

  // ── Title Row ──────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 18, height: 1.5, color: AppColors.primaryYellow),
        const SizedBox(width: 6),
        const Icon(Icons.auto_awesome, size: 11, color: AppColors.primaryYellow),
        const SizedBox(width: 8),
        Text(
          'TOP DESTINATIONS',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.auto_awesome, size: 11, color: AppColors.primaryYellow),
        const SizedBox(width: 6),
        Container(width: 18, height: 1.5, color: AppColors.primaryYellow),
      ],
    );
  }

  // ── Skeleton Loading Row ───────────────────────────────────────────────────
  Widget _buildSkeletonRow() {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        );
      }),
    );
  }

  // ── Cards Horizontal List ──────────────────────────────────────────────────
  Widget _buildCardsRow() {
    final int maxVisible = destinations.length > 5 ? 5 : destinations.length;
    final bool showExplore = true;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: maxVisible + (showExplore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == maxVisible) return _buildExploreCard();
        final dest = destinations[i];
        return FadeInRight(
          delay: Duration(milliseconds: i * 80),
          child: _buildDestCard(dest, i),
        );
      },
    );
  }

  // ── Single Destination Card ────────────────────────────────────────────────
  Widget _buildDestCard(Destination dest, int index) {
    return GestureDetector(
      onTap: () => onDestinationTap?.call(dest),
      child: Container(
        width: 118,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image ──
              _buildImage(dest.image),

              // ── Dark Gradient Overlay ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),

              // ── Destination Name ──
              Positioned(
                bottom: 10,
                left: 10,
                right: 6,
                child: Text(
                  dest.name,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image Builder ──────────────────────────────────────
  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) => _imageFallback(),
      );
    }
    if (url.isNotEmpty) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 32),
    );
  }

  // ── Explore All Card ───────────────────────────────────────────────────────
  Widget _buildExploreCard() {
    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryYellow,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              'Explore\nAll',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── View All Row ───────────────────────────────────────────────────────────
  Widget _buildViewAll() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: onViewAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1565C0), // AppColors.viewAllBlue mapping
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_circle_right_outlined,
                size: 18,
                color: Color(0xFF1565C0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


