import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/widgets/membership_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MembershipInfoView extends StatefulWidget {
  const MembershipInfoView({super.key});

  @override
  State<MembershipInfoView> createState() => _MembershipInfoViewState();
}

class _MembershipInfoViewState extends State<MembershipInfoView> {
  String? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _fetchHeroData();
  }

  Future<void> _fetchHeroData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ownholidayclub.com/api/hero-images/page/Membership'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _backgroundImage = data['data']['backgroundImage'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching membership hero: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bannerUrl = _backgroundImage ??
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80';

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Stack(
        children: [
          // ── Main scroll ──────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ═══════════════════════════════════════════════════
                //  Hero Image + Overlapping Card  (same as home page)
                // ═══════════════════════════════════════════════════
                Stack(
                  clipBehavior: Clip.none,
                  children: [

                    // ── 1. Full-screen hero image (440 px tall) ────
                    SizedBox(
                      height: 440,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: bannerUrl.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: bannerUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.black87),
                                    errorWidget: (context, url, error) =>
                                        Container(color: const Color(0xFF1A1A2E)),
                                  )
                                : Image.asset(bannerUrl, fit: BoxFit.cover),
                          ),
                          // gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.25),
                                    Colors.black.withOpacity(0.60),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── 2. Overlapping white card column ──────────
                    //    Starts at y=360 (same ratio as home page),
                    //    so the card overlaps the bottom 80px of image.
                    Column(
                      children: [
                        const SizedBox(height: 360),

                        // Signature Thought card — light yellow with subtle shadow
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                // rgba(0, 0, 0, 0.02) 0px 1px 3px 0px
                                BoxShadow(
                                  color: const Color(0x05000000),
                                  blurRadius: 3,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 1),
                                ),
                                // rgba(27, 31, 35, 0.15) 0px 0px 0px 1px
                                BoxShadow(
                                  color: const Color(0x261B1F23),
                                  blurRadius: 0,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(22),
                            child: _buildQuoteContent(),
                          ),
                        ),

                        // ── White body below the card ──────────────
                        Container(
                          color: AppColors.primaryWhite,
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                          child: _buildBodyContent(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Floating back button ─────────────────────────────────
          Positioned(
            top: topPad + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.90),
              radius: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryBlack, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // ── Floating CTA button ──────────────────────────────────
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlack.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => MembershipBottomSheet.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EXPLORE MEMBERSHIPS',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quote content inside the overlapping card ──────────────────
  Widget _buildQuoteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SIGNATURE THOUGHT',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: const Color(0xFFB45309),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Main italic quote
        Text(
          '"Babumoshai zindagi badi honi chahiye, lambi nahi..."',
          style: GoogleFonts.playfairDisplay(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF1E293B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),

        // Amber divider
        Container(
          width: 44, height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Colors.transparent,
              Color(0xFFF59E0B),
              Colors.transparent,
            ]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          '"The less stress, the more life" — this is exactly what we believe in. We offer our services to each and every event which matters to you the most because you matter to us the most. From planning your Holiday vacays to Weddings, Small Parties to Big corporate meetings - Own Holiday Club is just a call away to lend the best of our services.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF64748B),
            height: 1.65,
          ),
        ),
      ],
    );
  }

  // ── Body text below the overlapping card ───────────────────────
  Widget _buildBodyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To add some extra happiness, fun and adventure and to get you a break from your hustle and bustle of daily routine, we have come up with some impeccable, exquisite membership offers for you.',
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: const Color(0xFF64748B),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'You choose the best for you and we will offer the best of us. Yes, you could join any of the following Membership programs, starting from 5 years of duration to that of 35 years and you are all set to go for it. And to add some bling to your happiness, we also add your spouse along with two of your children (below 10 years) to our membership offers.',
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: const Color(0xFF64748B),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 20),

        // Note box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            'Note: The membership offer applies on "Member + Spouse + 2 kids (below 10 years of age)"',
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
        const SizedBox(height: 28),

        Text(
          "Don't worry about the accessibility!",
          style: GoogleFonts.dmSans(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),

        Text(
          "Domestic or International, tell us your plan. For your surprise, these Memberships are accessible to every one of your favorite destinations. It's our responsibility to make your trip the most memorable one. We will take you to the best resorts and execute the best events that you would always keep in your good memories. We promise to fill your and your loved ones' special moments with the amazing, venturesome memories to cherish for a lifetime.",
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: const Color(0xFF64748B),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),

        // Dark promise banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.favorite_rounded,
                    color: Color(0xFFF59E0B), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Pay once and get ready to have a carefree, stress-free holiday at the best resorts and destinations for many more years ahead — without any price hike.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.92),
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
