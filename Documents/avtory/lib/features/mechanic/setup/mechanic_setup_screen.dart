import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/constants/app_text_styles.dart';
import 'service_prices_screen.dart';
import 'workshop_screen.dart';
import '../../../shared/widgets/app_icon.dart';

class MechanicSetupScreen extends StatefulWidget {
  const MechanicSetupScreen({super.key});

  @override
  State<MechanicSetupScreen> createState() => _MechanicSetupScreenState();
}

class _MechanicSetupScreenState extends State<MechanicSetupScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cSurface,
      body: SafeArea(
        child: Column(
          children: [
            _progressBar(),
            Expanded(
              child: _step == 0
                  ? _WelcomeStep(onStart: () => setState(() => _step = 1))
                  : _step == 1
                      ? const ServicePricesScreen(
                          key: ValueKey('prices'),
                          isSetup: true,
                        )
                      : const WorkshopScreen(
                          key: ValueKey('workshop'),
                          isSetup: true,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    if (_step == 0) return const SizedBox.shrink();
    return Container(
      color: context.cSurface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sozlash $_step/2', style: AppTextStyles.caption),
              GestureDetector(
                onTap: () => context.go('/mechanic-dashboard'),
                child: Text("O'tkazib yuborish",
                    style: AppTextStyles.caption.copyWith(color: DesignTokens.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: DesignTokens.animationNormal,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: DesignTokens.animationNormal,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _step >= 2 ? DesignTokens.primary : context.cBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primary.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const AppIcon('build_circle_rounded', color: Colors.white, size: 56),
          ),
          const SizedBox(height: 40),
          const Text('Xush kelibsiz!', style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            "Haydovchilarga ko'rinishingiz uchun xizmat narxlaringizni va ustaxona joylashuvingizni belgilang.",
            style: AppTextStyles.body.copyWith(color: context.cTextSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const _StepItem(num: '1', title: 'Xizmatlar va narxlar', desc: 'Qaysi xizmatlarni va qancha narxda taklif qilasiz'),
          const SizedBox(height: 16),
          const _StepItem(num: '2', title: 'Joylashuv va ustaxona', desc: 'GPS bilan manzilni aniqlang va ish vaqtini belgilang'),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
                elevation: 0,
              ),
              child: const Text('Boshlash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/mechanic-dashboard'),
            child: Text("Keyinroq sozlayman",
                style: AppTextStyles.body.copyWith(color: context.cTextGray)),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.num, required this.title, required this.desc});
  final String num;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(gradient: DesignTokens.primaryGradient, shape: BoxShape.circle),
          child: Center(
            child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(desc, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
