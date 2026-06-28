import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/locale/locale_cubit.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../core/accessibility/accessibility.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/phone.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../services/biometrics_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/components/buttons/app_buttons.dart';
import '../../shared/widgets/ds_surface.dart';
import '../../shared/widgets/ds_dialog.dart';

const String kPrivacyUrl =
    'https://avtory-api-production.up.railway.app/privacy/';
const String kTermsUrl =
    'https://avtory-api-production.up.railway.app/terms/';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> _userProfile = {};
  String _role = '';
  bool _isLoading = true;
  int _totalJobs = 0;
  double _avgRating = 0;
  int _reviewCount = 0;
  int _vehicleCount = 0;
  int _favoritesCount = 0;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final role = await AppStorage.getRole() ?? '';
    String name = '',
        surname = '',
        phone = await AppStorage.getPhone() ?? '',
        carModel = '',
        carNumber = '';
    int jobs = 0;
    double avg = 0;
    int count = 0;

    try {
      if (role == 'driver') {
        final data = await ApiService.getDriverProfile();
        name = data['name'] as String? ?? '';
        surname = data['surname'] as String? ?? '';
        phone = data['phone'] as String? ?? phone;
        carModel = data['car_model'] as String? ?? '';
        carNumber = data['car_number'] as String? ?? '';
      } else if (role == 'mechanic') {
        final data = await ApiService.getMechanicProfile();
        name = data['name'] as String? ?? '';
        surname = data['surname'] as String? ?? '';
        phone = data['phone'] as String? ?? phone;
        avg = (data['avg_rating'] as num?)?.toDouble() ?? 0;
        count = data['total_reviews'] as int? ?? 0;
        jobs = data['total_jobs'] as int? ?? 0;
      }
    } catch (_) {
      final profile = await AppStorage.getUserProfile();
      name = profile['name'] ?? '';
      surname = profile['surname'] ?? '';
      carModel = profile['carModel'] ?? '';
      carNumber = profile['carNumber'] ?? '';
      if (role == 'mechanic') {
        final stats = await AppStorage.getMechanicStats();
        jobs = stats.jobs;
        avg = stats.avg;
        count = stats.count;
      }
    }

    int vCount = 0, fCount = 0;
    try {
      final vehicles = await ApiService.getVehicles();
      vCount = vehicles.length;
    } catch (_) {}
    try {
      final favorites = await ApiService.getFavorites();
      fCount = favorites.length;
    } catch (_) {}

    final biometricsEnabled = await BiometricsService.isEnabled();
    if (mounted) {
      setState(() {
        _userProfile = {
          'name': name,
          'surname': surname,
          'phone': phone,
          'carModel': carModel,
          'carNumber': carNumber,
        };
        _role = role;
        _totalJobs = jobs;
        _avgRating = avg;
        _reviewCount = count;
        _vehicleCount = vCount;
        _favoritesCount = fCount;
        _biometricsEnabled = biometricsEnabled;
        _isLoading = false;
      });
    }
  }

  String get _fullName {
    final n = _userProfile['name'] ?? '';
    final s = _userProfile['surname'] ?? '';
    final full = '$n $s'.trim();
    if (full.isEmpty) return 'Ism kiritilmagan';
    return full;
  }

  String get _phone => _userProfile['phone'] ?? '+998 -- --- -- --';
  String get _roleLabel => _role == 'mechanic' ? 'Mexanik' : 'Haydovchi';

  int get _completionPercent {
    int pct = 0;
    if ((_userProfile['name'] ?? '').isNotEmpty) pct += 30;
    if ((_userProfile['surname'] ?? '').isNotEmpty) pct += 30;
    if ((_userProfile['phone'] ?? '').isNotEmpty &&
        _userProfile['phone'] != '+998 -- --- -- --') {
      pct += 20;
    }
    if (_role == 'driver') {
      if ((_userProfile['carModel'] ?? '').isNotEmpty) pct += 20;
    } else {
      pct += 20;
    }
    return pct.clamp(0, 100);
  }

  List<String> get _missingInfo {
    final missing = <String>[];
    if ((_userProfile['name'] ?? '').isEmpty) {
      missing.add('Ism qo\'shing');
    }
    if ((_userProfile['surname'] ?? '').isEmpty) {
      missing.add('Familiya qo\'shing');
    }
    if (_role == 'driver' &&
        (_userProfile['carModel'] ?? '').isEmpty) {
      missing.add('Avtomobil qo\'shing');
    }
    return missing;
  }

  void _editProfile() {
    context.push(AppRoutes.profileEdit).then((_) => _load());
  }

  Future<void> _onBiometricsToggle(bool value) async {
    if (value) {
      final available = await BiometricsService.isAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Qurilmangiz biometriyani qo\'llab-quvvatlamaydi'),
            ),
          );
        }
        return;
      }
      final authed = await BiometricsService.authenticate();
      if (!authed) return;
      await BiometricsService.setEnabled(true);
      final phone = await AppStorage.getPhone();
      final token = await AppStorage.getToken();
      final refreshToken = await AppStorage.getRefreshToken();
      final role = await AppStorage.getRole();
      if (phone != null && token != null) {
        await BiometricsService.saveCredentials(phone, token,
            refreshToken: refreshToken);
        if (role != null) await BiometricsService.saveRole(role);
      }
      if (mounted) setState(() => _biometricsEnabled = true);
    } else {
      await BiometricsService.clearCredentials();
      await BiometricsService.setEnabled(false);
      if (mounted) setState(() => _biometricsEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go(AppRoutes.login);
      },
      child: Scaffold(
        backgroundColor: context.cScaffold,
        body: _isLoading ? _buildSkeleton() : _buildContent(),
      ),
    );
  }

  Widget _sectionGap() => SizedBox(height: context.sectionGap);

  Widget _buildSkeleton() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spMD,
            context.screenHorizontal, context.sp5XL),
        child: Column(
          children: [
            _skelBox(height: 200),
            SizedBox(height: context.spLG),
            _skelBox(height: context.sp6XL + 60),
            SizedBox(height: context.sectionGap),
            _skelBox(height: 160),
            SizedBox(height: context.sectionGap),
            _skelBox(height: 200),
            SizedBox(height: context.sectionGap),
            _skelBox(height: 160),
            SizedBox(height: context.sectionGap),
            _skelBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _skelBox({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: context.cFieldFill,
        borderRadius: BorderRadius.circular(context.radiusLG),
      ),
    );
  }

  Widget _buildContent() {
    final isMechanic = _role == 'mechanic';
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildHeaderCard(isMechanic)),
        if (_missingInfo.isNotEmpty)
          SliverToBoxAdapter(child: _buildCompletionCard()),
        SliverToBoxAdapter(child: _buildQuickActions()),
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(child: _buildAccountSettings()),
        if (!isMechanic)
          SliverToBoxAdapter(child: _buildVehicleSettings()),
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(child: _buildServicesSettings(isMechanic)),
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(child: _buildApplicationSettings()),
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(child: _buildSecuritySettings()),
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(child: _buildLegalSettings()),
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(child: _buildAccountActions()),
        SliverToBoxAdapter(child: SizedBox(height: context.sp5XL)),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    final isHome = GoRouterState.of(context).uri.toString() == AppRoutes.home;
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.cScaffold,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: !isHome,
      leading: isHome
          ? null
          : IconButton(
              icon: const AppIcon('arrow_back_ios_new', size: 20),
              onPressed: () => context.pop(),
            ),
      title: Text(
        'Profil',
        style: context.headingMedium(color: context.cTextPrimary),
      ),
      actions: [
        GestureDetector(
          onTap: _editProfile,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: context.cPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(context.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon('edit_outlined', size: 14, color: context.cPrimary),
                const SizedBox(width: 5),
                Text(
                  'Tahrirlash',
                  style: context.labelMedium(color: context.cPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(bool isMechanic) {
    final pct = _completionPercent;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          context.screenHorizontal, context.spSM, context.screenHorizontal, 0),
      child: Container(
        padding: EdgeInsets.all(context.spLG + 4),
        decoration: BoxDecoration(
          gradient: context.gPrimary,
          borderRadius: BorderRadius.circular(context.radiusXL),
          border: Border.all(color: context.cPrimary.withValues(alpha: 0.10)),
          boxShadow: context.shadowSM,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: context.gPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.cElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _fullName.isNotEmpty
                                ? _fullName[0].toUpperCase()
                                : 'A',
                            style: context
                                .headingLarge(color: context.cPrimary)
                                .copyWith(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _editProfile,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.cPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const AppIcon('camera_alt',
                              color: Colors.white, size: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: context.spMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _fullName,
                              overflow: TextOverflow.ellipsis,
                              style: context.headingMedium(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: context.spXS),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: context.cVerified,
                              shape: BoxShape.circle,
                            ),
                            child: const AppIcon('check',
                                size: 11, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spXXS),
                      Text(
                        _phone,
                        style: context.bodySmall(color: Colors.white70),
                      ),
                      SizedBox(height: context.spSM),
                      Row(
                        children: [
                          _roleChip(_roleLabel, context.cPrimary),
                          SizedBox(width: context.spXS),
                          _outlineChip(
                            'Premium',
                            context.cWarning,
                            Icons.workspace_premium_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spLG + 4),
            if (isMechanic) ...[
              _buildStats(isMechanic),
              SizedBox(height: context.spMD),
            ],
            _buildHeaderProgress(pct),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(bool isMechanic) {
    final stats = <Widget>[
      if (isMechanic) ...[
        _statBox('$_totalJobs', 'Bajarilgan', context.cSuccess),
        SizedBox(width: context.spSM),
        _statBox(
            _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '0.0',
            'Reyting',
            context.cStar),
        SizedBox(width: context.spSM),
        _statBox('$_reviewCount', 'Sharhlar', context.cPrimaryLight),
        SizedBox(width: context.spSM),
      ],
      _statBox('$_vehicleCount', 'Mashinalar', context.cPrimary),
      SizedBox(width: context.spSM),
      _statBox('$_favoritesCount', 'Sevimlilar', context.cDanger),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: stats),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 72),
      padding: EdgeInsets.symmetric(
          horizontal: context.spSM, vertical: context.spSM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.radiusMD),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.headingSmall(color: Colors.white),
          ),
          SizedBox(height: context.spXXS),
          Text(
            label,
            style: context.labelSmall(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderProgress(int pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profil to\'ldirilgan',
              style: context.bodySmall(color: Colors.white70),
            ),
            Text(
              '$pct%',
              style: context.labelSmall(
                  color: pct == 100 ? context.cSuccess : Colors.white),
            ),
          ],
        ),
        SizedBox(height: context.spXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.spXS),
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct == 100 ? context.cSuccess : Colors.white,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard() {
    final pct = _completionPercent;
    final missing = _missingInfo;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          context.screenHorizontal, context.spSM, context.screenHorizontal, 0),
      child: DsSurface(
        padding: EdgeInsets.all(context.cardGap + 4),
        radius: context.radiusXL,
        shadows: context.shadowSM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Profil to\'ldirilgan',
                  style: context.bodyLarge(color: context.cTextPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '$pct%',
                  style: context.labelMedium(color: context.cPrimary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: context.spSM),
            ClipRRect(
              borderRadius: BorderRadius.circular(context.spXS),
              child: LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: context.cFieldFill,
                valueColor: AlwaysStoppedAnimation<Color>(context.cPrimary),
                minHeight: 8,
              ),
            ),
            if (missing.isNotEmpty) ...[
              SizedBox(height: context.spMD),
              ...missing.map(
                (m) => Padding(
                  padding: EdgeInsets.only(bottom: context.spXS),
                  child: Row(
                    children: [
                      AppIcon('info_outline',
                          size: 18, color: context.cWarning),
                      SizedBox(width: context.spSM),
                      Expanded(
                        child: Text(
                          m,
                          style:
                              context.bodySmall(color: context.cTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.spMD),
              SizedBox(
                width: double.infinity,
                child: AppOutlinedButton(
                  label: 'To\'ldirish',
                  onPressed: _editProfile,
                  color: context.cPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _GridActionData(
        icon: 'directions_car_outlined',
        label: 'Mashinalar',
        color: context.cSuccess,
        onTap: () => context.push(AppRoutes.vehicles),
      ),
      _GridActionData(
        icon: 'favorite_border_rounded',
        label: 'Sevimlilar',
        color: context.cDanger,
        onTap: () => context.push(AppRoutes.favorites),
      ),
      _GridActionData(
        icon: 'chat_bubble_outline',
        label: 'Xabarlar',
        color: context.cPrimary,
        onTap: () => context.push(AppRoutes.notifications),
      ),
      _GridActionData(
        icon: 'history_rounded',
        label: 'Tarix',
        color: context.cWarning,
        onTap: () => context.push(AppRoutes.history),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
          context.screenHorizontal, context.spSM, context.screenHorizontal, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: context.spXXS, bottom: context.spSM),
            child: Text(
              'Tezkor amallar',
              style: context.labelLarge(color: context.cTextTertiary)
                  .copyWith(letterSpacing: 0.5),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _GridAction(
                  icon: actions[0].icon,
                  label: actions[0].label,
                  color: actions[0].color,
                  onTap: actions[0].onTap,
                ),
              ),
              SizedBox(width: context.spSM),
              Expanded(
                child: _GridAction(
                  icon: actions[1].icon,
                  label: actions[1].label,
                  color: actions[1].color,
                  onTap: actions[1].onTap,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spSM),
          Row(
            children: [
              Expanded(
                child: _GridAction(
                  icon: actions[2].icon,
                  label: actions[2].label,
                  color: actions[2].color,
                  onTap: actions[2].onTap,
                ),
              ),
              SizedBox(width: context.spSM),
              Expanded(
                child: _GridAction(
                  icon: actions[3].icon,
                  label: actions[3].label,
                  color: actions[3].color,
                  onTap: actions[3].onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.radiusFull),
      ),
      child: Text(
        label,
        style: context.labelSmall(color: color),
      ),
    );
  }

  Widget _outlineChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.labelSmall(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return _SettingsGroup(
      title: 'AKKAUNT',
      children: [
        _SettingsRow(
          icon: 'person_outline',
          title: 'Shaxsiy ma\'lumotlar',
          subtitle: 'Ism, familiya, telefon',
          showArrow: true,
          onTap: _editProfile,
        ),
        _SettingsRow(
          icon: 'lock_outline_rounded',
          title: 'Xavfsizlik',
          subtitle: 'Parol, biometriya',
          showArrow: true,
          onTap: () => _showComingSoon('Xavfsizlik sozlamalari'),
        ),
        _SettingsRow(
          icon: 'language_outlined',
          title: 'Til',
          trailing: Text(
            _currentLangLabel(),
            style: context.labelSmall(color: context.cPrimary),
          ),
          showArrow: true,
          onTap: _showLanguagePicker,
        ),
      ],
    );
  }

  Widget _buildVehicleSettings() {
    return _SettingsGroup(
      title: 'AVTOMOBIL',
      children: [
        _SettingsRow(
          icon: 'directions_car_outlined',
          title: 'Avtomobillarim',
          subtitle: _userProfile['carModel']?.isNotEmpty == true
              ? '${_userProfile['carModel']} | ${_userProfile['carNumber']}'
              : 'Avtomobil qo\'shilmagan',
          showArrow: true,
          onTap: () =>
              context.push(AppRoutes.vehicles).then((_) => _load()),
        ),
        _SettingsRow(
          icon: 'local_parking_rounded',
          title: 'Raqam',
          subtitle: _userProfile['carNumber']?.isNotEmpty == true
              ? _userProfile['carNumber']
              : 'Ko\'rsatilmagan',
        ),
      ],
    );
  }

  Widget _buildServicesSettings(bool isMechanic) {
    final items = <Widget>[
      if (!isMechanic)
        _SettingsRow(
          icon: 'favorite_border_rounded',
          title: 'Sevimlilar',
          subtitle: 'Saqlangan mexaniklar',
          showArrow: true,
          onTap: () => context.push(AppRoutes.favorites),
        ),
      _SettingsRow(
        icon: 'history_rounded',
        title: 'Tarix',
        subtitle: 'Buyurtmalar tarixi',
        showArrow: true,
        onTap: () => context.push(AppRoutes.history),
      ),
      _SettingsRow(
        icon: 'notifications_outlined',
        title: 'Bildirishnomalar',
        showArrow: true,
        onTap: () => context.push(AppRoutes.notifications),
      ),
    ];
    return _SettingsGroup(title: 'XIZMATLAR', children: items);
  }

  Widget _buildApplicationSettings() {
    return _SettingsGroup(
      title: 'ILOVA',
      children: [
        _SettingsRow(
          icon: 'light_mode_rounded',
          title: 'Tungi rejim',
          trailing: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return SizedBox(
                height: 30,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedCrossFade(
                      duration: context.dNormal,
                      crossFadeState: isDark
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Icon(Icons.light_mode,
                          size: 16, color: context.cWarning),
                      secondChild: Icon(Icons.dark_mode,
                          size: 16, color: context.cInfo),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: isDark,
                      onChanged: (_) =>
                          context.read<ThemeCubit>().toggle(),
                      activeTrackColor: context.cPrimary,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _SettingsRow(
          icon: 'info_outline',
          title: 'Ilova haqida',
          subtitle: 'v1.0.0',
          showArrow: true,
          onTap: _showAbout,
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return _SettingsGroup(
      title: 'XAVFSIZLIK',
      children: [
        _SettingsRow(
          icon: 'verified_rounded',
          title: 'Tasdiqlangan telefon',
          subtitle: _phone,
          trailing: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: context.cSuccess.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(context.radiusFull),
            ),
            child: Text(
              'Tasdiqlangan',
              style: context.labelSmall(color: context.cSuccess),
            ),
          ),
        ),
        _SettingsRow(
          icon: 'fingerprint',
          title: 'Biometrik kirish',
          trailing: Switch.adaptive(
            value: _biometricsEnabled,
            onChanged: _onBiometricsToggle,
            activeTrackColor: context.cPrimary,
          ),
        ),
        _SettingsRow(
          icon: 'vpn_key_rounded',
          title: 'Passkey',
          subtitle: 'Tez orada',
          showArrow: true,
          onTap: () => _showComingSoon('Passkey sozlamalari'),
          iconColor: context.cTextTertiary,
        ),
      ],
    );
  }

  Widget _buildLegalSettings() {
    return _SettingsGroup(
      title: 'HUQUQIY',
      children: [
        _SettingsRow(
          icon: 'privacy_tip_outlined',
          title: 'Maxfiylik siyosati',
          showArrow: true,
          onTap: () => openUrl(kPrivacyUrl),
        ),
        _SettingsRow(
          icon: 'description_outlined',
          title: 'Foydalanish shartlari',
          showArrow: true,
          onTap: () => openUrl(kTermsUrl),
        ),
        _SettingsRow(
          icon: 'admin_panel_settings_rounded',
          title: 'Litsenziyalar',
          showArrow: true,
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'AVTORY',
            applicationVersion: 'v1.0.0',
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          context.screenHorizontal, 0, context.screenHorizontal, 0),
      child: Column(
        children: [
          AppOutlinedButton(
            label: 'Chiqish',
            onPressed: _confirmLogout,
            color: context.cDanger,
          ),
          SizedBox(height: context.spMD),
          TextButton(
            onPressed: _confirmDeleteAccount,
            child: Text(
              'Hisobni o\'chirish',
              style: context.labelLarge(color: context.cTextTertiary),
            ),
          ),
        ],
      ),
    );
  }

  String _currentLangLabel() {
    final locale = context.read<LocaleCubit>().state;
    return switch (locale.languageCode) {
      'ru' => 'Русский',
      'en' => 'English',
      _ => "O'zbek",
    };
  }

  void _showComingSoon(String feature) {
    HapticFeedback.lightImpact();
    DsBottomSheet.show(
      context,
      icon: 'rocket_launch_rounded',
      title: 'Tez orada',
      description: feature,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.cPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(context.radiusMD)),
              elevation: 0,
              minimumSize: const Size(0, 50),
            ),
            child: const Text('Tushunarli'),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker() {
    final cubit = context.read<LocaleCubit>();
    DsBottomSheet.show(
      context,
      icon: null,
      title: 'Tilni tanlang',
      trailing: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.cFieldFill,
            shape: BoxShape.circle,
          ),
          child: AppIcon('close',
              size: 20, color: context.cTextTertiary),
        ),
      ),
      children: LocaleCubit.languages.map((lang) {
        final (code, label, flag) = lang;
        final isActive = cubit.state.languageCode == code;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              cubit.setLocale(code);
              Navigator.pop(context);
              setState(() {});
            },
            child: AnimatedContainer(
              duration: context.dNormal,
              padding: EdgeInsets.symmetric(
                  horizontal: context.screenHorizontal, vertical: 14),
              decoration: BoxDecoration(
                color: isActive
                    ? context.cPrimary.withValues(alpha: 0.06)
                    : context.cSurface,
                borderRadius: BorderRadius.circular(
                    context.radiusMD),
                border: Border.all(
                  color: isActive
                      ? context.cPrimary.withValues(alpha: 0.3)
                      : context.cBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isActive ? context.gPrimary : null,
                      color: isActive ? null : context.cFieldFill,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: context.bodyLarge(
                            color: isActive
                                ? context.cPrimary
                                : context.cTextPrimary,
                          ).copyWith(
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          code == 'uz'
                              ? "O'zbek tili"
                              : code == 'ru'
                                  ? 'Русский язык'
                                  : 'English language',
          style: context.labelSmall(color: context.cTextTertiary),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: context.gPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon('check',
                          size: 14, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAbout() {
    DsBottomSheet.show(
      context,
      icon: null,
      title: '',
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: context.gPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.cPrimary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'AVTORY',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: context.bodyMedium(color: context.cTextSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Yo'l yordami. Tez va ishonchli.",
          style: context.bodyMedium(color: context.cTextSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cFieldFill,
            borderRadius:
                BorderRadius.circular(context.radiusMD),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _aboutStat('Yaratildi', '2025'),
              _aboutStat('Versiya', '1.0.0'),
              _aboutStat('Platforma', 'iOS & Android'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.cPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(context.radiusMD)),
              elevation: 0,
              minimumSize: const Size(0, 50),
            ),
            child: const Text('Yopish'),
          ),
        ),
      ],
    );
  }

  Widget _aboutStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: context.bodyLarge(color: context.cTextPrimary)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.labelSmall(color: context.cTextTertiary),
        ),
      ],
    );
  }

  void _confirmLogout() {
    DsConfirmationSheet.show(
      context,
      icon: 'logout',
      title: 'Chiqish',
      description: "Hisobdan chiqmoqchimisiz?",
      confirmLabel: 'Chiqish',
      cancelLabel: 'Bekor qilish',
      isDestructive: true,
      onConfirm: () {
        context.read<AuthBloc>().add(AuthLogout());
      },
    );
  }

  void _confirmDeleteAccount() {
    DsConfirmationSheet.show(
      context,
      icon: 'delete_outline_rounded',
      title: "Hisobni o'chirish",
      description: "Hisobingiz butunlay o'chiriladi. "
          "Barcha ma'lumotlar qaytarib bo'lmaydigan darajada yo'qoladi.",
      confirmLabel: "Hisobni o'chirish",
      cancelLabel: 'Bekor qilish',
      isDestructive: true,
      onConfirm: _showFinalDeleteConfirm,
    );
  }

  void _showFinalDeleteConfirm() {
    DsConfirmationSheet.show(
      context,
      icon: 'error_outline_rounded',
      title: 'Ishonchingiz komilmi?',
      description: "Bu amalni qaytarib bo'lmaydi. "
          "Barcha ma'lumotlaringiz butunlay o'chiriladi.",
      confirmLabel: "Ha, o'chirish",
      cancelLabel: "Yo'q, qoldirish",
      isDestructive: true,
      onConfirm: () async {
        try {
          await ApiService.deleteAccount();
        } catch (_) {}
        await AppStorage.clearAll();
        if (mounted) context.go(AppRoutes.login);
      },
    );
  }
}

// ─── Reusable Private Widgets ─────────────────────────────────────

class _GridActionData {
  _GridActionData({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
}

class _GridAction extends StatelessWidget {
  const _GridAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DsSurface(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: context.spMD),
      radius: context.radiusMD,
      shadows: context.shadowSM,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(context.radiusMD),
            ),
            child: AppIcon(icon, size: 22, color: color),
          ),
          SizedBox(height: context.spXS),
          Text(
            label,
            style: context.labelSmall(color: context.cTextPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          context.screenHorizontal, 0, context.screenHorizontal, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: context.spXXS, bottom: context.spSM),
            child: Text(
              title,
              style: context.labelSmall(color: context.cTextTertiary)
                  .copyWith(letterSpacing: 0.8),
            ),
          ),
          DsSurface(
            padding: EdgeInsets.zero,
            radius: context.radiusXL,
            shadows: context.shadowSM,
            child: Column(
              children: children
                  .asMap()
                  .entries
                  .map((e) {
                    final child = e.value;
                    final isLast = e.key == children.length - 1;
                    if (isLast) return child;
                    return Column(
                      children: [
                        child,
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: context.cDivider,
                          indent: context.screenHorizontal,
                          endIndent: context.screenHorizontal,
                        ),
                      ],
                    );
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatefulWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showArrow = false,
    this.onTap,
    this.iconColor,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  State<_SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<_SettingsRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? context.cPrimary;
    return AppSemantics.button(
      label: widget.title,
      onTap: widget.onTap,
      child: GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              HapticFeedback.lightImpact();
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: EdgeInsets.symmetric(
                horizontal: context.screenHorizontal, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                        context.radiusSM),
                  ),
                  child: AppIcon(widget.icon,
                      size: 18, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: context.bodyMedium(color: context.cTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: context.labelSmall(color: context.cTextTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null)
                  widget.trailing!
                else if (widget.showArrow)
                  AppIcon('chevron_right_rounded',
                      size: 18, color: context.cTextTertiary),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
