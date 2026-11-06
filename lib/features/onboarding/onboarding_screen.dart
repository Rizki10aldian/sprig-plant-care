import 'package:flutter/material.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/widgets/pill_button.dart';
import 'package:sprig/widgets/plant_art.dart';

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.body,
    required this.art,
    required this.tint,
  });

  final String title;
  final String body;
  final PlantArtStyle art;
  final int tint;
}

const List<_OnboardingData> _pages = <_OnboardingData>[
  _OnboardingData(
    title: 'Kenali tanamanmu',
    body:
        'Jelajahi koleksi tanaman hias dan herbal lengkap dengan cahaya, air, dan tips perawatannya.',
    art: PlantArtStyle.leafy,
    tint: 0,
  ),
  _OnboardingData(
    title: 'Jadwal siram, tak lupa lagi',
    body:
        'Sprig menghitung kapan tiap tanaman perlu disiram, lalu menandainya saat waktunya tiba.',
    art: PlantArtStyle.cactus,
    tint: 2,
  ),
  _OnboardingData(
    title: 'Kebun kecil, tumbuh tiap hari',
    body:
        'Kumpulkan tanaman favoritmu dalam satu kebun dan pantau perkembangannya dengan tenang.',
    art: PlantArtStyle.fern,
    tint: 1,
  ),
];

/// Halaman 2: Onboarding (bercerita lewat tiga slide).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppMotion.resolve(context, AppMotion.medium),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Lewati', style: AppText.label),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardingPage(
                  data: _pages[i],
                  index: i,
                  controller: _controller,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  _Dots(count: _pages.length, index: _index),
                  const Spacer(),
                  PillButton(
                    label: _isLast ? 'Mulai' : 'Lanjut',
                    icon: Icons.arrow_forward_rounded,
                    expand: false,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.controller,
  });

  final _OnboardingData data;
  final int index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final ready = controller.hasClients && controller.position.haveDimensions;
        final page = ready ? (controller.page ?? index.toDouble()) : index.toDouble();
        final delta = (page - index).clamp(-1.0, 1.0).toDouble();
        final fade = (1 - delta.abs() * 0.7).clamp(0.0, 1.0).toDouble();

        final art = Transform.translate(
          offset: Offset(-delta * 80, 0),
          child: Opacity(
            opacity: fade,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: PlantArtPanel(
                    style: data.art,
                    tintIndex: data.tint,
                    radius: 36,
                    padding: const EdgeInsets.all(28),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Mascot(
                    size: 104,
                    mood: const [
                      MascotMood.wave,
                      MascotMood.happy,
                      MascotMood.idle,
                    ][index % 3],
                  ),
                ),
              ],
            ),
          ),
        );
        final text = Transform.translate(
          offset: Offset(-delta * 30, 0),
          child: Opacity(
            opacity: fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppText.display),
                const SizedBox(height: 12),
                Text(data.body, style: AppText.bodyMuted.copyWith(fontSize: 16)),
              ],
            ),
          ),
        );

        if (landscape) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(child: art),
                const SizedBox(width: 32),
                Expanded(child: SingleChildScrollView(child: text)),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(flex: 5, child: art),
              const SizedBox(height: 28),
              Expanded(flex: 3, child: text),
            ],
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.medium),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(right: 6),
            width: i == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.ink : AppColors.line,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}
