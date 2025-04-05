import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AppUser? _currentUser;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  // ? check if usr is authenticated
  void checkAuth() async {
    final AppUser? user = await authRepository.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // ? get curr user
  AppUser? get currentUser => _currentUser;

  // ? sign in with email

  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());
      final AppUser? user = await authRepository.signInWithEmail(
        email,
        password,
      );
      if (user != null) {
        _currentUser = user;
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: "Authentication error: ${e.message}"));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // ? sign up with email

  Future<void> signUp(String email, String password, String name) async {
    try {
      emit(AuthLoading());
      final AppUser? user = await authRepository.signUpWithEmail(
        email,
        password,
        name,
      );

      if (user != null) {
        _currentUser = user;
      } else {
        emit(AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: "Authentication error: ${e.message}"));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // ? sing out

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
