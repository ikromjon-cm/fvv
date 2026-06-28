import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/accessibility/accessibility.dart';
import '../../animations/motion.dart';
import '../../animations/animation_tokens.dart';
import '../../widgets/app_icon.dart';

// ─── Core Button Widget ───

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.appIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.isLarge = false,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.radius,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? appIcon;
  final String? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final bool isLarge;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final h = widget.height ??
        (widget.isCompact ? 40.0 : widget.isLarge ? 60.0 : 50.0);
    final fSize = widget.isCompact ? 13.0 : widget.isLarge ? 16.0 : 14.0;

    return Semantics(
      button: true,
      label: widget.label,
      enabled: _enabled,
      child: _pressCtrl.wrapGesture(
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: MotionTokens.fast,
          opacity: _enabled ? 1.0 : MotionTokens.disabledOpacity,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSemantics.minTouchTarget),
            width: widget.width ?? double.infinity,
            height: h.clamp(AppSemantics.minTouchTarget, double.infinity),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color ?? DesignTokens.primary,
              borderRadius:
                  BorderRadius.circular(widget.radius ?? DesignTokens.radiusMD),
            ),
            child: Center(
              child: widget.isLoading
                ? SizedBox(
                    width: fSize,
                    height: fSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: widget.textColor ?? Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon!,
                            size: widget.isCompact ? 16 : 20,
                            color: widget.textColor ?? Colors.white),
                        const SizedBox(width: 8),
                      ],
                      if (widget.appIcon != null) ...[
                        AppIcon(widget.appIcon!,
                            size: widget.isCompact ? 16 : 20,
                            color: widget.textColor ?? Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: fSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: widget.textColor ?? Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        AppIcon(widget.trailingIcon!,
                            size: widget.isCompact ? 16 : 20,
                            color: widget.textColor ?? Colors.white),
                      ],
                    ],
                  ),
              ),
            ),
        ),
      ),
    );
  }
}

// ─── Primary Button ───

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.appIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.isLarge = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? appIcon;
  final String? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final bool isLarge;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      appIcon: appIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isCompact: isCompact,
      isLarge: isLarge,
      width: width,
      color: DesignTokens.primary,
      textColor: Colors.white,
    );
  }
}

// ─── Secondary Button ───

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.appIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? appIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      appIcon: appIcon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isCompact: isCompact,
      width: width,
      color: context.cFieldFill,
      textColor: context.cTextPrimary,
    );
  }
}

// ─── Outlined Button ───

class AppOutlinedButton extends StatefulWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.appIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.color,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? appIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final Color? color;
  final double? width;

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? DesignTokens.primary;
    final h = (widget.isCompact ? 44.0 : 50.0);
    final fSize = widget.isCompact ? 13.0 : 14.0;

    return Semantics(
      button: true,
      label: widget.label,
      enabled: _enabled,
      child: _pressCtrl.wrapGesture(
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: MotionTokens.fast,
          opacity: _enabled ? 1.0 : MotionTokens.disabledOpacity,
          child: Container(
            width: widget.width ?? double.infinity,
            height: h,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: fSize,
                      height: fSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: color,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon!,
                              size: widget.isCompact ? 16 : 20, color: color),
                          const SizedBox(width: 8),
                        ],
                        if (widget.appIcon != null) ...[
                          AppIcon(widget.appIcon!,
                              size: widget.isCompact ? 16 : 20, color: color),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: fSize,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: color,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Text Button ───

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.color,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isDisabled;
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSemantics.minTouchTarget),
          child: AnimatedOpacity(
            duration: MotionTokens.fast,
            opacity: enabled ? 1.0 : MotionTokens.disabledOpacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color ?? DesignTokens.primary,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize ?? 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: color ?? DesignTokens.primary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Danger Button ───

class AppDangerButton extends StatelessWidget {
  const AppDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isCompact: isCompact,
      width: width,
      color: DesignTokens.danger,
      textColor: Colors.white,
    );
  }
}

// ─── Success Button ───

class AppSuccessButton extends StatelessWidget {
  const AppSuccessButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isCompact: isCompact,
      width: width,
      color: DesignTokens.success,
      textColor: Colors.white,
    );
  }
}

// ─── Icon Button ───

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.appIcon,
    this.onPressed,
    this.size = 44,
    this.color,
    this.backgroundColor,
    this.radius,
    this.isDisabled = false,
  });

  final IconData icon;
  final String? appIcon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double? radius;
  final bool isDisabled;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this, scale: 0.90);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isDisabled;
    final s = widget.size.clamp(AppSemantics.minTouchTarget, double.infinity);
    return Semantics(
      button: true,
      label: widget.appIcon ?? widget.icon.toString(),
      enabled: enabled,
      child: _pressCtrl.wrapGesture(
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: MotionTokens.fast,
          opacity: enabled ? 1.0 : MotionTokens.disabledOpacity,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: widget.backgroundColor ??
                  (enabled
                      ? context.cFieldFill
                      : context.cBorder.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(
                  widget.radius ?? s / 3),
            ),
            child: widget.appIcon != null
                ? AppIcon(widget.appIcon!,
                    size: s * 0.5,
                    color: widget.color ??
                        (enabled
                            ? context.cTextPrimary
                            : context.cTextTertiary))
                : Icon(widget.icon,
                    size: s * 0.5,
                    color: widget.color ??
                        (enabled
                            ? context.cTextPrimary
                            : context.cTextTertiary)),
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Button ───

class AppGradientButton extends StatefulWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF1A56CC), Color(0xFF4F46E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.icon,
    this.appIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isCompact = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final IconData? icon;
  final String? appIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isCompact;
  final double? width;

  @override
  State<AppGradientButton> createState() => _AppGradientButtonState();
}

class _AppGradientButtonState extends State<AppGradientButton>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final h = (widget.isCompact ? 44.0 : 50.0);
    final fSize = widget.isCompact ? 13.0 : 14.0;

    return Semantics(
      button: true,
      label: widget.label,
      enabled: _enabled,
      child: _pressCtrl.wrapGesture(
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: MotionTokens.fast,
          opacity: _enabled ? 1.0 : MotionTokens.disabledOpacity,
          child: Container(
            width: widget.width ?? double.infinity,
            height: h,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusMD),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first
                    .withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon!,
                            size: widget.isCompact ? 16 : 20,
                            color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      if (widget.appIcon != null) ...[
                        AppIcon(widget.appIcon!,
                            size: widget.isCompact ? 16 : 20,
                            color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: fSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      ),
    );
  }
}

// ─── Loading Button ───

class AppLoadingButton extends StatelessWidget {
  const AppLoadingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
    );
  }
}
