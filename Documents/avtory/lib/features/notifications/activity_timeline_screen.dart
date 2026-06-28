import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import 'notification_config.dart';

class ActivityTimelineScreen extends StatefulWidget {
  const ActivityTimelineScreen({super.key});

  @override
  State<ActivityTimelineScreen> createState() => _ActivityTimelineScreenState();
}

class _ActivityTimelineScreenState extends State<ActivityTimelineScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;

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

  List<_TimelineGroup> get _groups {
    if (_items.isEmpty) return [];
    final groups = <_TimelineGroup>[];
    List<Map<String, dynamic>> currentGroup = [];
    String currentLabel = '';

    for (final item in _items) {
      final dt = DateTime.tryParse(item['created_at'] as String? ?? '');
      if (dt == null) continue;
      final label = _dateLabel(dt);

      if (label != currentLabel) {
        if (currentGroup.isNotEmpty) {
          groups.add(_TimelineGroup(currentLabel, List.from(currentGroup)));
        }
        currentLabel = label;
        currentGroup = [item];
      } else {
        currentGroup.add(item);
      }
    }
    if (currentGroup.isNotEmpty) {
      groups.add(_TimelineGroup(currentLabel, currentGroup));
    }
    return groups;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return 'Bugun';
    if (msgDate == yesterday) return 'Kecha';
    final diff = today.difference(msgDate).inDays;
    if (diff < 7) return 'Bu hafta';
    const months = ['', 'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sent', 'Okt', 'Noy', 'Dek'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _timeStr(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: const Text('Faoliyat tarixi'),
        backgroundColor: context.cScaffold,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: context.cPrimary,
        child: _isLoading
            ? _buildSkeleton()
            : _error != null
                ? _buildError()
                : _items.isEmpty
                    ? _buildEmptyState()
                    : _buildTimeline(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(context.screenHorizontal),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2, height: 60,
                  color: context.cFieldFill,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: context.cFieldFill,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: context.cDanger.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: AppIcon('error_outline_rounded', size: 28, color: context.cDanger),
          ),
          const SizedBox(height: 16),
          Text('Xatolik', style: context.headingSmall(color: context.cTextPrimary)),
          const SizedBox(height: 8),
          Text('Yuklashda xatolik yuz berdi', style: context.labelLarge(color: context.cTextSecondary)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _load,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text('Qayta urinish',
                  style: context.labelLarge(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: context.cPrimary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: AppIcon('history_rounded', size: 36, color: context.cPrimary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text('Faoliyat tarixi yo\'q',
              style: context.headingMedium(color: context.cTextPrimary)),
          const SizedBox(height: 8),
          Text('Bildirishnomalar vaqt jadvalida ko\'rsatiladi',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final groups = _groups;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 8, context.screenHorizontal, 40),
      itemCount: groups.length,
      itemBuilder: (_, gi) {
        final group = groups[gi];
        final isLast = gi == groups.length - 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(group.label),
            ...List.generate(group.items.length, (ei) {
              final item = group.items[ei];
              final isLastItem = ei == group.items.length - 1;
              return _TimelineEntry(
                item: item,
                time: _timeStr(item['created_at'] as String?),
                isLast: isLastItem && isLast,
                showLine: !isLastItem,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: context.headingSmall(color: context.cTextPrimary),
          ),
        ],
      ),
    );
  }
}

class _TimelineGroup {
  const _TimelineGroup(this.label, this.items);
  final String label;
  final List<Map<String, dynamic>> items;
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.item,
    required this.time,
    required this.isLast,
    required this.showLine,
  });

  final Map<String, dynamic> item;
  final String time;
  final bool isLast;
  final bool showLine;

  static String _iconFor(String? type) =>
      NotificationCategory.fromType(type ?? '').icon;

  static Color _colorFor(String? type) =>
      NotificationCategory.fromType(type ?? '').color;

  @override
  Widget build(BuildContext context) {
    final type = item['notif_type'] as String?;
    final color = _colorFor(type);
    final icon = _iconFor(type);
    final title = item['title'] as String? ?? '';
    final body = item['body'] as String? ?? '';
    final isRead = item['is_read'] as bool? ?? true;

    return Semantics(
      button: true,
      label: title,
      child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 36,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    time,
                    style: context.labelSmall(color: context.cTextTertiary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isRead ? context.cTextTertiary : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRead ? context.cBorder : color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: context.cDivider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRead ? context.cSurface : context.cPrimary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                border: Border.all(
                  color: isRead ? context.cBorder : context.cPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(icon, size: 15, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.labelLarge(color: context.cTextPrimary).copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.labelSmall(color: context.cTextSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: DesignTokens.danger,
                        shape: BoxShape.circle,
                      ),
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
}
