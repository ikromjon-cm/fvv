import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../services/api_service.dart';
import '../../../shared/widgets/app_icon.dart';

class EarningsChart extends StatefulWidget {
  const EarningsChart({super.key});

  @override
  State<EarningsChart> createState() => _EarningsChartState();
}

class _EarningsChartState extends State<EarningsChart> {
  int _tab = 0;

  List<(String, int)> _weekData = const [
    ('Du', 0), ('Se', 0), ('Ch', 0), ('Pa', 0), ('Ju', 0), ('Sh', 0), ('Ya', 0),
  ];
  List<(String, int)> _monthData = const [
    ('1-hafta', 0), ('2-hafta', 0), ('3-hafta', 0), ('4-hafta', 0),
  ];
  int _weekTotal = 0;
  int _monthTotal = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final d = await ApiService.getEarnings();
      final week = (d['week'] as List? ?? [])
          .map((e) => ((e['label'] as String? ?? ''), (e['amount'] as num?)?.toInt() ?? 0))
          .toList();
      final month = (d['month'] as List? ?? [])
          .map((e) => ((e['label'] as String? ?? ''), (e['amount'] as num?)?.toInt() ?? 0))
          .toList();
      if (mounted) {
        setState(() {
          if (week.isNotEmpty) _weekData = week;
          if (month.isNotEmpty) _monthData = month;
          _weekTotal = (d['week_total'] as num?)?.toInt() ?? 0;
          _monthTotal = (d['month_total'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (_) {
      // silently fail
    }
  }

  static String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  List<(String, int)> get _data => _tab == 0 ? _weekData : _monthData;
  int get _total => _tab == 0 ? _weekTotal : _monthTotal;

  int get _maxVal {
    final m = _data.map((d) => d.$2).fold(0, (a, b) => a > b ? a : b);
    return m == 0 ? 1 : m;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Daromad grafigi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: context.cTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: context.cFieldFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Hafta', 'Oy'].asMap().entries.map((e) {
                    final active = e.key == _tab;
                    return GestureDetector(
                      onTap: () => setState(() => _tab = e.key),
                      child: AnimatedContainer(
                        duration: DesignTokens.animationFast,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: active
                              ? (context.isDark ? context.cPrimary : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: active
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                              : null,
                        ),
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? context.cTextPrimary : context.cTextGray,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${_fmt(_total)} so\'m',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                  color: context.cSuccess,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'jami',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Inter',
                  color: context.cTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_data.every((d) => d.$2 == 0))
            SizedBox(
              height: 140,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.cFieldFill,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon('bar_chart_rounded', size: 24, color: context.cTextTertiary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hali daromad yo\'q',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Inter',
                        color: context.cTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _data.asMap().entries.map((entry) {
                final d = entry.value;
                final ratio = d.$2 / _maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (d.$2 > 0)
                          Text(
                            _fmt(d.$2),
                            style: TextStyle(
                              fontSize: 8,
                              fontFamily: 'Inter',
                              color: context.cTextTertiary,
                            ),
                          ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () {},
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: ratio),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) => Container(
                              height: 100 * value.clamp(0.01, 1.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    DesignTokens.primary,
                                    DesignTokens.primaryLight,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignTokens.primary.withValues(
                                      alpha: 0.2 * value,
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.$1,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Inter',
                            color: context.cTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
