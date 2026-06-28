import 'package:flutter/material.dart';
import '../../../shared/widgets/app_icon.dart';

class QuickActionBar extends StatelessWidget {
  const QuickActionBar({
    super.key,
    this.onCall,
    this.onChat,
    this.onShareLocation,
    this.onCancel,
    this.onEmergency,
    this.isLoading = false,
  });

  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onShareLocation;
  final VoidCallback? onCancel;
  final VoidCallback? onEmergency;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 64,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF1A56CC),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionButton(
              icon: 'phone_outlined',
              label: 'Qo\'ng\'iroq',
              color: const Color(0xFF10B981),
              onTap: onCall,
            ),
            _ActionButton(
              icon: 'chat_bubble_outline',
              label: 'Chat',
              color: const Color(0xFF3B82F6),
              onTap: onChat,
            ),
            _ActionButton(
              icon: 'near_me_rounded',
              label: 'Joylashuv',
              color: const Color(0xFF8B5CF6),
              onTap: onShareLocation,
            ),
            _ActionButton(
              icon: 'close',
              label: 'Bekor qilish',
              color: const Color(0xFFEF4444),
              onTap: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppIcon(icon,
                  size: 18, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
