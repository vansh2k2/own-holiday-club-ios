import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DestinationDetailsView extends StatefulWidget {
  const DestinationDetailsView({super.key});

  @override
  State<DestinationDetailsView> createState() => _DestinationDetailsViewState();
}

class _DestinationDetailsViewState extends State<DestinationDetailsView> {
  final HomeController controller = Get.find<HomeController>();
  late Map<String, dynamic> destination;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    destination = Get.arguments ?? {};
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int next = _currentPage + 1;
        if (next >= _getImages().length) next = 0;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
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

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
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
                      FadeInUp(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination['name'] ?? 'Destination',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 12, color: AppColors.primaryYellow),
                                      const SizedBox(width: 4),
                                      Text(
                                        destination['region'] ?? 'Explore',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: AppColors.greyText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Starting ${destination['price'] ?? 'On Request'}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatsRow(),
                      const SizedBox(height: 28),
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Experience the Journey',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          _stripHtml(destination['fullDescription'] ?? destination['location'] ?? 'Explore the beauty of this destination with OHC.'),
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
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
    if (destination['image'] != null && destination['image'].toString().isNotEmpty) {
      imgs.add(destination['image']);
    }
    if (destination['gallery'] != null && destination['gallery'] is List) {
      for (var item in destination['gallery']) {
        if (item != null && item.toString().isNotEmpty) {
          imgs.add(item.toString());
        }
      }
    }
    return imgs.isEmpty ? ['assets/images/santorini_experience.png'] : imgs;
  }

  Widget _buildHeader(List<String> images) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 420,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (v) => setState(() => _currentPage = v),
                    itemCount: images.length,
                    itemBuilder: (context, i) => _buildImage(images[i]),
                  ),
                  Positioned(
                    bottom: 80,
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
          ),
        ],
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

  Widget _buildStatsRow() {
    final stats = destination['travelStats'] ?? {};
    return FadeInUp(
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.wb_sunny_outlined, 'Best Time', stats['bestTime'] ?? 'Oct - Mar'),
            _buildStatItem(Icons.thermostat_outlined, 'Temp', stats['temp'] ?? '22° - 30°'),
            _buildStatItem(Icons.flight_takeoff, 'Access', 'Easy'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryYellow),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.primaryBlack, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: FadeInUp(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _showInquiryForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ENQUIRE NOW',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 1),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
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

  void _showInquiryForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InquiryFormSheet(destination: destination),
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

class InquiryFormSheet extends StatefulWidget {
  final Map<String, dynamic> destination;
  const InquiryFormSheet({super.key, required this.destination});

  @override
  State<InquiryFormSheet> createState() => _InquiryFormSheetState();
}

class _InquiryFormSheetState extends State<InquiryFormSheet> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Request an Itinerary',
                style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete the details below to begin planning your trip to ${widget.destination['name']}.',
                style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.greyText),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _buildField(_nameCtrl, 'Full Name', Icons.person_outline)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined, keyboard: TextInputType.phone)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_emailCtrl, 'Email Address', Icons.email_outlined, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateField('Check-in', _checkIn, (d) => setState(() => _checkIn = d))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateField('Check-out', _checkOut, (d) => setState(() => _checkOut = d))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCounter('Adults', _adults, (v) => setState(() => _adults = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCounter('Kids', _kids, (v) => setState(() => _kids = v))),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_msgCtrl, 'Special Requests or Preferences...', Icons.message_outlined, maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SUBMIT INQUIRY', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(width: 8),
                          const Icon(Icons.send_rounded, size: 16),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'YOUR INFORMATION IS STRICTLY CONFIDENTIAL.',
                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboard, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, size: 16, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              date == null ? label : DateFormat('MM/dd/yyyy').format(date),
              style: GoogleFonts.montserrat(fontSize: 13, color: date == null ? Colors.grey : AppColors.primaryBlack, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int val, Function(int) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(label == 'Adults' ? Icons.person_outline : Icons.child_care_outlined, size: 18, color: Colors.grey),
          Text(val.toString(), style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900)),
          Row(
            children: [
              InkWell(onTap: () => val > 0 ? onChange(val - 1) : null, child: const Icon(Icons.remove, size: 16)),
              const SizedBox(width: 8),
              InkWell(onTap: () => onChange(val + 1), child: const Icon(Icons.add, size: 16)),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      Get.snackbar('Error', 'Please select dates', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<HomeController>();
    
    final payload = {
      'name': _nameCtrl.text,
      'email': _emailCtrl.text,
      'phone': _phoneCtrl.text,
      'checkIn': _checkIn!.toIso8601String(),
      'checkOut': _checkOut!.toIso8601String(),
      'adults': _adults,
      'kids': _kids,
      'message': _msgCtrl.text,
      'destinationName': widget.destination['name'] ?? 'Unknown',
      'destinationId': widget.destination['_id'] ?? '',
    };

    try {
      final success = await controller.submitEnquiry(payload);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Inquiry submitted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Submission failed. Please try again.', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
