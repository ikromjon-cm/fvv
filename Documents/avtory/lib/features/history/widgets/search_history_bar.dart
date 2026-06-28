import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';

class SearchHistoryBar extends StatefulWidget {
  const SearchHistoryBar({
    super.key,
    this.onSearch,
    this.recentSearches = const [],
    this.onClearRecent,
  });

  final ValueChanged<String>? onSearch;
  final List<String> recentSearches;
  final VoidCallback? onClearRecent;

  @override
  State<SearchHistoryBar> createState() => _SearchHistoryBarState();
}

class _SearchHistoryBarState extends State<SearchHistoryBar> {
  final _controller = TextEditingController();
  bool _showRecent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.radiusLG),
            child: BackdropFilter(
              filter: DesignTokens.glassFilter(8),
              child: Container(
                margin: EdgeInsets.fromLTRB(context.screenHorizontal, 4, context.screenHorizontal, 0),
                decoration: BoxDecoration(
                  color: context.glassFill,
                  borderRadius: BorderRadius.circular(context.radiusLG),
                  border: Border.all(color: context.glassBorder),
                ),
                child: Focus(
                  onFocusChange: (f) => setState(() => _showRecent = f),
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onSearch,
                    style: context.bodyMedium(color: context.cTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      hintStyle: context.bodyMedium(color: context.cTextTertiary),
                      prefixIcon: AppIcon(
                        'search_rounded',
                        size: 20,
                        color: context.cTextTertiary,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _controller.clear();
                                widget.onSearch?.call('');
                                setState(() {});
                              },
                              child: AppIcon(
                                'close',
                                size: 18,
                                color: context.cTextTertiary,
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.radiusLG),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.spLG,
                        vertical: context.spMD,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showRecent && widget.recentSearches.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(32, 4, 32, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(color: context.cBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AppIcon(
                      'history_rounded',
                      size: 14,
                      color: context.cTextTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'So\'nggi qidiruvlar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: context.cTextTertiary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        widget.onClearRecent?.call();
                        setState(() {});
                      },
                      child: Text(
                        'Tozalash',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: context.cPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...widget.recentSearches.take(5).map(
                      (s) => GestureDetector(
                        onTap: () {
                          _controller.text = s;
                          widget.onSearch?.call(s);
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              AppIcon(
                                'schedule_rounded',
                                size: 14,
                                color: context.cTextTertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                s,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: context.cTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }
}
