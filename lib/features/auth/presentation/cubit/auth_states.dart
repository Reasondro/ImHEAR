part of 'auth_cubit.dart';

// * define all the possible states of Auth related stuffs
final class AuthStates extends Equatable {
  const AuthStates();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthStates {}

final class AuthLoading extends AuthStates {}

final class AuthAuthenticated extends AuthStates {
  final AppUser user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthUnauthenticated extends AuthStates {
  //? Optional: Add a message property if needed (e.g., after sign out)
  //? final String? message;
  //? const Unauthenticated({this.message});
  //? @override List<Object?> get props => [message];
}

final class AuthError extends AuthStates {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
