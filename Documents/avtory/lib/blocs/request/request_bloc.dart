import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/app_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/models/request_model.dart';
import '../../services/api_service.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  RequestBloc() : super(RequestInitial()) {
    on<RequestLoadNearby>(_onLoadNearby);
    on<RequestCreate>(_onCreate);
    on<RequestCancel>(_onCancel);
    on<RequestStatusUpdated>(_onStatusUpdated);
  }

  Future<void> _onLoadNearby(RequestLoadNearby event, Emitter<RequestState> emit) async {
    emit(RequestLoading());
    try {
      // lat/lng comes from the event; RequestLoadNearby passes it
      final lat = event.lat;
      final lng = event.lng;

      if (lat == null || lng == null) {
        emit(NearbyMechanicsLoaded(const []));
        return;
      }

      final raw = await ApiService.getNearbyMechanics(
        lat: lat,
        lng: lng,
        serviceType: event.problemType,
      );

      final mechanics = raw.map((e) => _parseMechanic(e as Map<String, dynamic>)).toList();
      emit(NearbyMechanicsLoaded(mechanics));
    } on ApiException catch (e) {
      emit(RequestError(e.message));
    } catch (_) {
      emit(NearbyMechanicsLoaded(const []));
    }
  }

  Future<void> _onCreate(RequestCreate event, Emitter<RequestState> emit) async {
    emit(RequestLoading());
    try {
      final mechanicId = int.tryParse(event.mechanicId);
      final data = await ApiService.createRequest({
        'service_type': event.serviceType,
        'driver_lat': event.lat,
        'driver_lng': event.lng,
        if (event.description != null) 'description': event.description,
        if (mechanicId != null) 'mechanic': mechanicId,
      });

      emit(RequestCreated(
        requestId: data['id'].toString(),
        mechanicName: (data['mechanic_name'] as String?) ?? '',
      ));
    } on ApiException catch (e) {
      // Save to AppStorage as pending so mechanic sees it locally too
      final phone = await AppStorage.getPhone() ?? '';
      await AppStorage.addPendingRequest(
        type: event.serviceType,
        driverName: phone,
        lat: event.lat,
        lng: event.lng,
      );
      emit(RequestError(e.message));
    } catch (_) {
      emit(RequestError("So'rov yaratishda xato"));
    }
  }

  Future<void> _onCancel(RequestCancel event, Emitter<RequestState> emit) async {
    emit(RequestLoading());
    try {
      final id = int.tryParse(event.requestId);
      if (id != null) await ApiService.cancelRequest(id);
      emit(RequestCancelled());
    } catch (_) {
      emit(RequestCancelled());
    }
  }

  void _onStatusUpdated(RequestStatusUpdated event, Emitter<RequestState> emit) {
    final status = RequestStatus.fromString(event.status);
    emit(RequestStatusState(requestId: 'current', status: status, mechanicName: ''));
  }

  MechanicWithProfile _parseMechanic(Map<String, dynamic> e) =>
      MechanicWithProfile.fromNearby(e);
}
