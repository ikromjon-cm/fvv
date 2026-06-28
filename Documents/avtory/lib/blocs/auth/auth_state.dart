abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState { // only set in dev mode
  AuthOtpSent(this.phone, {this.devCode});
  final String phone;
  final String? devCode;
}

class AuthOtpError extends AuthState {
  AuthOtpError(this.message, {this.attemptsLeft = 3});
  final String message;
  final int attemptsLeft;
}

class AuthBlocked extends AuthState {
  AuthBlocked(this.minutesLeft);
  final int minutesLeft;
}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated({required this.role, this.needsProfile = false, this.needsSetup = false});
  final String role; // 'driver' | 'mechanic' | 'admin' | '' (needs profile)
  final bool needsProfile;
  final bool needsSetup; // mechanic registered but hasn't completed setup
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}
