import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/mechanic_card_v2.dart';
import '../../shared/widgets/ds_chip.dart';

class MechanicsScreen extends StatefulWidget {
  const MechanicsScreen({super.key});

  @override
  State<MechanicsScreen> createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> {
  List<Map<String, dynamic>> _mechanics = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  bool _onlyAvailable = false;
  final _searchFocus = FocusNode();
  final _searchCtrl = TextEditingController();
  bool _searchFocused = false;
  bool _showRecent = false;
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchFocus.addListener(() {
      setState(() {
        _searchFocused = _searchFocus.hasFocus;
        _showRecent = _searchFocus.hasFocus && _searchCtrl.text.isEmpty;
      });
    });
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.getNearbyMechanics(
          lat: 41.2995, lng: 69.2401);
      if (mounted) {
        setState(() {
          _mechanics = raw.map((e) => e as Map<String, dynamic>).toList();
          _applyFilter();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException
                ? e.message
                : "Ustalarni yuklab bo'lmadi."),
          ),
        );
      }
    }
  }

  void _applyFilter() {
    var list = List<Map<String, dynamic>>.from(_mechanics);
    if (_onlyAvailable) {
      list = list.where((m) => m['is_available'] == true).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((m) {
        final name =
            '${m['name'] ?? ''} ${m['surname'] ?? ''}'.toLowerCase();
        final services =
            (m['services'] as List?)?.join(' ').toLowerCase() ?? '';
        return name.contains(q) || services.contains(q);
      }).toList();
    }
    _filtered = list;
  }

  void _onSearchChanged() {
    final v = _searchCtrl.text;
    setState(() {
      _search = v;
      _showRecent = _searchFocus.hasFocus && _search.isEmpty;
      _applyFilter();
    });
  }

  void _onSearchSubmit(String value) {
    if (value.isNotEmpty && !_recentSearches.contains(value)) {
      _recentSearches.insert(0, value);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    }
    _searchFocus.unfocus();
    setState(() => _showRecent = false);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      body: RefreshIndicator(
        onRefresh: _load,
        color: context.cPrimary,
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: context.cSurface,
            surfaceTintColor: Colors.transparent,
            leading: GoRouterState.of(context).uri.toString() == '/home'
                ? null
                : IconButton(
                    icon: const AppIcon('arrow_back_ios_new', size: 20),
                    onPressed: () => context.pop(),
                  ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: DesignTokens.spaceLG,
                bottom: DesignTokens.spaceMD,
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yaqin ustalar',
                    style: TextStyle(
                      fontSize: DesignTokens.headlineLarge,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                      color: context.cTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Available mechanics around your location',
                    style: TextStyle(
                      fontSize: DesignTokens.titleSmall,
                      fontFamily: 'Inter',
                      color: context.cTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: AppIcon('my_location_rounded',
                    size: 20, color: context.cTextSecondary),
                onPressed: () {},
                tooltip: 'Map',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),
          if (_loading)
            SliverToBoxAdapter(child: _buildSkeleton())
          else if (_showRecent && _recentSearches.isNotEmpty)
            SliverToBoxAdapter(child: _buildRecentSearches())
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceLG,
                0,
                DesignTokens.spaceLG,
                DesignTokens.space4XL,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final mechanic = _filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: DesignTokens.spaceMD),
                      child: MechanicCardV2(
                        data: mechanic,
                        onTap: () => context.push(
                          '/mechanic/${mechanic['mechanic_id'] ?? mechanic['id']}',
                        ),
                        onCall: () {
                          final phone = mechanic['phone'] as String?;
                          if (phone != null && phone.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling $phone...')),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLG,
        DesignTokens.spaceSM,
        DesignTokens.spaceLG,
        DesignTokens.spaceXS,
      ),
      child: AnimatedContainer(
        duration: DesignTokens.animNormal,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: context.cFieldFill,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
          border: Border.all(
            color: _searchFocused
                ? DesignTokens.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _searchFocused
              ? [
                  BoxShadow(
                    color:
                        DesignTokens.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          onSubmitted: _onSearchSubmit,
          decoration: InputDecoration(
            hintText: _searchFocused ? 'Qidirish...' : 'Usta yoki xizmat...',
            hintStyle: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              fontFamily: 'Inter',
              color: context.cTextTertiary,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: AppIcon('search_rounded',
                  size: 20, color: context.cTextTertiary),
            ),
            suffixIcon: _search.isNotEmpty
                ? IconButton(
                    icon: AppIcon('close',
                        size: 18, color: context.cTextSecondary),
                    onPressed: _clearSearch,
                    splashRadius: 18,
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLG,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusXL),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLG,
        0,
        DesignTokens.spaceLG,
        DesignTokens.spaceMD,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DsChip(
              label: _onlyAvailable ? "Bo'sh ustalar" : 'Barcha ustalar',
              icon: _onlyAvailable
                  ? 'check_circle_rounded'
                  : 'engineering_rounded',
              isSelected: _onlyAvailable,
              onTap: () {
                setState(() {
                  _onlyAvailable = !_onlyAvailable;
                  _applyFilter();
                });
              },
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            DsChip(
              label: 'Eng yaqin',
              icon: 'near_me_rounded',
              isSelected: false,
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            DsChip(
              label: 'Eng yaxshi',
              icon: 'star_rounded',
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLG,
        0,
        DesignTokens.spaceLG,
        0,
      ),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: context.cFieldFill,
                          borderRadius: BorderRadius.circular(4),
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
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLG,
        0,
        DesignTokens.spaceLG,
        DesignTokens.spaceMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: DesignTokens.spaceSM),
            child: Row(
              children: [
                AppIcon('history_rounded',
                    size: 16, color: context.cTextTertiary),
                const SizedBox(width: DesignTokens.spaceXS),
                Text(
                  'So\'nggi qidiruvlar',
                  style: TextStyle(
                    fontSize: DesignTokens.titleSmall,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: context.cTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_recentSearches.length, (i) {
            final query = _recentSearches[i];
            return GestureDetector(
              onTap: () {
                _searchCtrl.text = query;
                _searchCtrl.selection = TextSelection.collapsed(
                    offset: query.length);
                setState(() => _showRecent = false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spaceXS,
                ),
                child: Row(
                  children: [
                    AppIcon('history',
                        size: 16, color: context.cTextTertiary),
                    const SizedBox(width: DesignTokens.spaceSM),
                    Expanded(
                      child: Text(
                        query,
                        style: TextStyle(
                          fontSize: DesignTokens.bodyMedium,
                          fontFamily: 'Inter',
                          color: context.cTextPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _recentSearches.removeAt(i));
                      },
                      child: AppIcon('close',
                          size: 14, color: context.cTextTertiary),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
                color: DesignTokens.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('engineering_rounded',
                  size: 44, color: DesignTokens.primary),
            ),
            const SizedBox(height: DesignTokens.spaceXL),
            Text(
              'Usta topilmadi',
              style: TextStyle(
                fontSize: DesignTokens.headlineMedium,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: context.cTextPrimary,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Text(
              _search.isNotEmpty
                  ? "'$_search' bo'yicha hech narsa topilmadi"
                  : "Hozircha ro'yxatda usta mavjud emas.\nKeyinroq qayta urinib ko'ring.",
              style: TextStyle(
                fontSize: DesignTokens.bodyMedium,
                fontFamily: 'Inter',
                color: context.cTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space2XL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _load,
                  icon: const AppIcon('refresh', size: 18),
                  label: const Text('Qayta yuklash'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignTokens.primary,
                    side: BorderSide(
                        color:
                            DesignTokens.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMD),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceXL,
                      vertical: DesignTokens.spaceMD,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
