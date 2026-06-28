import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/locale/locale_cubit.dart';
import 'blocs/request/request_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'core/constants/app_colors.dart';
import 'core/l10n/app_localizations.dart';
import 'core/network/connectivity_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'shared/widgets/app_icon.dart';

class AvtoryApp extends StatelessWidget {
  const AvtoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => RequestBloc()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'AVTORY',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: appRouter,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => _AppShell(child: child ?? const SizedBox()),
          );
        },
        ),
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});
  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> with SingleTickerProviderStateMixin {
  AppNotification? _current;
  late AnimationController _animCtrl;
  late Animation<Offset> _slide;
  StreamSubscription? _sub;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _sub = NotificationService().onNew.listen(_showBanner);
  }

  void _showBanner(AppNotification n) {
    _hideTimer?.cancel();
    setState(() => _current = n);
    _animCtrl.forward(from: 0);
    _hideTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    _animCtrl.reverse().then((_) {
      if (mounted) setState(() => _current = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hideTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityBanner(
      child: Stack(
        children: [
          widget.child,
          if (_current != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: _slide,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: _NotifBanner(notif: _current!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotifBanner extends StatelessWidget {
  const _NotifBanner({required this.notif});
  final AppNotification notif;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: notif.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: AppIcon(notif.icon, color: notif.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: context.cTextPrimary, fontFamily: 'Inter')),
                      ),
                      Text('Hozir',
                          style: TextStyle(fontSize: 11, color: context.cTextGray, fontFamily: 'Inter')),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(notif.body,
                      style: TextStyle(fontSize: 12, color: context.cTextSecondary, fontFamily: 'Inter'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
