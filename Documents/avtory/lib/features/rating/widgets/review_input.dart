import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';

class ReviewInput extends StatefulWidget {
  const ReviewInput({
    super.key,
    this.controller,
    this.maxLength = 300,
    this.onChanged,
  });

  final TextEditingController? controller;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  @override
  State<ReviewInput> createState() => _ReviewInputState();
}

class _ReviewInputState extends State<ReviewInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _controller.removeListener(_onTextChanged);
    _expandController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
    if (_controller.text.isNotEmpty && !_isExpanded) {
      _isExpanded = true;
      _expandController.forward();
    } else if (_controller.text.isEmpty && _isExpanded) {
      _isExpanded = false;
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            if (!_isExpanded) {
              _isExpanded = true;
              _expandController.forward();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cFieldFill,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(
                color: _controller.text.isNotEmpty
                    ? context.cPrimary.withValues(alpha: 0.3)
                    : context.cBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Fikr qoldirish',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: context.cTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_controller.text.length}/${widget.maxLength}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Inter',
                        color: _controller.text.length > widget.maxLength * 0.8
                            ? context.cDanger
                            : context.cTextTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: widget.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: context.cTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Xizmat sifati haqida fikringiz...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Inter',
                      color: context.cTextTertiary,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.cPrimary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusFull,
                    ),
                  ),
                  child: Text(
                    'AI taklif',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: context.cPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Tez kunda',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Inter',
                    color: context.cTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
