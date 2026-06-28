import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/components/buttons/app_buttons.dart';
import '../../shared/widgets/app_icon.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _mechanics = [];
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final phone = await AppStorage.getPhone() ?? '';
    try {
      final d = await ApiService.adminListMechanics();
      if (mounted) {
        setState(() {
          _mechanics =
              (d['mechanics'] as List? ?? []).map((e) => e as Map<String, dynamic>).toList();
          _loading = false;
          _phone = phone;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _phone = phone; });
    }
  }

  Future<void> _logout() async {
    await AppStorage.clearAll();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _addMechanic() async {
    final phoneCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final surnameCtrl = TextEditingController();
    bool saving = false;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: sheetCtx.cSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLG)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: sheetCtx.cBorder, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DesignTokens.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const AppIcon('person_add_alt_1_rounded', color: DesignTokens.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text("Mexanik qo'shish", style: AppTextStyles.h2),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Telefon raqami',
                    style: AppTextStyles.caption.copyWith(
                        color: sheetCtx.cTextPrimary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: sheetCtx.cFieldFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('+998',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                        decoration: _dec(sheetCtx, '90 123 45 67'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec(sheetCtx, 'Ism (ixtiyoriy)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: surnameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec(sheetCtx, 'Familiya'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: "Qo'shish",
                  isLoading: saving,
                  onPressed: () async {
                    if (phoneCtrl.text.trim().length < 9) return;
                    setSheet(() => saving = true);
                    try {
                      await ApiService.adminAddMechanic('+998${phoneCtrl.text.trim()}',
                          name: nameCtrl.text.trim(), surname: surnameCtrl.text.trim());
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx, true);
                    } catch (e) {
                      setSheet(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e is ApiException ? e.message : 'Xatolik'),
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true) {
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mexanik qo'shildi"),
          backgroundColor: context.cSuccess,
        ));
      }
    }
  }

  InputDecoration _dec(BuildContext ctx, String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: ctx.cFieldFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DesignTokens.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final active = _mechanics.where((m) => m['is_setup_done'] == true).length;
    return Scaffold(
      backgroundColor: context.cScaffold,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMechanic,
        backgroundColor: DesignTokens.primary,
        icon: const AppIcon('person_add_alt_1_rounded', color: Colors.white),
        label: const Text("Mexanik qo'shish", style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: DesignTokens.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(active)),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_mechanics.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _emptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacingMD, 8, DesignTokens.spacingMD, 100),
                sliver: SliverList.separated(
                  itemCount: _mechanics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MechCard(m: _mechanics[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(int active) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: DesignTokens.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const AppIcon('admin_panel_settings_rounded', color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin panel',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter')),
                    if (_phone.isNotEmpty)
                      Text(_phone,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontFamily: 'Inter')),
                  ],
                ),
              ),
              IconButton(
                onPressed: _logout,
                icon: const AppIcon('logout_rounded', color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _stat('${_mechanics.length}', 'Mexaniklar', 'groups_rounded')),
              const SizedBox(width: 12),
              Expanded(child: _stat('$active', 'Faol', 'verified_rounded')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, String icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppIcon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter')),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: DesignTokens.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('engineering_rounded', size: 46, color: DesignTokens.primary),
            ),
            const SizedBox(height: 20),
            Text("Hali mexanik qo'shilmagan",
                style: AppTextStyles.h3.copyWith(color: context.cTextPrimary)),
            const SizedBox(height: 8),
            Text(
              "Telefon raqami orqali birinchi mexanikni qo'shing.\nU ilovaga kirganda o'z profilini to'ldiradi.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: context.cTextSecondary),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(label: "Mexanik qo'shish", onPressed: _addMechanic, width: 240),
          ],
        ),
      ),
    );
  }
}

class _MechCard extends StatelessWidget {
  const _MechCard({required this.m});
  final Map<String, dynamic> m;

  @override
  Widget build(BuildContext context) {
    final name = '${m['name'] ?? ''} ${m['surname'] ?? ''}'.trim();
    final mechName = name.isEmpty ? 'Mexanik' : name;
    final setupDone = m['is_setup_done'] == true;
    final jobs = m['total_jobs'] ?? 0;
    final rating = (m['avg_rating'] as num?)?.toDouble() ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: setupDone ? DesignTokens.primaryGradient : null,
              color: setupDone ? null : context.cFieldFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppIcon('build_rounded',
                color: setupDone ? Colors.white : context.cTextGray),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mechName, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(m['phone'] as String? ?? '',
                    style: AppTextStyles.caption.copyWith(color: context.cTextSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (jobs is int && jobs > 0) ...[
                      const AppIcon('check_circle_outline', size: 13, color: DesignTokens.primary),
                      const SizedBox(width: 3),
                      Text('$jobs ish', style: AppTextStyles.caption),
                      const SizedBox(width: 10),
                    ],
                    if (rating > 0) ...[
                      AppIcon('star_rounded', size: 14, color: context.cEmergency),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(1), style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (setupDone ? context.cSuccess : context.cEmergency).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              setupDone ? 'Faol' : 'Kutilmoqda',
              style: AppTextStyles.caption.copyWith(
                  color: setupDone ? context.cSuccess : context.cEmergency,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
