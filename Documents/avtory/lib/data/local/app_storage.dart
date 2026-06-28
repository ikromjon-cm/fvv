import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // JWTs live in the OS keystore/keychain, not plaintext SharedPreferences.
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── Auth (tokens → secure storage) ─────────────────────
  // Reads are wrapped so a rare keystore hiccup can't break every API call.
  static Future<void> setToken(String token) async {
    try { await _secure.write(key: 'access_token', value: token); } catch (_) {}
  }
  static Future<String?> getToken() async {
    try { return await _secure.read(key: 'access_token'); } catch (_) { return null; }
  }
  static Future<void> setRefreshToken(String token) async {
    try { await _secure.write(key: 'refresh_token', value: token); } catch (_) {}
  }
  static Future<String?> getRefreshToken() async {
    try { return await _secure.read(key: 'refresh_token'); } catch (_) { return null; }
  }
  static Future<void> setUserId(String id) async => (await _p).setString('user_id', id);
  static Future<String?> getUserId() async => (await _p).getString('user_id');
  static Future<void> setRole(String role) async => (await _p).setString('user_role', role);
  static Future<String?> getRole() async => (await _p).getString('user_role');
  static Future<void> setPhone(String phone) async => (await _p).setString('user_phone', phone);
  static Future<String?> getPhone() async => (await _p).getString('user_phone');

  // ─── Default Vehicle ────────────────────────────────────
  static Future<void> setDefaultVehicleId(String id) async =>
      (await _p).setString('default_vehicle_id', id);

  static Future<String> getDefaultVehicleId() async =>
      (await _p).getString('default_vehicle_id') ?? '';

  // ─── User Profile ────────────────────────────────────────
  static Future<void> saveUserProfile({
    String? name,
    String? surname,
    String? carModel,
    String? carNumber,
    String? carImage,
  }) async {
    final p = await _p;
    if (name != null) await p.setString('user_name', name);
    if (surname != null) await p.setString('user_surname', surname);
    if (carModel != null) await p.setString('car_model', carModel);
    if (carNumber != null) await p.setString('car_number', carNumber);
    if (carImage != null) await p.setString('car_image', carImage);
  }

  static Future<Map<String, String>> getUserProfile() async {
    final p = await _p;
    return {
      'name': p.getString('user_name') ?? '',
      'surname': p.getString('user_surname') ?? '',
      'phone': p.getString('user_phone') ?? '',
      'carModel': p.getString('car_model') ?? '',
      'carNumber': p.getString('car_number') ?? '',
      'carImage': p.getString('car_image') ?? '',
    };
  }

  // ─── Mechanic Profile ────────────────────────────────────
  static Future<void> saveMechanicProfile({
    required String name,
    required String surname,
    required String speciality,
    required List<String> serviceTypes,
    int experienceYears = 1,
  }) async {
    final p = await _p;
    await p.setString('mech_name', name);
    await p.setString('mech_surname', surname);
    await p.setString('mech_speciality', speciality);
    await p.setStringList('mech_services', serviceTypes);
    await p.setInt('mech_experience', experienceYears);
    await p.setBool('mech_profile_done', true);
  }

  static Future<Map<String, dynamic>> getMechanicProfile() async {
    final p = await _p;
    return {
      'name': p.getString('mech_name') ?? p.getString('user_name') ?? '',
      'surname': p.getString('mech_surname') ?? p.getString('user_surname') ?? '',
      'phone': p.getString('user_phone') ?? '',
      'speciality': p.getString('mech_speciality') ?? 'Universal usta',
      'services': p.getStringList('mech_services') ?? [],
      'experience': p.getInt('mech_experience') ?? 1,
      'isSetupDone': p.getBool('mech_setup_done') ?? false,
      'isAvailable': p.getBool('mech_available') ?? true,
      'profileDone': p.getBool('mech_profile_done') ?? false,
    };
  }

  static Future<void> setMechanicAvailability(bool available) async =>
      (await _p).setBool('mech_available', available);
  static Future<bool> getMechanicAvailability() async =>
      (await _p).getBool('mech_available') ?? true;

  // ─── Mechanic Location ───────────────────────────────────
  static Future<void> saveMechanicLocation({
    required double lat,
    required double lng,
    String? workshopName,
    String? address,
  }) async {
    final p = await _p;
    await p.setDouble('mech_lat', lat);
    await p.setDouble('mech_lng', lng);
    if (workshopName != null) await p.setString('mech_workshop_name', workshopName);
    if (address != null) await p.setString('mech_address', address);
    await p.setBool('mech_location_set', true);
  }

  static Future<Map<String, dynamic>> getMechanicLocation() async {
    final p = await _p;
    return {
      'lat': p.getDouble('mech_lat'),
      'lng': p.getDouble('mech_lng'),
      'workshopName': p.getString('mech_workshop_name') ?? '',
      'address': p.getString('mech_address') ?? '',
      'isSet': p.getBool('mech_location_set') ?? false,
    };
  }

  // ─── Mechanic Work Hours ─────────────────────────────────
  static Future<void> saveWorkHours({
    required bool isAlways,
    int startHour = 8,
    int endHour = 20,
  }) async {
    final p = await _p;
    await p.setBool('mech_24_7', isAlways);
    await p.setInt('mech_start_hour', startHour);
    await p.setInt('mech_end_hour', endHour);
  }

  static Future<Map<String, dynamic>> getWorkHours() async {
    final p = await _p;
    return {
      'isAlways': p.getBool('mech_24_7') ?? false,
      'startHour': p.getInt('mech_start_hour') ?? 8,
      'endHour': p.getInt('mech_end_hour') ?? 20,
    };
  }

  // ─── Service Prices ──────────────────────────────────────
  static const _defaultPrices = {
    'battery': (50000, 150000),
    'tire': (30000, 80000),
    'engine': (80000, 200000),
    'evacuation': (100000, 400000),
    'gas': (20000, 60000),
    'other': (30000, 120000),
  };

  static Future<void> saveServicePrice(String type, int min, int max, bool enabled) async {
    final p = await _p;
    await p.setInt('price_${type}_min', min);
    await p.setInt('price_${type}_max', max);
    await p.setBool('price_${type}_on', enabled);
  }

  static Future<List<ServicePriceData>> getServicePrices(List<String> activeServices) async {
    final p = await _p;
    return ServicePriceData.allTypes.map((s) {
      final dflt = _defaultPrices[s.type] ?? (30000, 100000);
      return ServicePriceData(
        type: s.type,
        label: s.label,
        icon: s.icon,
        color: s.color,
        minPrice: p.getInt('price_${s.type}_min') ?? dflt.$1,
        maxPrice: p.getInt('price_${s.type}_max') ?? dflt.$2,
        enabled: p.getBool('price_${s.type}_on') ?? activeServices.contains(s.type),
      );
    }).toList();
  }

  // ─── Setup completion ─────────────────────────────────────
  static Future<void> markSetupDone() async => (await _p).setBool('mech_setup_done', true);
  static Future<void> setSetupDone(bool v) async => (await _p).setBool('mech_setup_done', v);
  static Future<bool> isSetupDone() async => (await _p).getBool('mech_setup_done') ?? false;

  // ─── Chat Messages ────────────────────────────────────────
  static Future<void> saveChatMessages(String chatId, List<Map<String, dynamic>> messages) async {
    final p = await _p;
    final encoded = jsonEncode(messages.map((m) => {
      'text': m['text'],
      'isMe': m['isMe'],
      'time': (m['time'] as DateTime).millisecondsSinceEpoch,
    }).toList());
    await p.setString('chat_$chatId', encoded);
  }

  static Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    final p = await _p;
    final raw = p.getString('chat_$chatId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => {
      'text': e['text'] as String,
      'isMe': e['isMe'] as bool,
      'time': DateTime.fromMillisecondsSinceEpoch(e['time'] as int),
    }).toList();
  }

  // ─── Request History (driver) ─────────────────────────────
  static Future<void> addHistoryItem(Map<String, dynamic> item) async {
    final p = await _p;
    final raw = p.getString('driver_history') ?? '[]';
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    list.insert(0, {...item, 'id': 'req_${DateTime.now().millisecondsSinceEpoch}'});
    if (list.length > 50) list.removeLast();
    await p.setString('driver_history', jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final p = await _p;
    final raw = p.getString('driver_history') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  // ─── Mechanic Stats & Ratings ─────────────────────────────
  static Future<void> addRating(double stars) async {
    final p = await _p;
    final count = (p.getInt('mech_rating_count') ?? 0) + 1;
    final total = (p.getDouble('mech_rating_total') ?? 0.0) + stars;
    final jobs = (p.getInt('mech_jobs_total') ?? 0) + 1;
    await p.setInt('mech_rating_count', count);
    await p.setDouble('mech_rating_total', total);
    await p.setInt('mech_jobs_total', jobs);
  }

  static Future<({double avg, int count, int jobs})> getMechanicStats() async {
    final p = await _p;
    final count = p.getInt('mech_rating_count') ?? 0;
    final total = p.getDouble('mech_rating_total') ?? 0.0;
    final jobs = p.getInt('mech_jobs_total') ?? 0;
    final avg = count > 0 ? total / count : 0.0;
    return (avg: avg, count: count, jobs: jobs);
  }

  // ─── Pending Requests (driver → mechanic) ─────────────────
  static Future<void> addPendingRequest({
    required String type,
    required String driverName,
    String? address,
    double? lat,
    double? lng,
  }) async {
    final p = await _p;
    final raw = p.getString('pending_requests') ?? '[]';
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    list.insert(0, {
      'id': 'req_${DateTime.now().millisecondsSinceEpoch}',
      'type': type,
      'driverName': driverName,
      'address': address ?? '',
      'lat': lat,
      'lng': lng,
      'status': 'pending',
      'time': DateTime.now().millisecondsSinceEpoch,
    });
    await p.setString('pending_requests', jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final p = await _p;
    final raw = p.getString('pending_requests') ?? '[]';
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.where((r) => r['status'] == 'pending').toList();
  }

  static Future<void> updateRequestStatus(String id, String status) async {
    final p = await _p;
    final raw = p.getString('pending_requests') ?? '[]';
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    for (final r in list) {
      if (r['id'] == id) r['status'] = status;
    }
    await p.setString('pending_requests', jsonEncode(list));
  }

  // ─── Clear all ────────────────────────────────────────────
  static Future<void> clearAll() async {
    await (await _p).clear();
    await _secure.deleteAll();
  }

  // ─── Clear auth only (preserve profile data) ────────────
  static Future<void> clearAuth() async {
    final p = await _p;
    await Future.wait([
      p.remove('user_token'),
      p.remove('user_refresh_token'),
      p.remove('user_id'),
      p.remove('user_role'),
      p.remove('user_phone'),
      p.remove('mech_setup_done'),
      p.remove('mechanic_availability'),
    ]);
    await _secure.deleteAll();
  }
}

class ServicePriceData {

  const ServicePriceData({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.minPrice,
    required this.maxPrice,
    required this.enabled,
  });
  final String type;
  final String label;
  final String icon;
  final int color;
  final int minPrice;
  final int maxPrice;
  final bool enabled;

  ServicePriceData copyWith({int? minPrice, int? maxPrice, bool? enabled}) => ServicePriceData(
        type: type,
        label: label,
        icon: icon,
        color: color,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        enabled: enabled ?? this.enabled,
      );

  String get priceLabel {
    final min = (minPrice / 1000).round();
    final max = (maxPrice / 1000).round();
    return "$min 000 – $max 000 so'm";
  }

  static const allTypes = [
    ServicePriceData(type: 'battery', label: 'Akkumulyator', icon: 'battery_charging_full_rounded', color: 0xFF3B82F6, minPrice: 50000, maxPrice: 150000, enabled: false),
    ServicePriceData(type: 'tire', label: 'Shina', icon: 'tire_repair_rounded', color: 0xFF10B981, minPrice: 30000, maxPrice: 80000, enabled: false),
    ServicePriceData(type: 'engine', label: 'Motor/Dvigatel', icon: 'engineering_rounded', color: 0xFFF59E0B, minPrice: 80000, maxPrice: 200000, enabled: false),
    ServicePriceData(type: 'evacuation', label: 'Evakuator', icon: 'local_shipping_rounded', color: 0xFFEF4444, minPrice: 100000, maxPrice: 400000, enabled: false),
    ServicePriceData(type: 'gas', label: 'Gaz/Shlang', icon: 'water_drop_rounded', color: 0xFF8B5CF6, minPrice: 20000, maxPrice: 60000, enabled: false),
    ServicePriceData(type: 'other', label: 'Boshqa xizmatlar', icon: 'build_rounded', color: 0xFF6B7280, minPrice: 30000, maxPrice: 120000, enabled: false),
  ];
}
