import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/theme/theme_cubit.dart';
import '../../../core/accessibility/accessibility.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;
  String _errorText = '';

  late final AnimationController _pulseCtrl;

  bool get _isValid => _phoneController.text.replaceAll(' ', '').length == 9;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _continue(BuildContext context) {
    if (!_isValid) {
      setState(() {
        _hasError = true;
        _errorText = 'Telefon raqamni to\'liq kiriting';
      });
      return;
    }
    final phone = '+998${_phoneController.text.replaceAll(' ', '')}';
    context.read<AuthBloc>().add(AuthSendOtp(phone));
  }

  void _validate(String value) {
    final digits = value.replaceAll(' ', '');
    setState(() {
      if (digits.isEmpty) {
        _hasError = false;
        _errorText = '';
      } else if (digits.length < 9) {
        _hasError = true;
        _errorText = 'Telefon raqam to\'liq emas';
      } else {
        _hasError = false;
        _errorText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          var url =
              '${AppRoutes.otp}?phone=${Uri.encodeComponent(state.phone)}';
          if (state.devCode != null) url += '&dev_code=${state.devCode}';
          context.push(url);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: context.cDanger),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.cScaffold,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.cardGap),
                        _buildGreeting(),
                        SizedBox(height: context.sectionGap + context.spSM),
                        _buildPhoneSection(),
                        SizedBox(height: context.cardGap + context.spSM),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final loading = state is AuthLoading;
                            return _buildContinueButton(loading);
                          },
                        ),
                        SizedBox(height: context.cardGap + context.spXXS),
                        _buildTrustRow(),
                        SizedBox(height: context.sectionGap + context.spSM),
                        _buildDivider(),
                        SizedBox(height: context.cardGap + context.spSM),
                        _buildFooter(),
                        SizedBox(height: context.sp2XL + MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spLG, context.screenHorizontal, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: context.gPrimary,
                  shape: BoxShape.circle,
                ),
                child: const AppIcon('build_rounded',
                    color: Colors.white, size: 18),
              ),
              SizedBox(width: context.cardGap - context.spXXS),
              AppSemantics.header(
                label: 'AVTORY',
                child: Text('AVTORY',
                    style: context.headingSmall(color: context.cTextPrimary).copyWith(
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return Semantics(
                button: true,
                label: isDark ? 'Yorug\' rejim' : 'Qorong\'i rejim',
                child: GestureDetector(
                  onTap: () => context.read<ThemeCubit>().toggle(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.cOverlay,
                      borderRadius: BorderRadius.circular(context.radiusMD),
                    ),
                    child: AppIcon(
                        isDark ? 'light_mode_rounded' : 'dark_mode_rounded',
                        size: 20,
                        color: context.cTextSecondary),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return AppSemantics.header(
      label: 'Xush kelibsiz',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xush kelibsiz!',
              style: context.headingMedium(color: context.cTextPrimary).copyWith(
                  fontSize: context.scaled(28), fontWeight: FontWeight.w800)),
          SizedBox(height: context.spXS + context.spXXS),
          Text(
            "Telefon raqamingizni kiriting. SMS kod yuboramiz.",
            style: context.bodyMedium(color: context.cTextSecondary).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: context.cSurface,
            borderRadius: BorderRadius.circular(context.radiusLG),
            border: Border.all(
              color: _hasError
                  ? context.cDanger
                  : _isFocused
                      ? context.cPrimary
                      : context.cBorder,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: context.cPrimary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ListenableBuilder(
            listenable: Listenable.merge([_phoneController, _focusNode]),
            builder: (context, _) {
              final hasText = _phoneController.text.isNotEmpty;
              return Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: context.cardGap - context.spSM),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spSM,
                      vertical: context.spXS,
                    ),
                    decoration: BoxDecoration(
                      color: context.cOverlay,
                      borderRadius: BorderRadius.circular(context.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 14,
                          child: CustomPaint(
                            painter: _UzbekFlagPainter(),
                          ),
                        ),
                        SizedBox(width: context.spXS),
                        Text('+998',
                            style: context.headingSmall(color: context.cTextPrimary).copyWith(
                                fontSize: context.scaled(17),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  SizedBox(width: context.spSM),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _PhoneFormatter(),
                      ],
                      onChanged: (v) {
                        setState(() => _validate(v));
                      },
                      style: context.headingSmall(color: context.cTextPrimary).copyWith(
                          fontSize: context.scaled(17),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                      decoration: InputDecoration(
                        hintText: hasText || _isFocused ? '' : '90 123 45 67',
                        hintStyle: context.bodyMedium(color: context.cTextTertiary).copyWith(
                            fontSize: context.scaled(17)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: context.spLG + context.spXXS),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (hasText)
                    Semantics(
                      button: true,
                      label: 'Tozalash',
                      child: GestureDetector(
                        onTap: () {
                          _phoneController.clear();
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: context.cardGap),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: context.cBorder,
                              shape: BoxShape.circle,
                            ),
                            child: const AppIcon('close',
                                size: 12, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (_hasError && _errorText.isNotEmpty) ...[
          SizedBox(height: context.spSM),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Row(
              children: [
                const AppIcon('error_outline_rounded',
                    size: 14, color: Color(0xFFEF4444)),
                SizedBox(width: context.spXS + context.spXXS),
                Text(_errorText,
                    style: context.labelSmall(color: context.cDanger)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton(bool loading) {
    final valid = _isValid && !loading;
    return AppSemantics.touchTarget(
      minSize: AppSemantics.minTouchTarget,
      onTap: valid ? () => _continue(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: valid
              ? context.gPrimary
              : null,
          color: valid ? null : context.cBorder,
          borderRadius: BorderRadius.circular(context.radiusLG),
          boxShadow: valid
              ? [
                  BoxShadow(
                    color: context.cPrimary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(context.radiusLG),
            onTap: valid ? () => _continue(context) : null,
            child: Semantics(
              button: true,
              label: 'Davom etish',
              enabled: valid,
              child: Center(
                child: loading
                    ? _ButtonLoader()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Davom etish',
                            style: context.headingSmall(color: valid ? Colors.white : context.cTextTertiary),
                          ),
                          SizedBox(width: context.spSM),
                          AppIcon(
                            'arrow_forward_rounded',
                            size: 20,
                            color: valid
                                ? Colors.white
                                : context.cTextTertiary,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustRow() {
    return Semantics(
      label: "Ma'lumotlaringiz xavfsiz",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.cSuccess.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.radiusSM),
            ),
            child: AppIcon('lock_outline_rounded',
                size: 16, color: context.cSuccess),
          ),
          SizedBox(width: context.cardGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ma'lumotlaringiz xavfsiz",
                    style: context.labelLarge(color: context.cTextPrimary)),
                SizedBox(height: context.spXXS),
                Text(
                  "Raqamingizga SMS-kod yuboramiz. Birinchi marta bo'lsangiz, avtomatik ro'yxatdan o'tasiz.",
                  style: context.bodySmall(color: context.cTextTertiary).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: context.cBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spLG),
          child: Text('yoki',
              style: context.labelLarge(color: context.cTextTertiary)),
        ),
        Expanded(child: Divider(color: context.cBorder)),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Maxfiylik siyosati', () {}),
            Container(
                width: 4,
                height: 4,
                margin: EdgeInsets.symmetric(horizontal: context.cardGap),
                decoration: BoxDecoration(
                    color: context.cBorder.withValues(alpha: 0.8), shape: BoxShape.circle)),
            _footerLink("Foydalanish shartlari", () {}),
          ],
        ),
        SizedBox(height: context.spLG),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink("Sozlamalar", () {
              _showSettingsSheet();
            }),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return Semantics(
      link: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.spXS),
          child: Text(label,
              style: context.labelLarge(color: context.cTextSecondary)),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    DsBottomSheet.show(
      context,
      icon: 'settings_rounded',
      title: 'Sozlamalar',
      children: [
        _settingsRow(
          icon: 'language_outlined',
          label: 'Til',
          trailing: "O'zbekcha",
          onTap: () {},
        ),
        Divider(height: 1, color: context.cDivider),
        _settingsRow(
          icon: 'support_agent_outlined',
          label: "Yordam",
          trailing: null,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _settingsRow({
    required String icon,
    required String label,
    required String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.cPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.radiusSM + 2),
        ),
        child: AppIcon(icon,
            size: 20, color: context.cPrimary),
      ),
      title: Text(label,
          style: context.labelLarge(color: context.cTextPrimary)),
      trailing: trailing != null && trailing.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailing,
                    style: context.bodyMedium(color: context.cTextSecondary)),
                SizedBox(width: context.spXS),
                AppIcon('chevron_right',
                    size: 18, color: context.cTextTertiary),
              ],
            )
          : AppIcon('chevron_right',
              size: 18, color: context.cTextTertiary),
      onTap: onTap,
    );
  }
}

class _ButtonLoader extends StatefulWidget {
  @override
  State<_ButtonLoader> createState() => _ButtonLoaderState();
}

class _ButtonLoaderState extends State<_ButtonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _ButtonLoaderPainter(_ctrl.value),
          size: const Size(24, 24),
        );
      },
    );
  }
}

class _ButtonLoaderPainter extends CustomPainter {
  _ButtonLoaderPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      t * 6.2832,
      (t * 6.2832) % 6.2832,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ButtonLoaderPainter old) => old.t != t;
}

class _UzbekFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    final w = size.width;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF0099B5),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h, w, h),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 2, w, h),
      Paint()..color = const Color(0xFF1EB53A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    if (digits.length > 9) return old;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(digits[i]);
    }
    final result = buf.toString();
    return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length));
  }
}
