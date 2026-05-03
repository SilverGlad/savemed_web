import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  late Timer _timer;

  int _currentIndex = 0;

  final List<_BannerItem> banners = const [
    _BannerItem(
      assetPath: 'assets/banners/banner1.jpg',
      eyebrow: 'Entrega agil',
      title: 'Seu cuidado diario sem fila e sem pressa',
      subtitle:
          'Medicamentos, higiene e beleza com experiencia mobile simples.',
    ),
    _BannerItem(
      assetPath: 'assets/banners/banner2.jpg',
      eyebrow: 'Descontos reais',
      title: 'Ofertas que fazem sentido para o bolso',
      subtitle: 'Combine itens essenciais e finalize com poucos toques.',
    ),
    _BannerItem(
      assetPath: 'assets/banners/banner3.jpg',
      eyebrow: 'Farmacias confiaveis',
      title: 'Compare opcoes e encontre o melhor estoque',
      subtitle: 'Mais clareza na busca, mais rapidez no pedido.',
    ),
    _BannerItem(
      assetPath: 'assets/banners/banner4.jpg',
      eyebrow: 'Experiencia SaveMed',
      title: 'Cuidado continuo com visual mais leve',
      subtitle: 'Uma vitrine mais moderna para navegar bem no celular.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.94);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      _currentIndex = (_currentIndex + 1) % banners.length;
      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
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
        final isMobile = constraints.maxWidth <= 700;
        final height = isMobile ? 232.0 : constraints.maxWidth * 0.3;

        return Column(
          children: [
            SizedBox(
              height: height.clamp(220, 430),
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
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              banner.assetPath,
                              fit: BoxFit.cover,
                              alignment: Alignment.centerRight,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.primaryDark.withValues(
                                      alpha: 0.88,
                                    ),
                                    AppColors.primary.withValues(alpha: 0.54),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.42, 1.0],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(isMobile ? 22 : 12),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isMobile ? 220 : 360,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.95,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        banner.eyebrow,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      banner.title,
                                      style: TextStyle(
                                        fontSize: isMobile ? 28 : 38,
                                        height: 1.02,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      banner.subtitle,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 15,
                                        height: 1.35,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: _currentIndex == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.22),
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
  final String eyebrow;
  final String title;
  final String subtitle;

  const _BannerItem({
    required this.assetPath,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
}
