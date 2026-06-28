import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/adaptive_spacing.dart';
import '../../core/responsive/adaptive_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/phone.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../shared/widgets/app_icon.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

enum _LocationStatus { loading, loaded, error }

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  _LocationStatus _locStatus = _LocationStatus.loading;
  double? _lat;
  double? _lng;

  String? _mechanicPhone;
  String? _mechanicName;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadLocation();
    _loadLastMechanic();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() => _locStatus = _LocationStatus.loading);
    final pos = await LocationService.current();
    if (!mounted) return;
    setState(() {
      _lat = pos.lat;
      _lng = pos.lng;
      _locStatus = pos.real ? _LocationStatus.loaded : _LocationStatus.error;
    });
  }

  Future<void> _loadLastMechanic() async {
    try {
      final raw = await ApiService.getRequests();
      if (!mounted) return;
      if (raw.isNotEmpty) {
        final last = raw.last as Map<String, dynamic>;
        final phone = last['mechanic_phone'] as String?;
        final name = last['mechanic_name'] as String?;
        if (phone != null && phone.isNotEmpty) {
          _mechanicPhone = phone;
          _mechanicName = name;
        }
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _call112() {
    HapticFeedback.heavyImpact();
    dialPhone('112');
  }

  void _callMechanic() {
    if (_mechanicPhone != null && _mechanicPhone!.isNotEmpty) {
      HapticFeedback.lightImpact();
      dialPhone(_mechanicPhone!);
    }
  }

  void _contactPlaceholder() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tez orada qo\'shiladi'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: DesignTokens.emergencyGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const Spacer(),
                _buildSosButton(context),
                const Spacer(),
                _buildLocationSection(context),
                const SizedBox(height: 32),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildFooter(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenHorizontal,
        vertical: context.spSM,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(context.radiusMD),
              ),
              child: const AppIcon('close_rounded', size: 22, color: Colors.white),
            ),
          ),
          const Spacer(),
          Text(
            'FAVQULODDA HOLAT',
            style: context.labelSmall(color: Colors.white.withValues(alpha: 0.7))
                .copyWith(letterSpacing: 1.2),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSosButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignTokens.danger,
            boxShadow: [
              BoxShadow(
                color: DesignTokens.danger
                    .withValues(alpha: 0.4 + _pulseCtrl.value * 0.3),
                blurRadius: 20 + _pulseCtrl.value * 20,
                spreadRadius: _pulseCtrl.value * 6,
              ),
            ],
          ),
          child: GestureDetector(
            onTap: _call112,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon('sos_rounded', size: 32, color: Colors.white),
                SizedBox(height: 2),
                Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon('my_location_rounded', size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Joylashuv',
                style: context.titleSmall(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_locStatus == _LocationStatus.loading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const LinearProgressIndicator(color: Colors.white70),
            )
          else ...[
            Text(
              '${_lat?.toStringAsFixed(4) ?? '—'}, ${_lng?.toStringAsFixed(4) ?? '—'}',
              style: context.bodyLarge(color: Colors.white),
            ),
            if (_locStatus == _LocationStatus.error) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: AppIcon('location_off',
                        size: 14, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'GPS o‘chirilgan. Joylashuvni aniq ko‘rsatish uchun GPS-ni yoqing.',
                      style: context.bodySmall(
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Row(
        children: [
          Expanded(child: _actionButton(
            context,
            icon: 'phone_outlined',
            label: '112',
            onTap: _call112,
          )),
          const SizedBox(width: 12),
          Expanded(child: _actionButton(
            context,
            icon: 'build_rounded',
            label: _mechanicName ?? 'Mexanik',
            onTap: _mechanicPhone != null ? _callMechanic : null,
            subtitle: _mechanicPhone,
          )),
          const SizedBox(width: 12),
          Expanded(child: _actionButton(
            context,
            icon: 'chat_bubble_outline',
            label: 'Kontakt',
            onTap: _contactPlaceholder,
          )),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String icon,
    required String label,
    VoidCallback? onTap,
    String? subtitle,
  }) {
    final disabled = onTap == null;
    final opacity = disabled ? 0.5 : 1.0;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(context.radiusMD),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, size: 22, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.labelLarge(color: Colors.white),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: context.labelSmall(
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon('my_location_rounded',
                size: 14, color: Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              'Joylashuvingiz ulashilmoqda',
              style: context.bodySmall(
                  color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.go(AppRoutes.home),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(context.radiusFull),
            ),
            child: Text(
              'Bekor qilish',
              style: context.labelLarge(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
