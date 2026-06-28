import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../shared/widgets/app_icon.dart';

enum AvatarState { loading, loaded, error }

class PremiumAvatar extends StatelessWidget {
  const PremiumAvatar({
    super.key,
    this.imageUrl,
    this.name = '',
    this.size = 44,
    this.isOnline = false,
    this.hasVerifiedBadge = false,
    this.state = AvatarState.loaded,
    this.onTap,
  });

  final String? imageUrl;
  final String name;
  final double size;
  final bool isOnline;
  final bool hasVerifiedBadge;
  final AvatarState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size;
    final onlineDotSize = size * 0.28;
    final badgeSize = size * 0.36;

    Widget avatarWidget;

    switch (state) {
      case AvatarState.loading:
        avatarWidget = _buildLoading(avatarSize);
      case AvatarState.error:
        avatarWidget = _buildFallback(avatarSize);
      case AvatarState.loaded:
        if (imageUrl != null && imageUrl!.isNotEmpty) {
          avatarWidget = _buildImage(avatarSize);
        } else {
          avatarWidget = _buildFallback(avatarSize);
        }
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: avatarSize + 4,
        height: avatarSize + 4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatarWidget,
            if (isOnline)
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: onlineDotSize,
                  height: onlineDotSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withAlpha(60),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasVerifiedBadge)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon('verified',
                      size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56CC).withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl!,
          width: s,
          height: s,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(s),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _buildLoading(s);
          },
        ),
      ),
    );
  }

  Widget _buildFallback(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        gradient: DesignTokens.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56CC).withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: s * 0.4,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: s * 0.35,
          height: s * 0.35,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF1A56CC),
          ),
        ),
      ),
    );
  }
}
