import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/widgets/enquiry_form_sheet.dart';

class ShortsReelView extends GetView<HomeController> {
  const ShortsReelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() {
            if (controller.isShortsLoading.value || controller.trendingShorts.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
            }
            // Get initial index from arguments if provided
            final initialIndex = Get.arguments as int? ?? 0;
            final pageController = PageController(initialPage: initialIndex);
            
            return PageView.builder(
              controller: pageController,
              scrollDirection: Axis.vertical,
              itemCount: controller.trendingShorts.length,
              itemBuilder: (context, index) {
                final short = controller.trendingShorts[index];
                return _ShortPage(short: short);
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

          // Scroll Up Hint
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

class _ShortPage extends StatelessWidget {
  final Map<String, dynamic> short;
  const _ShortPage({required this.short});

  @override
  Widget build(BuildContext context) {
    final String mediaUrl = short['videoUrl'] ?? short['image'] ?? short['video'] ?? '';
    final bool isVideo = mediaUrl.isNotEmpty;

    return Stack(
      children: [
        // Background Media (Image or Video)
        Positioned.fill(
          child: isVideo 
            ? _VideoPlayerItem(url: mediaUrl)
            : _buildImage(mediaUrl),
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
          right: 80, // Leave space for scroll hint
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(
                child: Text(
                  short['title'] ?? short['uploaderName'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    const Icon(Icons.remove_red_eye, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${short['views'] ?? 0} views',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }
}

class _VideoPlayerItem extends StatefulWidget {
  final String url;
  const _VideoPlayerItem({required this.url});

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.url.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    } else {
      _controller = VideoPlayerController.asset(widget.url);
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
          _controller.setVolume(1.0); // Sound ON in Reel View
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      print("Error initializing reel video: $e");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.white54, size: 40),
              SizedBox(height: 10),
              Text("Failed to load video", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }
    
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
