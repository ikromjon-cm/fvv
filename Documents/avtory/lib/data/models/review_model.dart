class ReviewModel {

  const ReviewModel({
    required this.id,
    required this.requestId,
    required this.driverId,
    required this.mechanicId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.driverName,
    this.driverAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: (json['id'] ?? '').toString(),
        requestId: (json['request'] ?? '').toString(),
        driverId: (json['driver'] ?? '').toString(),
        mechanicId: (json['mechanic'] ?? '').toString(),
        rating: (json['rating'] as int?) ?? 0,
        comment: json['comment']?.toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        driverName: json['driver_name']?.toString(),
        driverAvatar: json['driver_avatar']?.toString(),
      );
  final String id;
  final String requestId;
  final String driverId;
  final String mechanicId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? driverName;
  final String? driverAvatar;

  Map<String, dynamic> toJson() => {
        'request': requestId,
        'rating': rating,
        'comment': comment,
      };
}

class NotificationModel {

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        body: (json['body'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        data: json['data'] as Map<String, dynamic>?,
      );
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
}
