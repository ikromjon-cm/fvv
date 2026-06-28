import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/responsive/responsive.dart';
import '../../core/router/app_router.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/animations/transitions.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/ds_chip.dart';
import '../../shared/components/buttons/app_buttons.dart';
import 'widgets/history_card.dart';
import 'widgets/history_skeleton.dart';
import 'widgets/search_history_bar.dart';
import 'service_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = 'all';
  String _searchQuery = '';
  final List<String> _recentSearches = [];

  static const _filters = [
    ('all', 'Barchasi', null),
    ('completed', 'Bajarilgan', 'check_circle_rounded'),
    ('cancelled', 'Bekor qilingan', 'cancel_outlined'),
    ('in_progress', 'Jarayonda', 'pending_actions_rounded'),
    ('today', 'Bugun', 'calendar_today_outlined'),
    ('week', 'Bu hafta', 'date_range_rounded'),
    ('month', 'Bu oy', 'event_rounded'),
    ('favorites', 'Sevimlilar', 'favorite_border_rounded'),
    ('unrated', 'Baholanmagan', 'rate_review_outlined'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final raw = await ApiService.getRequests();
      final role = await AppStorage.getRole() ?? 'driver';
      final items = raw.map((r) {
        final m = r as Map<String, dynamic>;
        final status = m['status'] as String? ?? 'pending';
        final createdAt = m['created_at'] != null
            ? DateTime.parse(m['created_at'] as String)
            : null;
        final acceptedAt = m['accepted_at'] != null
            ? DateTime.parse(m['accepted_at'] as String)
            : null;
        final completedAt = m['completed_at'] != null
            ? DateTime.parse(m['completed_at'] as String)
            : null;
        final duration = (completedAt != null && createdAt != null)
            ? _formatDuration(completedAt.difference(createdAt))
            : null;
        return <String, dynamic>{
          'id': m['id'].toString(),
          'type': m['service_display'] as String? ??
              (m['service_type'] as String? ?? 'Xizmat'),
          'mechanicName': role == 'driver'
              ? (m['mechanic_name'] as String? ?? '--')
              : (m['driver_name'] as String? ?? '--'),
          'mechanicAvatar': m['mechanic_avatar'] as String?,
          'status': status,
          'createdAt': createdAt?.toIso8601String(),
          'date': createdAt != null
              ? _formatDate(createdAt)
              : '--',
          'price': m['agreed_price'] != null
              ? "${m['agreed_price']} so'm"
              : null,
          'rating': (m['rating'] as num?)?.toDouble() ?? 0.0,
          'vehicle': m['vehicle_display'] as String?,
          'plate': m['license_plate'] as String?,
          'description': m['description'] as String?,
          'distance': m['distance_km'] != null
              ? '${m['distance_km']} km'
              : null,
          'duration': duration,
          'isFavorite': false,
          'acceptedAt': acceptedAt?.toIso8601String(),
          'completedAt': completedAt?.toIso8601String(),
          'driverLat': (m['driver_lat'] as num?)?.toDouble(),
          'driverLng': (m['driver_lng'] as num?)?.toDouble(),
        };
      }).toList();
      if (mounted) {
        setState(() {
          _allItems = items;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (_) {
      final history = await AppStorage.getHistory();
      if (mounted) {
        setState(() {
          _allItems = history;
          _isLoading = false;
          _applyFilters();
          if (history.isEmpty) _errorMessage = null;
        });
      }
    }
  }

  void _applyFilters() {
    var items = List<Map<String, dynamic>>.from(_allItems);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) {
        return (i['mechanicName'] as String? ?? '').toLowerCase().contains(q) ||
            (i['type'] as String? ?? '').toLowerCase().contains(q) ||
            (i['vehicle'] as String? ?? '').toLowerCase().contains(q) ||
            (i['plate'] as String? ?? '').toLowerCase().contains(q);
      }).toList();
    }

    switch (_activeFilter) {
      case 'completed':
        items = items.where((i) => i['status'] == 'completed').toList();
      case 'cancelled':
        items = items.where((i) => i['status'] == 'cancelled').toList();
      case 'in_progress':
        items = items.where((i) =>
            i['status'] != 'completed' && i['status'] != 'cancelled').toList();
      case 'today':
        items = items.where((i) {
          final dt = i['createdAt'] != null
              ? DateTime.tryParse(i['createdAt'] as String)
              : null;
          if (dt == null) return false;
          final now = DateTime.now();
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        }).toList();
      case 'week': {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        items = items.where((i) {
          final dt = i['createdAt'] != null
              ? DateTime.tryParse(i['createdAt'] as String)
              : null;
          return dt != null && dt.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
      }
      case 'month': {
        final now = DateTime.now();
        items = items.where((i) {
          final dt = i['createdAt'] != null
              ? DateTime.tryParse(i['createdAt'] as String)
              : null;
          return dt != null &&
              dt.year == now.year &&
              dt.month == now.month;
        }).toList();
      }
      case 'favorites':
        items = items.where((i) => i['isFavorite'] == true).toList();
      case 'unrated':
        items = items.where((i) =>
            i['status'] == 'completed' &&
            (i['rating'] as num?)?.toDouble() == 0).toList();
    }

    setState(() => _filteredItems = items);
  }

  Map<String, List<Map<String, dynamic>>> _groupItems() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final groups = <String, List<Map<String, dynamic>>>{
      'Bugun': [],
      'Kecha': [],
      'Bu hafta': [],
      'Bu oy': [],
      'Eski': [],
    };

    for (final item in _filteredItems) {
      final dtStr = item['createdAt'] as String?;
      final dt = dtStr != null ? DateTime.tryParse(dtStr) : null;
      if (dt == null) {
        groups['Eski']!.add(item);
        continue;
      }
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) {
        groups['Bugun']!.add(item);
      } else if (day == yesterday) {
        groups['Kecha']!.add(item);
      } else if (day.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        groups['Bu hafta']!.add(item);
      } else if (day.isAfter(monthStart.subtract(const Duration(days: 1)))) {
        groups['Bu oy']!.add(item);
      } else {
        groups['Eski']!.add(item);
      }
    }

    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: Text(
          l.t('historyTitle'),
          style: context.headingLarge(color: context.cTextPrimary),
        ),
        backgroundColor: context.cScaffold,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          HistorySkeleton(),
        ],
      );
    }

    if (_errorMessage != null && _allItems.isEmpty) {
      return _buildErrorState();
    }

    final groups = _groupItems();
    if (groups.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SearchHistoryBar(
          onSearch: (q) {
            _searchQuery = q;
            _applyFilters();
          },
          recentSearches: _recentSearches,
        )),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverToBoxAdapter(child: SizedBox(height: 4)),
        ...groups.entries.map((entry) => [
          SliverToBoxAdapter(
            child: _buildGroupHeader(entry.key, entry.value.length),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: EdgeInsets.only(
                  left: context.screenHorizontal,
                  right: context.screenHorizontal,
                  bottom: context.cardGap,
                  top: i == 0 ? 8 : 0,
                ),
                child: RepaintBoundary(
                  child: HistoryCard(
                    item: entry.value[i],
                    onTap: () => _openServiceDetail(entry.value[i]),
                  ),
                ),
              ),
              childCount: entry.value.length,
            ),
          ),
        ]).expand((e) => e),
        SliverToBoxAdapter(child: SizedBox(height: context.sectionGap)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: context.spSM),
        itemBuilder: (_, i) {
          final (key, label, icon) = _filters[i];
          final count = key == 'all'
              ? _allItems.length
              : _allItems.where((item) {
                  switch (key) {
                    case 'completed':
                      return item['status'] == 'completed';
                    case 'cancelled':
                      return item['status'] == 'cancelled';
                    case 'in_progress':
                      return item['status'] != 'completed' &&
                          item['status'] != 'cancelled';
                    case 'today': {
                      final dt = item['createdAt'] != null
                          ? DateTime.tryParse(item['createdAt'] as String)
                          : null;
                      if (dt == null) return false;
                      final now = DateTime.now();
                      return dt.year == now.year &&
                          dt.month == now.month &&
                          dt.day == now.day;
                    }
                    case 'favorites':
                      return item['isFavorite'] == true;
                    case 'unrated':
                      return item['status'] == 'completed' &&
                          (item['rating'] as num?)?.toDouble() == 0;
                    default:
                      return true;
                  }
                }).length;

          return DsChip(
            label: label,
            isSelected: _activeFilter == key,
            icon: icon,
            showCount: key != 'all',
            count: count,
            onTap: () {
              setState(() => _activeFilter = key);
              _applyFilters();
            },
          );
        },
      ),
    );
  }

  Widget _buildGroupHeader(String label, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 8, context.screenHorizontal, 4),
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
                label,
                style: context.headingSmall(color: context.cTextPrimary),
              ),
              SizedBox(width: context.spSM - 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.cFieldFill,
                  borderRadius: BorderRadius.circular(context.radiusFull),
                ),
                child: Text(
                  count.toString(),
                  style: context.labelSmall(color: context.cTextSecondary).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              child: AppIcon(
                'history_rounded',
                size: 44,
                color: context.cPrimary,
              ),
            ),
            SizedBox(height: context.spXL),
            Text(
              'Tarix yo\'q',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            SizedBox(height: context.spSM),
            Text(
              'Bajarilgan buyurtmalar tarixi bu yerda ko\'rinadi.\nYangi buyurtma berishni boshlang!',
            style: context.bodyMedium(color: context.cTextSecondary),
            textAlign: TextAlign.center,
          ),
            SizedBox(height: context.sectionGap),
            AppPrimaryButton(
              label: 'Buyurtma berish',
              onPressed: () => context.push(AppRoutes.problemType),
            ),
          ],
        ),
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
              child: AppIcon(
                'error_outline_rounded',
                size: 36,
                color: context.cDanger,
              ),
            ),
            SizedBox(height: context.spLG),
            Text(
              'Xatolik yuz berdi',
              style: context.headingSmall(color: context.cTextPrimary),
            ),
            SizedBox(height: context.spSM),
            Text(
              'Tarixni yuklashda xatolik.\nIltimos, qayta urinib ko\'ring.',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: 'Qayta urinish',
              onPressed: _load,
            ),
          ],
        ),
      ),
    );
  }

  void _openServiceDetail(Map<String, dynamic> item) {
    final requestId = item['id'] as String? ?? '';
    MotionPageTransitions.push(
      context,
      ServiceDetailScreen(
        requestId: requestId,
        data: item,
      ),
      type: PageTransitionType.slideUp,
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
      'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '$hours soat $minutes min';
    return '$minutes min';
  }
}
