import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../services/fcm_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthSelectRole>(_onSelectRole);
    on<AuthLogout>(_onLogout);
  }
  int _otpAttempts = 0;
  Timer? _blockTimer;

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final token = await AppStorage.getToken();
    final role = await AppStorage.getRole() ?? '';
    if (token != null && role.isNotEmpty) {
      final setupDone = await AppStorage.isSetupDone();
      bool needsProfile = false;
      if (role == 'driver') {
        final profile = await AppStorage.getUserProfile();
        needsProfile = (profile['name'] ?? '').isEmpty;
      } else if (role == 'mechanic') {
        final profile = await AppStorage.getMechanicProfile();
        needsProfile = profile['profileDone'] != true;
      }
      emit(AuthAuthenticated(
        role: role,
        needsProfile: needsProfile,
        needsSetup: role == 'mechanic' && !setupDone,
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    try {
      final data = await ApiService.sendOtp(event.phone);
      await AppStorage.setPhone(event.phone);
      final devCode = data['dev_code'] as String?;
      emit(AuthOtpSent(event.phone, devCode: devCode));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError("Server bilan bog'lanib bo'lmadi"));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtp event, Emitter<AuthState> emit) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    try {
      final data = await ApiService.verifyOtp(event.phone, event.code);
      _otpAttempts = 0;

      final access = data['access'] as String;
      final refresh = data['refresh'] as String;
      final user = data['user'] as Map<String, dynamic>;
      final userRole = (user['role'] as String?) ?? '';
      // Fall back to locally-saved role if the server didn't return one.
      final savedRole = await AppStorage.getRole() ?? '';
      final role = userRole.isNotEmpty ? userRole : savedRole;
      final needsProfile = (data['needs_profile'] as bool?) ?? false;
      final isSetupDone = (data['is_setup_done'] as bool?) ?? true;

      await AppStorage.setToken(access);
      await AppStorage.setRefreshToken(refresh);
      await AppStorage.setUserId(user['id'].toString());
      await AppStorage.setPhone(user['phone'] as String);
      if (role.isNotEmpty) await AppStorage.setRole(role);
      await AppStorage.setSetupDone(isSetupDone);

      // Cross-check with locally cached profile: if we already have profile data,
      // don't ask again even if server says needs_profile=true.
      final bool hasLocalProfile;
      if (role == 'mechanic') {
        final mechProfile = await AppStorage.getMechanicProfile();
        hasLocalProfile = mechProfile['profileDone'] == true;
      } else {
        final driverProfile = await AppStorage.getUserProfile();
        hasLocalProfile = (driverProfile['name'] ?? '').isNotEmpty;
      }

      // Now authenticated — register this device's push token with the backend.
      FcmService.registerToken();

      emit(AuthAuthenticated(
        role: role,
        needsProfile: (needsProfile && !hasLocalProfile) || role.isEmpty,
        needsSetup: role == 'mechanic' && !isSetupDone,
      ));
    } on ApiException catch (e) {
      _otpAttempts++;
      if (_otpAttempts >= 3) {
        emit(AuthBlocked(5));
        _blockTimer?.cancel();
        _blockTimer = Timer(const Duration(minutes: 5), () {
          _otpAttempts = 0;
        });
      } else {
        emit(AuthOtpError(e.message, attemptsLeft: 3 - _otpAttempts));
      }
    } catch (_) {
      emit(AuthError("Server bilan bog'lanib bo'lmadi"));
    }
  }

  Future<void> _onSelectRole(AuthSelectRole event, Emitter<AuthState> emit) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    try {
      await ApiService.selectRole(event.role);
      await AppStorage.setRole(event.role);
      emit(AuthAuthenticated(role: event.role));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError("Server bilan bog'lanib bo'lmadi"));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final refresh = await AppStorage.getRefreshToken();
    if (refresh != null) {
      await Future.wait([
        ApiService.logout(refresh),
        FcmService.unregisterToken(),
      ]);
    }
    await AppStorage.clearAuth();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _blockTimer?.cancel();
    return super.close();
  }
}
