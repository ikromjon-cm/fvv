abstract class AuthEvent {}

class AuthSendOtp extends AuthEvent {
  AuthSendOtp(this.phone);
  final String phone;
}

class AuthVerifyOtp extends AuthEvent {
  AuthVerifyOtp(this.phone, this.code);
  final String phone;
  final String code;
}

class AuthSelectRole extends AuthEvent {
  AuthSelectRole(this.role);
  final String role;
}

class AuthLogout extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}
