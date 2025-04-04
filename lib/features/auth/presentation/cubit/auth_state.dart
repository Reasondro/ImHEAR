part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  //? Optional: Add a message property if needed (e.g., after sign out)
  //? final String? message;
  //? const Unauthenticated({this.message});
  //? @override List<Object?> get props => [message];
}

final class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
