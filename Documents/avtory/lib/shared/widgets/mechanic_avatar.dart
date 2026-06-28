import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/utils/photo_picker.dart';

/// Shows a mechanic's uploaded photo (base64 data-URL), or a clean
/// initial-letter fallback in a brand-tinted circle when there is no photo.
class MechanicAvatar extends StatelessWidget {
  const MechanicAvatar({
    super.key,
    this.avatar,
    this.name = '',
    this.size = 48,
    this.borderColor,
  });

  final String? avatar;
  final String name;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final bytes = decodeDataUrl(avatar);
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    // Stable colour per name so the same mechanic always gets the same tint.
    final palette = [
      DesignTokens.primary, DesignTokens.success, const Color(0xFF0EA5E9),
      const Color(0xFFF59E0B), const Color(0xFF8B5CF6), const Color(0xFFEF4444),
    ];
    final color = palette[letter.codeUnitAt(0) % palette.length];

    final border = borderColor != null
        ? Border.all(color: borderColor!, width: 2)
        : null;

    if (bytes != null) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: color,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
