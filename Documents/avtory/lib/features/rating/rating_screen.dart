import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../core/router/app_router.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/ds_card.dart';
import '../../shared/components/buttons/app_buttons.dart';
import 'widgets/animated_star.dart';
import 'widgets/review_input.dart';
import 'widgets/rating_success_sheet.dart';
import 'widgets/rating_skeleton.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({
    super.key,
    required this.requestId,
    required this.mechanicName,
  });

  final String requestId;
  final String mechanicName;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final _commentController = TextEditingController();
  final Map<String, int> _categoryRatings = {
    'quality': 0,
    'speed': 0,
    'professionalism': 0,
    'communication': 0,
  };
  bool _isLoading = false;
  bool _isSubmitting = false;

  static const _ratingLabels = [
    '',
    'Yomon',
    'Qoniqarsiz',
    'Yaxshi',
    "Zo'r",
    'Ajoyib',
  ];

  static const _ratingEmojis = [
    '',
    '😞',
    '😕',
    '🙂',
    '😊',
    '🤩',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);

    try {
      final requestId = int.tryParse(widget.requestId);
      if (requestId != null) {
        await ApiService.submitRating(
          requestId,
          _rating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );
      }
    } catch (_) {
      await AppStorage.addRating(_rating);
    }

    await AppStorage.addHistoryItem({
      'type': 'Xizmat',
      'mechanicName': widget.mechanicName,
      'status': 'completed',
      'date': _dateLabel(),
      'price': '--',
      'rating': _rating,
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await RatingSuccessSheet.show(
      context,
      mechanicName: widget.mechanicName,
      rating: _rating,
    );
  }

  String _dateLabel() {
    final d = DateTime.now();
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
      'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.cSurface,
        appBar: _buildAppBar(context),
        body: const RatingSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: context.cSurface,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStars(context)),
          SliverToBoxAdapter(child: _buildCategoryRatings(context)),
          SliverToBoxAdapter(child: _buildReviewField(context)),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildSubmitSection(context)),
          SliverToBoxAdapter(child: const SizedBox(height: 40)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(
          'Baho berish',
          style: context.headingMedium(color: context.cTextPrimary),
        ),
      backgroundColor: context.cSurface,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: AppIcon('close_rounded', size: 24),
        onPressed: () {
          if (_rating > 0 || _commentController.text.isNotEmpty) {
            _showExitConfirmation();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp2XL + 4, context.spLG, context.sp2XL + 4, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: context.gPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.cPrimary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: AppIcon(
                'build_rounded',
                color: context.cPrimary,
                size: 44,
              ),
            ),
          ),
          SizedBox(height: context.spXL),
          Text(
            'Xizmatdan qoniqdingizmi?',
            style: context.headingLarge(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w800, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spSM - 2),
          Text(
            widget.mechanicName,
            style: context.bodyMedium(color: context.cTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(BuildContext context) {
    final label = _rating > 0 ? _ratingLabels[_rating.toInt()] : '';
    final emoji = _rating > 0 ? _ratingEmojis[_rating.toInt()] : '';

    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp2XL + 4, context.sp2XL, context.sp2XL + 4, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = _rating >= i + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedStar(
                  size: 52,
                  filled: filled,
                  onTap: () => setState(() => _rating = (i + 1).toDouble()),
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            SizedBox(height: context.spMD),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: anim,
                  child: child,
                ),
              ),
              child: Row(
                key: ValueKey(_rating),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: context.spSM - 2),
                  Text(
                    label,
                    style: context.headingSmall(color: context.cRatingGold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRatings(BuildContext context) {
    final categories = [
      ('quality', 'Xizmat sifati', 'Xizmat sifati qanday edi?'),
      ('speed', 'Tezlik', 'Mexanik qanchalik tez yetib keldi?'),
      ('professionalism', 'Professionallik', 'Mexanikning ish mahorati qanday?'),
      ('communication', 'Muloqot', 'Mexanik bilan muloqot qanday edi?'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp2XL + 4, context.sp2XL, context.sp2XL + 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: context.spMD),
            child: Text(
              'Batafsil baho',
              style: context.headingSmall(color: context.cTextPrimary),
            ),
          ),
          ...categories.map((c) {
            final key = c.$1;
            final title = c.$2;
            final hint = c.$3;
            final current = _categoryRatings[key] ?? 0;

            return Padding(
              padding: EdgeInsets.only(bottom: context.spMD),
              child: DsCard(
                radius: context.radiusMD,
                hasBorder: true,
                borderColor: current > 0
                    ? context.cPrimary.withValues(alpha: 0.2)
                    : context.cBorder,
                color: context.cFieldFill,
                padding: EdgeInsets.all(context.spMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.labelLarge(color: context.cTextPrimary),
                    ),
                    SizedBox(height: context.spXS),
                    Text(
                      hint,
                      style: context.labelSmall(color: context.cTextTertiary),
                    ),
                    SizedBox(height: context.spSM),
                    Row(
                      children: List.generate(5, (i) {
                        final filled = current >= i + 1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _categoryRatings[key] = i + 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: filled
                                    ? context.cRatingGold
                                        .withValues(alpha: 0.15)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: AppIcon(
                                filled
                                    ? 'star_rounded'
                                    : 'star_border_rounded',
                                size: 18,
                                color: filled
                                    ? context.cRatingGold
                                    : context.cTextTertiary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp2XL + 4, context.spLG, context.sp2XL + 4, 0),
      child: ReviewInput(
        controller: _commentController,
        maxLength: 300,
      ),
    );
  }

  Widget _buildSubmitSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sp2XL + 4),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              if (_commentController.text.isNotEmpty || _rating > 0) {
                _showExitConfirmation();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Text(
              "Keyinroq",
              style: context.labelLarge(color: context.cTextSecondary),
            ),
          ),
          SizedBox(height: context.spSM),
          AppPrimaryButton(
            label: 'Baho yuborish',
            onPressed: _rating > 0 ? _submit : null,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.all(context.screenHorizontal),
        padding: EdgeInsets.all(context.sp2XL),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(context.radiusLG + 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.cTextTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.spXL),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.cWarning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                'info_outline',
                size: 28,
                color: context.cWarning,
              ),
            ),
            SizedBox(height: context.spLG),
            Text(
              'Baho qoldirilmadi',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            SizedBox(height: context.spSM),
            Text(
              'Fikringiz mexanik uchun juda muhim.\nKeyinroq ham baho berishingiz mumkin.',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spXL),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Qaytish',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: context.spMD),
                Expanded(
                  child: AppDangerButton(
                    label: 'Chiqish',
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.home);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
