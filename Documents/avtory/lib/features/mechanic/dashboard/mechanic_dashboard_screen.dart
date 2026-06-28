import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/photo_picker.dart';
import '../../../data/local/app_storage.dart';
import '../../../services/api_service.dart';
import '../../../services/notification_service.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_card.dart';
import '../../../shared/widgets/ds_badge.dart';
import 'earnings_chart.dart';
import '../widgets/mechanic_status_card.dart';
import '../widgets/mechanic_kpi_card.dart';
import '../widgets/incoming_request_card.dart';
import '../widgets/mechanic_dashboard_skeleton.dart';

class MechanicDashboardScreen extends StatefulWidget {
  const MechanicDashboardScreen({super.key});

  @override
  State<MechanicDashboardScreen> createState() => _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState extends State<MechanicDashboardScreen> {
  int _navIndex = 0;
  bool _isAvailable = true;
  bool _isLoading = true;
  String? _errorMessage;
  int _notifBadge = 0;
  late StreamSubscription _notifSub;
  String _mechanicName = 'Mexanik';
  String _speciality = '';
  String _avatar = '';
  bool _uploadingAvatar = false;
  List<Map<String, dynamic>> _pendingRequests = [];
  double _avgRating = 0;
  int _reviewCount = 0;
  int _totalJobs = 0;

  @override
  void initState() {
    super.initState();
    _notifBadge = NotificationService().unreadCount;
    _notifSub = NotificationService().onCount.listen((c) {
      if (mounted) setState(() => _notifBadge = c);
    });
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApiService.getMechanicProfile();
      final requests = await ApiService.getRequests(status: 'pending');
      if (mounted) {
        setState(() {
          final name = '${data['name'] ?? ''} ${data['surname'] ?? ''}'.trim();
          _mechanicName = name.isEmpty ? 'Mexanik' : name;
          _speciality = data['speciality'] as String? ?? '';
          _avatar = data['avatar'] as String? ?? '';
          _isAvailable = data['is_available'] as bool? ?? true;
          _avgRating = (data['avg_rating'] as num?)?.toDouble() ?? 0;
          _reviewCount = data['total_reviews'] as int? ?? 0;
          _totalJobs = data['total_jobs'] as int? ?? 0;
          _pendingRequests = requests.map((r) => r as Map<String, dynamic>).toList();
          _isLoading = false;
        });
        await AppStorage.setMechanicAvailability(_isAvailable);
      }
    } catch (_) {
      final profile = await AppStorage.getMechanicProfile();
      final available = await AppStorage.getMechanicAvailability();
      final pending = await AppStorage.getPendingRequests();
      final stats = await AppStorage.getMechanicStats();
      if (mounted) {
        setState(() {
          final name = '${profile['name'] ?? ''} ${profile['surname'] ?? ''}'.trim();
          _mechanicName = name.isEmpty ? 'Mexanik' : name;
          _speciality = profile['speciality'] as String? ?? '';
          _isAvailable = available;
          _pendingRequests = pending;
          _avgRating = stats.avg;
          _reviewCount = stats.count;
          _totalJobs = stats.jobs;
          _isLoading = false;
          if (profile.isEmpty) _errorMessage = "Profil ma'lumotlari topilmadi";
        });
      }
    }
  }

  Future<void> _changeAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ctx.cSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: ctx.cTextTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            _sourceTile(ctx, 'camera_alt_rounded', 'Kamera', ImageSource.camera),
            _sourceTile(ctx, 'photo_library_rounded', 'Galereya', ImageSource.gallery),
          ],
        ),
      ),
    );
    if (source == null) return;
    final dataUrl = await pickPhotoDataUrl(source);
    if (dataUrl == null || !mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      await ApiService.updateMechanicAvatar(dataUrl);
      if (mounted) setState(() => _avatar = dataUrl);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rasm yuklab bo'lmadi")),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Widget _sourceTile(BuildContext ctx, String icon, String label, ImageSource source) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DesignTokens.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AppIcon(icon, color: DesignTokens.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontFamily: 'Inter')),
      onTap: () => Navigator.pop(ctx, source),
    );
  }

  Future<void> _toggleAvailability(bool v) async {
    HapticFeedback.mediumImpact();
    setState(() => _isAvailable = v);
    try {
      await ApiService.setAvailability(v);
    } catch (_) {}
    await AppStorage.setMechanicAvailability(v);
  }

  @override
  void dispose() {
    _notifSub.cancel();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _navIndex = 0);
      return;
    }
    setState(() => _navIndex = index);
    void resetNav() {
      if (mounted) setState(() => _navIndex = 0);
    }
    switch (index) {
      case 1:
        context.push(AppRoutes.messages).then((_) => resetNav());
      case 2:
        context.push(AppRoutes.history).then((_) => resetNav());
      case 3:
        context.push(AppRoutes.mapTab).then((_) => resetNav());
      case 4:
        context.push(AppRoutes.profile).then((_) => resetNav());
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.cScaffold,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        isMechanic: true,
        notifBadge: _notifBadge,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: context.cScaffold,
      titleSpacing: 12,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: _uploadingAvatar ? null : _changeAvatar,
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.cBorder, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: context.cFieldFill,
                  backgroundImage: _avatar.isNotEmpty ? NetworkImage(_avatar) : null,
                  child: _avatar.isEmpty
                      ? AppIcon('person_rounded', size: 20, color: context.cTextTertiary)
                      : null,
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: DesignTokens.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.cScaffold, width: 1.5),
                  ),
                  child: _uploadingAvatar
                      ? const SizedBox(
                          width: 10, height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                      : const AppIcon('camera_alt_rounded', color: Colors.white, size: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: 'AVT',
                style: context.headingMedium(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: 'ORY',
                style: context.headingMedium(color: context.cPrimary).copyWith(fontWeight: FontWeight.w800),
              ),
            ]),
          ),
          if (_mechanicName != 'Mexanik' || _speciality.isNotEmpty)
            Text(
              _speciality.isNotEmpty ? '$_mechanicName \u00b7 $_speciality' : _mechanicName,
              style: context.labelSmall(color: context.cTextGray),
            ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: AppIcon('notifications_outlined', size: 22),
              onPressed: () {
                context.push(AppRoutes.notifications).then((_) {
                  if (mounted) {
                    setState(() {
                      _navIndex = 0;
                      _notifBadge = NotificationService().unreadCount;
                    });
                  }
                });
              },
            ),
            if (_notifBadge > 0)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.cDanger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _notifBadge > 99 ? '99+' : '$_notifBadge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return RefreshIndicator(
        onRefresh: _loadProfile,
        color: DesignTokens.primary,
        child: const MechanicDashboardSkeleton(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: DesignTokens.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: MechanicStatusCard(
            isAvailable: _isAvailable,
            onToggle: _toggleAvailability,
          )),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildEarningsCard()),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildQuickActions()),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildIncomingRequestsSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildEarningsChartSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final ratingLabel = _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '--';
    final jobsLabel = _totalJobs > 0 ? '$_totalJobs' : '--';
    final reviewLabel = _reviewCount > 0 ? '$_reviewCount' : '--';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Row(
        children: [
          Expanded(
            child: MechanicKpiCard(
              label: 'Ishlar',
              value: jobsLabel,
              icon: 'check_circle_rounded',
              color: context.cSuccess,
            ),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            child: MechanicKpiCard(
              label: 'Reyting',
              value: ratingLabel,
              icon: 'star_rounded',
              color: DesignTokens.star,
            ),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            child: MechanicKpiCard(
              label: 'Izohlar',
              value: reviewLabel,
              icon: 'rate_review_outlined',
              color: context.cPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: DsGradientCard(
        gradient: context.gPrimary,
        height: 100,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(context.radiusMD),
              ),
              child: const AppIcon(
                'account_balance_wallet_outlined',
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: context.spLG),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Umumiy ishlar',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: context.spXS),
                  Text(
                    _totalJobs > 0 ? '$_totalJobs ta ish' : "Hali ish yo'q",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_avgRating > 0)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "O'rtacha baho",
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Inter',
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: context.spXS),
                  Row(
                    children: [
                      const AppIcon('star_rounded', size: 16, color: DesignTokens.star),
                      SizedBox(width: context.spXS),
                      Text(
                        _avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('handyman_outlined', 'Xizmatlar', context.cEmergency, () => context.push(AppRoutes.mechanicServices)),
      ('price_change_outlined', 'Narxlar', DesignTokens.primary, () => context.push(AppRoutes.servicePrices)),
      ('store_outlined', 'Ustaxona', context.cSuccess, () => context.push(AppRoutes.workshopInfo)),
      ('bar_chart_rounded', 'Statistika', DesignTokens.primaryLight, () => _showStatsSheet()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  gradient: context.gPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: context.spSM),
              Text(
                'Tezkor amallar',
                style: context.headingSmall(color: context.cTextPrimary),
              ),
            ],
          ),
        ),
        SizedBox(height: context.spMD),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
          child: Row(
            children: actions.map((a) {
              final icon = a.$1;
              final label = a.$2;
              final color = a.$3;
              final onTap = a.$4;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: context.spSM),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap();
                    },
                    child: DsCard(
                      radius: context.radiusMD,
                      hasBorder: true,
                      padding: EdgeInsets.symmetric(vertical: context.spMD),
                      shadows: context.shadowSM,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(context.radiusSM),
                            ),
                            child: AppIcon(icon, size: 20, color: color),
                          ),
                          SizedBox(height: context.spSM - 2),
                          Text(
                            label,
                            style: context.labelSmall(color: context.cTextSecondary).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  gradient: context.gPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: context.spSM),
              Text(
                'Kirish so\'rovlari',
                style: context.headingSmall(color: context.cTextPrimary),
              ),
              if (_pendingRequests.isNotEmpty) ...[
                SizedBox(width: context.spSM - 2),
                DsCountBadge(
                  count: _pendingRequests.length,
                  size: 20,
                ),
              ],
              const Spacer(),
              if (_pendingRequests.isNotEmpty)
                GestureDetector(
                  onTap: () => _showAllRequestsSheet(),
                  child: Text(
                    'Hammasi',
                    style: context.labelLarge(color: context.cPrimary),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: context.spMD),
        if (!_isAvailable)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
            child: DsCard(
              radius: context.radiusMD,
              hasBorder: false,
              color: context.cFieldFill,
              padding: EdgeInsets.all(context.spXL),
              child: Row(
                children: [
                  AppIcon('pause_circle_outline', size: 28, color: context.cTextTertiary),
                  SizedBox(width: context.spMD),
                  Expanded(
                    child: Text(
                      "Siz hozir 'Band' holatdasiz.\nSo'rovlarni qabul qilish uchun holatni o'zgartiring.",
                      style: context.bodyMedium(color: context.cTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_pendingRequests.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
            child: DsCard(
              radius: context.radiusMD,
              hasBorder: true,
              color: context.cFieldFill,
              padding: EdgeInsets.all(context.sp2XL),
              child: Column(
                children: [
                  AppIcon('inbox_outlined', size: 36, color: context.cTextTertiary),
                  SizedBox(height: context.spMD),
                  Text(
                    'Hozircha so\'rovlar yo\'q',
                    style: context.bodyMedium(color: context.cTextSecondary).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: context.spXS),
                  Text(
                    "Haydovchilar so'rov yuborganida bu yerda ko'rinadi",
                    style: context.bodySmall(color: context.cTextTertiary),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(
            _pendingRequests.length > 3 ? 3 : _pendingRequests.length,
            (i) {
              final req = _pendingRequests[i];
              final id = req['id'].toString();
              final ms = req['time'] as int? ?? 0;
              final dt = DateTime.fromMillisecondsSinceEpoch(ms);
              final diff = DateTime.now().difference(dt);
              final timeAgo = diff.inMinutes < 1 ? 'Hozir' : '${diff.inMinutes} daq';
              return Padding(
                padding: EdgeInsets.only(
                  left: context.screenHorizontal,
                  right: context.screenHorizontal,
                  bottom: context.spSM + 2,
                ),
                child: IncomingRequestCard(
                  driverName: req['driverName'] as String? ?? 'Haydovchi',
                  problemType: _typeLabel(req['type'] as String? ?? ''),
                  distance: req['address'] as String? ?? '',
                  etaMinutes: 3,
                  reward: req['agreed_price'] != null
                      ? '${req['agreed_price']} so\'m'
                      : '',
                  timeAgo: timeAgo,
                  onAccept: () => _acceptRequest(id),
                  onDecline: () => _declineRequest(id),
                ),
              );
            },
          ),
        if (_pendingRequests.length > 3) ...[
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: _showAllRequestsSheet,
              child: Text(
                'Yana ${_pendingRequests.length - 3} ta so\'rov',
                style: context.labelLarge(color: context.cPrimary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEarningsChartSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: context.gPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: context.spSM),
                Text(
                  'Daromadlar',
                  style: context.headingSmall(color: context.cTextPrimary),
                ),
              ],
            ),
          ),
          const EarningsChart(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.cDanger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: AppIcon('error_outline_rounded', size: 36, color: context.cDanger),
            ),
            const SizedBox(height: 16),
            Text(
              'Xatolik yuz berdi',
              style: context.headingSmall(color: context.cTextPrimary),
            ),
            SizedBox(height: context.spSM),
            Text(
              'Profil ma\'lumotlarini yuklashda xatolik.\nIltimos, qayta urinib ko\'ring.',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadProfile,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.sp2XL, vertical: context.spMD),
                decoration: BoxDecoration(
                  gradient: context.gPrimary,
                  borderRadius: BorderRadius.circular(context.radiusMD),
                ),
                child: Text(
                  'Qayta urinish',
                  style: context.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRequest(String id) async {
    HapticFeedback.mediumImpact();
    try {
      final numId = int.tryParse(id);
      if (numId != null) {
        await ApiService.acceptRequest(numId);
      } else {
        await AppStorage.updateRequestStatus(id, 'accepted');
      }
      await _loadProfile();
      if (mounted) context.push('/request-status/$id');
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _declineRequest(String id) async {
    HapticFeedback.lightImpact();
    try {
      final numId = int.tryParse(id);
      if (numId != null) {
        await ApiService.declineRequest(numId);
      } else {
        await AppStorage.updateRequestStatus(id, 'declined');
      }
      await _loadProfile();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showAllRequestsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          padding: EdgeInsets.all(context.spLG),
          decoration: BoxDecoration(
            color: context.cSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXL),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: context.spLG),
                decoration: BoxDecoration(
                  color: context.cTextTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Barcha so\'rovlar (${_pendingRequests.length})',
                style: context.headingSmall(color: context.cTextPrimary),
              ),
              SizedBox(height: context.spMD),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _pendingRequests.length,
                  padding: EdgeInsets.only(bottom: context.sp2XL),
                  itemBuilder: (_, i) {
                    final req = _pendingRequests[i];
                    final id = req['id'].toString();
                    final ms = req['time'] as int? ?? 0;
                    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
                    final diff = DateTime.now().difference(dt);
                    final timeAgo = diff.inMinutes < 1 ? 'Hozir' : '${diff.inMinutes} daq';
                    return Padding(
                      padding: EdgeInsets.only(bottom: context.spSM + 2),
                      child: IncomingRequestCard(
                        driverName: req['driverName'] as String? ?? 'Haydovchi',
                        problemType: _typeLabel(req['type'] as String? ?? ''),
                        distance: req['address'] as String? ?? '',
                        etaMinutes: 3,
                        reward: req['agreed_price'] != null
                            ? '${req['agreed_price']} so\'m'
                            : '',
                        timeAgo: timeAgo,
                        onAccept: () {
                          Navigator.of(context).pop();
                          _acceptRequest(id);
                        },
                        onDecline: () {
                          Navigator.of(context).pop();
                          _declineRequest(id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.all(context.screenHorizontal),
        padding: EdgeInsets.all(context.sp2XL),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(context.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.cTextTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.spLG),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: context.cPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('bar_chart_rounded', size: 28, color: DesignTokens.primary),
            ),
            SizedBox(height: context.spLG),
            Text(
              'Statistika',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            SizedBox(height: context.spSM),
            Text(
              'To\'liq statistika paneli tez kunda',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spXL),
            Row(
              children: [
                Expanded(
                  child: _statsBox(context, 'Ishlar', '$_totalJobs'),
                ),
                SizedBox(width: context.spSM),
                Expanded(
                  child: _statsBox(context, 'Reyting', _avgRating.toStringAsFixed(1)),
                ),
                SizedBox(width: context.spSM),
                Expanded(
                  child: _statsBox(context, 'Izohlar', '$_reviewCount'),
                ),
              ],
            ),
            SizedBox(height: context.spLG),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: context.spMD + 2),
                decoration: BoxDecoration(
                  gradient: context.gPrimary,
                  borderRadius: BorderRadius.circular(context.radiusMD),
                ),
                child: Center(
                  child: Text(
                    'Yopish',
                    style: context.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsBox(BuildContext context, String label, String value) {
    return DsCard(
      radius: context.radiusMD,
      hasBorder: false,
      color: context.cFieldFill,
      padding: EdgeInsets.all(context.spMD),
      child: Column(
        children: [
          Text(
            value,
            style: context.headingSmall(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: context.labelSmall(color: context.cTextSecondary),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
    'battery' => 'Akkumulyator',
    'tire' => "Shina",
    'engine' => 'Motor muammosi',
    'evacuation' => 'Evakuator',
    'gas' => 'Gaz/Shlang',
    _ => 'Boshqa muammo',
  };
}
