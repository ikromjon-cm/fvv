import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/components/buttons/app_buttons.dart';

class RatingSuccessSheet extends StatefulWidget {
  const RatingSuccessSheet({
    super.key,
    required this.mechanicName,
    required this.rating,
  });

  final String mechanicName;
  final double rating;

  static Future<void> show(
    BuildContext context, {
    required String mechanicName,
    required double rating,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RatingSuccessSheet(
        mechanicName: mechanicName,
        rating: rating,
      ),
    );
  }

  @override
  State<RatingSuccessSheet> createState() => _RatingSuccessSheetState();
}

class _RatingSuccessSheetState extends State<RatingSuccessSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.screenHorizontal),
      padding: EdgeInsets.fromLTRB(context.sp2XL + 4, context.sp4XL, context.sp2XL + 4, context.sp2XL),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DesignTokens.star, DesignTokens.emergency],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.star.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: AppIcon(
                    'emoji_events_rounded',
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Rahmat!',
                style: context.headingLarge(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w800, fontSize: 24),
              ),
              SizedBox(height: context.spSM),
              Text(
                'Sizning fikringiz ${widget.mechanicName} uchun juda muhim!',
                style: context.bodyMedium(color: context.cTextSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spLG),
              Container(
                padding: EdgeInsets.all(context.spMD),
                decoration: BoxDecoration(
                  color: context.cFieldFill,
                  borderRadius: BorderRadius.circular(context.radiusMD),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(5, (i) {
                      final filled = widget.rating >= i + 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AppIcon(
                          filled ? 'star_rounded' : 'star_border_rounded',
                          size: 20,
                          color: filled
                              ? DesignTokens.star
                              : context.cTextTertiary,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: context.sp2XL),
              AppPrimaryButton(
                label: 'Bosh sahifaga',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.home);
                },
              ),
              SizedBox(height: context.spSM),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.history);
                },
                child: Text(
                  'Tarixni ko\'rish',
                  style: context.labelLarge(color: context.cTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
