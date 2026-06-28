import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';

import '../../core/router/app_router.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/mechanic_avatar.dart';
import '../../shared/widgets/ds_surface.dart';
import '../../shared/widgets/ds_chip.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;
  Timer? _pollTimer;
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final raw = await ApiService.getRequests();
      final active = raw.where((r) {
        final s = (r as Map<String, dynamic>)['status'] as String? ?? '';
        return s == 'accepted' || s == 'in_progress' || s == 'pending';
      }).toList();

      if (mounted) setState(() { _chats = active.map((e) => e as Map<String, dynamic>).toList(); _loading = false; });
    } catch (_) {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  String _statusLabel(String status) => switch (status) {
        'accepted' => 'Qabul qilindi',
        'in_progress' => "Yo'lda",
        'pending' => 'Kutilmoqda',
        'completed' => 'Yakunlandi',
        _ => status,
      };

  Color _statusColor(String status) => switch (status) {
        'accepted' => DesignTokens.emerald,
        'in_progress' => context.cPrimary,
        'pending' => DesignTokens.orange,
        _ => context.cPrimary,
      };

  List<Map<String, dynamic>> get _filteredChats {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = _chats.where((c) {
      final name = (c['mechanic_name'] as String? ?? '').toLowerCase();
      final service = (c['service_type_display'] as String? ?? '').toLowerCase();
      final s = c['status'] as String? ?? '';
      if (_statusFilter != 'all' && s != _statusFilter) return false;
      if (query.isNotEmpty && !name.contains(query) && !service.contains(query)) return false;
      return true;
    }).toList();
    return filtered;
  }

  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Hozir';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}k';
      return '${dt.day}.${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      body: _loading
          ? _buildSkeleton()
          : _chats.isEmpty && !_showSearch
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildSkeleton() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spLG, context.screenHorizontal, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 160, height: 28, decoration: _shimmerDecoration()),
            const SizedBox(height: 24),
            ...List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _skeletonCard(),
            )),
          ],
        ),
      ),
    );
  }

  BoxDecoration _shimmerDecoration() {
    return BoxDecoration(
      color: context.cFieldFill,
      borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
    );
  }

  Widget _skeletonCard() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        boxShadow: DesignTokens.shadowSM(context.isDark ? Colors.black : DesignTokens.lightTextPrimary),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: context.cFieldFill)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 14, decoration: _shimmerDecoration()),
                const SizedBox(height: 8),
                Container(width: 180, height: 11, decoration: _shimmerDecoration()),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
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
              child: AppIcon('chat_bubble_outline_rounded', color: context.cPrimary, size: 40),
            ),
            SizedBox(height: context.spXL),
            Text("Hozircha xabarlar yo'q", style: context.headingSmall(color: context.cTextPrimary)),
            SizedBox(height: context.spSM),
            Text(
              'Mexanik chaqirganingizdan keyin\nchat bu yerda ko\'rinadi',
              textAlign: TextAlign.center,
              style: context.bodyMedium(color: context.cTextSecondary),
            ),
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
                    SizedBox(width: context.spSM),
                    Text(
                      'Mexanik qidirish',
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

  Widget _buildContent() {
    final filtered = _filteredChats;
    return RefreshIndicator(
      color: context.cPrimary,
      onRefresh: () => _load(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          if (_showSearch)
            SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spXS, context.screenHorizontal, context.spMD),
              child: Text(
                '${filtered.length} ta suhbat',
                style: context.labelLarge(color: context.cTextTertiary),
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon('search_rounded', size: 40, color: context.cTextTertiary),
                    const SizedBox(height: 12),
                    Text('Natija topilmadi', style: context.bodyLarge(color: context.cTextSecondary)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ChatTile(
                  chat: filtered[i],
                  statusLabel: _statusLabel(filtered[i]['status'] ?? ''),
                  statusColor: _statusColor(filtered[i]['status'] ?? ''),
                  timeAgo: _timeAgo(filtered[i]['updated_at'] as String?),
                  onTap: () => context.push(
                    '${AppRoutes.chat}?requestId=${filtered[i]['id']}&mechanic=${Uri.encodeComponent(filtered[i]['mechanic_name'] ?? 'Mexanik')}',
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final isHome = GoRouterState.of(context).uri.toString() == '/home';
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.cScaffold,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: isHome
          ? null
          : IconButton(
              icon: const AppIcon('arrow_back_ios_new', size: 20),
              onPressed: () => context.pop(),
            ),
      title: Row(
        children: [
          Text('Xabarlar', style: context.headingMedium(color: context.cTextPrimary)),
          if (_chats.isNotEmpty) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                '${_chats.length}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter', color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: AppIcon(_showSearch ? 'close' : 'search_rounded', color: context.cTextPrimary),
          onPressed: () => setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) _searchCtrl.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spXS, context.screenHorizontal, context.spSM),
      child: Container(
        decoration: BoxDecoration(
          color: context.cFieldFill,
          borderRadius: BorderRadius.circular(context.radiusMD),
          border: Border.all(color: context.cBorder),
        ),
        child: TextField(
          controller: _searchCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Mexanik nomi yoki xizmat...',
            hintStyle: context.bodyMedium(color: context.cTextTertiary),
            prefixIcon: AppIcon('search_rounded', size: 20, color: context.cTextTertiary),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                    child: AppIcon('close', size: 18, color: context.cTextTertiary),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMD), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['all', 'accepted', 'in_progress', 'pending'];
    final labels = {'all': 'Barchasi', 'accepted': 'Qabul', 'in_progress': "Yo'lda", 'pending': 'Kutilmoqda'};
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.spXS),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _statusFilter == f;
            return Padding(
              padding: EdgeInsets.only(right: context.spSM),
              child: DsChip(
                label: labels[f] ?? f,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _statusFilter = f);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
    this.timeAgo = '',
  });

  final Map<String, dynamic> chat;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    final mechanic = chat['mechanic_name'] as String? ?? 'Mexanik';
    final service = chat['service_type_display'] as String? ?? chat['service_type'] as String? ?? 'Xizmat';
    final description = chat['description'] as String? ?? '';
    final unread = (chat['unread_count'] as int? ?? 0);
    final avatar = chat['mechanic_photo'] as String?;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spLG, vertical: context.spXS),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: DsSurface(
          padding: EdgeInsets.all(context.spMD),
          color: unread > 0 ? context.cPrimary.withValues(alpha: 0.03) : null,
          hasBorder: unread > 0,
          borderColor: context.cPrimary.withValues(alpha: 0.12),
          child: Row(
            children: [
              Stack(
                children: [
                  MechanicAvatar(avatar: avatar, name: mechanic, size: 52),
                  if (true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: DesignTokens.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.cSurface, width: 2.5),
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
                      children: [
                        Expanded(
                          child: Text(
                            mechanic,
                            overflow: TextOverflow.ellipsis,
                            style: context.labelLarge(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (timeAgo.isNotEmpty)
                          Text(
                            timeAgo,
                            style: context.labelSmall(color: context.cTextTertiary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service,
                      overflow: TextOverflow.ellipsis,
                      style: context.labelLarge(color: context.cPrimary).copyWith(fontSize: 12),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodySmall(color: context.cTextSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    ),
                      child: Text(
                        statusLabel,
                        style: context.labelSmall(color: statusColor),
                      ),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        gradient: DesignTokens.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: context.labelSmall(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
