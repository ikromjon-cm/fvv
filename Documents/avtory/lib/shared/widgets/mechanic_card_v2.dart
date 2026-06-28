import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/accessibility/accessibility.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../data/models/user_model.dart';
import '../animations/motion.dart';
import 'app_icon.dart';
import 'mechanic_avatar.dart';
import 'ds_card.dart';
import 'ds_chip.dart';
import 'ds_badge.dart';

class MechanicCardV2 extends StatefulWidget {
  const MechanicCardV2({
    super.key,
    required this.data,
    this.isFavorite,
    this.onCall,
    this.onChat,
    this.onTap,
    this.onFavorite,
    this.onDirections,
  });

  factory MechanicCardV2.fromMechanicWithProfile({
    required MechanicWithProfile mechanic,
    VoidCallback? onCall,
    VoidCallback? onChat,
    VoidCallback? onTap,
    VoidCallback? onFavorite,
    VoidCallback? onDirections,
  }) {
    final profile = mechanic.profile;
    final user = mechanic.user;
    return MechanicCardV2(
      data: {
        'name': user.fullName.split(' ').first,
        'surname': user.fullName.split(' ').length > 1
            ? user.fullName.split(' ').sublist(1).join(' ')
            : '',
        'avatar': user.avatar,
        'is_available': profile.isAvailable,
        'avg_rating': profile.avgRating,
        'total_reviews': profile.totalReviews,
        'total_jobs': profile.totalJobs,
        'distance_km': profile.distanceKm,
        'eta_minutes': profile.etaMinutes,
        'services': profile.services,
        'is_verified': profile.isVerified,
        'is_favorite': profile.isFavorite,
        'starting_price': profile.startingPrice,
        'mechanic_id': user.id,
        'phone': user.phone,
      },
      isFavorite: profile.isFavorite,
      onCall: onCall,
      onChat: onChat,
      onTap: onTap,
      onFavorite: onFavorite,
      onDirections: onDirections,
    );
  }

  final Map<String, dynamic> data;
  final bool? isFavorite;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDirections;

  @override
  State<MechanicCardV2> createState() => _MechanicCardV2State();
}

class _MechanicCardV2State extends State<MechanicCardV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _favCtrl;
  late Animation<double> _favScale;

  @override
  void initState() {
    super.initState();
    _favCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _favScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _favCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _favCtrl.dispose();
    super.dispose();
  }

  String get _name {
    final n = widget.data['name'] as String? ?? '';
    final s = widget.data['surname'] as String? ?? '';
    return '$n $s'.trim();
  }

  bool get _isAvailable => widget.data['is_available'] == true;
  double get _rating => (widget.data['avg_rating'] as num?)?.toDouble() ?? 0;
  int get _reviews => widget.data['total_reviews'] as int? ?? 0;
  int get _jobs => widget.data['total_jobs'] as int? ?? 0;
  double? get _distance => (widget.data['distance_km'] as num?)?.toDouble();
  int? get _eta => widget.data['eta_minutes'] as int?;
  bool get _isVerified => widget.data['is_verified'] == true;
  bool get _isFav => widget.isFavorite ?? widget.data['is_favorite'] == true;
  List<String> get _services =>
      (widget.data['services'] as List?)?.cast<String>() ?? [];
  int? get _startingPrice => widget.data['starting_price'] as int?;

  void _onFavorite() {
    HapticFeedback.lightImpact();
    widget.onFavorite?.call();
    _favCtrl.forward().then((_) => _favCtrl.reverse());
  }

  Color _statusColor(BuildContext context) {
    if (_isAvailable) return context.cOnline;
    return context.cOffline;
  }

  Color _statusBgColor(BuildContext context) {
    if (_isAvailable) return context.cSuccess.withValues(alpha: 0.1);
    return context.cOffline.withValues(alpha: 0.1);
  }

  String _statusLabel() {
    return _isAvailable ? "Bo'sh" : 'Band';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data['name'] as String? ?? '';
    return DsCard(
      onTap: widget.onTap,
      radius: context.radiusXL,
      shadows: context.shadowMD,
      hasBorder: true,
      borderColor: _isAvailable
          ? context.cSuccess.withValues(alpha: 0.15)
          : context.cBorder,
      color: context.cCard,
      padding: EdgeInsets.zero,
      child: Semantics(
        button: true,
        label: name,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.spLG,
                context.spLG,
                context.spLG,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(context),
                  SizedBox(width: context.spMD),
                  Expanded(child: _buildInfo(context, _rating)),
                ],
              ),
            ),
            if (_services.isNotEmpty || _distance != null || _eta != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.spLG,
                  context.spSM,
                  context.spLG,
                  0,
                ),
                child: _buildMeta(context),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.spSM,
                context.spSM,
                context.spSM,
                context.spSM,
              ),
              child: _buildActions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final avatar = widget.data['avatar'] as String?;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _isVerified
                  ? context.cVerified
                  : context.cBorder,
              width: _isVerified ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: context.cPrimary.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: MechanicAvatar(
            avatar: avatar,
            name: _name,
            size: 56,
          ),
        ),
        Positioned(
          bottom: 0,
          right: -2,
          child: DsStatusDot(
            isActive: _isAvailable,
            activeColor: context.cOnline,
            size: 14,
          ),
        ),
        if (_isVerified)
          Positioned(
            top: -2,
            right: -4,
            child: Container(
              width: context.spXL,
              height: context.spXL,
              decoration: BoxDecoration(
                color: context.cVerified,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.cVerified.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: AppIcon('verified',
                  size: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context, double rating) {
    final price = _startingPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _name.isNotEmpty ? _name : 'Usta',
                style: context.headingMedium(color: context.cTextPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: context.spXS),
        Row(
          children: [
            ...List.generate(5, (i) {
              final filled = rating >= i + 0.5;
              return Padding(
                padding: const EdgeInsets.only(right: 1),
                child: AppIcon(
                  filled ? 'star_rounded' : 'star_outline',
                  size: 14,
                  color: filled
                      ? context.cRatingGold
                      : context.cTextTertiary,
                ),
              );
            }),
            SizedBox(width: context.spXS),
            Text(
              rating.toStringAsFixed(1),
              style: context.labelLarge(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w700),
            ),
            if (_reviews > 0) ...[
              SizedBox(width: context.spXXS),
              Text(
                '($_reviews)',
                style: context.labelSmall(color: context.cTextTertiary),
              ),
            ],
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spSM,
                vertical: context.spXXS,
              ),
              decoration: BoxDecoration(
                color: _statusBgColor(context),
                borderRadius:
                    BorderRadius.circular(context.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DsStatusDot(
                    isActive: _isAvailable,
                    activeColor: context.cOnline,
                    size: 6,
                  ),
                  SizedBox(width: context.spXS),
                  Text(
                    _statusLabel(),
                    style: context.labelSmall(color: _statusColor(context)).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.spXS),
        Row(
          children: [
            if (_isVerified)
              Padding(
                padding: EdgeInsets.only(right: context.spSM),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon('verified',
                        size: 12, color: context.cVerified),
                    SizedBox(width: context.spXXS),
                    Text(
                      'Tasdiqlangan',
                      style: context.labelSmall(color: context.cVerified).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (price != null && _jobs > 0)
              Text(
                '$_jobs ish',
                style: context.labelSmall(color: context.cTextTertiary),
              ),
            if (price != null && _jobs > 0 && _isVerified)
              Text(
                ' • ',
                style: context.labelSmall(color: context.cTextTertiary),
              ),
            if (price != null)
              Text(
                '≈ ${(price / 1000).round()} 000 so\'m',
                style: context.labelSmall(color: context.cPrimary).copyWith(fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeta(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          ...(_services.take(2).map((s) => Padding(
                padding: EdgeInsets.only(right: context.spXS),
                child: DsServiceChip(label: s),
              ))),
          const Spacer(),
          if (_distance != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon('location_on_rounded',
                    size: 12, color: context.cTextTertiary),
                SizedBox(width: context.spXXS),
                Text(
                  '${_distance!.toStringAsFixed(1)} km',
                  style: context.labelSmall(color: context.cTextSecondary).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          if (_distance != null && _eta != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.spXS),
              child: Text(
                '•',
                style: context.labelSmall(color: context.cTextTertiary),
              ),
            ),
          if (_eta != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon('timer_outlined',
                    size: 12, color: context.cSuccess),
                SizedBox(width: context.spXXS),
                Text(
                  '$_eta min',
                  style: context.labelSmall(color: context.cSuccess).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            )
          else if (_distance != null)
            Text(
              'Hisoblanmoqda...',
              style: context.labelSmall(color: context.cTextTertiary).copyWith(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cFieldFill.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.radiusMD),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.spaceXXS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: 'phone_outlined',
            label: 'Qo\'ng\'iroq',
            color: context.cSuccess,
            onTap: widget.onCall,
          ),
          Container(
            width: 1,
            height: 24,
            color: context.cBorder.withValues(alpha: 0.5),
          ),
          _ActionButton(
            icon: 'chat_bubble_outline',
            label: 'Xabar',
            color: context.cPrimary,
            onTap: widget.onChat,
          ),
          Container(
            width: 1,
            height: 24,
            color: context.cBorder.withValues(alpha: 0.5),
          ),
          _ActionButton(
            icon: 'person_outline_rounded',
            label: 'Profil',
            color: context.cPrimaryLight,
            onTap: widget.onTap,
          ),
          Container(
            width: 1,
            height: 24,
            color: context.cBorder.withValues(alpha: 0.5),
          ),
          AppSemantics.touchTarget(
            minSize: 44,
            onTap: _onFavorite,
            child: AnimatedBuilder(
              animation: _favScale,
              builder: (_, __) {
                return Transform.scale(
                  scale: _favCtrl.isAnimating
                      ? _favScale.value
                      : 1.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spLG,
                      vertical: context.spSM,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          _isFav ? 'favorite' : 'favorite_border',
                          size: 18,
                          color: _isFav
                              ? context.cDanger
                              : context.cTextTertiary,
                        ),
                        SizedBox(height: context.spXXS),
                        Text(
                          'Sevimli',
                          style: context.bodySmall(color: context.cTextTertiary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this, scale: 0.92);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSemantics.touchTarget(
      minSize: 44,
      onTap: widget.onTap,
      child: _pressCtrl.wrapGesture(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spLG,
            vertical: context.spSM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(widget.icon,
                  size: 18, color: widget.color),
              SizedBox(height: context.spXXS),
              Text(
                widget.label,
                style: context.bodySmall(color: widget.color).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
