import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/accessibility/accessibility.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_surface.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, this.devCode});
  final String phone;
  final String? devCode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  int _secondsLeft = 45;
  Timer? _timer;
  bool _isResending = false;

  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsLeft = 45);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
        if (mounted) setState(() {});
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    context.read<AuthBloc>().add(AuthSendOtp(widget.phone));
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isResending = false);
      _startTimer();
    }
  }

  String get _timerText {
    final s = _secondsLeft % 60;
    final m = _secondsLeft ~/ 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    return '${phone.substring(0, 4)}** *** **${phone.substring(phone.length - 2)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == 'admin') {
            context.go(AppRoutes.adminDashboard);
          } else if (state.needsProfile || state.role.isEmpty) {
            final profileRole = state.role.isNotEmpty ? state.role : 'driver';
            context.go('${AppRoutes.profileCreate}?role=$profileRole');
          } else if (state.role == 'mechanic') {
            context.go(state.needsSetup
                ? AppRoutes.mechanicSetup
                : AppRoutes.mechanicDashboard);
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      builder: (context, state) {
        final isBlocked = state is AuthBlocked;
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: context.cScaffold,
          appBar: AppBar(
            backgroundColor: context.cScaffold,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const AppIcon('arrow_back_ios_new', size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: context.cardGap + context.spSM),
                  _buildIcon(),
                  SizedBox(height: context.sectionGap),
                  AppSemantics.header(
                    label: l.t('otpTitle'),
                    child: Text(
                      l.t('otpTitle'),
                      style: context.headingMedium(color: context.cTextPrimary).copyWith(
                          fontSize: context.scaled(26), fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(height: context.spSM),
                  Text.rich(
                    TextSpan(
                      text: 'Kod ',
                      style: context.bodyMedium(color: context.cTextSecondary),
                      children: [
                        TextSpan(
                          text: _maskPhone(widget.phone),
                          style: context.bodyMedium(color: context.cTextPrimary).copyWith(
                              fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' raqamiga yuborildi'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spXS + context.spXXS),
                  Semantics(
                    link: true,
                    label: 'Raqamni o\'zgartirish',
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Raqamni o\'zgartirish',
                        style: context.labelLarge(color: context.cPrimary),
                      ),
                    ),
                  ),
                  if (widget.devCode != null) ...[
                    SizedBox(height: context.spLG),
                    _DevCodeBanner(devCode: widget.devCode!),
                  ],
                  SizedBox(height: context.sectionGap + context.spLG),
                  _OtpInput(
                    key: ValueKey('otp_input_$_isResending'),
                    disabled: isBlocked || isLoading,
                    onCompleted: (code) {
                      context
                          .read<AuthBloc>()
                          .add(AuthVerifyOtp(widget.phone, code));
                    },
                    onError: () {
                      _shakeCtrl.forward(from: 0);
                      HapticFeedback.heavyImpact();
                    },
                    shakeCtrl: _shakeCtrl,
                  ),
                  SizedBox(height: context.sectionGap + context.spSM),
                  _buildTimerRow(l, isLoading, isBlocked),
                  SizedBox(height: context.sp2XL),
                  if (state is AuthOtpError)
                    _ErrorBanner(
                      message:
                          '${state.message}. ${state.attemptsLeft} ta urinish qoldi.',
                    ),
                  if (state is AuthBlocked)
                    _ErrorBanner(
                      message: '${state.minutesLeft} daqiqa kutishingiz kerak.',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    return AppSemantics.image(
      label: 'QR kod ikonkasi',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: context.gPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.cPrimary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const AppIcon('lock_outline_rounded',
            color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildTimerRow(
      AppLocalizations l, bool isLoading, bool isBlocked) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.cPrimary,
            ),
          ),
          SizedBox(width: context.cardGap - context.spXXS),
          Text('Tekshirilmoqda...',
              style: context.bodyMedium(color: context.cTextSecondary)),
        ],
      );
    }
    return Column(
      children: [
        if (_secondsLeft > 0)
          Semantics(
            label: 'Kodni qayta yuborish: $_timerText',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Kodni qayta yuborish: ',
                    style: context.bodyMedium(color: context.cTextSecondary)),
                Text(_timerText,
                    style: context.bodyMedium(color: context.cPrimary).copyWith(
                        fontWeight: FontWeight.w700)),
              ],
            ),
          )
        else
          Semantics(
            button: true,
            label: 'Kodni qayta yuborish',
            enabled: !isBlocked,
            child: GestureDetector(
              onTap: isBlocked ? null : _resend,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.cardGap + context.spSM, vertical: context.spSM),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.radiusSM + 2),
                  color: context.cPrimary.withValues(alpha: 0.08),
                ),
                child: _isResending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.cPrimary,
                        ),
                      )
                    : Text('Kodni qayta yuborish',
                        style: context.labelLarge(color: context.cPrimary)),
              ),
            ),
          ),
      ],
    );
  }
}

class _OtpInput extends StatefulWidget {
  const _OtpInput({
    super.key,
    required this.disabled,
    required this.onCompleted,
    required this.onError,
    required this.shakeCtrl,
  });
  final bool disabled;
  final ValueChanged<String> onCompleted;
  final VoidCallback onError;
  final AnimationController shakeCtrl;

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _cursorCtrl;
  String _code = '';
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(_OtpInput old) {
    super.didUpdateWidget(old);
    if (widget.disabled && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    if (!widget.disabled && old.disabled) {
      _focusNode.requestFocus();
    }
  }

  void _onChanged(String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 6) return;
    setState(() => _code = digits);
    if (digits.length == 6) {
      _focusNode.unfocus();
      widget.onCompleted(digits);
    }
  }

  void _clearAll() {
    _ctrl.clear();
    setState(() => _code = '');
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _code.length == 6 && _code.isNotEmpty;

    return GestureDetector(
      onTap: widget.disabled ? null : () => _focusNode.requestFocus(),
      child: AnimatedBuilder(
        animation: widget.shakeCtrl,
        builder: (_, child) {
          final dx = widget.shakeCtrl.isAnimating
              ? math.sin(widget.shakeCtrl.value * 5) * 6
              : 0.0;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0,
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: _onChanged,
                enableInteractiveSelection: false,
                buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final hasDigit = i < _code.length;
                final isActive = i == _code.length && _isFocused;
                return Padding(
                  padding: EdgeInsets.only(right: i < 5 ? 10 : 0),
                  child: _Cell(
                    digit: hasDigit ? _code[i] : null,
                    isActive: isActive,
                    hasError: hasError,
                    disabled: widget.disabled,
                    showCursor: isActive,
                    cursorCtrl: _cursorCtrl,
                  ),
                );
              }),
            ),
            if (_code.isNotEmpty && _isFocused)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: _clearAll,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: DesignTokens.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon('close',
                        size: 14, color: Color(0xFF1A56CC)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.digit,
    required this.isActive,
    required this.hasError,
    required this.disabled,
    required this.showCursor,
    required this.cursorCtrl,
  });
  final String? digit;
  final bool isActive, hasError, disabled, showCursor;
  final AnimationController cursorCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 50,
      height: 58,
      decoration: BoxDecoration(
        color: disabled
            ? context.cFieldFill
            : hasError
                ? context.cDanger.withValues(alpha: 0.06)
                : isActive
                    ? context.cSurface
                    : context.cScaffold,
        borderRadius: BorderRadius.circular(context.radiusMD + 2),
        border: Border.all(
          color: hasError
              ? context.cDanger
              : isActive
                  ? context.cPrimary
                  : digit != null
                      ? context.cBorder.withValues(alpha: 0.8)
                      : context.cBorder,
          width: isActive ? 2 : 1.5,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: context.cPrimary.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (digit != null)
            Semantics(
              label: 'Raqam $digit',
              child: Text(
                digit!,
                style: context.headingSmall(color: context.cTextPrimary).copyWith(
                    fontSize: context.scaled(22), fontWeight: FontWeight.w700),
              ),
            ),
          if (showCursor)
            Positioned(
              bottom: 14,
              child: AnimatedBuilder(
                animation: cursorCtrl,
                builder: (_, __) {
                  return Container(
                    width: 1.5,
                    height: 22,
                    decoration: BoxDecoration(
                      color: context.cPrimary
                          .withValues(alpha: (0.12 + cursorCtrl.value * 0.4).clamp(0.0, 0.52)),
                      borderRadius: BorderRadius.circular(1),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.cardGap),
      child: DsSurface(
        padding: EdgeInsets.symmetric(horizontal: context.spLG, vertical: context.cardGap),
        color: context.cDanger.withValues(alpha: 0.06),
        hasBorder: true,
        borderColor: context.cDanger.withValues(alpha: 0.3),
        radius: context.radiusMD,
        shadows: const [],
        child: Row(
          children: [
            AppIcon('error_outline_rounded',
                size: 20, color: context.cDanger),
            SizedBox(width: context.cardGap - context.spXXS),
            Expanded(
              child: Semantics(
                liveRegion: true,
                label: message,
                child: Text(
                  message,
                  style: context.bodySmall(color: context.cDanger.withValues(alpha: 0.9)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevCodeBanner extends StatelessWidget {
  const _DevCodeBanner({required this.devCode});
  final String devCode;

  @override
  Widget build(BuildContext context) {
    const warningColor = Color(0xFF856404);
    return DsSurface(
      padding: EdgeInsets.symmetric(horizontal: context.spLG, vertical: context.cardGap),
      color: const Color(0xFFFFF3CD),
      hasBorder: true,
      borderColor: const Color(0xFFFFE083),
      radius: context.radiusMD,
      shadows: const [],
      child: Row(
        children: [
          const AppIcon('developer_mode', color: Color(0xFF856404), size: 20),
          SizedBox(width: context.cardGap - context.spXXS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dev rejimi: SMS yuborilmadi',
                  style: context.labelSmall(color: warningColor)),
              Text('Kod: $devCode',
                  style: context.headingSmall(color: const Color(0xFF533F03)).copyWith(
                      fontSize: context.scaled(18),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2)),
            ],
          ),
        ],
      ),
    );
  }
}
