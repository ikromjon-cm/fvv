import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../data/local/app_storage.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';

class ServicePricesScreen extends StatefulWidget {
  const ServicePricesScreen({super.key, this.isSetup = false});
  final bool isSetup;

  @override
  State<ServicePricesScreen> createState() => _ServicePricesScreenState();
}

class _ServicePricesScreenState extends State<ServicePricesScreen> {
  List<ServicePriceData> _prices = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final apiPrices = await ApiService.getMechanicPrices();
      final savedMap = {for (final p in apiPrices) p['service_type'] as String: p};

      final prices = ServicePriceData.allTypes.map((s) {
        final saved = savedMap[s.type];
        return s.copyWith(
          minPrice: saved != null ? saved['min_price'] as int? : null,
          maxPrice: saved != null ? saved['max_price'] as int? : null,
          enabled: saved != null ? (saved['is_enabled'] as bool? ?? false) : false,
        );
      }).toList();

      if (mounted) setState(() { _prices = prices; _isLoading = false; });
    } catch (_) {
      final profile = await AppStorage.getMechanicProfile();
      final services = List<String>.from(profile['services'] as List? ?? []);
      final prices = await AppStorage.getServicePrices(services);
      if (mounted) setState(() { _prices = prices; _isLoading = false; });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final payload = _prices.map((p) => {
        'service_type': p.type,
        'min_price': p.minPrice,
        'max_price': p.maxPrice,
        'is_enabled': p.enabled,
      }).toList();
      await ApiService.saveMechanicPrices(payload);
      for (final p in _prices) {
        await AppStorage.saveServicePrice(p.type, p.minPrice, p.maxPrice, p.enabled);
      }
      if (!mounted) return;
      if (widget.isSetup) {
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Narxlar saqlandi'),
          backgroundColor: context.cSuccess,
        ));
        context.pop();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: context.cDanger,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggle(int i, bool v) => setState(() => _prices[i] = _prices[i].copyWith(enabled: v));
  void _setMin(int i, int v) => setState(() => _prices[i] = _prices[i].copyWith(minPrice: v));
  void _setMax(int i, int v) => setState(() => _prices[i] = _prices[i].copyWith(maxPrice: v));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        backgroundColor: context.cSurface,
        title: Text(widget.isSetup ? 'Xizmatlar va narxlar' : 'Narxlarni tahrirlash'),
        leading: widget.isSetup
            ? null
            : IconButton(
                icon: AppIcon('arrow_back_ios_new', size: 20),
                onPressed: () => context.pop(),
              ),
        automaticallyImplyLeading: !widget.isSetup,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: context.cPrimary.withValues(alpha: 0.06),
                  padding: EdgeInsets.all(context.spMD),
                  child: Row(
                    children: [
                      AppIcon('info_outline', color: context.cPrimary, size: 18),
                      SizedBox(width: context.spSM),
                      Expanded(
                        child: Text(
                          "Taklif qiladigan xizmatingizni yoqing va narx oralig'ini belgilang",
                          style: context.bodySmall(color: context.cPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(context.spMD),
                    itemCount: _prices.length,
                    separatorBuilder: (_, __) => SizedBox(height: context.spSM),
                    itemBuilder: (_, i) => _PriceCard(
                      data: _prices[i],
                      onToggle: (v) => _toggle(i, v),
                      onMinChanged: (v) => _setMin(i, v),
                      onMaxChanged: (v) => _setMax(i, v),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(context.spMD, 0, context.spMD, context.sp3XL),
                  child: AppPrimaryButton(
                    label: widget.isSetup ? 'Keyingisi' : 'Saqlash',
                    onPressed: _save,
                    isLoading: _isSaving,
                    trailingIcon: widget.isSetup ? 'arrow_forward_rounded' : null,
                  ),
                ),
              ],
            ),
    );
  }
}

class _PriceCard extends StatelessWidget {

  const _PriceCard({
    required this.data,
    required this.onToggle,
    required this.onMinChanged,
    required this.onMaxChanged,
  });
  final ServicePriceData data;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onMinChanged;
  final ValueChanged<int> onMaxChanged;

  @override
  Widget build(BuildContext context) {
    final color = Color(data.color);
    return AnimatedContainer(
      duration: DesignTokens.animationFast,
      padding: EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(context.radiusLG),
        border: Border.all(
          color: data.enabled ? color.withValues(alpha: 0.4) : context.cBorder,
          width: data.enabled ? 1.5 : 1,
        ),
        boxShadow: data.enabled
            ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: data.enabled ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(context.radiusMD),
                ),
                child: Center(
                  child: AppIcon(data.icon, size: 22, color: color),
                ),
              ),
              SizedBox(width: context.spMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.label,
                        style: context.titleMedium(
                            color: data.enabled ? context.cTextPrimary : context.cTextGray)),
                    if (data.enabled)
                      Text(data.priceLabel,
                          style: context.bodySmall(color: color).copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Switch(
                value: data.enabled,
                onChanged: onToggle,
                activeThumbColor: color,
              ),
            ],
          ),
          if (data.enabled) ...[
            SizedBox(height: context.spMD),
            const Divider(height: 1),
            SizedBox(height: context.spMD),
            Row(
              children: [
                Expanded(
                  child: _PriceField(
                    label: 'Minimum narx',
                    value: data.minPrice,
                    onChanged: onMinChanged,
                    color: color,
                  ),
                ),
                SizedBox(width: context.spMD),
                Expanded(
                  child: _PriceField(
                    label: 'Maximum narx',
                    value: data.maxPrice,
                    onChanged: onMaxChanged,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceField extends StatefulWidget {

  const _PriceField({required this.label, required this.value, required this.onChanged, required this.color});
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  @override
  State<_PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<_PriceField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: context.bodySmall()),
        SizedBox(height: context.spXS),
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null && n > 0) widget.onChanged(n);
          },
          style: context.titleSmall(),
          decoration: InputDecoration(
            suffixText: "so'm",
            suffixStyle: context.bodySmall(),
            filled: true,
            fillColor: context.cFieldFill,
            contentPadding: EdgeInsets.symmetric(horizontal: context.spMD, vertical: context.spSM),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusSM), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusSM),
                borderSide: BorderSide(color: widget.color, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
