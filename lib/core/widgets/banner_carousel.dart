import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../services/content_service.dart';
import '../../models/content_block.dart';

class BannerCarousel extends StatefulWidget {
  final ValueChanged<String>? onCta;

  const BannerCarousel({super.key, this.onCta});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  late Timer _timer;

  int _currentIndex = 0;

  List<_BannerItem> banners = const [
    _BannerItem(
      assetPath: 'assets/images/editorial/delivery.jpeg',
      eyebrow: 'Entrega em Americana e região',
      title: 'Remédio sem pagar caro.',
      subtitle:
          'Medicamentos, higiene e beleza com experiência mobile simples.',
    ),
    _BannerItem(
      assetPath: 'assets/images/editorial/paracetamol_front.jpeg',
      eyebrow: 'Descontos reais',
      title: 'Medicamentos lacrados e dentro do prazo.',
      subtitle: 'Economia de verdade com farmácias regularizadas.',
    ),
    _BannerItem(
      assetPath: 'assets/images/editorial/family.jpeg',
      eyebrow: 'Farmácias confiáveis',
      title: 'Compare opções e encontre o melhor estoque',
      subtitle: 'Mais clareza na busca, mais rapidez no pedido.',
    ),
    _BannerItem(
      assetPath: 'assets/images/editorial/maternity.jpeg',
      eyebrow: 'Pequenos cuidados',
      title: 'Cuidar hoje é cuidar de amanhã.',
      subtitle: 'Conteúdo e produtos para cada fase da sua vida.',
    ),
  ];

  bool _loadedRemote = false;
  bool _isPaused = false;
  bool _autoPlay = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedRemote) return;
    _loadedRemote = true;
    _loadRemoteContent();
  }

  Future<void> _loadRemoteContent() async {
    try {
      final remote = await const ContentService().getActive();
      if (!mounted || remote.isEmpty) return;
      setState(() {
        banners = remote.map(_BannerItem.fromContent).toList();
        _currentIndex = 0;
      });
    } catch (_) {
      // The local editorial fallback keeps the app usable when offline.
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.94);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_autoPlay ||
          _isPaused ||
          !_controller.hasClients ||
          banners.length < 2 ||
          MediaQuery.disableAnimationsOf(context)) {
        return;
      }
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
        final textWidth = (constraints.maxWidth * 0.94 - (isMobile ? 56 : 36))
            .clamp(100.0, double.infinity);
        double measuredHeight(String text, double size, double lineHeight) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: size,
                height: lineHeight,
                fontWeight: FontWeight.w700,
              ),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: textWidth);
          final height = painter.height;
          painter.dispose();
          return height;
        }

        final height = banners.fold<double>(isMobile ? 232 : 300, (
          maximum,
          banner,
        ) {
          final required =
              110 +
              measuredHeight(banner.eyebrow, 11, 1.2) +
              measuredHeight(banner.title, isMobile ? 28 : 38, 1.02) +
              measuredHeight(banner.subtitle, isMobile ? 13 : 15, 1.35) +
              (banner.ctaLabel.isEmpty
                  ? 0
                  : 48 * MediaQuery.textScalerOf(context).scale(1));
          return required > maximum ? required : maximum;
        });

        return Column(
          children: [
            SizedBox(
              height: height,
              child: ScrollConfiguration(
                behavior: _MouseDragScrollBehavior(),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isPaused = true),
                  onExit: (_) => setState(() => _isPaused = false),
                  child: Focus(
                    onFocusChange: (focused) =>
                        setState(() => _isPaused = focused),
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
                                banner.imageUrl != null
                                    ? Image.network(
                                        banner.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
                                              banner.assetPath,
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                    : Image.asset(
                                        banner.assetPath,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.centerRight,
                                      ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.38),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isMobile ? 22 : 12),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: isMobile ? 220 : 360,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        if (banner.ctaLabel.isNotEmpty) ...[
                                          const SizedBox(height: 14),
                                          FilledButton.icon(
                                            onPressed: widget.onCta == null
                                                ? null
                                                : () => widget.onCta!(
                                                    banner.ctaUrl,
                                                  ),
                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 17,
                                            ),
                                            label: Text(banner.ctaLabel),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: AppColors.accent,
                                              foregroundColor:
                                                  AppColors.textDark,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 11,
                                                  ),
                                            ),
                                          ),
                                        ],
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
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Banner anterior',
                  onPressed: () => _controller.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_currentIndex + 1} / ${banners.length}',
                  style: const TextStyle(color: AppColors.textLight),
                ),
                IconButton(
                  tooltip: _autoPlay ? 'Pausar banners' : 'Reproduzir banners',
                  onPressed: () => setState(() => _autoPlay = !_autoPlay),
                  icon: Icon(_autoPlay ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  tooltip: 'Próximo banner',
                  onPressed: () => _controller.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
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
  final String? imageUrl;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String ctaUrl;

  const _BannerItem({
    required this.assetPath,
    this.imageUrl,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.ctaLabel = '',
    this.ctaUrl = '',
  });

  factory _BannerItem.fromContent(ContentBlock item) => _BannerItem(
    assetPath: 'assets/images/editorial/delivery.jpeg',
    imageUrl: item.image,
    eyebrow: item.eyebrow.isEmpty ? _prettySlug(item.slug) : item.eyebrow,
    title: item.title,
    subtitle: item.subtitle.isEmpty ? item.body : item.subtitle,
    ctaLabel: item.ctaLabel,
    ctaUrl: item.ctaUrl,
  );
}

String _prettySlug(String slug) {
  final words = slug.replaceAll('-', ' ').trim();
  if (words.isEmpty) return 'SaveMed';
  return words[0].toUpperCase() + words.substring(1);
}
