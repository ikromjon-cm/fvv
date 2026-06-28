import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/accessibility/accessibility.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/adaptive_spacing.dart';
import '../../core/responsive/adaptive_typography.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_icon.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _page = PageController(viewportFraction: 1);
  int _idx = 0;
  double _pageOffset = 0;

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;

  static const _pages = [
    _PageData(
      'Yaqin mexanikni toping',
      "GPS orqali sizga eng yaqin va eng yaxshi baholangan ustalarni bir zumda toping",
      'location_on_rounded',
    ),
    _PageData(
      'Jonli kuzatuv',
      "Mexanik yo'lga chiqqanidan boshlab uning joylashuvini xaritada real vaqtda kuzating",
      'near_me_rounded',
    ),
    _PageData(
      'Tez yordam. Har doim.',
      "O'zbekiston bo'ylab istalgan joyda tez va ishonchli yo'l yordami",
      'verified_rounded',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _btnScale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
    _page.addListener(() {
      setState(() => _pageOffset = _page.page ?? _idx.toDouble());
    });
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_idx < _pages.length - 1) {
      _page.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _page.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (_, i) => _OnboardingPage(
              index: i,
              pageOffset: _pageOffset,
              data: _pages[i],
              isCurrent: i == _idx,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.screenHorizontal, vertical: context.spSM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const AppIcon('build_rounded',
                                  color: Colors.white, size: 16),
                            ),
                            SizedBox(width: context.spSM),
                            AppSemantics.header(
                              label: 'AVTORY',
                              child: const Text('AVTORY',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Inter')),
                            ),
                          ],
                        ),
                        if (_idx < _pages.length - 1)
                          Semantics(
                            button: true,
                            label: "O'tkazib yuborish",
                            child: TextButton(
                              onPressed: _finish,
                              child: Text("O'tkazib yuborish",
                                  style: context.labelLarge(color: Colors.white60)),
                            ),
                          )
                        else
                          const SizedBox(width: 100),
                      ],
                    ),
                  ),
                const Spacer(),
                _MorphingIndicator(count: _pages.length, index: _idx),
                SizedBox(height: context.sp3XL - context.spSM),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
                  child: _buildButton(),
                ),
                SizedBox(height: context.sectionGap + context.spSM),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    final isLast = _idx == _pages.length - 1;
    return Semantics(
      button: true,
      label: isLast ? 'AVTORY ni boshlash' : 'Keyingisi',
      child: GestureDetector(
        onTapDown: isLast ? null : (_) => _btnCtrl.forward(),
        onTapUp: isLast ? null : (_) => _btnCtrl.reverse(),
        onTapCancel: () => _btnCtrl.reverse(),
        child: ScaleTransition(
          scale: isLast ? const AlwaysStoppedAnimation(1.0) : _btnScale,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _next,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'AVTORY ni boshlash' : 'Keyingisi',
                        style: context.headingSmall(color: const Color(0xFF0F172A)),
                      ),
                      if (!isLast) ...[
                        SizedBox(width: context.spSM),
                        const AppIcon('arrow_forward_rounded',
                            color: Color(0xFF0F172A), size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData(this.title, this.description, this.icon);
  final String title;
  final String description;
  final String icon;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.index,
    required this.pageOffset,
    required this.data,
    required this.isCurrent,
  });
  final int index;
  final double pageOffset;
  final _PageData data;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final offset = (pageOffset - index).clamp(-1.0, 1.0);
    final parallax = offset * 0.15;
    final opacity = 1.0 - (offset.abs() * 0.3).clamp(0.0, 1.0);
    final scale = 1.0 - (offset.abs() * 0.08).clamp(0.0, 0.5);

    final colors = [
      [const Color(0xFF1A56CC), const Color(0xFF4F46E5)],
      [const Color(0xFF0EA5E9), const Color(0xFF2563EB)],
      [const Color(0xFF059669), const Color(0xFF10B981)],
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors[index],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal + context.spLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: context.sp5XL + context.sp2XL),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(-parallax * 30, parallax * 15),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(parallax * 20, -parallax * 10),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: AppIcon(data.icon,
                              color: colors[index][0], size: 56),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sectionGap + context.spLG),
              Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(parallax * 40, 0),
                  child: Column(
                    children: [
                      Semantics(
                        header: true,
                        label: data.title,
                        child: Text(
                          data.title,
                          style: context.headingMedium(color: Colors.white).copyWith(
                              fontSize: context.scaled(30),
                              fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: context.cardGap + context.spXXS),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.spSM),
                        child: Text(
                          data.description,
                          style: context.bodyMedium(color: Colors.white.withValues(alpha: 0.85)).copyWith(height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _MorphingIndicator extends StatelessWidget {
  const _MorphingIndicator({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sahifa $index / $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(horizontal: context.spXXS + 1),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(context.radiusFull),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
