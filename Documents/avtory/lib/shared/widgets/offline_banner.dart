import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/adaptive_typography.dart';
import 'app_icon.dart';

enum SyncStatus { syncing, synced, error, offline }

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.show = false});

  final bool show;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: AnimatedCrossFade(
        firstChild: const SizedBox(width: double.infinity, height: 0),
        secondChild: _buildBanner(context),
        crossFadeState: show ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: DesignTokens.animNormal,
        sizeCurve: DesignTokens.easeOut,
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.spLG,
        vertical: context.spSM,
      ),
      decoration: BoxDecoration(
        color: context.cWarning.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(color: context.cWarning.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          AppIcon('wifi_off_rounded', size: 18, color: context.cEmergency),
          SizedBox(width: context.spSM),
          Expanded(
            child: Text(
              'Internet aloqasi yo\'q',
              style: context.bodySmall(color: context.cEmergency).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({
    super.key,
    required this.status,
    this.label,
  });

  final SyncStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(context),
        if (label != null) ...[
          SizedBox(width: context.spXS),
          Text(
            label!,
            style: context.labelSmall(color: _color(context)),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.cPrimary,
          ),
        );
      case SyncStatus.synced:
        return AppIcon('check_circle_rounded', size: 16, color: context.cSuccess);
      case SyncStatus.error:
        return AppIcon('error_outline_rounded', size: 16, color: context.cDanger);
      case SyncStatus.offline:
        return AppIcon('cloud_off_rounded', size: 16, color: context.cOffline);
    }
  }

  Color _color(BuildContext context) {
    switch (status) {
      case SyncStatus.syncing:
        return context.cPrimary;
      case SyncStatus.synced:
        return context.cSuccess;
      case SyncStatus.error:
        return context.cDanger;
      case SyncStatus.offline:
        return context.cOffline;
    }
  }
}
