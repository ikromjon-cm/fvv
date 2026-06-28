abstract class RequestEvent {}

class RequestLoadNearby extends RequestEvent {
  RequestLoadNearby(this.problemType, {this.lat, this.lng});
  final String problemType;
  final double? lat;
  final double? lng;
}

class RequestCreate extends RequestEvent {
  RequestCreate({
    required this.serviceType,
    required this.mechanicId,
    required this.lat,
    required this.lng,
    this.description,
  });
  final String serviceType;
  final String mechanicId;
  final double lat;
  final double lng;
  final String? description;
}

class RequestCancel extends RequestEvent {
  RequestCancel(this.requestId);
  final String requestId;
}

class RequestStatusUpdated extends RequestEvent {
  RequestStatusUpdated(this.status);
  final String status;
}
