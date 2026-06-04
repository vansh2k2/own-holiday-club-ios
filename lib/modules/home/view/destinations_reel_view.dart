import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/widgets/enquiry_form_sheet.dart';

class DestinationsReelView extends GetView<HomeController> {
  const DestinationsReelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() {
            if (controller.destinations.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
            }
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: controller.destinations.length,
              itemBuilder: (context, index) {
                final dest = controller.destinations[index];
                return _DestinationPage(destination: dest);
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

class _DestinationPage extends StatelessWidget {
  final Map<String, dynamic> destination;
  const _DestinationPage({required this.destination});

  @override
  Widget build(BuildContext context) {
    final String mediaUrl = destination['image'] ?? destination['video'] ?? '';
    final bool isVideo = mediaUrl.toLowerCase().contains('.mp4') || 
                        mediaUrl.toLowerCase().contains('.mov') || 
                        mediaUrl.toLowerCase().contains('.avi');

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
                  destination['name'] ?? destination['title'] ?? '',
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
                  destination['description'] ?? 'Experience the luxury and beauty of this magnificent destination.',
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
                  height: 45, // Reduced height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    onPressed: () => Get.find<HomeController>().goToDestinationDetails(destination),
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
          _controller.setVolume(0); // Muted by default for auto-play
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
