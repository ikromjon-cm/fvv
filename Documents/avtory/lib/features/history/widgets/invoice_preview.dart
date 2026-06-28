import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../shared/widgets/app_icon.dart';

class InvoicePreview extends StatelessWidget {
  const InvoicePreview({
    super.key,
    this.price,
    this.status,
  });

  final String? price;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.cPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppIcon(
                    'receipt_long_outlined',
                    size: 18,
                    color: DesignTokens.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Hisob-faktura',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: context.cTextPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.cWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    'Tez kunda',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: context.cWarning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 56),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                _infoRow(
                  context,
                  'Xizmat narxi',
                  price ?? '--',
                  context.cTextPrimary,
                ),
                const SizedBox(height: 6),
                _infoRow(
                  context,
                  'Qo\'shimcha xizmatlar',
                  '--',
                  context.cTextTertiary,
                ),
                const SizedBox(height: 6),
                _infoRow(
                  context,
                  'Jami',
                  price ?? '--',
                  context.cSuccess,
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            color: context.cTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Inter',
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class PaymentPreview extends StatelessWidget {
  const PaymentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.cSuccess.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppIcon(
                    'payments_outlined',
                    size: 18,
                    color: DesignTokens.success,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "To'lov",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: context.cTextPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.cWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    'Tez kunda',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: context.cWarning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 56),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "To'lov usullari",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: context.cTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _paymentMethodChip(context, 'Naqd', false),
                    const SizedBox(width: 8),
                    _paymentMethodChip(context, 'Karta', false),
                    const SizedBox(width: 8),
                    _paymentMethodChip(context, 'Click', true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodChip(BuildContext context, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? context.cPrimary.withValues(alpha: 0.08)
            : context.cFieldFill,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: active
            ? Border.all(
                color: context.cPrimary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          color: active ? context.cPrimary : context.cTextTertiary,
        ),
      ),
    );
  }
}

class FutureServiceActions extends StatelessWidget {
  const FutureServiceActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('sync_rounded', 'Qayta buyurtma', 'Xuddi shu mexanikdan'),
      ('file_download_outlined', 'PDF yuklab olish', 'Hisobotni saqlash'),
      ('share_outlined', 'Ulashish', 'Xizmat haqida'),
      ('receipt_long_outlined', 'Kvitansiya', "To'lov cheki"),
      ('sell_outlined', 'Kupon', 'Chegirma olish'),
      ('lightbulb_outlined', 'Tavsiyalar', 'Xizmat ko\'rsatish'),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.cPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const AppIcon(
                  'auto_awesome_rounded',
                  size: 18,
                  color: DesignTokens.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Qo\'shimcha imkoniyatlar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: context.cTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((a) {
              final icon = a.$1;
              final label = a.$2;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label — tez kunda'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 3,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                    border: Border.all(color: context.cBorder),
                  ),
                  child: Column(
                    children: [
                      AppIcon(
                        icon,
                        size: 20,
                        color: context.cTextSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: context.cTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
