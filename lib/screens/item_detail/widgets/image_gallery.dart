import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Swipeable image gallery for item detail.
/// Full-width image with page indicator dots at the bottom.
class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 320,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = widget.imageUrls;

    if (images.isEmpty) {
      return _EmptyGallery(height: widget.height, isDark: isDark);
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // ── Page view ───────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _GalleryImage(
              url: images[index],
              isDark: isDark,
            ),
          ),

          // ── Dot indicators ──────────────────────────────────────────────
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => _GalleryDot(isActive: i == _currentPage),
                ),
              ),
            ),

          // ── Image counter ───────────────────────────────────────────────
          if (images.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String url;
  final bool isDark;

  const _GalleryImage({required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => Container(
        color: isDark ? AppColors.darkDivider : AppColors.divider,
      ),
      errorWidget: (_, __, ___) => Container(
        color: isDark ? AppColors.darkDivider : AppColors.divider,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}

class _GalleryDot extends StatelessWidget {
  final bool isActive;
  const _GalleryDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final double height;
  final bool isDark;

  const _EmptyGallery({required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: isDark ? AppColors.darkDivider : AppColors.divider,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
