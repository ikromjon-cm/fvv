class UserModel {

  const UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.avatar,
    required this.role,
    this.isVerified = false,
    this.isActive = true,
    this.lat,
    this.lng,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        phone: (json['phone'] ?? '').toString(),
        fullName: (json['full_name'] ?? '').toString(),
        avatar: json['avatar'] as String?,
        role: (json['role'] ?? '').toString(),
        isVerified: json['is_verified'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        fcmToken: json['fcm_token'] as String?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
  final String id;
  final String phone;
  final String fullName;
  final String? avatar;
  final String role; // 'driver' | 'mechanic'
  final bool isVerified;
  final bool isActive;
  final double? lat;
  final double? lng;
  final String? fcmToken;
  final DateTime createdAt;

  bool get isDriver => role == 'driver';
  bool get isMechanic => role == 'mechanic';

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'full_name': fullName,
        'avatar': avatar,
        'role': role,
        'is_verified': isVerified,
        'is_active': isActive,
        'lat': lat,
        'lng': lng,
        'fcm_token': fcmToken,
        'created_at': createdAt.toIso8601String(),
      };
}

class MechanicProfile {

  const MechanicProfile({
    required this.userId,
    required this.services,
    required this.experienceYears,
    this.workStart,
    this.workEnd,
    required this.isAvailable,
    required this.avgRating,
    required this.totalReviews,
    required this.totalJobs,
    this.distanceKm,
    this.etaMinutes,
    this.address,
    this.isVerified = false,
    this.isFavorite = false,
    this.startingPrice,
  });

  factory MechanicProfile.fromJson(Map<String, dynamic> json) => MechanicProfile(
        userId: (json['user'] ?? '').toString(),
        services: List<String>.from(json['services'] as List? ?? []),
        experienceYears: json['experience_years'] as int? ?? 0,
        workStart: json['work_start'] as String?,
        workEnd: json['work_end'] as String?,
        isAvailable: json['is_available'] as bool? ?? false,
        avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        totalJobs: json['total_jobs'] as int? ?? 0,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        etaMinutes: json['eta_minutes'] as int?,
        address: json['address'] as String?,
      );
  final String userId;
  final List<String> services; // service slugs
  final int experienceYears;
  final String? workStart;
  final String? workEnd; // null = 24/7
  final bool isAvailable;
  final double avgRating;
  final int totalReviews;
  final int totalJobs;
  final double? distanceKm;
  final int? etaMinutes;
  final String? address;
  final bool isVerified;
  final bool isFavorite;
  final int? startingPrice; // lowest enabled service min_price

  bool get isAlwaysAvailable => workEnd == null;
}

class MechanicWithProfile {

  const MechanicWithProfile({required this.user, required this.profile});

  factory MechanicWithProfile.fromJson(Map<String, dynamic> json) => MechanicWithProfile(
        user: UserModel.fromJson(json),
        profile: MechanicProfile.fromJson(json['mechanic_profile'] as Map<String, dynamic>),
      );

  /// Parses the flat `NearbyMechanicSerializer` payload (nearby / favorites /
  /// mechanic detail) into a [MechanicWithProfile].
  factory MechanicWithProfile.fromNearby(Map<String, dynamic> e) {
    final user = UserModel(
      id: (e['mechanic_id'] ?? '').toString(),
      phone: (e['phone'] ?? '').toString(),
      fullName: '${e['name'] ?? ''} ${e['surname'] ?? ''}'.trim(),
      avatar: e['avatar'] as String?,
      role: 'mechanic',
      createdAt: DateTime.now(),
    );
    final prices = (e['enabled_prices'] as List? ?? [])
        .map((p) => (p is Map<String, dynamic> ? (p['min_price'] as int? ?? 0) : 0))
        .where((v) => v > 0)
        .toList();
    final profile = MechanicProfile(
      userId: (e['mechanic_id'] ?? '').toString(),
      services: List<String>.from(e['services'] as List? ?? []),
      experienceYears: (e['experience_years'] as int?) ?? 0,
      isAvailable: (e['is_available'] as bool?) ?? false,
      avgRating: (e['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (e['total_reviews'] as int?) ?? 0,
      totalJobs: (e['total_jobs'] as int?) ?? 0,
      distanceKm: (e['distance_km'] as num?)?.toDouble(),
      etaMinutes: e['eta_minutes'] as int?,
      address: e['address'] as String?,
      isVerified: (e['is_verified'] as bool?) ?? false,
      isFavorite: (e['is_favorite'] as bool?) ?? false,
      startingPrice: prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b),
    );
    return MechanicWithProfile(user: user, profile: profile);
  }
  final UserModel user;
  final MechanicProfile profile;
}
