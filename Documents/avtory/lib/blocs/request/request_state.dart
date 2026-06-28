import '../../data/models/user_model.dart';
import '../../data/models/request_model.dart';

abstract class RequestState {}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class NearbyMechanicsLoaded extends RequestState {
  NearbyMechanicsLoaded(this.mechanics);
  final List<MechanicWithProfile> mechanics;
}

class RequestCreated extends RequestState {
  RequestCreated({required this.requestId, required this.mechanicName});
  final String requestId;
  final String mechanicName;
}

class RequestStatusState extends RequestState {
  RequestStatusState({
    required this.requestId,
    required this.status,
    this.mechanicName,
  });
  final String requestId;
  final RequestStatus status;
  final String? mechanicName;
}

class RequestCancelled extends RequestState {}

class RequestError extends RequestState {
  RequestError(this.message);
  final String message;
}
