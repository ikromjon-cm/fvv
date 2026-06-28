import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/components/buttons/app_buttons.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/ds_badge.dart';
import '../../shared/widgets/ds_card.dart';
import '../../shared/widgets/ds_loading.dart';
import '../../shared/widgets/ds_surface.dart';
import '../../shared/widgets/error_state.dart';

class VehicleDashboardScreen extends StatefulWidget {
  const VehicleDashboardScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehicleDashboardScreen> createState() => _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends State<VehicleDashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _vehicle;
  Map<String, String> _modelImages = {};
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _favorites = [];
  String? _mechanicPhone;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getVehicles(),
        ApiService.getCarCatalogue(),
        ApiService.getRequests(),
        AppStorage.getHistory(),
        ApiService.getFavorites(),
        ApiService.getDriverProfile(),
      ]);
      final vehicles = (results[0] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final catalogue = results[1] as Map<String, dynamic>;
      final requestsRaw = results[2] as List<dynamic>;
      final historyList = results[3] as List<Map<String, dynamic>>;
      final favoritesRaw = results[4] as List<dynamic>;
      final driverProfile = results[5] as Map<String, dynamic>;

      final vehicleId = int.tryParse(widget.vehicleId);
      final vehicle = vehicles.firstWhere(
        (v) => v['id'] == vehicleId,
        orElse: () => <String, dynamic>{},
      );

      final images = <String, String>{};
      final brands = (catalogue['brands'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
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

      final requests = requestsRaw
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final favorites = favoritesRaw
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final phone = driverProfile['phone'] as String?;

      if (mounted) {
        setState(() {
          _vehicle = vehicle;
          _modelImages = images;
          _requests = requests;
          _history = historyList;
          _favorites = favorites;
          _mechanicPhone = phone;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e is ApiException ? e.message : 'Xatolik yuz berdi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: Text(
          _vehicle != null
              ? (_vehicle!['model'] as String? ?? 'Avtomobil')
              : 'Avtomobil',
          style: context.headingSmall(color: context.cTextPrimary),
        ),
        backgroundColor: context.cScaffold,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const AppIcon('edit_outlined', size: 20),
            onPressed: () => context.pushNamed('vehicles'),
          ),
        ],
      ),
      body: _loading
          ? _buildSkeleton()
          : _error != null
              ? ErrorStateWidget(message: _error, onRetry: _load)
              : _vehicle == null || _vehicle!.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.sp4XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.cFieldFill,
                shape: BoxShape.circle,
              ),
              child: AppIcon('directions_car_rounded', size: 44, color: context.cTextTertiary),
            ),
            SizedBox(height: context.sp2XL),
            Text(
              'Avtomobil topilmadi',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            SizedBox(height: context.spSM),
            Text(
              'Avtomobil ma\'lumotlari yuklanmadi',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.sp2XL),
            AppPrimaryButton(
              label: 'Qayta yuklash',
              onPressed: _load,
              width: 220,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return DsShimmer(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
        children: [
          const SizedBox(height: 12),
          DsShimmerSurface(height: 200, radius: context.radiusLG),
          const SizedBox(height: 16),
          const DsShimmerSurface(height: 80),
          const SizedBox(height: 16),
          const DsShimmerSurface(height: 180),
          const SizedBox(height: 16),
          const DsShimmerSurface(height: 100),
          const SizedBox(height: 16),
          const DsShimmerSurface(height: 100),
          const SizedBox(height: 16),
          const DsShimmerSurface(height: 60),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final v = _vehicle!;
    final model = v['model'] as String? ?? '';
    final number = v['number'] as String? ?? '';
    final vehicleImage = v['image'] as String? ?? _modelImages[model];
    final brand = model.split(' ').first;
    final modelName = model.replaceFirst('$brand ', '');
    final isDefault = v['is_default'] as bool? ?? false;

    final completed = _requests.where((r) => r['status'] == 'completed').toList();
    final totalSpending = completed.fold<int>(
      0,
      (sum, r) => sum + ((r['agreed_price'] as int?) ?? (r['price'] as int?) ?? 0),
    );

    final vehicleId = v['id'];
    final recentRequests = _requests
        .where((r) => r['vehicle'] == vehicleId || r['vehicle_id'] == vehicleId)
        .take(3)
        .toList();

    String? favMechanic;
    String? favMechanicPhone;
    for (final h in _history) {
      final mechName = h['mechanic_name'] as String?;
      if (mechName != null && mechName.isNotEmpty) {
        favMechanic = mechName;
        favMechanicPhone = h['mechanic_phone'] as String?;
        break;
      }
    }

    return RefreshIndicator(
      color: context.cPrimary,
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
        children: [
          SizedBox(height: context.spMD),
          _buildVehicleHero(vehicleImage, number, brand, modelName, isDefault),
          SizedBox(height: context.spLG),
          _buildStatsRow(_requests.length, completed.length, _favorites.length),
          SizedBox(height: context.spLG),
          if (totalSpending > 0) ...[
            _buildSection(
              title: 'Umumiy xarajat',
              icon: 'payments_outlined',
              child: DsCard(
                padding: EdgeInsets.all(context.spLG),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.cSuccess.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.radiusMD),
                      ),
                      child: AppIcon('payments_outlined', color: context.cSuccess, size: 22),
                    ),
                    SizedBox(width: context.spMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jami sarflangan',
                            style: context.bodySmall(color: context.cTextTertiary),
                          ),
                          SizedBox(height: context.spXXS),
                          Text(
                            _formatPrice(totalSpending),
                            style: context.headingMedium(color: context.cTextPrimary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'so\'m',
                      style: context.bodySmall(color: context.cTextTertiary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spLG),
          ],
          if (favMechanic != null) ...[
            _buildSection(
              title: 'Sevimli usta',
              icon: 'favorite_border_rounded',
              child: DsCard(
                padding: EdgeInsets.all(context.spLG),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.cFavorite.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.radiusMD),
                      ),
                      child: AppIcon('favorite_border_rounded', color: context.cFavorite, size: 22),
                    ),
                    SizedBox(width: context.spMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oxirgi murojaat qilingan usta',
                            style: context.bodySmall(color: context.cTextTertiary),
                          ),
                          SizedBox(height: context.spXXS),
                          Text(
                            favMechanic,
                            style: context.bodyLarge(color: context.cTextPrimary),
                          ),
                          if (favMechanicPhone != null && favMechanicPhone.isNotEmpty) ...[
                            SizedBox(height: context.spXXS),
                            Text(
                              favMechanicPhone,
                              style: context.bodySmall(color: context.cTextSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spLG),
          ],
          if (recentRequests.isNotEmpty) ...[
            _buildSection(
              title: 'Oxirgi faoliyat',
              icon: 'history_rounded',
              child: DsCard(
                padding: EdgeInsets.all(context.spLG),
                child: Column(
                  children: recentRequests
                      .map((r) => _buildRequestItem(r))
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: context.spLG),
          ],
          _buildPlaceholderSection(
            title: 'Kelgusi xizmat',
            icon: 'event_rounded',
            message: 'Ma\'lumot mavjud emas',
          ),
          SizedBox(height: context.spMD),
          _buildPlaceholderSection(
            title: 'Sug\'urta',
            icon: 'description_outlined',
            message: 'Ma\'lumot mavjud emas',
          ),
          SizedBox(height: context.spLG),
          _buildQuickActions(),
          SizedBox(height: context.sp4XL),
        ],
      ),
    );
  }

  Widget _buildVehicleHero(
    String? image,
    String number,
    String brand,
    String modelName,
    bool isDefault,
  ) {
    return DsCard(
      hasBorder: isDefault,
      borderColor: context.cPrimary.withValues(alpha: 0.3),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(context.radiusLG)),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primary.withValues(alpha: 0.06),
                    DesignTokens.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: image != null && image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const _CarIconPlaceholder(),
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const _CarIconPlaceholder(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.spLG),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand,
                        style: context.headingMedium(color: context.cTextPrimary),
                      ),
                      if (modelName.isNotEmpty) ...[
                        SizedBox(height: context.spXXS),
                        Text(
                          modelName,
                          style: context.bodyMedium(color: context.cTextSecondary),
                        ),
                      ],
                      if (number.isNotEmpty) ...[
                        SizedBox(height: context.spSM),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spSM + 2,
                            vertical: context.spXXS + 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.cPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(context.radiusSM),
                          ),
                          child: Text(
                            number,
                            style: context.labelSmall(color: context.cPrimary).copyWith(letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isDefault)
                  const DsBadge(
                    label: 'Asosiy',
                    variant: DsBadgeVariant.primary,
                    icon: 'check_circle_rounded',
                    fontSize: 11,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int completedCount, int favoritesCount) {
    return DsCard(
      padding: EdgeInsets.symmetric(vertical: context.spLG),
      child: DsStatsRow(
        items: [
          DsStatItem(
            value: total.toString(),
            label: 'Arizalar',
            appIcon: 'assignment_rounded',
            valueColor: context.cPrimary,
          ),
          DsStatItem(
            value: completedCount.toString(),
            label: 'Bajarilgan',
            appIcon: 'check_circle_rounded',
            valueColor: context.cSuccess,
          ),
          DsStatItem(
            value: favoritesCount.toString(),
            label: 'Sevimlilar',
            appIcon: 'favorite_border_rounded',
            valueColor: context.cFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    final status = request['status'] as String? ?? '';
    final type = request['problem_type'] as String? ?? request['type'] as String? ?? 'Xizmat';
    final time = request['created_at'] as String? ?? '';
    final date = time.isNotEmpty ? time.substring(0, 10) : '';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = context.cSuccess;
        statusLabel = 'Bajarilgan';
      case 'in_progress':
        statusColor = context.cWarning;
        statusLabel = 'Jarayonda';
      case 'accepted':
        statusColor = context.cPrimary;
        statusLabel = 'Qabul qilingan';
      default:
        statusColor = context.cTextTertiary;
        statusLabel = 'Kutilmoqda';
    }

    return Padding(
      padding: EdgeInsets.only(top: context.spSM),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            child: Text(
              type,
              style: context.bodyMedium(color: context.cTextPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (date.isNotEmpty) ...[
            SizedBox(width: context.spSM),
            Text(
              date,
              style: context.labelSmall(color: context.cTextTertiary),
            ),
          ],
          SizedBox(width: context.spSM),
          DsBadge(
            label: statusLabel,
            variant: DsBadgeVariant.neutral,
            fontSize: 9,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.spSM, bottom: context.spSM),
          child: Row(
            children: [
              AppIcon(icon, size: 18, color: context.cTextSecondary),
              SizedBox(width: context.spSM),
              Text(
                title,
                style: context.labelLarge(color: context.cTextSecondary),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildPlaceholderSection({
    required String title,
    required String icon,
    required String message,
  }) {
    return _buildSection(
      title: title,
      icon: icon,
      child: DsSurface(
        padding: EdgeInsets.all(context.spLG),
        hasBorder: true,
        borderColor: context.cBorder.withValues(alpha: 0.5),
        color: context.cCard,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.cFieldFill,
                borderRadius: BorderRadius.circular(context.radiusMD),
              ),
              child: AppIcon(icon, size: 20, color: context.cTextTertiary),
            ),
            SizedBox(width: context.spMD),
            Expanded(
              child: Text(
                message,
                style: context.bodyMedium(color: context.cTextTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: 'phone_outlined',
            label: 'Ustaga qo\'ng\'iroq',
            color: context.cSuccess,
            onTap: _callMechanic,
          ),
        ),
        SizedBox(width: context.spMD),
        Expanded(
          child: _QuickActionButton(
            icon: 'add_rounded',
            label: 'Yangi ariza',
            color: context.cPrimary,
            onTap: () => context.push('/problem-type'),
          ),
        ),
        SizedBox(width: context.spMD),
        Expanded(
          child: _QuickActionButton(
            icon: 'my_location_rounded',
            label: 'Joylashuv',
            color: context.cEmergency,
            onTap: _shareLocation,
          ),
        ),
      ],
    );
  }

  Future<void> _callMechanic() async {
    final phone = _mechanicPhone;
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usta telefoni mavjud emas')),
        );
      }
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joylashuv ulashish tez kunda')),
    );
  }

  String _formatPrice(int amount) {
    if (amount == 0) return '0';
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: context.spLG, horizontal: context.spSM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.radiusMD),
            ),
            child: AppIcon(icon, size: 22, color: color),
          ),
          SizedBox(height: context.spSM),
          Text(
            label,
            style: context.labelSmall(color: context.cTextSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CarIconPlaceholder extends StatelessWidget {
  const _CarIconPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppIcon('directions_car_rounded', size: 64, color: context.cTextTertiary.withValues(alpha: 0.4)),
    );
  }
}
