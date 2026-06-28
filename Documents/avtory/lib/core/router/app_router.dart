import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/otp/otp_screen.dart';
import '../../features/auth/profile_create/profile_create_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/request/problem_type/problem_type_screen.dart';
import '../../features/request/nearby_mechanics/nearby_mechanics_screen.dart';
import '../../features/request/mechanic_profile/mechanic_profile_screen.dart';
import '../../features/request/request_status/request_status_screen.dart';
import '../../features/rating/rating_screen.dart';
import '../../features/mechanic/dashboard/mechanic_dashboard_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/mechanic/setup/mechanic_setup_screen.dart';
import '../../features/mechanic/setup/service_prices_screen.dart';
import '../../features/mechanic/setup/mechanic_services_screen.dart';
import '../../features/mechanic/setup/workshop_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/vehicles/vehicles_screen.dart';
import '../../features/vehicles/vehicle_dashboard_screen.dart';
import '../../features/home/map_tab_screen.dart';
import '../../features/home/full_map_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/mechanics/mechanics_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/notifications/activity_timeline_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/profile_edit_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../shared/widgets/error_state.dart';
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String profileCreate = '/profile-create';
  static const String home = '/home';
  static const String problemType = '/problem-type';
  static const String nearbyMechanics = '/nearby-mechanics';
  static const String mechanicProfile = '/mechanic/:id';
  static const String requestStatus = '/request-status/:id';
  static const String rating = '/rating/:requestId';
  static const String mechanicDashboard = '/mechanic-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String mechanicSetup = '/mechanic-setup';
  static const String servicePrices = '/service-prices';
  static const String mechanicServices = '/mechanic-services';
  static const String workshopInfo = '/workshop-info';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String vehicles = '/vehicles';
  static const String vehicleDashboard = '/vehicle-dashboard';
  static const String fullMap = '/full-map';
  static const String messages = '/messages';
  static const String mechanics = '/mechanics';
  static const String notifications = '/notifications';
  static const String activityTimeline = '/activity-timeline';
  static const String mapTab = '/map-tab';
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';
  static const String chat = '/chat';
  static const String emergency = '/emergency';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: AppRoutes.otp,
      builder: (_, state) => OtpScreen(
        phone: state.uri.queryParameters['phone'] ?? '',
        devCode: state.uri.queryParameters['dev_code'],
      ),
    ),
    GoRoute(
      path: AppRoutes.profileCreate,
      builder: (_, state) => ProfileCreateScreen(role: state.uri.queryParameters['role'] ?? 'driver'),
    ),
    GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
    GoRoute(path: AppRoutes.messages, builder: (_, __) => const MessagesScreen()),
    GoRoute(path: AppRoutes.mechanics, builder: (_, __) => const MechanicsScreen()),
    GoRoute(path: AppRoutes.mapTab, builder: (_, __) => const MapTabScreen()),
    GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
    GoRoute(path: AppRoutes.problemType, builder: (_, __) => const ProblemTypeScreen()),
    GoRoute(
      path: AppRoutes.nearbyMechanics,
      builder: (_, state) => NearbyMechanicsScreen(problemType: state.uri.queryParameters['type'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.mechanicProfile,
      builder: (_, state) => MechanicProfileScreen(mechanicId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.requestStatus,
      builder: (_, state) => RequestStatusScreen(
        requestId: state.pathParameters['id'] ?? '',
        mechanicName: state.uri.queryParameters['mechanic'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.rating,
      builder: (_, state) => RatingScreen(
        requestId: state.pathParameters['requestId'] ?? '',
        mechanicName: state.uri.queryParameters['mechanic'] ?? '',
      ),
    ),
    GoRoute(path: AppRoutes.mechanicDashboard, builder: (_, __) => const MechanicDashboardScreen()),
    GoRoute(path: AppRoutes.adminDashboard, builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(path: AppRoutes.mechanicSetup, builder: (_, __) => const MechanicSetupScreen()),
    GoRoute(
      path: AppRoutes.servicePrices,
      builder: (_, state) => ServicePricesScreen(
        isSetup: state.uri.queryParameters['setup'] == 'true',
      ),
    ),
    GoRoute(
      path: AppRoutes.mechanicServices,
      builder: (_, state) => MechanicServicesScreen(
        isSetup: state.uri.queryParameters['setup'] == 'true',
      ),
    ),
    GoRoute(
      path: AppRoutes.workshopInfo,
      builder: (_, state) => WorkshopScreen(
        isSetup: state.uri.queryParameters['setup'] == 'true',
      ),
    ),
    GoRoute(
      path: AppRoutes.fullMap,
      builder: (_, state) => FullMapScreen(
        lat: double.tryParse(state.uri.queryParameters['lat'] ?? '') ?? 41.2995,
        lng: double.tryParse(state.uri.queryParameters['lng'] ?? '') ?? 69.2401,
      ),
    ),
    GoRoute(path: AppRoutes.history, builder: (_, __) => const HistoryScreen()),
    GoRoute(path: AppRoutes.favorites, builder: (_, __) => const FavoritesScreen()),
    GoRoute(path: AppRoutes.vehicles, builder: (_, __) => const VehiclesScreen()),
    GoRoute(
      path: AppRoutes.vehicleDashboard,
      builder: (_, state) => VehicleDashboardScreen(
        vehicleId: state.uri.queryParameters['id'] ?? '',
      ),
    ),
    GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: AppRoutes.activityTimeline, builder: (_, __) => const ActivityTimelineScreen()),
    GoRoute(path: AppRoutes.profileEdit, builder: (_, __) => const ProfileEditScreen()),
    GoRoute(
      path: AppRoutes.chat,
      builder: (_, state) => ChatScreen(
        requestId: state.uri.queryParameters['requestId'] ?? 'demo',
        mechanicName: state.uri.queryParameters['mechanic'] ?? 'Mexanik',
      ),
    ),
    GoRoute(path: AppRoutes.emergency, builder: (_, __) => const EmergencyScreen()),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: ErrorStateWidget(
      message: 'Sahifa topilmadi',
      onRetry: () {},
    ),
  ),
);
