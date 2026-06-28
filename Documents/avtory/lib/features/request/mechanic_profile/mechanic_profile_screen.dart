import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/widgets/mechanic_avatar.dart';
import '../../../shared/widgets/ds_card.dart';
import '../../../shared/widgets/ds_surface.dart';
import '../../../shared/widgets/ds_chip.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/photo_picker.dart';
import '../../../data/local/app_storage.dart' show ServicePriceData;
import '../../../core/network/auth_guard.dart';
import '../../../services/api_service.dart';
import '../../../services/location_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/app_icon.dart';

class MechanicProfileScreen extends StatefulWidget {
  const MechanicProfileScreen({super.key, required this.mechanicId});
  final String mechanicId;

  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  bool _isLoading = true;
  String? _error;
  bool _calling = false;
  bool _isFavorite = false;
  String? _photo;

  Map<String, dynamic> _m = {};
  List<ServicePriceData> _prices = [];
  List<Map<String, dynamic>> _reviews = [];

  late double _driverLat;
  late double _driverLng;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.mechanicId);
    if (id == null) {
      setState(() {
        _error = "Mexanik topilmadi";
        _isLoading = false;
      });
      return;
    }
    try {
      final pos = await LocationService.current();
      _driverLat = pos.lat;
      _driverLng = pos.lng;
      final data =
          await ApiService.getMechanicDetail(id, lat: pos.lat, lng: pos.lng);
      final prices = (data['enabled_prices'] as List? ?? []).map((p) {
        final mp = p as Map<String, dynamic>;
        final type = mp['service_type'] as String? ?? 'other';
        final base = ServicePriceData.allTypes.firstWhere(
          (t) => t.type == type,
          orElse: () => ServicePriceData(
              type: type,
              label: type,
              icon: 'build_rounded',
              color: 0xFF6B7280,
              minPrice: 0,
              maxPrice: 0,
              enabled: true),
        );
        return ServicePriceData(
            type: type,
            label: base.label,
            icon: base.icon,
            color: base.color,
            minPrice: (mp['min_price'] as num?)?.toInt() ?? base.minPrice,
            maxPrice: (mp['max_price'] as num?)?.toInt() ?? base.maxPrice,
            enabled: true);
      }).toList();
      List<Map<String, dynamic>> reviews = [];
      try {
        final raw = await ApiService.getMechanicReviews(id);
        reviews = raw.map((e) => e as Map<String, dynamic>).toList();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _m = data;
          _prices = prices;
          _reviews = reviews;
          _isFavorite = data['is_favorite'] as bool? ?? false;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "Ma'lumotni yuklashda xato";
          _isLoading = false;
        });
      }
    }
  }

  String get _displayName {
    final name =
        '${_m['name'] ?? ''} ${_m['surname'] ?? ''}'.trim();
    return name.isEmpty ? 'Mexanik' : name;
  }

  Future<void> _call() async {
    if (_calling) return;
    final failMsg = AppLocalizations.of(context).t('requestFailed');
    setState(() => _calling = true);
    try {
      final id = int.parse(widget.mechanicId);
      final services =
          List<String>.from(_m['services'] as List? ?? []);
      final serviceType = _prices.isNotEmpty
          ? _prices.first.type
          : (services.isNotEmpty ? services.first : 'other');
      final req = await ApiService.createRequest({
        'service_type': serviceType,
        'mechanic': id,
        'driver_lat': _driverLat,
        'driver_lng': _driverLng,
        'driver_address': (_m['address'] as String?) ?? '',
        if (_photo != null) 'photo': _photo,
      });
      final reqId = req['id'];
      final mechName = (req['mechanic_name'] as String?)?.trim();
      if (mounted) {
        final nm = (mechName == null || mechName.isEmpty)
            ? _displayName
            : mechName;
        context.push(
            '/request-status/$reqId?mechanic=${Uri.encodeComponent(nm)}');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        _snack("Xizmatdan foydalanish uchun profilingizni to'ldiring");
      } else if (!AuthGuard.handleUnauthorized(context, e)) {
        _snack(e.message);
      }
    } catch (_) {
      _snack(failMsg);
    } finally {
      if (mounted) setState(() => _calling = false);
    }
  }

  // ignore: unused_element
  Future<void> _message() async {
    final failMsg = AppLocalizations.of(context).t('requestFailed');
    try {
      final id = int.parse(widget.mechanicId);
      final req = await ApiService.createRequest({
        'service_type': 'other',
        'mechanic': id,
        'driver_lat': _driverLat,
        'driver_lng': _driverLng,
        'description': "Xabar orqali bog'lanish",
      });
      final reqId = req['id'];
      if (mounted) {
        context.push(
            '/chat?mechanic=${Uri.encodeComponent(_displayName)}&requestId=$reqId');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        _snack("Xizmatdan foydalanish uchun profilingizni to'ldiring");
      } else if (!AuthGuard.handleUnauthorized(context, e)) {
        _snack(e.message);
      }
    } catch (_) {
      _snack(failMsg);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: context.cDanger));
  }

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLG))),
      builder: (_) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: context.spMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _.cBorder,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: l.t('photoFromCamera'),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: context.cPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: AppIcon('camera_alt_outlined',
                        color: context.cPrimary),
                  ),
                  title: Text(l.t('photoFromCamera')),
                  onTap: () =>
                      Navigator.pop(context, ImageSource.camera),
                ),
              ),
              Semantics(
                button: true,
                label: l.t('photoFromGallery'),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: context.cPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: AppIcon('photo_library_outlined',
                        color: context.cPrimary),
                  ),
                  title: Text(l.t('photoFromGallery')),
                  onTap: () =>
                      Navigator.pop(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    try {
      final dataUrl = await pickPhotoDataUrl(source);
      if (dataUrl != null && mounted) setState(() => _photo = dataUrl);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final id = int.tryParse(widget.mechanicId);
    if (id == null) return;
    setState(() => _isFavorite = !_isFavorite);
    try {
      final result = await ApiService.toggleFavorite(id);
      if (mounted) setState(() => _isFavorite = result);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !_isFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading(context);
    if (_error != null) return _buildError(context);

    return Scaffold(
      backgroundColor: context.cScaffold,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCta(context),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        backgroundColor: context.cSurface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spLG),
        child: Column(
          children: [
            _skeletonBlock(height: 200),
            SizedBox(height: context.spLG),
            _skeletonBlock(height: 72),
            SizedBox(height: context.spLG),
            _skeletonBlock(height: 48),
            SizedBox(height: context.spLG),
            _skeletonBlock(height: 160),
            SizedBox(height: context.spLG),
            _skeletonBlock(height: 120),
            SizedBox(height: context.spLG),
            _skeletonBlock(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBlock({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: context.cFieldFill,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        backgroundColor: context.cSurface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ErrorStateWidget(
        icon: 'error_outline_rounded',
        message: _error,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _load();
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final lat = (_m['lat'] as num?)?.toDouble();
    final lng = (_m['lng'] as num?)?.toDouble();
    final hasMap = lat != null && lng != null;

    return SliverAppBar(
      expandedHeight: hasMap ? 200 : 0,
      pinned: true,
      stretch: true,
      backgroundColor: context.cSurface,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.cSurface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8)
              ],
            ),
            child: const AppIcon('arrow_back_ios_new', size: 16),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.cSurface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8)
                ],
              ),
              child: AppIcon(
                _isFavorite ? 'favorite' : 'favorite_border',
                size: 18,
                color: _isFavorite
                    ? context.cDanger
                    : context.cTextSecondary,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: hasMap
          ? FlexibleSpaceBar(
              background: Stack(
                children: [
                  ClipRRect(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat, lng),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'uz.avtory.app',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 56,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: context.cPrimary,
                                    width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color: context.cPrimary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12)
                                ],
                              ),
                              child: AppIcon('build_rounded',
                                  color: context.cPrimary,
                                  size: 24),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          context.cScaffold,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context) {
    final l = AppLocalizations.of(context);
    final displayName = _displayName;
    final speciality = (_m['speciality'] as String?)?.trim();
    final experience =
        (_m['experience_years'] as num?)?.toInt() ?? 0;
    final totalJobs =
        (_m['total_jobs'] as num?)?.toInt() ?? 0;
    final workshopName = (_m['workshop_name'] as String?) ?? '';
    final address = (_m['address'] as String?) ?? '';
    final avgRating =
        (_m['avg_rating'] as num?)?.toDouble() ?? 0;
    final reviewCount =
        (_m['total_reviews'] as num?)?.toInt() ?? 0;
    final isAvailable = (_m['is_available'] as bool?) ?? true;
    final isVerified = (_m['is_verified'] as bool?) ?? false;
    final services =
        List<String>.from(_m['services'] as List? ?? []);
    final avatar = _m['avatar'] as String?;
    final distanceKm =
        (_m['distance_km'] as num?)?.toDouble();
    final etaMinutes = (_m['eta_minutes'] as int?);
    final phone = _m['phone'] as String?;
    final workStart = (_m['work_start'] as String?) ?? '';
    final workEnd = (_m['work_end'] as String?) ?? '';
    final lat = (_m['lat'] as num?)?.toDouble();
    final lng = (_m['lng'] as num?)?.toDouble();
    final hasWorkshop = workshopName.isNotEmpty || address.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spLG,
        0,
        context.spLG,
        context.spLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(
            avatar: avatar,
            name: displayName,
            isVerified: isVerified,
            isAvailable: isAvailable,
            speciality: speciality,
            avgRating: avgRating,
            reviewCount: reviewCount,
            experience: experience,
            totalJobs: totalJobs,
            distanceKm: distanceKm,
            etaMinutes: etaMinutes,
          ),
          SizedBox(height: context.spLG),
          _buildStatsGrid(
            context,
            totalJobs: totalJobs,
            reviewCount: reviewCount,
            avgRating: avgRating,
            serviceCount: services.length,
          ),
          if (_prices.isNotEmpty) ...[
            SizedBox(height: context.sp2XL),
            const _SectionTitle(title: 'Xizmatlar va narxlar'),
            SizedBox(height: context.spSM),
            Wrap(
              spacing: context.spSM,
              runSpacing: context.spSM,
              children: _prices.map((p) => DsServiceChip(
                label: p.label,
                icon: p.icon,
                color: Color(p.color),
              )).toList(),
            ),
          ],
          if (hasWorkshop) ...[
            SizedBox(height: context.sp2XL),
            const _SectionTitle(title: 'Ustaxona'),
            SizedBox(height: context.spSM),
            _WorkshopCard(
              workshopName: workshopName,
              address: address,
              distanceKm: distanceKm,
              workStart: workStart,
              workEnd: workEnd,
              phone: phone,
              onCall: phone != null ? () => dialPhone(phone) : null,
              onMap: (lat != null && lng != null)
                  ? () {
                      context.push(
                          '/map?lat=$lat&lng=$lng');
                    }
                  : null,
            ),
          ],
          SizedBox(height: context.sp2XL),
          _AvailabilityCard(
            isAvailable: isAvailable,
            etaMinutes: etaMinutes,
            workStart: workStart,
            workEnd: workEnd,
            distanceKm: distanceKm,
          ),
          if (speciality != null || experience > 0) ...[
            SizedBox(height: context.sp2XL),
            const _SectionTitle(title: 'Usta haqida'),
            SizedBox(height: context.spSM),
            _AboutCard(
              speciality: speciality,
              experience: experience,
              totalJobs: totalJobs,
              services: services,
            ),
          ],
          if (_reviews.isNotEmpty) ...[
            SizedBox(height: context.sp2XL),
            _SectionTitle(
                title: 'Sharhlar ($reviewCount)'),
            SizedBox(height: context.spSM),
            ..._reviews
                .take(5)
                .map((r) => Padding(
                      padding: EdgeInsets.only(
                          bottom: context.spSM),
                      child: _ReviewCard(review: r),
                    )),
          ],
          SizedBox(height: context.spLG),
          _buildPhotoSection(l),
          SizedBox(height: context.sp2XL),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalJobs,
    required int reviewCount,
    required double avgRating,
    required int serviceCount,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(
              icon: 'check_circle_outline',
              value: '$totalJobs',
              label: 'Bajarilgan ishlar',
            )),
            SizedBox(width: context.spSM),
            Expanded(child: _StatCard(
              icon: 'chat_bubble_outline',
              value: '$reviewCount',
              label: 'Sharhlar',
            )),
          ],
        ),
        SizedBox(height: context.spSM),
        Row(
          children: [
            Expanded(child: _StatCard(
              icon: 'star_outline',
              value: avgRating.toStringAsFixed(1),
              label: 'Reyting',
            )),
            SizedBox(width: context.spSM),
            Expanded(child: _StatCard(
              icon: 'build_outline',
              value: '$serviceCount',
              label: 'Xizmatlar soni',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSection(AppLocalizations l) {
    if (_photo == null) {
      return OutlinedButton.icon(
        onPressed: _pickPhoto,
        icon: const AppIcon('add_a_photo_outlined', size: 18),
        label: Text(l.t('attachPhoto')),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: context.cPrimary,
          side: BorderSide(
              color: context.cPrimary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusMD),
          ),
        ),
      );
    }
    final data = decodeDataUrl(_photo);
    return Container(
      padding: EdgeInsets.all(context.spMD),
      decoration: BoxDecoration(
        color: context.cFieldFill,
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusMD),
      ),
      child: Row(
        children: [
          if (data != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              child: Image.memory(data,
                  width: 56, height: 56, fit: BoxFit.cover),
            ),
          if (data != null)
            SizedBox(width: context.spMD),
          Expanded(
            child: Text(l.t('problemPhoto'),
                style: context.bodyMedium()),
          ),
          IconButton(
            icon: AppIcon('close',
                size: 20, color: context.cDanger),
            onPressed: () => setState(() => _photo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    final l = AppLocalizations.of(context);
    final phone = _m['phone'] as String?;
    return Container(
      padding: EdgeInsets.only(
        left: context.spLG,
        right: context.spLG,
        top: context.spMD,
        bottom: MediaQuery.of(context).padding.bottom + context.spMD,
      ),
      decoration: BoxDecoration(
        color: context.cSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppOutlinedButton(
              label: "Qo'ng'iroq qilish",
              appIcon: 'phone_outlined',
              onPressed: phone != null ? () => dialPhone(phone) : null,
            ),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            flex: 2,
            child: AppGradientButton(
              label: _calling ? l.t('sending') : "Yordam so'rash",
              onPressed: _calling ? null : _call,
              appIcon: _calling ? null : 'build_rounded',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.avatar,
    required this.name,
    required this.isVerified,
    required this.isAvailable,
    this.speciality,
    required this.avgRating,
    required this.reviewCount,
    required this.experience,
    required this.totalJobs,
    this.distanceKm,
    this.etaMinutes,
  });

  final String? avatar;
  final String name;
  final bool isVerified;
  final bool isAvailable;
  final String? speciality;
  final double avgRating;
  final int reviewCount;
  final int experience;
  final int totalJobs;
  final double? distanceKm;
  final int? etaMinutes;

  @override
  Widget build(BuildContext context) {
    final sp = speciality;
    return DsSurface(
      gradient: context.gPremium,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.spLG),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    MechanicAvatar(avatar: avatar, name: name, size: 80),
                    if (isVerified)
                      Positioned(
                        top: 0,
                        right: -2,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: DesignTokens.verified,
                            shape: BoxShape.circle,
                          ),
                          child: const AppIcon('verified', size: 14, color: Colors.white),
                        ),
                      ),
                    Positioned(
                      bottom: 2,
                      right: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isAvailable ? context.cOnline : context.cOffline,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
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
                      Text(
                        name,
                        style: context.headingSmall(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sp != null && sp.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          sp,
                          style: context.bodySmall(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                      SizedBox(height: context.spSM),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final filled = avgRating >= i + 0.5;
                            return Padding(
                              padding: const EdgeInsets.only(right: 1),
                              child: AppIcon(
                                filled ? 'star_rounded' : 'star_outline',
                                size: 14,
                                color: filled ? DesignTokens.star : Colors.white.withValues(alpha: 0.4),
                              ),
                            );
                          }),
                          SizedBox(width: context.spXS),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: context.labelLarge(color: Colors.white),
                          ),
                          if (reviewCount > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($reviewCount)',
                              style: context.labelMedium(color: Colors.white.withValues(alpha: 0.7)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spMD),
            Row(
              children: [
                if (experience > 0) ...[
                  _HeaderChip(icon: 'work_outline', label: '$experience yil'),
                  SizedBox(width: context.spSM),
                ],
                if (totalJobs > 0)
                  _HeaderChip(icon: 'check_circle_rounded', label: '$totalJobs ish'),
              ],
            ),
            if (distanceKm != null || etaMinutes != null) ...[
              SizedBox(height: context.spSM),
              Row(
                children: [
                  if (distanceKm != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon('location_on_rounded', size: 13, color: Colors.white.withValues(alpha: 0.7)),
                        const SizedBox(width: 2),
                        Text(
                          '${distanceKm!.toStringAsFixed(1)} km',
                          style: context.labelMedium(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  if (distanceKm != null && etaMinutes != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('•', style: context.labelMedium(color: Colors.white.withValues(alpha: 0.5))),
                    ),
                  if (etaMinutes != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon('timer_outlined', size: 13, color: context.cSuccessLight),
                        const SizedBox(width: 2),
                        Text(
                          '$etaMinutes min',
                          style: context.labelMedium(color: context.cSuccessLight),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: EdgeInsets.all(context.spMD),
      child: Column(
        children: [
          AppIcon(icon, size: 20, color: context.cPrimary),
          SizedBox(height: context.spXS),
          Text(
            value,
            style: context.headingSmall(color: context.cTextPrimary),
          ),
          Text(
            label,
            style: context.labelSmall(color: context.cTextTertiary),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.spSM, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: context.labelSmall(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: DesignTokens.primaryGradient,
            borderRadius:
                BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.spSM),
        Text(
          title,
          style: context.titleLarge(color: context.cTextPrimary),
        ),
      ],
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  const _WorkshopCard({
    required this.workshopName,
    required this.address,
    this.distanceKm,
    this.workStart,
    this.workEnd,
    this.phone,
    this.onCall,
    this.onMap,
  });

  final String workshopName;
  final String address;
  final double? distanceKm;
  final String? workStart;
  final String? workEnd;
  final String? phone;
  final VoidCallback? onCall;
  final VoidCallback? onMap;

  @override
  Widget build(BuildContext context) {
    final ph = phone;
    final wn = workshopName;

    return Container(
      padding: EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
        boxShadow: DesignTokens.shadowSM(
          context.isDark ? Colors.black : DesignTokens.lightTextPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.cPrimary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                      DesignTokens.radiusMD),
                ),
                child: AppIcon('store_outlined',
                    size: 20, color: context.cPrimary),
              ),
              SizedBox(width: context.spMD),
              Expanded(
                child: Text(
                  wn.isNotEmpty
                      ? wn
                      : 'Ustaxona',
                  style: context.titleMedium(color: context.cTextPrimary),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spMD),
          _InfoRow(
              icon: 'location_on_rounded',
              text: address.isNotEmpty
                  ? address
                  : 'Manzil ko\'rsatilmagan'),
          if (distanceKm != null)
            Padding(
              padding: EdgeInsets.only(
                  top: context.spSM),
              child: _InfoRow(
                  icon: 'near_me_rounded',
                  text:
                      '${distanceKm!.toStringAsFixed(1)} km uzoqlikda'),
            ),
          if (workStart != null || workEnd != null)
            Padding(
              padding: EdgeInsets.only(
                  top: context.spSM),
              child: _InfoRow(
                  icon: 'access_time',
                  text:
                      '${workStart ?? "00:00"} - ${workEnd ?? "24:00"}'),
            ),
          if (ph != null)
            Padding(
              padding: EdgeInsets.only(
                  top: context.spSM),
              child: _InfoRow(
                  icon: 'phone_outlined',
                  text: ph),
            ),
          if (onMap != null || onCall != null) ...[
            SizedBox(height: context.spMD),
            Row(
              children: [
                if (onMap != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMap,
                      icon: const AppIcon(
                          'my_location_rounded',
                          size: 16),
                      label: Text(
                        'Xaritada',
                        style: context.bodySmall(),
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            context.cPrimary,
                        side: BorderSide(
                            color: context
                                .cPrimary
                                .withValues(
                                    alpha: 0.3)),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  DesignTokens
                                      .radiusSM),
                        ),
                        padding: const EdgeInsets
                            .symmetric(
                            vertical: 10),
                      ),
                    ),
                  ),
                if (onMap != null && onCall != null)
                  SizedBox(
                      width: context.spSM),
                if (onCall != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCall,
                      icon: const AppIcon(
                          'phone_outlined',
                          size: 16),
                      label: Text(
                        'Qo\'ng\'iroq',
                        style: context.bodySmall(),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            DesignTokens.success,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  DesignTokens
                                      .radiusSM),
                        ),
                        padding: const EdgeInsets
                            .symmetric(
                            vertical: 10),
                        elevation: 0,
                      ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon,
            size: 15, color: context.cTextTertiary),
        SizedBox(width: context.spSM),
        Expanded(
          child: Text(
            text,
            style: context.bodySmall(color: context.cTextSecondary),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    this.etaMinutes,
    this.workStart,
    this.workEnd,
    this.distanceKm,
  });

  final bool isAvailable;
  final int? etaMinutes;
  final String? workStart;
  final String? workEnd;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.success.withValues(alpha: 0.06),
            context.cPrimary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(
          color: DesignTokens.success.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isAvailable
                      ? DesignTokens.success
                      : DesignTokens.lightTextTertiary)
                  .withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusMD),
            ),
            child: AppIcon(
              isAvailable
                  ? 'check_circle_rounded'
                  : 'pause_circle_outline',
              size: 22,
              color: isAvailable
                  ? DesignTokens.success
                  : DesignTokens.lightTextTertiary,
            ),
          ),
          SizedBox(width: context.spMD),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? DesignTokens.success
                            : DesignTokens
                                .lightTextTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable
                          ? 'Hozir bo\'sh'
                          : 'Band',
                      style: context.titleMedium(color: context.cTextPrimary),
                    ),
                  ],
                ),
                if (etaMinutes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Kelish vaqti: $etaMinutes min',
                    style: context.bodySmall(color: context.cSuccess).copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
                if (workStart != null ||
                    workEnd != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 2),
                    child: Text(
                      'Ish vaqti: ${workStart ?? "00:00"} - ${workEnd ?? "24:00"}',
                      style: context.bodySmall(color: context.cTextTertiary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatefulWidget {
  const _AboutCard({
    this.speciality,
    required this.experience,
    required this.totalJobs,
    required this.services,
  });

  final String? speciality;
  final int experience;
  final int totalJobs;
  final List<String> services;

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _expanded = false;

  static const _serviceColors = {
    'battery': Color(0xFF3B82F6),
    'tire': Color(0xFF10B981),
    'engine': Color(0xFFF59E0B),
    'evacuation': Color(0xFFEF4444),
    'gas': Color(0xFF8B5CF6),
    'other': Color(0xFF6B7280),
  };

  static const _serviceIcons = {
    'battery': 'battery_charging_full_rounded',
    'tire': 'tire_repair_rounded',
    'engine': 'engineering_rounded',
    'evacuation': 'local_shipping_rounded',
    'gas': 'water_drop_rounded',
    'other': 'build_rounded',
  };

  @override
  Widget build(BuildContext context) {
    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                if (widget.speciality != null && widget.speciality!.isNotEmpty) ...[
                  AppIcon('build_rounded', size: 16, color: context.cPrimary),
                  SizedBox(width: context.spSM),
                  Expanded(
                    child: Text(
                      widget.speciality!,
                      style: context.bodyMedium(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ] else
                  const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: DesignTokens.animNormal,
                  child: AppIcon('expand_more', size: 20, color: context.cTextTertiary),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(top: context.spMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  SizedBox(height: context.spMD),
                  Row(
                    children: [
                      _AboutItem(icon: 'work_outline', value: '${widget.experience} yil', label: 'Tajriba'),
                      SizedBox(width: context.spXL),
                      _AboutItem(icon: 'check_circle_rounded', value: '${widget.totalJobs}', label: 'Bajarilgan ishlar'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.cPrimary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                        ),
                        child: Text(
                          '${widget.services.length} xizmat',
                          style: context.labelSmall(color: context.cPrimary),
                        ),
                      ),
                    ],
                  ),
                  if (widget.services.isNotEmpty) ...[
                    SizedBox(height: context.spMD),
                    Wrap(
                      spacing: context.spSM,
                      runSpacing: context.spSM,
                      children: widget.services.map((s) {
                        final color = _serviceColors[s] ?? context.cPrimary;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: context.spSM, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(_serviceIcons[s] ?? 'build_rounded', size: 12, color: color),
                              const SizedBox(width: 4),
                              Text(s, style: context.labelSmall(color: color)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: DesignTokens.animNormal,
          ),
        ],
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon(icon,
                size: 14, color: context.cPrimary),
            const SizedBox(width: 4),
            Text(
              value,
              style: context.titleMedium(color: context.cTextPrimary),
            ),
          ],
        ),
        Text(
          label,
          style: context.labelSmall(color: context.cTextTertiary),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final stars =
        (review['stars'] as num?)?.toInt() ?? 0;
    final comment =
        (review['comment'] as String?)?.trim() ?? '';
    final name =
        (review['driver_name'] as String?) ?? 'Haydovchi';
    final createdAt = review['created_at'] as String?;
    String timeAgo = '';
    if (createdAt != null) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        final diff =
            DateTime.now().difference(dt);
        if (diff.inDays > 0) {
          timeAgo = '${diff.inDays} kun oldin';
        } else if (diff.inHours > 0) {
          timeAgo = '${diff.inHours} soat oldin';
        } else {
          timeAgo = 'Hozir';
        }
      }
    }

    return Column(
      children: [
        DsCard(
          padding: EdgeInsets.all(context.spLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.cPrimary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'H',
                        style: context.titleMedium(color: context.cPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: context.spSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: context.titleSmall(color: context.cTextPrimary)),
                        if (timeAgo.isNotEmpty)
                          Text(timeAgo, style: context.labelSmall(color: context.cTextTertiary)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => Padding(
                      padding: const EdgeInsets.only(right: 1),
                      child: AppIcon(
                        i < stars ? 'star_rounded' : 'star_border_rounded',
                        size: 14,
                        color: DesignTokens.star,
                      ),
                    )),
                  ),
                ],
              ),
              if (comment.isNotEmpty) ...[
                SizedBox(height: context.spSM),
                Text(
                  comment,
                  style: context.bodySmall(color: context.cTextSecondary).copyWith(height: 1.45),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: context.spLG, right: context.spLG),
          child: Divider(height: 1, color: context.cDivider),
        ),
      ],
    );
  }
}
