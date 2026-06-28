import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/responsive/adaptive_spacing.dart';
import '../../core/responsive/adaptive_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/problem_icons.dart';
import '../../core/utils/phone.dart';
import '../../data/local/app_storage.dart';
import '../../data/models/problem_category.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/premium_bottom_nav.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/ds_card.dart';
import '../messages/messages_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../mechanic/dashboard/mechanic_dashboard_screen.dart';
import '../history/history_screen.dart';
import 'map_tab_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/section_title.dart';
import 'widgets/premium_avatar.dart';
import 'widgets/weather_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/welcome_banner.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/home_error_widget.dart';
import 'widgets/promo_banner.dart';
import 'widgets/problem_type_card.dart';
import 'widgets/emergency_sos_card.dart';
import 'widgets/mechanic_preview_card.dart';
import 'widgets/location_card.dart';
import 'widgets/map_preview.dart';
import 'widgets/recent_request_card.dart';
import '../../shared/widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ─── Navigation ───
  int _navIndex = 0;
  int _notifBadge = 0;
  String _role = '';
  late StreamSubscription _notifSub;

  // ─── State ───
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showWelcome = false;

  // ─── Animations ───
  late AnimationController _greetingCtrl;
  late AnimationController _pulseCtrl;

  // ─── Location & Mechanics ───
  static const _tashkent = LatLng(41.2995, 69.2401);
  LatLng _center = _tashkent;
  List<Map<String, dynamic>> _mechanics = [];
  bool _onlyAvailable = false;

  // ─── Problems ───
  static const _problems = [
    _Problem('Akkumulyator', 'battery_charging_full_rounded',
        DesignTokens.primary, 'battery'),
    _Problem("Shina yo'ildi", 'tire_repair_rounded',
        DesignTokens.success, 'tire'),
    _Problem('Motor', 'engineering_rounded',
        DesignTokens.warning, 'engine'),
    _Problem('Evakuator', 'car_repair_rounded',
        DesignTokens.danger, 'evacuation'),
    _Problem('Gaz/Shlang', 'water_drop_rounded',
        const Color(0xFF8B5CF6), 'gas'),
    _Problem('Boshqa', 'more_horiz_rounded',
        const Color(0xFF6B7280), 'other'),
  ];

  // ─── Recent Requests ───
  List<Map<String, dynamic>> _recentRequests = [];

  // ─── Data ───
  static const _defaultCarImage =
      'https://img.icons8.com/color/480/sedan.png';
  ProblemCatalogue? _catalogue;
  String _carModel = '';
  String _carNumber = '';
  String? _carImage;
  String _userName = '';
  Map<String, String> _modelImages = {};
  bool _hasGps = false;

  @override
  void initState() {
    super.initState();
    _greetingCtrl = AnimationController(
      vsync: this,
      duration: DesignTokens.animSlow,
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _greetingCtrl.forward();

    _notifBadge = NotificationService().unreadCount;
    _notifSub = NotificationService().onCount.listen((c) {
      if (mounted) setState(() => _notifBadge = c);
    });

    _initData();
    _loadRole();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      await Future.wait([
        _initLocation(),
        _loadCategories(),
        _loadProfile(),
        _loadCatalogue(),
        _loadRecentRequests(),
      ]).timeout(const Duration(seconds: 20));
    } catch (_) {
      // timeout or unexpected error — show whatever content we have
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRole() async {
    final role = await AppStorage.getRole();
    if (mounted) {
      setState(() => _role = role ?? '');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final d = await ApiService.getProblemCategories();
      final cats = (d['categories'] as List? ?? [])
          .map((e) => ProblemCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      final groups = (d['groups'] as List? ?? [])
          .map((e) => ProblemGroup.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted && cats.isNotEmpty) {
        setState(() =>
            _catalogue = ProblemCatalogue(categories: cats, groups: groups));
      }
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AppStorage.getUserProfile();
      if (!mounted) return;
      setState(() {
        _carModel = profile['carModel'] ?? '';
        _carNumber = profile['carNumber'] ?? '';
        final name = profile['name'] ?? '';
        final surname = profile['surname'] ?? '';
        _userName = '$name $surname'.trim();
        final savedImage = profile['carImage'] ?? '';
        _carImage = savedImage.isNotEmpty
            ? savedImage
            : _findCarImage(_carModel, _modelImages);
      });
    } catch (_) {}
  }

  Future<void> _loadCatalogue() async {
    try {
      final d = await ApiService.getCarCatalogue();
      if (!mounted) return;
      final brands = (d['brands'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final images = <String, String>{};
      for (final b in brands) {
        final brandName = b['name'] as String? ?? '';
        final models = b['models'] as List? ?? [];
        for (final m in models) {
          final m2 = m as Map<String, dynamic>;
          final modelName = m2['name'] as String? ?? '';
          final img = m2['image'] as String? ?? '';
          if (modelName.isNotEmpty && img.isNotEmpty) {
            images['$brandName $modelName'] = img;
          }
        }
      }
      setState(() {
        _modelImages = images;
        final found = _findCarImage(_carModel, images);
        _carImage = found;
      });
      if (_carImage != null && _carModel.isNotEmpty) {
        await AppStorage.saveUserProfile(
          carModel: _carModel,
          carNumber: _carNumber,
          carImage: _carImage!,
        );
      }
    } catch (_) {}
  }

  String? _findCarImage(String model, Map<String, String> images) {
    if (model.isEmpty) return null;
    final exact = images[model];
    if (exact != null) return exact;
    final ml = model.toLowerCase();
    for (final entry in images.entries) {
      final key = entry.key;
      if (ml.contains(key.toLowerCase()) ||
          key.toLowerCase().contains(ml)) {
        return entry.value;
      }
    }
    return null;
  }

  Future<void> _initLocation() async {
    try {
      _loadMechanics();
      final pos = await LocationService.current();
      if (!mounted || !pos.real) return;
      setState(() {
        _center = LatLng(pos.lat, pos.lng);
        _hasGps = true;
      });
      _loadMechanics();
    } catch (_) {}
  }

  Future<void> _loadMechanics() async {
    try {
      final raw = await ApiService.getNearbyMechanics(
          lat: _center.latitude, lng: _center.longitude);
      if (mounted) {
        setState(() =>
            _mechanics = raw.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (_) {}
  }

  Future<void> _loadRecentRequests() async {
    try {
      final history = await AppStorage.getHistory();
      if (mounted) {
        setState(() =>
            _recentRequests = history.take(3).toList());
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _visibleMechanics => _onlyAvailable
      ? _mechanics.where((m) => m['is_available'] == true).toList()
      : _mechanics;

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _navIndex = index);
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Xayrli tong';
    if (h < 18) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  @override
  void dispose() {
    _notifSub.cancel();
    _greetingCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMechanic = _role == 'mechanic';
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _navIndex,
        children: isMechanic
            ? [
                const MechanicDashboardScreen(),
                const HistoryScreen(),
                const MessagesScreen(),
                const MapTabScreen(),
                const ProfileScreen(),
              ]
            : [
                _buildHomeTab(),
                const MessagesScreen(),
                const MechanicsScreen(),
                const MapTabScreen(),
                const ProfileScreen(),
              ],
      ),
      bottomNavigationBar: PremiumBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        isMechanic: isMechanic,
        notifBadge: _notifBadge,
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_isLoading) return const HomeSkeleton();
    if (_hasError) {
      return HomeErrorWidget(
        onRetry: _initData,
        message: _errorMessage.isNotEmpty ? _errorMessage : null,
      );
    }
    if (_carModel.isEmpty && !_isLoading) {
      return HomeEmptyState(
        onAddVehicle: () async {
          await context.push(AppRoutes.vehicles);
          _loadProfile();
          _loadCatalogue();
        },
      );
    }

    final l = AppLocalizations.of(context);
    final greeting = _getGreeting();
    final hasUnreadNotifs = _notifBadge > 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F4FF),
            Color(0xFFF8F9FC),
            Color(0xFFF8F9FC),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _initData,
        color: context.cPrimary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── Pinned App Bar ───
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 0,
              collapsedHeight: 70,
              toolbarHeight: 70,
              flexibleSpace: const SizedBox.shrink(),
              title: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top > 20 ? 0 : 16,
                ),
                child: _buildAppBarContent(greeting, hasUnreadNotifs, l),
              ),
            ),

            // ─── Welcome Banner ───
            if (_showWelcome)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: WelcomeBanner(
                    onDismiss: () => setState(() => _showWelcome = false),
                  ),
                ),
              ),

            // ─── Vehicle Card ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _premiumCarCard(context),
              ),
            ),

            // ─── Weather Card (future-ready) ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: const WeatherCard(isLoading: false),
              ),
            ),

            // ─── Quick Actions ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _quickActions(context),
              ),
            ),

            // ─── Search Bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: HomeSearchBar(
                  onSearch: (q) => context.push(
                      '${AppRoutes.nearbyMechanics}?q=${Uri.encodeComponent(q)}'),
                  onFilterTap: _showFilterSheet,
                  hasFilter: _onlyAvailable,
                ),
              ),
            ),

            // ─── Promo Banner (future-ready) ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: const PromoBanner(),
              ),
            ),

            // ─── Problem Types (Premium 2-Column) ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _problemSection(context),
              ),
            ),

            // ─── Emergency SOS ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: EmergencySosCard(
                  onCall: () => dialPhone('112'),
                ),
              ),
            ),

            // ─── Location Card ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: LocationCard(
                  isGpsActive: _hasGps,
                  lat: _center.latitude,
                  lng: _center.longitude,
                ),
              ),
            ),

            // ─── Nearby Mechanics Preview ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _nearbyMechanicsSection(context),
              ),
            ),

            // ─── Map Preview ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: MapPreview(
                  center: _center,
                  mechanicPoints: _visibleMechanics
                      .map((m) => LatLng(
                          (m['lat'] as num?)?.toDouble() ?? 0,
                          (m['lng'] as num?)?.toDouble() ?? 0))
                      .toList(),
                  onOpenFullMap: () => context.push(AppRoutes.fullMap),
                ),
              ),
            ),

            // ─── Recent Requests ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _recentRequestsSection(context),
              ),
            ),

            // ─── Bottom Spacing ───
            SliverToBoxAdapter(
              child: SizedBox(
                height: context.bottomNavInset + 72 + context.sp2XL,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarContent(
      String greeting, bool hasUnreadNotifs, AppLocalizations l) {
    return Row(
      children: [
        PremiumAvatar(
          name: _userName,
          isOnline: _hasGps,
          size: 44,
          state: _userName.isNotEmpty
              ? AvatarState.loaded
              : AvatarState.loading,
          onTap: () => context.push(AppRoutes.profile).then((_) {
            _loadProfile();
          }),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$greeting${_userName.isNotEmpty ? ", $_userName" : ""}',
                style: context.bodyLarge(color: context.cTextPrimary)
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _hasGps
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _hasGps ? l.t('readyToHelp') : l.t('locationOff'),
                    style: context.bodySmall(color: context.cTextTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _sosBtn(context),
        const SizedBox(width: 8),
        _notifBtn(context, hasUnreadNotifs),
      ],
    );
  }

  // ─── Vehicle Card ───
  Widget _premiumCarCard(BuildContext context) {
    final imgUrl = _carImage ?? _defaultCarImage;
    return DsCard(
      height: 190,
      gradient: LinearGradient(
        colors: [
          DesignTokens.primary.withValues(alpha: 0.08),
          DesignTokens.primary.withValues(alpha: 0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      radius: context.radiusXL,
      elevation: 2,
      padding: EdgeInsets.zero,
      onTap: () async {
        final vid = await AppStorage.getDefaultVehicleId();
        await context.push('${AppRoutes.vehicleDashboard}?id=$vid');
        _loadProfile();
        _loadCatalogue();
      },
      child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -10,
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                width: 260,
                height: 180,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => _carPlaceholder(),
                placeholder: (_, __) => SizedBox(
                  width: 260,
                  height: 180,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DesignTokens.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _carModel.isNotEmpty
                        ? _carModel.split(' ').first
                        : 'Avtomobil',
                    style: context.labelSmall(color: context.cTextTertiary)
                        .copyWith(letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _carModel.isNotEmpty
                        ? _carModel.replaceFirst(
                            '${_carModel.split(' ').first} ', '')
                        : '',
                    style: context.headingMedium(color: context.cTextPrimary),
                  ),
                  if (_carNumber.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.primary.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusSM),
                        border: Border.all(
                          color: DesignTokens.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        _carNumber,
                        style: context.headingMedium(color: context.cPrimary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const AppIcon('chevron_right',
                    size: 18, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
    );
  }

  Widget _carPlaceholder() {
    return SizedBox(
      width: 260,
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon('directions_car_rounded',
              size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 8),
          Text(
            _carModel.isNotEmpty ? _carModel : 'Avtomobil',
            style: context.bodySmall(color: context.cTextTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Quick Actions ───
  Widget _quickActions(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Tezkor amallar', subtitle: 'Sizga kerakli xizmatlar'),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: 'my_location_rounded',
                title: l.t('findMe'),
                subtitle: 'Xaritada',
                color: DesignTokens.primary,
                onTap: () => context.push(AppRoutes.fullMap),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionCard(
                icon: 'history_rounded',
                title: l.t('history'),
                subtitle: 'So\'nggi 3 ta',
                color: DesignTokens.success,
                onTap: () => context.push(AppRoutes.history),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionCard(
                icon: 'favorite_border_rounded',
                title: l.t('favorites'),
                subtitle: 'Sevimlilar',
                color: DesignTokens.danger,
                onTap: () => context.push(AppRoutes.favorites),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Search Bar ───
  // (uses HomeSearchBar widget)

  // ─── Problem Section ───
  Widget _problemSection(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cat = _catalogue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: l.t('selectProblem'),
          subtitle: 'Yordam turini tanlang',
          actionLabel: l.t('viewAll'),
          onActionTap: _showAllProblems,
        ),
        _problemGrid(context, cat),
      ],
    );
  }

  Widget _problemGrid(BuildContext context, ProblemCatalogue? cat) {
    if (cat == null) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: _problems.length,
        itemBuilder: (_, i) {
          final p = _problems[i];
          return ProblemTypeCard(
            icon: p.icon,
            title: p.label,
            color: p.color,
            onTap: () => context.push(
                '${AppRoutes.nearbyMechanics}?type=${p.key}'),
          );
        },
      );
    }

    final locale = AppLocalizations.of(context).locale.languageCode;
    final popular = cat.popular.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: popular.length + 1,
      itemBuilder: (_, i) {
        if (i < popular.length) {
          final c = popular[i];
          return ProblemTypeCard(
            icon: problemIcon(c.icon),
            title: c.name(locale),
            color: problemColor(c.group),
            isPopular: i == 0,
            onTap: () => context
                .push('${AppRoutes.nearbyMechanics}?type=${c.slug}'),
          );
        }
        return ProblemTypeCard(
          icon: 'grid_view_rounded',
          title: '...',
          color: const Color(0xFF6B7280),
          onTap: _showAllProblems,
        );
      },
    );
  }

  // ─── Nearby Mechanics Section ───
  Widget _nearbyMechanicsSection(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_visibleMechanics.isEmpty) {
      return EmptyStateWidget(
        icon: 'engineering_rounded',
        title: 'Ustalar topilmadi',
        subtitle: 'Yaqin atrofda hozircha ustalar mavjud emas',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: l.t('nearbyMechanics'),
          subtitle: _hasGps ? 'Sizga eng yaqin' : null,
          actionLabel: l.t('viewAll'),
          onActionTap: () => context.push(AppRoutes.mechanics),
        ),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4),
            itemCount: _visibleMechanics.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final m = _visibleMechanics[i];
              return MechanicPreviewCard(
                name: m['name'] as String? ?? 'Mexanik',
                avatarUrl: m['avatar'] as String?,
                rating: (m['rating'] as num?)?.toDouble(),
                reviewCount: (m['review_count'] as num?)?.toInt(),
                distance: m['distance'] != null
                    ? '${m['distance']} km'
                    : null,
                status: m['is_available'] == true
                    ? MechanicStatus.online
                    : MechanicStatus.offline,
                isVerified: m['is_verified'] == true,
                onCall: () => dialPhone(
                    (m['phone'] as String?) ?? ''),
                onTap: () => context.push(
                    '${AppRoutes.mechanicProfile}${m['id'] ?? ''}'),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Recent Requests Section ───
  Widget _recentRequestsSection(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_recentRequests.isEmpty) {
      return EmptyStateWidget(
        icon: 'history_rounded',
        title: 'So\'rovlar mavjud emas',
        subtitle: 'Siz hali hech qanday so\'rov yubormadingiz\n\nSo\'rov yuborish uchun pastdagi muammo turlaridan birini tanlang',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: l.t('recentRequests'),
          subtitle: 'So\'nggi 3 ta',
          actionLabel: l.t('viewAll'),
          onActionTap: () => context.push(AppRoutes.history),
        ),
        Column(
          children: [
            for (int i = 0; i < _recentRequests.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              RecentRequestCard(
                problemType:
                    _recentRequests[i]['type'] as String? ?? 'Xizmat',
                mechanicName:
                    _recentRequests[i]['mechanic'] as String?,
                status: RequestStatus.completed,
                time: _recentRequests[i]['time'] != null
                    ? _formatTimestamp(
                        _recentRequests[i]['time'] as int)
                    : null,
                onTap: () => context.push(AppRoutes.history),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatTimestamp(int ms) {
    final dt =
        DateTime.fromMillisecondsSinceEpoch(ms);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  void _showAllProblems() {
    final cat = _catalogue;
    if (cat == null) return;
    final locale = AppLocalizations.of(context).locale.languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, controller) => Container(
          decoration: BoxDecoration(
            color: sheetCtx.cSurface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DesignTokens.radius2XL)),
          ),
          child: Column(
            children: [
              SizedBox(height: context.cardGap),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetCtx.cBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(locale == 'ru' ? 'Vse problemi' : 'Barcha muammolar',
                  style: context.headingMedium(color: context.cTextPrimary)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    for (final g in cat.groups)
                      ..._buildGroupSection(g, cat, locale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupSection(
      ProblemGroup g, ProblemCatalogue cat, String locale) {
    final items =
        cat.categories.where((c) => c.group == g.slug).toList();
    if (items.isEmpty) return const [];
    final color = problemColor(g.slug);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              g.name(locale),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: color,
              ),
            ),
          ],
        ),
      ),
      ...items.map((c) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusMD),
              ),
              child: AppIcon(problemIcon(c.icon),
                  color: color, size: 22),
            ),
            title: Text(c.name(locale),
                style: context.bodyMedium(color: context.cTextPrimary)
                    .copyWith(fontWeight: FontWeight.w500)),
            trailing: const AppIcon('chevron_right_rounded',
                size: 20, color: Color(0xFF94A3B8)),
            onTap: () {
              Navigator.pop(context);
              context.push(
                  '${AppRoutes.nearbyMechanics}?type=${c.slug}');
            },
          )),
    ];
  }

  // ─── SOS ───
  Widget _sosBtn(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Favqulodda rejim',
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.emergency),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: DesignTokens.emergencyGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignTokens.emergency.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const AppIcon('sos_rounded',
              color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _sosConfirm() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusXL)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: DesignTokens.emergencyGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.emergency.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const AppIcon('sos_rounded',
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                l.t('emergencyCall'),
                style: context.headingMedium(color: context.cTextPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                l.t('sosConfirm'),
                style: context.bodyMedium(color: context.cTextSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.sectionGap),
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD),
                    gradient: DesignTokens.emergencyGradient,
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.emergency.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMD),
                      onTap: () {
                        Navigator.pop(context);
                        dialPhone('112');
                      },
                      child: const Center(
                        child: Text(
                          '112',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Bekor qilish',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Notification Button ───
  Widget _notifBtn(BuildContext context, bool hasUnread) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.notifications).then((_) {
          if (mounted) {
            setState(() =>
                _notifBadge = NotificationService().unreadCount);
          }
        });
      },
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) {
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: hasUnread
                      ? const Color(0xFF1A56CC).withAlpha(25)
                      : Colors.black.withAlpha(8),
                  blurRadius: hasUnread ? 12 : 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppIcon(
                  hasUnread
                      ? 'notifications_active_rounded'
                      : 'notifications_outlined',
                  size: 22,
                  color: hasUnread
                      ? const Color(0xFF1A56CC)
                      : const Color(0xFF0F172A),
                ),
                if (hasUnread)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444)
                            .withValues(alpha: 0.7 + _pulseCtrl.value * 0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withAlpha(80),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_notifBadge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Filter Bottom Sheet ───
  void _showFilterSheet() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius2XL)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtrlash',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon('close',
                          size: 20, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.sectionGap),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(
                      DesignTokens.radiusMD),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _onlyAvailable = false);
                          setLocal(() {});
                        },
                        child: AnimatedContainer(
                          duration: DesignTokens.animNormal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: !_onlyAvailable
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusSM),
                            boxShadow: !_onlyAvailable
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              l.t('all'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                color: !_onlyAvailable
                                    ? const Color(0xFF1A56CC)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _onlyAvailable = true);
                          setLocal(() {});
                        },
                        child: AnimatedContainer(
                          duration: DesignTokens.animNormal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: _onlyAvailable
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusSM),
                            boxShadow: _onlyAvailable
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              l.t('onlyAvailable'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                color: _onlyAvailable
                                    ? const Color(0xFF1A56CC)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sectionGap),
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD),
                    gradient: DesignTokens.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.primary.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMD),
                      onTap: () => Navigator.pop(ctx),
                      child: Center(
                        child: Text(
                          '${l.t('apply')} (${_visibleMechanics.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Supporting Classes ───
class _Problem {
  const _Problem(
      this.label, this.icon, this.color, this.key);
  final String label;
  final String icon;
  final Color color;
  final String key;
}
