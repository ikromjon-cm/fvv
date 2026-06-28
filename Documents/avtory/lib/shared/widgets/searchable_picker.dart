import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';

/// Generic searchable bottom-sheet picker. Returns the chosen item, or null.
Future<T?> showSearchablePicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  String leadingIcon = 'directions_car_rounded',
  String Function(T)? imageOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SearchablePicker<T>(
      title: title,
      items: items,
      labelOf: labelOf,
      leadingIcon: leadingIcon,
      imageOf: imageOf,
    ),
  );
}

class _SearchablePicker<T> extends StatefulWidget {
  const _SearchablePicker({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.leadingIcon,
    this.imageOf,
  });
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String leadingIcon;
  final String Function(T)? imageOf;

  @override
  State<_SearchablePicker<T>> createState() => _SearchablePickerState<T>();
}

class _SearchablePickerState<T> extends State<_SearchablePicker<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((e) => widget.labelOf(e).toLowerCase().contains(_query.toLowerCase()))
            .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, controller) => Container(
        decoration: BoxDecoration(
          color: ctx.cSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: ctx.cBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.title, style: AppTextStyles.h3),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l.t('search'),
                  prefixIcon: AppIcon('search_rounded', color: ctx.cTextGray),
                  filled: true,
                  fillColor: ctx.cFieldFill,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(l.t('noResults'),
                          style: AppTextStyles.body
                              .copyWith(color: ctx.cTextSecondary)))
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final img = widget.imageOf?.call(item);
                        return ListTile(
                          leading: img != null && img.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: img,
                                    width: 56, height: 56,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => _leadingIcon(),
                                    placeholder: (_, __) => _leadingIcon(),
                                  ),
                                )
                              : _leadingIcon(),
                          title: Text(widget.labelOf(item),
                              style: AppTextStyles.body),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadingIcon() {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: DesignTokens.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppIcon(widget.leadingIcon,
          size: 24, color: DesignTokens.primary),
    );
  }
}
