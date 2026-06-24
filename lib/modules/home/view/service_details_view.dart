import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:own_holiday_app/data/repository/auth_repo.dart';
import 'package:own_holiday_app/data/repository/service_repo.dart';
import 'dart:async';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

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
  List<Map<String, dynamic>> _subCategories = [];
  bool _isLoadingSubCategories = false;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments ?? {};

    final fullDetail = controller.allServicesWithGallery.firstWhere(
      (s) => s['serviceTitle'] == args['title'] || s['slug'] == args['title'].toString().toLowerCase().replaceAll(' ', '-'),
      orElse: () => <String, dynamic>{},
    );

    // Merge: args (card info) + fullDetail (gallery, fullDesc, etc.)
    // Keep args['subServices'] if fullDetail['subServices'] is null or empty
    final mergedSubServices = (fullDetail['subServices'] is List && (fullDetail['subServices'] as List).isNotEmpty)
        ? fullDetail['subServices']
        : args['subServices'];

    service = {...args, ...fullDetail};
    if (mergedSubServices != null) {
      service['subServices'] = mergedSubServices;
    }

    _startAutoScroll();

    // Pre-populate from already-merged subServices (instant)
    final existing = service['subServices'];
    if (existing is List && existing.isNotEmpty) {
      _subCategories = existing
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      print('✅ [SERVICE DETAILS] Pre-loaded ${_subCategories.length} subServices from merged data');
    }

    // Resolve slug — try multiple possible field names, fallback to slugified title
    final slug = (service['slug'] ??
            service['serviceSlug'] ??
            service['service_slug'] ??
            service['title']?.toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-') ??
            '')
        .toString()
        .trim();

    print('🚀 [SERVICE DETAILS] service keys: ${service.keys.toList()}');
    print('🚀 [SERVICE DETAILS] resolved slug: "$slug"');

    if (slug.isNotEmpty) _fetchSubCategories(slug);
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

  Future<void> _fetchSubCategories(String slug) async {
    // ── Build URL and log everything ────────────────────────
    final url = 'https://api.ownholidayclub.com/api/service-details/slug/$slug';
    print('╔══════════════════════════════════════════════════════════');
    print('║ 🔍 [SERVICE CATEGORIES] API REQUEST');
    print('║ 🔗 URL : $url');
    print('║ 📋 ALL SERVICE KEYS: ${service.keys.toList()}');
    print('║ 📋 SLUG USED       : $slug');
    print('╚══════════════════════════════════════════════════════════');

    if (mounted) setState(() => _isLoadingSubCategories = true);
    try {
      final response = await controller.serviceRepo.getServiceDetailsBySlug(slug);
      print('╔══════════════════════════════════════════════════════════');
      print('║ ✅ [SERVICE CATEGORIES] API RESPONSE');
      print('║ 📊 STATUS CODE : ${response.statusCode}');
      print('║ 📦 BODY        : ${response.body}');
      print('╚══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          print('║ 🗝️  DATA KEYS: ${(data as Map).keys.toList()}');
          // Primary key is subServices — fallback to others
          final raw = data['subServices'] ??
              data['serviceDetails'] ??
              data['categories'] ??
              data['subCategories'] ??
              data['items'] ??
              data['types'] ??
              data['details'] ??
              [];
          print('║ 📋 RAW CATEGORIES COUNT: ${raw is List ? raw.length : "not a list"}');
            if (raw is List && raw.isNotEmpty && mounted) {
              setState(() => _subCategories = raw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList());
              print('║ ✅ Loaded ${_subCategories.length} sub-categories from API');
              if (_subCategories.isNotEmpty) {
                print('🔍 FIRST SUB-CATEGORY KEYS: ${_subCategories[0].keys.toList()}');
                print('🔍 FIRST SUB-CATEGORY DETAILS: ${_subCategories[0]}');
                for (int k = 0; k < _subCategories.length; k++) {
                  print('📷 Sub-cat $k: Title: "${_subCategories[k]['title']}" | Image: "${_subCategories[k]['image']}" | Thumbnail: "${_subCategories[k]['thumbnail']}" | ExploreImage: "${_subCategories[k]['exploreImage']}" | Icon: "${_subCategories[k]['icon']}"');
                }
              }
            } else {
            print('║ ⚠️  subServices empty or missing — keeping pre-loaded data (${_subCategories.length} items)');
          }
        } else {
          print('║ ⚠️  success=false or data=null. Full body: ${response.body}');
        }
      } else {
        print('║ ❌ Non-200 status: ${response.statusCode}');
        print('║ 📦 ERROR BODY: ${response.body}');
      }
    } catch (e, st) {
      print('║ ❌ EXCEPTION: $e');
      print('║ 📋 STACKTRACE: $st');
    } finally {
      if (mounted) setState(() => _isLoadingSubCategories = false);
    }
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
                      // Highlights / What's Included section removed by user request
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
                      // ── Sub-Categories Grid ─────────────────────
                      if (_isLoadingSubCategories) ...[
                        const SizedBox(height: 28),
                        const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
                      ] else if (_subCategories.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryYellow.withOpacity(0.18),
                                AppColors.primaryYellow.withOpacity(0.02),
                                Colors.transparent,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              left: BorderSide(color: AppColors.primaryYellow, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.grid_view_rounded,
                                color: AppColors.primaryBlack,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${service['serviceTitle'] ?? service['title'] ?? 'SERVICE'} CATEGORIES',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlack,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover our curated sub-services and experiences tailored specifically to your needs.',
                          style: GoogleFonts.montserrat(fontSize: 11.5, color: AppColors.greyText, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _subCategories.length,
                          separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                          itemBuilder: (ctx, i) => _buildSubCategoryCard(_subCategories[i], i),
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

  Widget _buildSubCategoryCard(Map<String, dynamic> cat, int index) {
    final title = cat['title']?.toString() ?? cat['name']?.toString() ?? 'Category';
    final desc = _stripHtml(cat['shortDescription']?.toString() ?? cat['description']?.toString() ?? '');
    final imageUrl = cat['image']?.toString() ?? cat['thumbnail']?.toString() ?? '';
    final num = (index + 1).toString().padLeft(2, '0');
    return GestureDetector(
      onTap: () => _showServiceInquiryForm(context, preSelectedCategory: title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number badge
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlack,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(num, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: GoogleFonts.montserrat(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
              ),
            ),
            const SizedBox(height: 6),
            // Description
            if (desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  desc,
                  style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText, height: 1.4),
                ),
              ),
            // Image with fallback
            Builder(
              builder: (context) {
                final fallbackUrl = service['image']?.toString() ?? '';
                final finalImageUrl = imageUrl.isNotEmpty ? imageUrl : fallbackUrl;
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: finalImageUrl.isNotEmpty && finalImageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: finalImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Skeleton(),
                            errorWidget: (c, u, e) => fallbackUrl.isNotEmpty && fallbackUrl.startsWith('http') && finalImageUrl != fallbackUrl
                                ? CachedNetworkImage(
                                    imageUrl: fallbackUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => const Skeleton(),
                                    errorWidget: (c, u, e) => Container(color: Colors.grey.shade100),
                                  )
                                : Container(color: Colors.grey.shade100),
                          )
                        : (finalImageUrl.isNotEmpty
                            ? Image.asset(finalImageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey.shade100)),
                  ),
                );
              }
            ),
          ],
        ),
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

  void _showServiceInquiryForm(BuildContext context, {String? preSelectedCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceInquiryFormSheet(
        service: service,
        serviceCategories: _subCategories,
        preSelectedCategory: preSelectedCategory,
      ),
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
  final List<Map<String, dynamic>> serviceCategories;
  final String? preSelectedCategory;

  const ServiceInquiryFormSheet({
    super.key,
    required this.service,
    this.serviceCategories = const [],
    this.preSelectedCategory,
  });

  @override
  State<ServiceInquiryFormSheet> createState() => _ServiceInquiryFormSheetState();
}

class _ServiceInquiryFormSheetState extends State<ServiceInquiryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  List<String> _locationSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 2;
  bool _isSubmitting = false;

  final AuthRepo _authRepo = Get.find<AuthRepo>();
  final ServiceRepo _serviceRepo = Get.find<ServiceRepo>();
  bool _isMobileOtpSent = false;
  bool _isMobileVerified = false;
  bool _isSendingMobileOtp = false;
  bool _isVerifyingMobileOtp = false;
  String? _tempMobile;

  String? _selectedService;
  String? _selectedCategory;
  String _budget = '';

  List<String> get _serviceOptions {
    final homeCtrl = Get.find<HomeController>();
    final list = homeCtrl.services
        .map((s) => (s['title'] ?? s['serviceTitle'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    
    // Add current service title if not present
    final currentTitle = (widget.service['title'] ?? widget.service['serviceTitle'] ?? '').toString();
    if (currentTitle.isNotEmpty && !list.any((e) => e.toLowerCase() == currentTitle.toLowerCase())) {
      list.add(currentTitle);
    }

    // Add hardcoded defaults if not present
    for (final opt in ['Holiday', 'Events', 'Wedding', 'Outing']) {
      if (!list.any((e) => e.toLowerCase() == opt.toLowerCase())) {
        list.add(opt);
      }
    }
    return list;
  }

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

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preSelectedCategory;
    final initialService = widget.service['title']?.toString() ?? widget.service['serviceTitle']?.toString() ?? '';
    if (initialService.isNotEmpty) {
      final match = _serviceOptions.firstWhere(
        (opt) => initialService.toLowerCase().contains(opt.toLowerCase()) || opt.toLowerCase().contains(initialService.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        _selectedService = match;
      }
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _locationSuggestions = [];
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': 'AIzaSyDarNwOH5Gfi1KseDZ82fkh2b0wn66uudg',
        },
        body: jsonEncode({
          'input': query,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['suggestions'] != null) {
          final List suggestions = data['suggestions'];
          setState(() {
            _locationSuggestions = suggestions
                .map((s) => s['placePrediction']['text']['text'].toString())
                .toList();
          });
        } else {
          setState(() {
            _locationSuggestions = [];
          });
        }
      } else {
        setState(() {
          _locationSuggestions = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
      setState(() {
        _locationSuggestions = [];
      });
    } finally {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _onLocationChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchLocationSuggestions(val);
    });
  }

  List<Map<String, dynamic>> get _currentCategories {
    if (_selectedService == null) {
      return [];
    }
    final homeCtrl = Get.find<HomeController>();
    final sel = _selectedService!.trim().toLowerCase();

    // 1. Try finding in allServicesWithGallery (which has full subServices)
    var svc = homeCtrl.allServicesWithGallery.firstWhere(
      (s) {
        final title = (s['serviceTitle'] ?? s['title'] ?? '').toString().trim().toLowerCase();
        return title.contains(sel) || sel.contains(title);
      },
      orElse: () => <String, dynamic>{},
    );

    // 2. Fallback to services
    if (svc.isEmpty) {
      svc = homeCtrl.services.firstWhere(
        (s) {
          final title = (s['title'] ?? s['serviceTitle'] ?? '').toString().trim().toLowerCase();
          return title.contains(sel) || sel.contains(title);
        },
        orElse: () => <String, dynamic>{},
      );
    }

    if (svc.isNotEmpty) {
      final rawSub = svc['subServices'] ?? svc['categories'] ?? svc['subCategories'] ?? [];
      if (rawSub is List && rawSub.isNotEmpty) {
        return List<Map<String, dynamic>>.from(rawSub.whereType<Map>());
      }
    }

    // 3. Fallback to widget.serviceCategories if selected service matches current view service
    final currentTitle = (widget.service['title'] ?? widget.service['serviceTitle'] ?? '').toString().trim().toLowerCase();
    if (sel.contains(currentTitle) || currentTitle.contains(sel)) {
      return widget.serviceCategories;
    }

    return [];
  }
  Future<void> _sendMobileOtp() async {
    final mobile = _phoneCtrl.text;
    if (mobile.length != 10) {
      Get.snackbar('Error', 'Please enter a valid 10-digit mobile number.',
          backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    setState(() => _isSendingMobileOtp = true);
    try {
      final response = await _serviceRepo.sendMobileOtp(mobile);
      if (response.statusCode == 200) {
        setState(() {
          _tempMobile = mobile;
          _isMobileOtpSent = true;
          _phoneCtrl.clear();
        });
        Get.snackbar('Success', 'OTP sent to mobile number.',
            backgroundColor: Colors.black, colorText: Colors.white);
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
      final response = await _serviceRepo.verifyMobileOtp(_tempMobile!, otp);
      if (response.statusCode == 200) {
        setState(() {
          _isMobileVerified = true;
          _isMobileOtpSent = false;
          _phoneCtrl.text = _tempMobile!;
        });
        Get.snackbar('Success', 'Mobile number verified successfully!',
            backgroundColor: Colors.black, colorText: Colors.white);
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



  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottomPadding),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle bar
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Close button / title header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SERVICE ENQUIRY",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 3,
                          margin: const EdgeInsets.only(top: 1, bottom: 0),
                          color: AppColors.primaryYellow,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Full Name
                _buildLabel("FULL NAME"),
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    "Enter full name",
                    Icons.person_outline_rounded,
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 8),

                // Mobile Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel("MOBILE NUMBER"),
                    if (_isMobileOtpSent && !_isMobileVerified)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isMobileOtpSent = false;
                            if (_tempMobile != null) {
                              _phoneCtrl.text = _tempMobile!;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'EDIT NUMBER',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        enabled: !_isMobileVerified,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D1321),
                        ),
                        decoration: _inputDecoration(
                          _isMobileVerified ? 'Verified Phone' : (_isMobileOtpSent ? '6-digit OTP' : '10-digit mobile'),
                          Icons.phone_iphone_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isMobileVerified
                        ? Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF059669),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "✓ VERIFIED",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF047857),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isSendingMobileOtp || _isVerifyingMobileOtp
                                  ? () {}
                                  : (_isMobileOtpSent ? _verifyMobileOtp : _sendMobileOtp),
                              child: _isSendingMobileOtp || _isVerifyingMobileOtp
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isMobileOtpSent ? "VERIFY" : "SEND OTP",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 8),

                // Email Address
                _buildLabel("EMAIL ADDRESS *"),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    'you@example.com',
                    Icons.mail_outline_rounded,
                  ),
                  validator: (v) => (v == null || v.isEmpty || !GetUtils.isEmail(v)) ? "Required" : null,
                ),
                const SizedBox(height: 8),

                // Arrival & Departure Row (Check-In & Check-Out)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("CHECK-IN DATE"),
                          _buildDatePickerButton(
                            label: _checkIn == null
                                ? "mm/dd/yyyy"
                                : DateFormat('MM/dd/yyyy').format(_checkIn!),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (d != null) setState(() => _checkIn = d);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("CHECK-OUT DATE"),
                          _buildDatePickerButton(
                            label: _checkOut == null
                                ? "mm/dd/yyyy"
                                : DateFormat('MM/dd/yyyy').format(_checkOut!),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (d != null) setState(() => _checkOut = d);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // No of Guests
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("NO OF GUESTS"),
                    DropdownButtonFormField<int>(
                      value: _adults,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1321),
                      ),
                      decoration: _inputDecoration(
                        null,
                        Icons.people_outline_rounded,
                      ),
                      items: List.generate(20, (i) => i + 1).map((n) {
                        return DropdownMenuItem<int>(
                          value: n,
                          child: Text("$n Guest${n != 1 ? 's' : ''}"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _adults = val ?? 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Select Service
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("SELECT SERVICE"),
                    DropdownButtonFormField<String>(
                      value: _selectedService,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1321),
                      ),
                      decoration: _inputDecoration(
                        "Select service...",
                        Icons.room_service_outlined,
                      ),
                      items: _serviceOptions.map((svc) {
                        return DropdownMenuItem<String>(
                          value: svc,
                          child: Text(svc),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedService = val;
                            _selectedCategory = null;
                            _budget = '';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location autocomplete field
                _buildLocationAutocompleteField(),
                const SizedBox(height: 8),

                // Service Category in full width below them
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("SERVICE CATEGORY"),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1321),
                      ),
                      decoration: _inputDecoration(
                        _selectedService == null ? 'Select first...' : 'Category...',
                        Icons.category_outlined,
                      ),
                      items: _currentCategories.map((cat) {
                        final n = cat['title']?.toString() ?? cat['name']?.toString() ?? '';
                        return DropdownMenuItem<String>(
                          value: n,
                          child: Text(
                            n,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        );
                      }).toList(),
                      onChanged: _selectedService == null
                          ? null
                          : (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                });
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Budget selection
                _buildLabel("SELECT YOUR BUDGET"),
                DropdownButtonFormField<String>(
                  value: _budget.isEmpty ? null : _budget,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    "Select a budget...",
                    Icons.payments_outlined,
                  ),
                  items: _selectedService != null
                      ? (_budgetOptions[_selectedService!] ?? _budgetOptions['Events'] ?? []).map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(opt['label']!),
                          );
                        }).toList()
                      : [],
                  onChanged: _selectedService == null
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() {
                              _budget = val;
                            });
                          }
                        },
                ),
                const SizedBox(height: 8),

                // Special Request (Optional)
                _buildLabel("SPECIAL REQUEST (OPTIONAL)"),
                TextFormField(
                  controller: _msgCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    "Any special request? Let us know!",
                    Icons.message_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlack,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "CONFIRM REQUEST",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.send_rounded, size: 16),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required VoidCallback onTap,
  }) {
    final hasDate = label != "mm/dd/yyyy";
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCED4DA)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,
                color: hasDate ? const Color(0xFF0D1321) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
      ),
    );
  }

  Widget _buildLocationAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("SPECIFIC LOCATION"),
        TextFormField(
          controller: _locationCtrl,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D1321),
          ),
          decoration: InputDecoration(
            hintText: "Search precise location...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Colors.grey,
            ),
            suffixIcon: _isLoadingSuggestions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF000000),
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
            ),
          ),
          onChanged: _onLocationChanged,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        if (_locationSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCED4DA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _locationSuggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEDEFF2)),
              itemBuilder: (context, index) {
                final suggestion = _locationSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    suggestion,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF0D1321),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _locationCtrl.text = suggestion;
                      _locationSuggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }


  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Mobile OTP verification is optional for mobile app
    if (!_isMobileVerified) {
      debugPrint("Mobile number not verified, proceeding anyway.");
    }
    if (_checkIn == null) {
      Get.snackbar('Error', 'Please select a check-in date.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_locationCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please select a location.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_selectedService == null || _selectedService!.isEmpty) {
      Get.snackbar('Error', 'Please select a service.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
      return;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      Get.snackbar('Error', 'Please select a service category.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
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
      'email': _emailCtrl.text,
      'phone': _tempMobile ?? _phoneCtrl.text,
      'checkIn': _checkIn!.toIso8601String(),
      'checkOut': _checkOut?.toIso8601String(),
      'adults': _adults,
      'location': _locationCtrl.text,
      'service': _selectedService ?? '',
      'serviceCategory': _selectedCategory ?? '',
      'budget': _budget,
      'message': _msgCtrl.text,
      'serviceName': widget.service['title'] ?? 'Unknown',
      'serviceId': widget.service['_id'] ?? '',
    };

    try {
      final success = await controller.submitServiceEnquiry(payload);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Service inquiry submitted successfully!', backgroundColor: Colors.black, colorText: Colors.white);
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
