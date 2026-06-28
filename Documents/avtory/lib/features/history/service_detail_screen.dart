import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/ds_card.dart';
import '../../shared/widgets/ds_dialog.dart';
import '../../shared/components/buttons/app_buttons.dart';
import 'widgets/service_timeline.dart';
import 'widgets/mechanic_summary_header.dart';
import 'widgets/service_detail_skeleton.dart';
import 'widgets/invoice_preview.dart';
import 'widgets/history_status_badge.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
    required this.requestId,
    required this.data,
  });

  final String requestId;
  final Map<String, dynamic> data;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.cScaffold,
        appBar: _buildAppBar(context),
        body: const ServiceDetailSkeleton(),
      );
    }

    final data = widget.data;
    final status = data['status'] as String? ?? 'pending';
    final description = data['description'] as String?;
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = status == 'completed';

    final createdAtStr = data['createdAt'] as String?;
    final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
    final acceptedAtStr = data['acceptedAt'] as String?;
    final acceptedAt = acceptedAtStr != null ? DateTime.tryParse(acceptedAtStr) : null;
    final completedAtStr = data['completedAt'] as String?;
    final completedAt = completedAtStr != null ? DateTime.tryParse(completedAtStr) : null;

    final stages = ServiceTimeline.buildStages(
      createdAt: createdAt ?? DateTime.now(),
      acceptedAt: acceptedAt,
      arrivedAt: null,
      completedAt: completedAt,
    );

    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildMechanicHeader(context)),
          SliverToBoxAdapter(child: _buildInfoCards(context)),
          SliverToBoxAdapter(child: _buildSectionHeader(context, 'Xizmat holati')),
          SliverToBoxAdapter(child: _buildTimelineSection(context, stages, status)),
          if (description != null && description.isNotEmpty)
            SliverToBoxAdapter(child: _buildNotesSection(context, description)),
          if (isCompleted) ...[
            SliverToBoxAdapter(child: _buildSectionHeader(context, 'Batafsil ma\'lumot')),
            SliverToBoxAdapter(child: _buildInfoGrid(context, data)),
            SliverToBoxAdapter(child: const InvoicePreview()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: const PaymentPreview()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: const FutureServiceActions()),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, isCompleted, rating),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(
          'Xizmat detallari',
          style: context.headingMedium(color: context.cTextPrimary),
        ),
      backgroundColor: context.cScaffold,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: AppIcon('arrow_back_ios_new', size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: AppIcon('more_vert_rounded', size: 20),
          onPressed: () => _showMoreMenu(context),
        ),
      ],
    );
  }

  Widget _buildMechanicHeader(BuildContext context) {
    final data = widget.data;
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spSM, context.screenHorizontal, context.spMD),
      child: MechanicSummaryHeader(
        avatarUrl: data['mechanicAvatar'] as String?,
        name: data['mechanicName'] as String? ?? '--',
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        experienceYears: 0,
        workshop: data['type'] as String? ?? '',
        distanceKm: (data['distance'] as String?) != null
            ? double.tryParse(
                (data['distance'] as String).replaceAll(' km', ''))
            : null,
        isVerified: false,
        isPremiumPartner: false,
        onCall: () {},
        onChat: () {
          final requestId = widget.requestId;
          final mechanicName = data['mechanicName'] as String? ?? '';
          context.push(
            '${AppRoutes.chat}?requestId=$requestId&mechanic=$mechanicName',
          );
        },
        onViewProfile: () => _openMechanicProfile(context),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final data = widget.data;
    final date = data['date'] as String? ?? '--';
    final duration = data['duration'] as String?;
    final type = data['type'] as String? ?? 'Xizmat';

    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.spLG),
      child: Row(
        children: [
          Expanded(
            child: _infoCard(
              context,
              icon: 'calendar_today_outlined',
              title: 'Sana',
              value: date,
            ),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            child: _infoCard(
              context,
              icon: 'timer_outlined',
              title: 'Davomiyligi',
              value: duration ?? '--',
            ),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            child: _infoCard(
              context,
              icon: 'build_rounded',
              title: 'Xizmat',
              value: type,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String value,
  }) {
    return DsCard(
      radius: context.radiusMD,
      hasBorder: true,
      padding: EdgeInsets.all(context.spSM + 2),
      child: Column(
        children: [
          AppIcon(icon, size: 16, color: context.cTextTertiary),
          SizedBox(height: context.spXS),
          Text(
            value,
            style: context.labelSmall(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: context.labelSmall(color: context.cTextTertiary).copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spSM, context.screenHorizontal, context.spSM),
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
            title,
            style: context.headingSmall(color: context.cTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    List<TimelineStage> stages,
    String status,
  ) {
    return DsCard(
      margin: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.spLG),
      radius: context.radiusLG,
      shadows: context.shadowSM,
      hasBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Xizmat jarayoni',
                  style: context.labelLarge(color: context.cTextPrimary),
                ),
              ),
              HistoryStatusBadge(status: status),
            ],
          ),
          SizedBox(height: context.spLG),
          ServiceTimeline(stages: stages),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, String description) {
    return DsCard(
      margin: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.spLG),
      radius: context.radiusLG,
      hasBorder: true,
      padding: EdgeInsets.all(context.spLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.cPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(context.spSM),
            ),
            child: AppIcon(
              'notes_rounded',
              size: 18,
              color: context.cPrimary,
            ),
          ),
          SizedBox(width: context.spSM + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xizmat haqida',
                  style: context.labelLarge(color: context.cTextPrimary),
                ),
                SizedBox(height: context.spXS),
                Text(
                  description,
                  style: context.bodySmall(color: context.cTextSecondary).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, Map<String, dynamic> data) {
    final vehicle = data['vehicle'] as String?;
    final plate = data['plate'] as String?;
    final distance = data['distance'] as String?;
    final duration = data['duration'] as String?;

    final infoItems = [
      ('directions_car_filled_rounded', 'Avtomobil', vehicle ?? '--'),
      ('local_offer_outlined', 'Raqam', plate ?? '--'),
      ('my_location_rounded', 'Masofa', distance ?? '--'),
      ('timer_outlined', 'Davomiylik', duration ?? '--'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, 0, context.screenHorizontal, context.spLG),
      child: DsCard(
        radius: context.radiusLG,
        hasBorder: true,
        padding: EdgeInsets.all(context.spLG),
        child: Column(
          children: [
            for (int i = 0; i < infoItems.length; i++) ...[
              if (i > 0) SizedBox(height: context.spMD),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.cFieldFill,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AppIcon(
                      infoItems[i].$1,
                      size: 14,
                      color: context.cTextSecondary,
                    ),
                  ),
                  SizedBox(width: context.spSM + 2),
                  Expanded(
                    child: Text(
                      infoItems[i].$2,
                      style: context.bodySmall(color: context.cTextSecondary),
                    ),
                  ),
                  Text(
                    infoItems[i].$3,
                    style: context.bodySmall(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isCompleted, double rating) {
    if (!isCompleted) return const SizedBox.shrink();

    if (rating > 0) {
      return Container(
        padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spSM, context.screenHorizontal, context.sp3XL),
        decoration: BoxDecoration(
          color: context.cScaffold,
          border: Border(
            top: BorderSide(color: context.cBorder, width: 0.5),
          ),
        ),
        child: AppPrimaryButton(
          label: 'Yana xizmat buyurtma qilish',
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.problemType);
          },
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spSM, context.screenHorizontal, context.sp3XL),
      decoration: BoxDecoration(
        color: context.cScaffold,
        border: Border(
          top: BorderSide(color: context.cBorder, width: 0.5),
        ),
      ),
        child: AppPrimaryButton(
        label: 'Mexanikni baholash',
        onPressed: () {
          Navigator.of(context).pop();
          final mechanic = widget.data['mechanicName'] as String? ?? '';
          context.push('/rating/${widget.requestId}?mechanic=$mechanic');
        },
      ),
    );
  }

  void _openMechanicProfile(BuildContext context) {
    // Stub - mechanic profile navigation
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DsBottomSheet(
        title: '',
        children: [
          _menuItem(context, 'share_outlined', 'Ulashish'),
          _menuItem(context, 'file_download_outlined', 'PDF yuklab olish'),
          _menuItem(context, 'repeat_rounded', 'Qayta buyurtma qilish'),
          _menuItem(context, 'report_outlined', 'Shikoyat qilish'),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spXS),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.spMD),
          child: Row(
            children: [
              AppIcon(icon, size: 20, color: context.cTextSecondary),
              SizedBox(width: context.spMD),
              Text(
                label,
                style: context.bodyMedium(color: context.cTextPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
