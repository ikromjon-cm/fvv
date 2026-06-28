import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import 'app_icon.dart';

class DsBottomSheet extends StatelessWidget {
  const DsBottomSheet({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.children = const [],
    this.actions,
    this.trailing,
    this.maxHeight,
    this.contentPadding,
  });

  final String? icon;
  final String title;
  final String? description;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? trailing;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;

  static Future<T?> show<T>(
    BuildContext context, {
    String? icon,
    required String title,
    String? description,
    List<Widget> children = const [],
    List<Widget>? actions,
    Widget? trailing,
    double? maxHeight,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DsBottomSheet(
        icon: icon,
        title: title,
        description: description,
        children: children,
        actions: actions,
        trailing: trailing,
        maxHeight: maxHeight,
        contentPadding: contentPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius2XL)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.cBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (icon != null || title.isNotEmpty || trailing != null) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.spLG, context.spLG, context.spLG, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.cPrimary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(context.radiusMD),
                      ),
                      child: AppIcon(icon!,
                          size: 20, color: context.cPrimary),
                    ),
                    SizedBox(width: context.spMD),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.headingSmall(color: context.cTextPrimary),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: context.bodySmall(color: context.cTextSecondary).copyWith(height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
          if (children.isNotEmpty)
            Flexible(
              child: ListView(
                padding: contentPadding ??
                    EdgeInsets.fromLTRB(
                        context.spLG,
                        context.spMD,
                        context.spLG,
                        context.spMD),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: children,
              ),
            ),
          if (actions != null && actions!.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.spLG, 0, context.spLG, MediaQuery.of(context).padding.bottom + context.spSM),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class DsConfirmationSheet extends StatelessWidget {
  const DsConfirmationSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.isConfirmLoading = false,
  });

  final String icon;
  final String title;
  final String description;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool isConfirmLoading;

  static Future<void> show(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required String confirmLabel,
    String? cancelLabel,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool isConfirmLoading = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DsConfirmationSheet(
        icon: icon,
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        isConfirmLoading: isConfirmLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius2XL)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            context.spLG, context.spLG, context.spLG, MediaQuery.of(context).padding.bottom + context.spSM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.cBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.spXL),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (isDestructive ? context.cDanger : context.cPrimary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon,
                  size: 28,
                  color: isDestructive ? context.cDanger : context.cPrimary),
            ),
            SizedBox(height: context.spLG),
            Text(
              title,
              style: context.headingMedium(color: context.cTextPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spSM),
            Text(
              description,
              style: context.bodyMedium(color: context.cTextSecondary).copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spXL),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isConfirmLoading ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDestructive ? context.cDanger : context.cPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.radiusMD)),
                    elevation: 0,
                  ),
                  child: isConfirmLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(confirmLabel,
                          style: context.labelLarge(color: Colors.white).copyWith(
                            fontWeight: FontWeight.w700,
                          )),
              ),
            ),
            SizedBox(height: context.spSM),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                child: Text(
                  cancelLabel ?? 'Bekor qilish',
                  style: context.labelLarge(color: context.cTextSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
