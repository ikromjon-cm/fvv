import 'package:flutter/services.dart';
import '../../core/constants/design_tokens.dart';

class HapticUtils {
  HapticUtils._();

  static Future<void> light() =>
      HapticFeedback.lightImpact();
  static Future<void> medium() =>
      HapticFeedback.mediumImpact();
  static Future<void> heavy() =>
      HapticFeedback.heavyImpact();
  static Future<void> selection() =>
      HapticFeedback.selectionClick();
  static Future<void> success() =>
      HapticFeedback.mediumImpact();

  static Future<void> press() async {
    if (DesignTokens.useHaptic) await HapticFeedback.lightImpact();
  }

  static Future<void> longPress() async {
    if (DesignTokens.useHaptic) await HapticFeedback.heavyImpact();
  }

  static Future<void> toggle() async {
    if (DesignTokens.useHaptic) await HapticFeedback.selectionClick();
  }

  static Future<void> error() async {
    if (DesignTokens.useHaptic) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.heavyImpact();
    }
  }
}
