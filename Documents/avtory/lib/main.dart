import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/network/connectivity_service.dart';
import 'core/router/app_router.dart';
import 'services/api_service.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService.init();
  ApiService.onUnauthorized = () => appRouter.go(AppRoutes.login);
  ConnectivityService().init();
  NotificationService().init();
  // Push notifications (FCM) — non-blocking; app still works via polling if it
  // can't initialize (web/dev/misconfig).
  FcmService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AvtoryApp());
}
