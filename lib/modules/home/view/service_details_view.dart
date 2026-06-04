import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:own_holiday_app/data/repository/auth_repo.dart';
import 'dart:async';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServiceDetailsView extends StatefulWidget {
  const ServiceDetailsView({super.key});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  final HomeController controller = Get.find<HomeController>();
  late Map<String, dynamic> service;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments ?? {};
    
    // Try to find full details from the controller's cache
    final fullDetail = controller.allServicesWithGallery.firstWhere(
      (s) => s['serviceTitle'] == args['title'] || s['slug'] == args['title'].toString().toLowerCase().replaceAll(' ', '-'),
      orElse: () => <String, dynamic>{},
    );

    // Merge: args (card info) + fullDetail (gallery, fullDesc, etc.)
    service = {...args, ...fullDetail};
    
    _startAutoScroll();
  }

  void _startAutoScroll() {
    final images = _getImages();
    if (images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          int next = _currentPage + 1;
          if (next >= images.length) next = 0;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
    final stats = service['quickStats'] ?? {};
    final hasStats = stats.isNotEmpty && 
        (stats['bestTime']?.toString().trim().isNotEmpty == true ||
         stats['temp']?.toString().trim().isNotEmpty == true ||
         stats['flight']?.toString().trim().isNotEmpty == true ||
         stats['timezone']?.toString().trim().isNotEmpty == true);

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(images),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['title'] ?? 'Service Detail',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 16, color: AppColors.primaryYellow),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premium Offering',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13.0,
                                        color: AppColors.greyText,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hasStats) ...[
                        const SizedBox(height: 24),
                        _buildStatsRow(),
                      ],
                      const SizedBox(height: 28),
                      Text(
                        'Service Overview',
                        style: GoogleFonts.montserrat(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stripHtml(service['fullDescription'] ?? service['description'] ?? 'Discover our premium service offerings designed for your ultimate comfort and luxury.'),
                        style: GoogleFonts.montserrat(
                          fontSize: 13.0,
                          color: AppColors.primaryBlack,
                          height: 1.6,
                        ),
                      ),
                      if (service['highlights'] != null && service['highlights'] is List && (service['highlights'] as List).isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          "What's Included",
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (var hl in (service['highlights'] as List))
                          if (hl.toString().trim().isNotEmpty)
                            _buildHighlightItem(Icons.check_circle_outline_rounded, hl.toString(), 'Included Benefit'),
                      ],
                      if (service['properties'] != null && service['properties'] is List && (service['properties'] as List).isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          'Recommended Stays',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (service['properties'] as List).length,
                            itemBuilder: (context, idx) {
                              final prop = service['properties'][idx];
                              return _buildPropertyCard(prop);
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(),
          _buildBackButton(),
        ],
      ),
    );
  }

  List<String> _getImages() {
    List<String> imgs = [];
    if (service['image'] != null && service['image'].toString().isNotEmpty) {
      imgs.add(service['image']);
    }
    if (service['gallery'] != null && service['gallery'] is List) {
      for (var item in service['gallery']) {
        if (item != null && item.toString().isNotEmpty) {
          imgs.add(item.toString());
        }
      }
    }
    return imgs.isEmpty ? ['assets/images/santorini_experience.png'] : imgs;
  }

  Widget _buildHeader(List<String> images) {
    return SliverToBoxAdapter(
      child: Container(
        height: 350,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (v) => setState(() => _currentPage = v),
              itemCount: images.length,
              itemBuilder: (context, i) => _buildImage(images[i]),
            ),
            if (images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primaryYellow : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return const Skeleton();
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Skeleton(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    try {
      return Image.asset(path, fit: BoxFit.cover);
    } catch (e) {
      return const Skeleton();
    }
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlack.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _showServiceInquiryForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: AppColors.primaryBlack,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ENQUIRE NOW',
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
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryBlack, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  void _showServiceInquiryForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceInquiryFormSheet(service: service),
    );
  }

  Widget _buildStatsRow() {
    final stats = service['quickStats'] ?? {};
    final List<Map<String, dynamic>> items = [];

    if (stats['bestTime'] != null && stats['bestTime'].toString().trim().isNotEmpty) {
      items.add({
        'icon': Icons.access_time_rounded,
        'label': 'Timing',
        'value': stats['bestTime'].toString(),
        'iconColor': const Color(0xFFFF9800),
      });
    }

    if (stats['temp'] != null && stats['temp'].toString().trim().isNotEmpty) {
      items.add({
        'icon': Icons.payments_outlined,
        'label': 'Cost/Price',
        'value': stats['temp'].toString(),
        'iconColor': const Color(0xFFE91E63),
      });
    }

    if (stats['flight'] != null && stats['flight'].toString().trim().isNotEmpty) {
      items.add({
        'icon': Icons.hourglass_empty_rounded,
        'label': 'Duration',
        'value': stats['flight'].toString(),
        'iconColor': const Color(0xFF00B0FF),
      });
    }

    if (stats['timezone'] != null && stats['timezone'].toString().trim().isNotEmpty) {
      items.add({
        'icon': Icons.map_rounded,
        'label': 'Region',
        'value': stats['timezone'].toString(),
        'iconColor': const Color(0xFF4CAF50),
      });
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (items.isNotEmpty)
                Expanded(child: _buildGridItem(items[0])),
              if (items.length > 1) ...[
                Container(width: 1, height: 64, color: Colors.grey.shade200),
                Expanded(child: _buildGridItem(items[1])),
              ] else if (items.isNotEmpty)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (items.length > 2) ...[
            Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
            Row(
              children: [
                Expanded(child: _buildGridItem(items[2])),
                Container(width: 1, height: 64, color: Colors.grey.shade200),
                Expanded(
                  child: items.length > 3 
                      ? _buildGridItem(items[3]) 
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (item['iconColor'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, size: 18, color: item['iconColor'] as Color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['label'] as String,
                  style: GoogleFonts.montserrat(
                    fontSize: 10.0,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['value'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 11.0,
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFFFB300)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 11.0,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(dynamic prop) {
    if (prop == null || prop is! Map) return const SizedBox.shrink();
    final name = prop['name'] ?? 'Luxury Stay';
    final type = prop['type'] ?? 'Hotel';
    final rating = prop['rating'] ?? '5.0';
    final image = prop['image'] ?? '';

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: image.isNotEmpty
                  ? (image.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => const Skeleton(),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.hotel_rounded, color: AppColors.greyText),
                          ),
                        )
                      : Image.asset(image, fit: BoxFit.cover, width: double.infinity))
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.hotel_rounded, color: AppColors.greyText),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.primaryYellow),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: GoogleFonts.montserrat(
                    fontSize: 11.0,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 50.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 105);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ServiceInquiryFormSheet extends StatefulWidget {
  final Map<String, dynamic> service;
  const ServiceInquiryFormSheet({super.key, required this.service});

  @override
  State<ServiceInquiryFormSheet> createState() => _ServiceInquiryFormSheetState();
}

class _ServiceInquiryFormSheetState extends State<ServiceInquiryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 2;
  int _kids = 0;
  bool _isSubmitting = false;

  final AuthRepo _authRepo = Get.find<AuthRepo>();
  bool _isMobileOtpSent = false;
  bool _isMobileVerified = false;
  bool _isSendingMobileOtp = false;
  bool _isVerifyingMobileOtp = false;
  String? _tempMobile;

  bool _isEmailOtpSent = false;
  bool _isEmailVerified = false;
  bool _isSendingEmailOtp = false;
  bool _isVerifyingEmailOtp = false;
  bool _isEmailSkipped = false;
  String? _tempEmail;

  String _travelType = 'Holiday';
  String _budget = '';

  final List<String> _travelTypes = ['Holiday', 'Events', 'Wedding', 'Outing'];

  final Map<String, List<Map<String, String>>> _budgetOptions = {
    'Holiday': [
      {'label': 'Below 5,000 (per day)', 'value': 'Below 5000'},
      {'label': '5,000 - 7,000 (per day)', 'value': '5000 - 7000'},
      {'label': '7,000 - 10,000 (per day)', 'value': '7000 - 10000'},
      {'label': 'Above 10,000 (per day)', 'value': 'Above 10000'},
    ],
    'Events': [
      {'label': 'Below 1,000 (per person)', 'value': 'Below 1000'},
      {'label': '1,000 - 2,000 (per person)', 'value': '1000 - 2000'},
      {'label': '2,000 - 3,000 (per person)', 'value': '2000 - 3000'},
      {'label': 'Above 3,000 (per person)', 'value': 'Above 3000'},
    ],
    'Wedding': [
      {'label': 'Below 1,500 (per person)', 'value': 'Below 1500'},
      {'label': '1,500 - 2,500 (per person)', 'value': '1500 - 2500'},
      {'label': '2,500 - 3,500 (per person)', 'value': '2500 - 3500'},
      {'label': 'Above 3,500 (per person)', 'value': 'Above 3500'},
    ],
    'Outing': [
      {'label': 'Below 500 (per person)', 'value': 'Below 500'},
      {'label': '1,000 - 2,000 (per person)', 'value': '1000 - 2000'},
      {'label': '3,000 - 5,000 (per person)', 'value': '3000 - 5000'},
      {'label': 'Above 5,000 (per person)', 'value': 'Above 5000'},
    ],
  };

  Future<void> _sendMobileOtp() async {
    final mobile = _phoneCtrl.text;
    if (mobile.length != 10) {
      Get.snackbar('Error', 'Please enter a valid 10-digit mobile number.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    setState(() => _isSendingMobileOtp = true);
    try {
      final response = await _authRepo.sendMobileOtp(mobile);
      if (response.statusCode == 200) {
        setState(() {
          _tempMobile = mobile;
          _isMobileOtpSent = true;
          _phoneCtrl.clear();
        });
        Get.snackbar('Success', 'OTP sent to mobile number.',
            backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to send OTP.',
            backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
    } finally {
      setState(() => _isSendingMobileOtp = false);
    }
  }

  Future<void> _verifyMobileOtp() async {
    final otp = _phoneCtrl.text;
    if (otp.isEmpty) {
      Get.snackbar('Error', 'Please enter the OTP.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_tempMobile == null) return;
    setState(() => _isVerifyingMobileOtp = true);
    try {
      final response = await _authRepo.verifyMobileOtp(_tempMobile!, otp);
      if (response.statusCode == 200) {
        setState(() {
          _isMobileVerified = true;
          _isMobileOtpSent = false;
          _phoneCtrl.text = _tempMobile!;
        });
        Get.snackbar('Success', 'Mobile number verified successfully!',
            backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Invalid OTP code.',
            backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
    } finally {
      setState(() => _isVerifyingMobileOtp = false);
    }
  }

  Future<void> _sendEmailOtp() async {
    final email = _emailCtrl.text;
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    setState(() => _isSendingEmailOtp = true);
    try {
      final response = await _authRepo.sendEmailOtp(email);
      if (response.statusCode == 200) {
        setState(() {
          _tempEmail = email;
          _isEmailOtpSent = true;
          _emailCtrl.clear();
        });
        Get.snackbar('Success', 'OTP sent to email.',
            backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to send OTP.',
            backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
    } finally {
      setState(() => _isSendingEmailOtp = false);
    }
  }

  Future<void> _verifyEmailOtp() async {
    final otp = _emailCtrl.text;
    if (otp.isEmpty) {
      Get.snackbar('Error', 'Please enter the OTP.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_tempEmail == null) return;
    setState(() => _isVerifyingEmailOtp = true);
    try {
      final response = await _authRepo.verifyEmailOtp(_tempEmail!, otp);
      if (response.statusCode == 200) {
        setState(() {
          _isEmailVerified = true;
          _isEmailOtpSent = false;
          _emailCtrl.text = _tempEmail!;
        });
        Get.snackbar('Success', 'Email verified successfully!',
            backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Invalid OTP code.',
            backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
    } finally {
      setState(() => _isVerifyingEmailOtp = false);
    }
  }

  void _skipEmailOtp() {
    setState(() {
      _isEmailVerified = false;
      _isEmailOtpSent = false;
      _isEmailSkipped = true;
    });
    Get.snackbar('Notice', 'Email OTP verification skipped.',
        backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.borderGrey, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Service Inquiry',
                style: GoogleFonts.montserrat(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete the details below to inquire about ${widget.service['title']}.',
                style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText),
              ),
              const SizedBox(height: 16),
              _buildField(_nameCtrl, 'Full Name', 'Enter your full name', Icons.person_outline),
              const SizedBox(height: 12),
              _buildField(
                _phoneCtrl,
                'Phone Number',
                _isMobileVerified ? 'Verified Phone' : (_isMobileOtpSent ? '6-digit OTP' : '10-digit mobile'),
                Icons.phone_outlined,
                keyboard: TextInputType.phone,
                readOnly: _isMobileVerified,
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _isMobileVerified
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow, size: 20)
                      : _buildInlineButton(
                          label: _isMobileOtpSent ? 'VERIFY' : 'SEND OTP',
                          onTap: _isSendingMobileOtp || _isVerifyingMobileOtp
                              ? () {}
                              : (_isMobileOtpSent ? _verifyMobileOtp : _sendMobileOtp),
                          isLoading: _isSendingMobileOtp || _isVerifyingMobileOtp,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              _buildField(
                _emailCtrl,
                'Email Address',
                _isEmailVerified
                    ? 'Verified Email'
                    : (_isEmailSkipped ? 'Skipped Email' : 'you@example.com'),
                Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                readOnly: _isEmailVerified || _isEmailSkipped,
                headerTrailing: _isEmailVerified
                    ? null
                    : (_isEmailSkipped
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                _isEmailSkipped = false;
                                _emailCtrl.clear();
                              });
                            },
                            child: Text(
                              'VERIFY INSTEAD',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.0,
                                color: AppColors.primaryYellow,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: _skipEmailOtp,
                            child: Text(
                              'SKIP VERIFICATION',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.0,
                                color: AppColors.greyText,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )),
                suffixIcon: _isEmailVerified
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow, size: 20)
                    : (_isEmailSkipped
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _buildInlineButton(
                              label: _isEmailOtpSent ? 'VERIFY' : 'SEND OTP',
                              onTap: _isSendingEmailOtp || _isVerifyingEmailOtp
                                  ? () {}
                                  : (_isEmailOtpSent ? _verifyEmailOtp : _sendEmailOtp),
                              isLoading: _isSendingEmailOtp || _isVerifyingEmailOtp,
                            ),
                          )),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDateField('Preferred Date', 'mm/dd/yyyy', _checkIn, (d) => setState(() => _checkIn = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateField('End Date', 'mm/dd/yyyy', _checkOut, (d) => setState(() => _checkOut = d), isOptional: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCounter('Expected Guests', _adults, (v) => setState(() => _adults = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCounter('Staff/Misc', _kids, (v) => setState(() => _kids = v), isOptional: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Travel Type',
                      DropdownButton<String>(
                        value: _travelType,
                        isExpanded: true,
                        hint: Text('Select...', style: GoogleFonts.montserrat(fontSize: 13.0, color: AppColors.greyText)),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.greyText),
                        items: _travelTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.montserrat(fontSize: 13.0, color: AppColors.primaryBlack)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _travelType = val;
                              _budget = '';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      'Estimated Budget',
                      DropdownButton<String>(
                        value: _budget.isEmpty ? null : _budget,
                        isExpanded: true,
                        hint: Text('Select...', style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText), overflow: TextOverflow.ellipsis),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.greyText),
                        items: (_budgetOptions[_travelType] ?? []).map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(opt['label']!, style: GoogleFonts.montserrat(fontSize: 11.0, color: AppColors.primaryBlack), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _budget = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildField(_msgCtrl, 'Special Requests', 'Any specific needs or occasions...', Icons.message_outlined, maxLines: 2, isOptional: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlack))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SUBMIT INQUIRY', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13.0, letterSpacing: 0.5)),
                          const SizedBox(width: 6),
                          const Icon(Icons.send_rounded, size: 14),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'YOUR INFORMATION IS STRICTLY CONFIDENTIAL.',
                  style: GoogleFonts.montserrat(fontSize: 9.0, color: AppColors.greyText, fontWeight: FontWeight.w500, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
    bool isOptional = false,
    Widget? suffixIcon,
    bool readOnly = false,
    Widget? headerTrailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isOptional ? '${label.toUpperCase()} (OPTIONAL)' : label.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8F9399),
                letterSpacing: 1.0,
              ),
            ),
            if (headerTrailing != null) headerTrailing,
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          readOnly: readOnly,
          style: GoogleFonts.montserrat(fontSize: 13.0, fontWeight: FontWeight.normal, color: AppColors.primaryBlack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(fontSize: 13.0, color: AppColors.greyText),
            prefixIcon: Icon(icon, size: 16, color: AppColors.greyText),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: isOptional ? null : (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint, DateTime? date, Function(DateTime) onSelect, {bool isOptional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOptional ? '${label.toUpperCase()} (OPTIONAL)' : label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8F9399),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d != null) onSelect(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.lightGrey, width: 1.0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.greyText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date == null ? hint : DateFormat('MM/dd/yyyy').format(date),
                    style: GoogleFonts.montserrat(
                        fontSize: 13.0,
                        color: date == null ? AppColors.greyText : AppColors.primaryBlack,
                        fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int val, Function(int) onChange, {bool isOptional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOptional ? '${label.toUpperCase()} (OPTIONAL)' : label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8F9399),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightGrey, width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                (label.contains('Adult') || label.contains('Guest'))
                    ? Icons.person_outline
                    : Icons.child_care_outlined,
                size: 16,
                color: AppColors.greyText,
              ),
              Text(val.toString(), style: GoogleFonts.montserrat(fontSize: 13.0, fontWeight: FontWeight.normal, color: AppColors.primaryBlack)),
              Row(
                children: [
                  InkWell(
                    onTap: () => val > 0 ? onChange(val - 1) : null,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.remove, size: 14, color: AppColors.primaryBlack),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => onChange(val + 1),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.add, size: 14, color: AppColors.primaryBlack),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, Widget dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8F9399),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightGrey, width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(child: dropdown),
        ),
      ],
    );
  }

  Widget _buildInlineButton({
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
    Color? bgColor,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryBlack,
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? AppColors.primaryBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isMobileVerified) {
      Get.snackbar('Verification Required', 'Please verify your phone number with OTP first.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (!_isEmailVerified && !_isEmailSkipped) {
      Get.snackbar('Verification Required', 'Please verify your email address or skip verification.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_checkIn == null) {
      Get.snackbar('Error', 'Please select a preferred date', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_budget.isEmpty) {
      Get.snackbar('Error', 'Please select a budget.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<HomeController>();

    final payload = {
      'name': _nameCtrl.text,
      'email': _isEmailSkipped ? _emailCtrl.text : (_tempEmail ?? _emailCtrl.text),
      'phone': _tempMobile ?? _phoneCtrl.text,
      'checkIn': _checkIn!.toIso8601String(),
      'checkOut': _checkOut?.toIso8601String(),
      'adults': _adults,
      'kids': _kids,
      'travelType': _travelType,
      'budget': _budget,
      'message': _msgCtrl.text,
      'serviceName': widget.service['title'] ?? 'Unknown',
      'serviceId': widget.service['_id'] ?? '',
    };

    try {
      final success = await controller.submitServiceEnquiry(payload);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Service inquiry submitted successfully!', backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Submission failed. Please try again.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
