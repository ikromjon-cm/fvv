import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/responsive/responsive.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/mechanic_card_v2.dart';
import '../../shared/widgets/ds_loading.dart';
import '../../shared/widgets/error_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loading = true;
  bool _hasError = false;
  List<MechanicWithProfile> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final raw = await ApiService.getFavorites();
      final items = raw
          .map((e) =>
              MechanicWithProfile.fromNearby(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: Text(l.t('favorites')),
        backgroundColor: context.cScaffold,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Semantics(
        label: 'Favorites page',
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const DsListSkeleton(count: 4);
    }
    if (_hasError) {
      return ErrorStateWidget(onRetry: _load);
    }
    if (_items.isEmpty) {
      return _buildEmptyState();
    }
    return _buildList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontal,
          vertical: context.sp4XL,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Favorites empty icon',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.cDanger.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  'favorite_border_rounded',
                  size: 40,
                  color: context.cDanger,
                ),
              ),
            ),
            SizedBox(height: context.sectionGap),
            Text(
              'Sevimlilar yo\'q',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            SizedBox(height: context.cardGap),
            Text(
              'Sevimli ustalaringizni qo\'shing',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          context.spLG,
          context.spLG,
          context.spLG,
          context.sp2XL,
        ),
        itemCount: _items.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(bottom: context.cardGap),
          child: MechanicCardV2.fromMechanicWithProfile(
            mechanic: _items[i],
            onCall: () => context.push('/mechanic/${_items[i].user.id}'),
            onTap: () => context.push('/mechanic/${_items[i].user.id}'),
          ),
        ),
      ),
    );
  }
}
