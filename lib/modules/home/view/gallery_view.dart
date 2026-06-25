import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryItem {
  final String url;
  final String title;
  GalleryItem(this.url, this.title);
}

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>() 
        ? Get.find<HomeController>() 
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.primaryWhite, // Changed back to white
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: () {
            if (Get.previousRoute.isEmpty) {
              Get.offAllNamed('/dashboard');
            } else {
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryBlack, size: 16),
          label: const Text('Back', style: TextStyle(color: AppColors.primaryBlack, fontSize: 14)),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.appGalleryImages.isEmpty) {
          // Skeleton loading
          return Column(
            children: [
              const SizedBox(height: 16),
              const Skeleton(height: 30, width: 250),
              const SizedBox(height: 8),
              const Skeleton(height: 16, width: 200),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.custom(
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      repeatPattern: QuiltedGridRepeatPattern.inverted,
                      pattern: const [
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 2),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) => const Skeleton(borderRadius: 8.0),
                      childCount: 28, // Increased to fill the entire page with skeleton layout
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (controller.appGalleryImages.isEmpty) {
          return const Center(
            child: Text('No gallery images available.', style: TextStyle(color: AppColors.primaryBlack)),
          );
        }

        // Map App Gallery images into GalleryItem objects
        final List<GalleryItem> allImages = controller.appGalleryImages
            .map((img) => GalleryItem(img['url'] ?? '', img['title'] ?? ''))
            .toList();

        return Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.primaryYellow],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'FULL GALLERY',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryYellow, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'A glimpse into our luxurious experiences',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: const [
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 2),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 1),
                    ],
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: (index % 10) * 50),
                        child: _buildGalleryImage(allImages[index]),
                      );
                    },
                    childCount: allImages.length,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGalleryImage(GalleryItem item) {
    return GestureDetector(
      onTap: () {
        // Full screen preview logic can be added here
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Skeleton(borderRadius: 8),
              errorWidget: (context, url, error) => Container(
                color: AppColors.lightGrey,
                child: const Icon(Icons.broken_image_outlined, color: AppColors.greyText),
              ),
            ),
            // Gradient Overlay and Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
