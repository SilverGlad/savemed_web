import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  late Timer _timer;

  int _currentIndex = 0;

  final List<_BannerItem> banners = [
    _BannerItem(assetPath: 'assets/banners/banner1.jpg'),
    _BannerItem(assetPath: 'assets/banners/banner2.jpg'),
    _BannerItem(assetPath: 'assets/banners/banner3.jpg'),
    _BannerItem(assetPath: 'assets/banners/banner4.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;

      _currentIndex = (_currentIndex + 1) % banners.length;

      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 📐 Altura responsiva
        final double bannerHeight = constraints.maxWidth * 0.32;

        return Column(
          children: [
            SizedBox(
              height: bannerHeight.clamp(180, 420),
              child: ScrollConfiguration(
                behavior: _MouseDragScrollBehavior(),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (_, index) {
                    final banner = banners[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: AssetImage(banner.assetPath),
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.45),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔘 Indicador de páginas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == index
                        ? Colors.green
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

class _BannerItem {
  final String assetPath;

  _BannerItem({required this.assetPath});
}
