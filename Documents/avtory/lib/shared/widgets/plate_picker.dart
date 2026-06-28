import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/widgets/app_icon.dart';

/// A modern Uzbek license-plate number selector.
/// No keyboard input — user picks each segment via bottom-sheet wheels.
///
/// Result format: `01 A 123 AA`
class PlatePicker extends StatefulWidget {
  const PlatePicker({
    super.key,
    this.onChanged,
    this.initialValue,
  });

  final ValueChanged<String>? onChanged;
  final String? initialValue;

  @override
  State<PlatePicker> createState() => _PlatePickerState();
}

class _PlatePickerState extends State<PlatePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  String _region = '01';
  String _firstLetter = 'A';
  String _d1 = '0';
  String _d2 = '0';
  String _d3 = '0';
  String _el1 = 'A';
  String _el2 = 'A';

  static const _regions = [
    '01', '10', '20', '30', '40', '50', '60', '70', '80', '90',
  ];

  static const _digits = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  ];

  static const _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    if (widget.initialValue != null) _parseInitial(widget.initialValue!);
    _animCtrl.forward();
  }

  void _parseInitial(String v) {
    final parts = v.split(' ');
    if (parts.length == 4) {
      _region = parts[0];
      _firstLetter = parts[1];
      final nums = parts[2].padLeft(3, '0');
      _d1 = nums.isNotEmpty ? nums[0] : '0';
      _d2 = nums.length > 1 ? nums[1] : '0';
      _d3 = nums.length > 2 ? nums[2] : '0';
      final ends = parts[3].padRight(2, 'A');
      _el1 = ends.isNotEmpty ? ends[0] : 'A';
      _el2 = ends.length > 1 ? ends[1] : 'A';
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String get value => '$_region $_firstLetter $_d1$_d2$_d3 $_el1$_el2';

  void _emit() => widget.onChanged?.call(value);

  Future<void> _pickRegion() async {
    final result = await _showWheelPicker(_regions, _region, 'Viloyat');
    if (result != null) {
      setState(() => _region = result);
      _emit();
    }
  }

  Future<void> _pickFirstLetter() async {
    final result = await _showWheelPicker(_letters, _firstLetter, 'Birinchi harf');
    if (result != null) {
      setState(() => _firstLetter = result);
      _emit();
    }
  }

  Future<void> _pickDigit1() async {
    final result = await _showWheelPicker(_digits, _d1, '1-raqam');
    if (result != null) {
      setState(() => _d1 = result);
      _emit();
    }
  }

  Future<void> _pickDigit2() async {
    final result = await _showWheelPicker(_digits, _d2, '2-raqam');
    if (result != null) {
      setState(() => _d2 = result);
      _emit();
    }
  }

  Future<void> _pickDigit3() async {
    final result = await _showWheelPicker(_digits, _d3, '3-raqam');
    if (result != null) {
      setState(() => _d3 = result);
      _emit();
    }
  }

  Future<void> _pickEndLetter1() async {
    final result = await _showWheelPicker(_letters, _el1, '1-oxirgi harf');
    if (result != null) {
      setState(() => _el1 = result);
      _emit();
    }
  }

  Future<void> _pickEndLetter2() async {
    final result = await _showWheelPicker(_letters, _el2, '2-oxirgi harf');
    if (result != null) {
      setState(() => _el2 = result);
      _emit();
    }
  }

  Future<String?> _showWheelPicker(List<String> items, String current,
      String title) {
    String selected = current;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: ctx.cSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: ctx.cBorder, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Expanded(
              child: ListWheelScrollView(
                itemExtent: 44,
                diameterRatio: 1.5,
                useMagnifier: true,
                magnification: 1.15,
                onSelectedItemChanged: (i) => selected = items[i],
                children: items.map((e) {
                  final isSelected = e == selected;
                  return Center(
                    child: Text(
                      e,
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                        color: isSelected ? ctx.cPrimary : ctx.cTextPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ctx.cPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tanlash'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Davlat raqami *',
              style: AppTextStyles.caption.copyWith(
                  color: context.cTextPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.cFieldFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.cBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _segment(_region, _pickRegion, flex: 2),
                _sep(),
                _segment(_firstLetter, _pickFirstLetter, flex: 1),
                _sep(),
                _segment(_d1, _pickDigit1, flex: 1),
                _segment(_d2, _pickDigit2, flex: 1),
                _segment(_d3, _pickDigit3, flex: 1),
                _sep(),
                _segment(_el1, _pickEndLetter1, flex: 1),
                _segment(_el2, _pickEndLetter2, flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(String value, VoidCallback onTap, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.cTextPrimary,
                  fontFamily: 'Inter',
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              AppIcon('keyboard_arrow_down_rounded',
                  size: 18, color: context.cTextGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 1,
        height: 28,
        color: context.cBorder,
      ),
    );
  }
}
