import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/request/request_bloc.dart';
import '../../../blocs/request/request_event.dart';
import '../../../blocs/request/request_state.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/user_model.dart';
import '../../../services/location_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/mechanic_card_v2.dart';
import '../../../shared/widgets/ds_chip.dart';

enum _SortMode { distance, rating, available }

class NearbyMechanicsScreen extends StatefulWidget {
  const NearbyMechanicsScreen({super.key, required this.problemType});
  final String problemType;

  @override
  State<NearbyMechanicsScreen> createState() => _NearbyMechanicsScreenState();
}

class _NearbyMechanicsScreenState extends State<NearbyMechanicsScreen> {
  _SortMode _sort = _SortMode.distance;
  bool _onlyAvailable = false;
  double? _lat;
  double? _lng;
  bool _realLocation = true;

  @override
  void initState() {
    super.initState();
    _loadWithLocation();
  }

  Future<void> _loadWithLocation() async {
    final pos = await LocationService.current();
    if (mounted) {
      setState(() {
        _lat = pos.lat;
        _lng = pos.lng;
        _realLocation = pos.real;
      });
      context.read<RequestBloc>().add(
            RequestLoadNearby(widget.problemType, lat: pos.lat, lng: pos.lng),
          );
    }
  }

  List<MechanicWithProfile> _filter(List<MechanicWithProfile> list) {
    var result = _onlyAvailable
        ? list.where((m) => m.profile.isAvailable).toList()
        : List.of(list);
    result.sort((a, b) => switch (_sort) {
          _SortMode.rating =>
            b.profile.avgRating.compareTo(a.profile.avgRating),
          _SortMode.available =>
            (b.profile.isAvailable ? 1 : 0)
                .compareTo(a.profile.isAvailable ? 1 : 0),
          _ => (a.profile.distanceKm ?? 99)
              .compareTo(b.profile.distanceKm ?? 99),
        });
    return result;
  }

  void _reload() {
    context.read<RequestBloc>().add(
      RequestLoadNearby(widget.problemType, lat: _lat, lng: _lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      body: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 110,
                backgroundColor: context.cSurface,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const AppIcon('arrow_back_ios_new', size: 20),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    left: context.screenHorizontal,
                    bottom: DesignTokens.spaceMD,
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Mechanics',
                        style: context.headingMedium(color: context.cTextPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _sortLabel(),
                        style: context.bodyMedium(color: context.cTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (!_realLocation)
                SliverToBoxAdapter(
                  child: Container(
                    color: context.cDanger.withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.screenHorizontal,
                      vertical: DesignTokens.spaceSM,
                    ),
                    child: Row(
                      children: [
                        AppIcon('location_off',
                            size: 16, color: context.cDanger),
                        const SizedBox(width: DesignTokens.spaceSM),
                        Expanded(
                          child: Text(
                            "Joylashuv aniqlanmadi — barcha mexaniklar ko'rsatilmoqda",
                            style: context.bodySmall(color: context.cDanger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _buildFilterChips(context),
              ),
              if (state is RequestLoading)
                SliverToBoxAdapter(child: _buildSkeleton())
              else if (state is RequestError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(state.message),
                )
              else if (state is NearbyMechanicsLoaded)
                ..._buildLoadedState(context, state)
              else
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }

  String _sortLabel() {
    switch (_sort) {
      case _SortMode.rating:
        return 'Eng yuqori baho bo\'yicha';
      case _SortMode.available:
        return 'Mavjud ustalar bo\'yicha';
      case _SortMode.distance:
        return 'Eng yaqin ustalar';
    }
  }

  List<Widget> _buildLoadedState(
      BuildContext context, NearbyMechanicsLoaded state) {
    final l = AppLocalizations.of(context);
    final filtered = _filter(state.mechanics);
    final count = filtered.length;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.screenHorizontal,
            DesignTokens.spaceXS,
            context.screenHorizontal,
            DesignTokens.spaceSM,
          ),
          child: Text(
            '$count ${l.t('mechanicsFound')}',
            style: context.labelLarge(color: context.cTextSecondary),
          ),
        ),
      ),
      if (filtered.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(context),
        )
      else
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            context.screenHorizontal,
            0,
            context.screenHorizontal,
            DesignTokens.space4XL,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final mechanic = filtered[index];
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: DesignTokens.spaceMD),
                  child: MechanicCardV2.fromMechanicWithProfile(
                    mechanic: mechanic,
                    onTap: () =>
                        context.push('/mechanic/${mechanic.user.id}'),
                    onCall: () => dialPhone(mechanic.user.phone),
                  ),
                );
              },
              childCount: filtered.length,
            ),
          ),
        ),
    ];
  }

  Widget _buildFilterChips(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.screenHorizontal,
        DesignTokens.spaceSM,
        context.screenHorizontal,
        DesignTokens.spaceSM,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DsChip(
              label: l.t('sortDistance'),
              icon: 'near_me_rounded',
              isSelected: _sort == _SortMode.distance,
              onTap: () => setState(() => _sort = _SortMode.distance),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            DsChip(
              label: l.t('sortRating'),
              icon: 'star_rounded',
              isSelected: _sort == _SortMode.rating,
              onTap: () => setState(() => _sort = _SortMode.rating),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            DsChip(
              label: _onlyAvailable
                  ? l.t('available')
                  : 'Barcha ustalar',
              icon: _onlyAvailable
                  ? 'check_circle_rounded'
                  : 'engineering_rounded',
              isSelected: _onlyAvailable,
              onTap: () =>
                  setState(() => _onlyAvailable = !_onlyAvailable),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.screenHorizontal,
        0,
        context.screenHorizontal,
        0,
      ),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding:
                const EdgeInsets.only(bottom: DesignTokens.spaceMD),
            child: _buildShimmerCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        border: Border.all(color: context.cBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                          color: context.cFieldFill,
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: context.cFieldFill,
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.cFieldFill,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusMD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space4XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.cDanger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('wifi_off',
                  size: 44, color: DesignTokens.danger),
            ),
            const SizedBox(height: DesignTokens.spaceXL),
            Text(
              'Yuklab bo\'lmadi',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Text(
              message,
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space2XL),
            AppPrimaryButton(
              label: 'Qayta urinish',
              appIcon: 'refresh',
              onPressed: _reload,
              width: 180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space4XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.cPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('engineering_rounded',
                  size: 44, color: DesignTokens.primary),
            ),
            const SizedBox(height: DesignTokens.spaceXL),
            Text(
              l.t('noMechanicsFound'),
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space3XL),
              child: Text(
                l.t('noMechanicsHint'),
                style: context.bodyMedium(color: context.cTextSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DesignTokens.space2XL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppOutlinedButton(
                  label: l.t('refresh'),
                  appIcon: 'refresh',
                  onPressed: _reload,
                  width: 160,
                ),
                const SizedBox(width: DesignTokens.spaceMD),
                AppPrimaryButton(
                  label: 'Xaritada',
                  appIcon: 'my_location_rounded',
                  onPressed: () {},
                  width: 160,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
