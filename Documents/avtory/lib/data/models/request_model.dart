class RequestModel {

  const RequestModel({
    required this.id,
    required this.driverId,
    this.mechanicId,
    required this.serviceType,
    this.description,
    required this.driverLat,
    required this.driverLng,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.arrivedAt,
    this.completedAt,
    this.mechanicName,
    this.mechanicAvatar,
    this.mechanicPhone,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: (json['id'] ?? '').toString(),
        driverId: (json['driver'] ?? '').toString(),
        mechanicId: json['mechanic']?.toString(),
        serviceType: (json['service_type'] ?? '').toString(),
        description: json['description']?.toString(),
        driverLat: (json['driver_lat'] as num?)?.toDouble() ?? 0.0,
        driverLng: (json['driver_lng'] as num?)?.toDouble() ?? 0.0,
        status: RequestStatus.fromString(json['status']?.toString() ?? ''),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        acceptedAt: json['accepted_at'] != null
            ? DateTime.tryParse(json['accepted_at']!.toString())
            : null,
        arrivedAt: json['arrived_at'] != null
            ? DateTime.tryParse(json['arrived_at']!.toString())
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at']!.toString())
            : null,
        mechanicName: json['mechanic_name']?.toString(),
        mechanicAvatar: json['mechanic_avatar']?.toString(),
        mechanicPhone: json['mechanic_phone']?.toString(),
      );
  final String id;
  final String driverId;
  final String? mechanicId;
  final String serviceType;
  final String? description;
  final double driverLat;
  final double driverLng;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? mechanicName;
  final String? mechanicAvatar;
  final String? mechanicPhone;

  bool get canBeCancelled =>
      status == RequestStatus.pending ||
      status == RequestStatus.accepted ||
      status == RequestStatus.onWay;

  Map<String, dynamic> toJson() => {
        'id': id,
        'driver': driverId,
        'mechanic': mechanicId,
        'service_type': serviceType,
        'description': description,
        'driver_lat': driverLat,
        'driver_lng': driverLng,
        'status': status.value,
        'created_at': createdAt.toIso8601String(),
      };
}

enum RequestStatus {
  pending,
  accepted,
  onWay,
  arrived,
  completed,
  cancelled;

  static RequestStatus fromString(String value) {
    return switch (value) {
      'pending' => pending,
      'accepted' => accepted,
      'on_way' => onWay,
      'arrived' => arrived,
      'completed' => completed,
      'cancelled' => cancelled,
      _ => pending,
    };
  }

  String get value => switch (this) {
        pending => 'pending',
        accepted => 'accepted',
        onWay => 'on_way',
        arrived => 'arrived',
        completed => 'completed',
        cancelled => 'cancelled',
      };

  String get label => switch (this) {
        pending => "So'rov yuborildi",
        accepted => "Mexanik qabul qildi",
        onWay => "Yo'lda",
        arrived => "Yetib keldi",
        completed => "Yakunlandi",
        cancelled => "Bekor qilindi",
      };
}

class ServiceType {

  const ServiceType({
    required this.id,
    required this.slug,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.icon,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
        id: (json['id'] as int?) ?? 0,
        slug: (json['slug'] ?? '').toString(),
        nameUz: (json['name_uz'] ?? '').toString(),
        nameRu: (json['name_ru'] ?? '').toString(),
        nameEn: (json['name_en'] ?? '').toString(),
        icon: (json['icon'] ?? '').toString(),
      );
  final int id;
  final String slug;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String icon;

  static List<ServiceType> get defaults => [
        const ServiceType(id: 1, slug: 'battery', nameUz: 'Akkumulyator', nameRu: 'Аккумулятор', nameEn: 'Battery', icon: 'battery'),
        const ServiceType(id: 2, slug: 'tire', nameUz: "Shina yo'ildi", nameRu: 'Шина', nameEn: 'Tire', icon: 'tire'),
        const ServiceType(id: 3, slug: 'engine', nameUz: 'Motor muammosi', nameRu: 'Двигатель', nameEn: 'Engine', icon: 'engine'),
        const ServiceType(id: 4, slug: 'evacuation', nameUz: 'Evakuator', nameRu: 'Эвакуатор', nameEn: 'Evacuation', icon: 'evacuation'),
        const ServiceType(id: 5, slug: 'other', nameUz: 'Boshqa', nameRu: 'Другое', nameEn: 'Other', icon: 'other'),
      ];
}
