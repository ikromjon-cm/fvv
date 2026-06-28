import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/responsive/responsive.dart';
import '../../core/router/app_router.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/ds_chip.dart';
import 'notification_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all';

  static const _filters = [
    ('all', 'Barchasi'),
    ('unread', "O'qilmagan"),
    ('request', 'Buyurtmalar'),
    ('message', 'Xabarlar'),
    ('system', 'Tizim'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final raw = await ApiService.getNotifications();
      if (mounted) {
        setState(() {
          _items = raw
              .map((e) => e as Map<String, dynamic>)
              .where((e) => !NotificationCategory.fromType(e['notif_type'] as String? ?? '').isHidden)
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _error = 'Xatolik yuz berdi'; });
    }
  }

  int get _unreadCount => _items.where((e) => e['is_read'] == false).length;

  List<Map<String, dynamic>> get _filteredItems {
    if (_filter == 'all') return _items;
    if (_filter == 'unread') return _items.where((e) => e['is_read'] == false).toList();
    return _items.where((e) {
      final type = e['notif_type'] as String? ?? '';
      if (_filter == 'request') return ['request', 'accepted', 'on_way', 'arrived', 'completed', 'cancelled'].contains(type);
      if (_filter == 'message') return type == 'message';
      if (_filter == 'system') return type == 'system' || type == 'security';
      return true;
    }).toList();
  }

  Future<void> _markRead(Map<String, dynamic> item) async {
    if (item['is_read'] == true) return;
    setState(() => item['is_read'] = true);
    try {
      await ApiService.markRead(item['id'] as int);
    } catch (_) {}
  }

  Future<void> _onTapNotification(Map<String, dynamic> item) async {
    await _markRead(item);
    if (!mounted) return;
    final data = (item['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final reqId = data['request_id'];
    if (reqId != null) {
      context.push('/request-status/$reqId');
    }
  }

  Future<void> _markAllRead() async {
    setState(() {
      for (final item in _items) {
        item['is_read'] = true;
      }
    });
    try {
      await ApiService.markAllRead();
    } catch (_) {}
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '';
    final t = DateTime.tryParse(createdAt);
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return '${t.day}.${t.month}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.cScaffold,
      body: RefreshIndicator(
        onRefresh: _load,
        color: context.cPrimary,
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(l),
          SliverToBoxAdapter(child: _buildFilterChips()),
          if (_isLoading)
            _buildSkeleton()
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_filteredItems.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(l))
          else
            _buildNotificationList(),
        ],
      ),
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.cScaffold,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const AppIcon('arrow_back_ios_new', size: 20),
        onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
      ),
      title: Row(
        children: [
          Text(
            l.t('notifications'),
            style: context.headingMedium(color: context.cTextPrimary),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [context.cDanger, const Color(0xFFDC2626)]),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: context.labelSmall(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              l.t('markAllRead'),
              style: context.bodySmall(color: context.cPrimary),
            ),
          ),
        IconButton(
          icon: AppIcon('more_horiz_rounded', color: context.cTextPrimary),
          onPressed: () => context.push(AppRoutes.activityTimeline),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 4, context.screenHorizontal, context.cardGap),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final key = f.$1;
            final label = f.$2;
            final isSelected = _filter == key;
            final count = key == 'all'
                ? _items.length
                : key == 'unread'
                    ? _unreadCount
                    : _filteredItems.length;
            return Padding(
              padding: EdgeInsets.only(right: context.spSM),
              child: DsChip(
                label: label,
                isSelected: isSelected,
                showCount: count > 0,
                count: count,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _filter = key);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverList _buildNotificationList() {
    final items = _filteredItems;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _NotificationCard(
          item: items[i],
          onTap: () => _onTapNotification(items[i]),
          onSwipe: () => _markRead(items[i]),
          timeAgo: _timeAgo(items[i]['created_at'] as String?),
        ),
        childCount: items.length,
      ),
    );
  }

  Widget _buildSkeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Padding(
          padding: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.cardGap),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
              border: Border.all(color: context.cBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140, height: 13, decoration: BoxDecoration(
                        color: context.cFieldFill,
                        borderRadius: BorderRadius.circular(4),
                      )),
                      const SizedBox(height: 8),
                      Container(width: 200, height: 10, decoration: BoxDecoration(
                        color: context.cFieldFill,
                        borderRadius: BorderRadius.circular(4),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        childCount: 6,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: context.cDanger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: AppIcon('error_outline_rounded', size: 36, color: context.cDanger),
            ),
            const SizedBox(height: 20),
            Text(
              'Xatolik yuz berdi',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Bildirishnomalarni yuklashda xatolik',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: DesignTokens.primaryGradient,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: context.cPrimary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon('refresh_rounded', size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                      Text(
                        'Qayta urinish',
                        style: context.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    final isFiltered = _filter != 'all';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.cPrimary.withValues(alpha: 0.06),
                    context.cPrimary.withValues(alpha: 0.02),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: context.cPrimary.withValues(alpha: 0.10)),
              ),
              child: AppIcon(
                isFiltered ? 'search_rounded' : 'notifications_none',
                size: 40,
                color: context.cPrimary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered ? 'Bildirishnomalar yo\'q' : l.t('noNotifications'),
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Ushbu turdagi bildirishnomalar mavjud emas'
                  : 'Hozircha hech qanday bildirishnoma yo\'q',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.push(AppRoutes.mechanics),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: DesignTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: context.cPrimary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon('build_rounded', size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Mexaniklarni ko\'rish',
                        style: context.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onSwipe,
    required this.timeAgo,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onSwipe;
  final String timeAgo;

  static String _iconFor(String? type) =>
      NotificationCategory.fromType(type ?? '').icon;

  static Color _colorFor(String? type) =>
      NotificationCategory.fromType(type ?? '').color;

  @override
  Widget build(BuildContext context) {
    final isRead = item['is_read'] as bool? ?? true;
    final type = item['notif_type'] as String?;
    final icon = _iconFor(type);
    final color = _colorFor(type);
    final title = item['title'] as String? ?? '';
    final body = item['body'] as String? ?? '';

    return Semantics(
      button: true,
      label: title,
      child: Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.cardGap),
      child: Dismissible(
        key: ValueKey(item['id']),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: DesignTokens.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
          ),
          child: AppIcon('check_circle_rounded', size: 24, color: DesignTokens.success),
        ),
        onDismissed: (_) => onSwipe(),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: DesignTokens.animNormal,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead ? context.cSurface : context.cPrimary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
              border: Border.all(
                color: isRead
                    ? context.cBorder
                    : context.cPrimary.withValues(alpha: 0.2),
              ),
              boxShadow: isRead
                  ? DesignTokens.shadowSM(
                      context.isDark ? Colors.black : DesignTokens.lightTextPrimary)
                  : [
                      BoxShadow(
                        color: context.cPrimary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(icon, color: color, size: 20),
                    ),
                    if (!isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: context.cPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.cSurface, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: context.bodyMedium(color: context.cTextPrimary).copyWith(
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: context.labelSmall(color: context.cTextTertiary),
                          ),
                        ],
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodySmall(color: isRead ? context.cTextSecondary : context.cTextPrimary).copyWith(height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                            ),
                            child: Text(
                              type ?? '',
                                style: context.labelSmall(color: color).copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                AppIcon('chevron_right_rounded', size: 16, color: context.cTextTertiary),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
