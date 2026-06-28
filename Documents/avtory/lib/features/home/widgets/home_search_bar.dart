import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../shared/widgets/app_icon.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.onSearch,
    this.onFilterTap,
    this.hasFilter = false,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback? onFilterTap;
  final bool hasFilter;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _focusCtrl;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevation = Tween<double>(begin: 1, end: 4).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusCtrl.forward();
      } else {
        _focusCtrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _focusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevation,
      builder: (_, child) {
        return Container(
          height: 54,
          decoration: BoxDecoration(
            color: context.glassFill,
            borderRadius: BorderRadius.circular(context.radiusFull),
            border: Border.all(color: context.glassBorder),
            boxShadow: context.shadowSM,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const AppIcon('search_rounded',
                  size: 20, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search mechanics, services or workshops',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: Color(0xFF0F172A),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    _focusNode.unfocus();
                    if (v.trim().isNotEmpty) widget.onSearch(v.trim());
                  },
                ),
              ),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon('close',
                        size: 16, color: Color(0xFF94A3B8)),
                  ),
                ),
              if (widget.onFilterTap != null)
                GestureDetector(
                  onTap: widget.onFilterTap,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.hasFilter
                          ? const Color(0xFF1A56CC)
                          : const Color(0xFF1A56CC).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const AppIcon('tune_rounded',
                        size: 18, color: Color(0xFF1A56CC)),
                  ),
                ),
              if (_ctrl.text.isNotEmpty || widget.onFilterTap == null)
                const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}
