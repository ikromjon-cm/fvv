import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, defaultTargetPlatform, TargetPlatform;
import '../data/local/app_storage.dart';

// Production: deployed HTTPS backend on Railway. When set, every platform uses
// it (the dev hosts below are ignored), so the app works from anywhere.
const String kProductionUrl = 'https://avtory-api-production.up.railway.app/api';

// LAN IP of the dev machine. Lets a REAL phone on the same Wi-Fi reach the local
// Django backend. Run the backend with: `manage.py runserver 0.0.0.0:8002`.
// (The Android emulator alias 10.0.2.2 does NOT work on a physical phone.)
const String kDevLanHost = '192.168.137.159';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

String get kApiBase {
  if (kProductionUrl.isNotEmpty) return kProductionUrl;
  if (_isAndroid) return 'http://$kDevLanHost:8002/api';
  return 'http://127.0.0.1:8002/api';
}

// WebSocket base (ws:// for dev, wss:// for production)
String get kWsBase {
  if (kProductionUrl.isNotEmpty) {
    return kProductionUrl.replaceFirst('https://', 'wss://').replaceFirst('/api', '');
  }
  if (_isAndroid) return 'ws://$kDevLanHost:8002';
  return 'ws://127.0.0.1:8002';
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  static late final Dio _dio;
  static bool _initialized = false;
  static bool _isRefreshing = false;
  static void Function()? onUnauthorized;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    _dio = Dio(BaseOptions(
      baseUrl: kApiBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AppStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final prefs = await AppStorage.getRefreshToken();
            if (prefs != null) {
              final res = await Dio(BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              )).post('$kApiBase/token/refresh/', data: {'refresh': prefs});
              final newAccess = (res.data['access'] as String?) ?? '';
              await AppStorage.setToken(newAccess);
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final response = await _dio.fetch(error.requestOptions);
              _isRefreshing = false;
              return handler.resolve(response);
            }
          } catch (_) {
            // fall through to clearAuth
          }
          _isRefreshing = false;
          await AppStorage.clearAuth();
          onUnauthorized?.call();
        }
        return handler.next(error);
      },
    ));
  }

  static String _extractError(dynamic e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401) return "Sessiya muddati tugagan. Iltimos, qaytadan kiring.";
      if (status == 403) return "Bu amal uchun ruxsatingiz yo'q.";
      if (status == 404) return "Ma'lumot topilmadi.";
      if (status != null && status >= 500) return "Serverda xatolik yuz berdi. Birozdan so'ng qayta urinib ko'ring.";
      final data = e.response?.data;
      if (data is Map) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first is String) return first;
        return data['error']?.toString() ?? "Server xatosi";
      }
    }
    return "Tarmoq xatosi. Internetni tekshiring.";
  }

  static Future<T> _call<T>(Future<Response> Function() fn) async {
    try {
      final res = await fn();
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      debugPrint('ApiService unexpected error: $e');
      throw ApiException("Kutilmagan xatolik yuz berdi. Qayta urinib ko'ring.");
    }
  }

  // ─── Auth ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> sendOtp(String phone) =>
      _call(() => _dio.post('/auth/send-otp/', data: {'phone': phone}));

  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) =>
      _call(() => _dio.post('/auth/verify-otp/', data: {'phone': phone, 'code': code}));

  static Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout/', data: {'refresh': refreshToken});
    } catch (_) {}
  }

  // ─── User ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMe() =>
      _call(() => _dio.get('/users/me/'));

  static Future<Map<String, dynamic>> selectRole(String role) =>
      _call(() => _dio.post('/users/me/role/', data: {'role': role}));

  static Future<Map<String, dynamic>> getDriverProfile() =>
      _call(() => _dio.get('/users/me/driver-profile/'));

  static Future<Map<String, dynamic>> updateDriverProfile(Map<String, dynamic> data) =>
      _call(() => _dio.put('/users/me/driver-profile/', data: data));

  static Future<Map<String, dynamic>> getMechanicProfile() =>
      _call(() => _dio.get('/users/me/mechanic-profile/'));

  static Future<Map<String, dynamic>> updateMechanicProfile(Map<String, dynamic> data) =>
      _call(() => _dio.put('/users/me/mechanic-profile/', data: data));

  static Future<Map<String, dynamic>> updateMechanicAvatar(String dataUrl) =>
      _call(() => _dio.put('/users/me/mechanic-profile/', data: {'avatar': dataUrl}));

  static Future<void> setAvailability(bool available) =>
      _call(() => _dio.put('/users/me/availability/', data: {'is_available': available}));

  static Future<List<dynamic>> getMechanicPrices() =>
      _call(() => _dio.get('/users/me/prices/'));

  static Future<void> saveMechanicPrices(List<Map<String, dynamic>> prices) =>
      _call(() => _dio.post('/users/me/prices/', data: {'prices': prices}));

  static Future<Map<String, dynamic>> getMechanicServices() =>
      _call(() => _dio.get('/users/me/services/'));

  static Future<void> saveMechanicServices(List<String> services) =>
      _call(() => _dio.put('/users/me/services/', data: {'services': services}));

  static Future<Map<String, dynamic>> saveMechanicWorkshop(Map<String, dynamic> data) =>
      _call(() => _dio.put('/users/me/workshop/', data: data));

  static Future<void> saveFcmToken(String token) =>
      _call(() => _dio.post('/users/me/fcm-token/', data: {'fcm_token': token}));

  static Future<void> deleteFcmToken() =>
      _call(() => _dio.delete('/users/me/fcm-token/'));

  static Future<void> deleteAccount() =>
      _call(() => _dio.delete('/users/me/delete/'));

  // ─── Vehicles ─────────────────────────────────────────────
  static Future<List<dynamic>> getVehicles() =>
      _call(() => _dio.get('/users/me/vehicles/'));

  static Future<Map<String, dynamic>> addVehicle(String model, String number) =>
      _call(() => _dio.post('/users/me/vehicles/', data: {'model': model, 'number': number}));

  static Future<void> deleteVehicle(int id) =>
      _call(() => _dio.delete('/users/me/vehicles/$id/'));

  static Future<void> setDefaultVehicle(int id) =>
      _call(() => _dio.post('/users/me/vehicles/$id/'));

  // ─── Earnings ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getEarnings() =>
      _call(() => _dio.get('/users/me/earnings/'));

  // ─── Mechanics ────────────────────────────────────────────

  static Future<List<dynamic>> getNearbyMechanics({
    required double lat,
    required double lng,
    String? serviceType,
    double radiusKm = 15,
  }) =>
      _call(() => _dio.get('/mechanics/nearby/', queryParameters: {
            'lat': lat,
            'lng': lng,
            if (serviceType != null && serviceType.isNotEmpty) 'type': serviceType,
            'radius': radiusKm,
          }));

  static Future<Map<String, dynamic>> getMechanicDetail(int userId, {double? lat, double? lng}) =>
      _call(() => _dio.get('/mechanics/$userId/', queryParameters: {
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
          }));

  static Future<List<dynamic>> getMechanicReviews(int userId) =>
      _call(() => _dio.get('/mechanics/$userId/reviews/'));

  static Future<bool> toggleFavorite(int userId) async {
    final res = await _call<Map<String, dynamic>>(
        () => _dio.post('/mechanics/$userId/favorite/'));
    return (res['is_favorite'] as bool?) ?? false;
  }

  static Future<List<dynamic>> getFavorites() =>
      _call(() => _dio.get('/users/me/favorites/'));

  // ─── Service Requests ─────────────────────────────────────

  static Future<List<dynamic>> getRequests({String? status}) =>
      _call(() => _dio.get('/requests/', queryParameters: {
            if (status != null) 'status': status,
          }));

  static Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data) =>
      _call(() => _dio.post('/requests/', data: data));

  /// Full problem-type catalogue ({categories, groups}). Public endpoint.
  static Future<Map<String, dynamic>> getProblemCategories() =>
      _call(() => _dio.get('/problem-categories/'));

  /// Car catalogue ({brands:[{id,name,slug,models:[{id,name,image}]}]}). Public.
  static Future<Map<String, dynamic>> getCarCatalogue() =>
      _call(() => _dio.get('/cars/'));

  /// Dynamic app config (support phone, contact email). Public.
  static Future<Map<String, dynamic>> getAppConfig() =>
      _call(() => _dio.get('/app-config/'));

  // ─── Admin ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> adminListMechanics() =>
      _call(() => _dio.get('/admin/mechanics/'));

  static Future<Map<String, dynamic>> adminAddMechanic(String phone,
          {String? name, String? surname}) =>
      _call(() => _dio.post('/admin/mechanics/', data: {
            'phone': phone,
            if (name != null && name.isNotEmpty) 'name': name,
            if (surname != null && surname.isNotEmpty) 'surname': surname,
          }));

  static Future<Map<String, dynamic>> acceptRequest(int id) =>
      _call(() => _dio.post('/requests/$id/accept/'));

  static Future<Map<String, dynamic>> declineRequest(int id) =>
      _call(() => _dio.post('/requests/$id/decline/'));

  static Future<void> cancelRequest(int id) =>
      _call(() => _dio.post('/requests/$id/cancel/'));

  static Future<Map<String, dynamic>> updateStatus(int id, String status,
          {int? agreedPrice, String? workDescription}) =>
      _call(() => _dio.post('/requests/$id/status/', data: {
            'status': status,
            if (agreedPrice != null) 'agreed_price': agreedPrice,
            if (workDescription != null && workDescription.isNotEmpty)
              'work_description': workDescription,
          }));

  static Future<void> updateMechanicLocation(int id, double lat, double lng) =>
      _call(() => _dio.post('/requests/$id/location/', data: {'lat': lat, 'lng': lng}));

  static Future<void> submitRating(int requestId, double stars, {String? comment}) =>
      _call(() => _dio.post('/requests/$requestId/rate/', data: {
            'stars': stars.toInt(),
            if (comment != null && comment.isNotEmpty) 'comment': comment,
          }));

  // ─── Notifications ────────────────────────────────────────

  static Future<List<dynamic>> getNotifications() =>
      _call(() => _dio.get('/notifications/'));

  static Future<Map<String, dynamic>> getUnreadCount() =>
      _call(() => _dio.get('/notifications/unread/'));

  static Future<void> markAllRead() =>
      _call(() => _dio.post('/notifications/read-all/'));

  static Future<void> markRead(int id) =>
      _call(() => _dio.post('/notifications/$id/read/'));

  // ─── Chat ─────────────────────────────────────────────────

  static Future<List<dynamic>> getChatMessages(int requestId) =>
      _call(() => _dio.get('/chat/$requestId/'));

  static Future<Map<String, dynamic>> sendChatMessage(int requestId, String text) =>
      _call(() => _dio.post('/chat/$requestId/send/', data: {'text': text}));

  // ─── Request detail ───────────────────────────────────────

  static Future<Map<String, dynamic>> getRequest(int id) =>
      _call(() => _dio.get('/requests/$id/'));
}
