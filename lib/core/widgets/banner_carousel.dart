import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:SaveMed/core/services/highlight_banner_service.dart';
import 'package:SaveMed/core/theme/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final HighlightBannerService _service = HighlightBannerService();

  late final PageController _controller;
  Timer? _timer;

  List<String> _banners = [];
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _loadBanners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _service.getBannerImages();
      if (!mounted) return;

      setState(() {
        _banners = banners;
        _loading = false;
      });

      if (banners.length > 1) {
        _timer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (!_controller.hasClients || _banners.isEmpty) return;
          _currentIndex = (_currentIndex + 1) % _banners.length;
          _controller.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOutCubic,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 700;
        final height = isMobile ? 190.0 : 290.0;

        if (_loading) {
          return _BannerShell(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _BannerShell(
              height: height,
              child: ScrollConfiguration(
                behavior: _MouseDragScrollBehavior(),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (_, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: _BannerImage(imageSource: _banners[index]),
                    );
                  },
                ),
              ),
            ),
            if (_banners.length > 1) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: _currentIndex == index
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerImage extends StatelessWidget {
  final String imageSource;

  const _BannerImage({required this.imageSource});

  @override
  Widget build(BuildContext context) {
    if (imageSource.startsWith('data:image')) {
      final commaIndex = imageSource.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(imageSource.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _BannerFallback(),
          );
        } catch (_) {
          return const _BannerFallback();
        }
      }
    }

    return Image.network(
      imageSource,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _BannerFallback(),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 38,
        color: AppColors.primaryDark,
      ),
    );
  }
}

class _BannerShell extends StatelessWidget {
  final double height;
  final Widget child;

  const _BannerShell({
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
