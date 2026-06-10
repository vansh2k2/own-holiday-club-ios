import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:own_holiday_app/utils/app_colors.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Transparent App Bar overlaying the banner image
          SliverAppBar(
            expandedHeight: 240.0,
            floating: false,
            pinned: true,
            stretch: true,
            leading: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            backgroundColor: AppColors.primaryBlack,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=90',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.primaryBlack),
                    errorWidget: (context, url, error) => Container(color: AppColors.primaryBlack),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'ABOUT US.',
                          style: GoogleFonts.poppins(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Discover our heritage and the legacy of hospitality we bring to every journey.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- The Origin Section ---
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 2,
                        color: const Color(0xFFC8102E),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'THE ORIGIN',
                        style: GoogleFonts.poppins(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC8102E),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Redefining Hospitality.',
                    style: GoogleFonts.poppins(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D1321),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Own Holiday Club  ·  Since. 2012',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chips Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('20+ years experience'),
                      _buildChip('Hotels & Resorts'),
                      _buildChip('Pan India'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description Text
                  Text(
                    'A world of your OWN experiences. A taste of authenticity. A touch of comfort that feels oh! So familiar. Welcome to OWN HOLIDAY CLUB your home away from home.',
                    style: GoogleFonts.poppins(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D1321),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Own Holiday Club is a fast growing and well known company in hospitality sector in India. We have 20 year of experience in promoting Hotels, Clubs, Resorts all over India.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF495057),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Own Holiday Club started in 2012, originally known as Rigel Hospitality Services Pvt Ltd. Specialized in creating Vacation experiences, we customize events and holidays to fit your needs and taste.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF495057),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'With 20 years of experience, Own Holiday Club is a proven name in the holidays and Vacation industry today. While painting India as never envisioned, we were able to create our mark as a Vacation and event management expert with over 10,000 privilege members. We strive to provide only the best of imagination for our guests from all over the world. We are known for providing an excellent standard of customer service with highly experienced and a professional team of staff.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF495057),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Overlapping Images Section (Similar to website right-side layout)
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Main Wide Image (Top-Right aligned)
                        Positioned(
                          top: 0,
                          right: 0,
                          left: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Overlapping Smaller Image (Bottom-Left aligned with shadow border)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80',
                                width: 180,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('70,000+', 'Members'),
                        _buildDivider(),
                        _buildStat('12+', 'Years Active'),
                        _buildDivider(),
                        _buildStat('500+', 'Properties'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Our Vision, Mission & Promise Section ---
                  _buildPillarCard(
                    'An Extended Family',
                    'Our Vision',
                    'We plan to create not a clientele but an extended family by providing unforgettable experiences with nonmonetary value. To ensure the same, we have professionals who plan and execute everything flawlessly while keeping in mind your needs and pocket.',
                    Icons.people_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildPillarCard(
                    'Anecdotes in Your Life',
                    'Our Mission',
                    'We aim to create experiences that become anecdotes in your life. Keeping an eye for details and personalization, we strive to provide satiating experiences for each one of you, across the globe.',
                    Icons.track_changes_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildPillarCard(
                    'Dreams to Reality',
                    'Our Promise',
                    'We offer innovative and customized events planned extensively to leave a beautiful imprint on your mind. Focused on creating memorable experiences, we ensure that your dream transforms into reality. Whether you have a destination or theme in mind or not, our experts and selection of picturesque destinations will surely provide you with an experience of a lifetime!',
                    Icons.card_giftcard_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF495057),
        ),
      ),
    );
  }

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryYellow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF495057),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildPillarCard(String sub, String title, String body, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryYellow, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC8102E),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1321),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 12.0,
              color: const Color(0xFF495057),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
