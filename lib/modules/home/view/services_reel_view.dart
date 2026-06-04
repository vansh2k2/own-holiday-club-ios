import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/routes/app_pages.dart';

class ServicesReelView extends GetView<HomeController> {
  const ServicesReelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() {
            if (controller.services.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
            }
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: controller.services.length,
              itemBuilder: (context, index) {
                final svc = controller.services[index];
                return _ServicePage(service: svc);
              },
            );
          }),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Scroll hint
          Positioned(
            bottom: 40,
            right: 20,
            child: FadeInUp(
              duration: const Duration(seconds: 2),
              child: Column(
                children: [
                  const Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.white70, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    'Scroll Up',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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
}

class _ServicePage extends StatelessWidget {
  final Map<String, dynamic> service;
  const _ServicePage({required this.service});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = service['image'] ?? '';

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: _buildImage(imageUrl),
        ),

        // Gradient overlay — covers only the bottom text area
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.35, 0.65, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 100,
          left: 20,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(
                child: Text(
                  service['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  service['description'] ?? 'Experience our premium service offerings crafted just for you.',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    onPressed: () => Get.toNamed(
                      Routes.SERVICE_DETAILS,
                      arguments: service,
                    ),
                    child: const Text(
                      'BOOK NOW',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return Container(color: Colors.grey[900]);
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[900]),
        errorWidget: (context, url, error) => Container(color: Colors.grey[900], child: const Icon(Icons.error, color: Colors.white)),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }
}
