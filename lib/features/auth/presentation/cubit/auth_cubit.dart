import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepository authRepository;
  AppUser? _currentUser;
  late final StreamSubscription<AppUser?> _authStateSubscription;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    //? subscribe to the auth state stream when Cubit is created
    _authStateSubscription = authRepository.authStateChanges.listen(
      (AppUser? user) {
        // print("AuthCubit received user from stream: ${user?.id}"); //? debug
        if (user != null) {
          _currentUser = user;
          emit(AuthAuthenticated(user: user));
        } else {
          _currentUser = null;
          emit(AuthUnauthenticated());
        }
      },
      onError: (error) {
        // print("AuthCubit stream error: $error"); //? debuug
        //? emit an error state if the stream itself has an issue
        emit(AuthError(message: "Authentication stream error: $error"));
      },
    );
  }

  @override
  Future<void> close() {
    // print("AuthCubit closing, cancelling subsciption.");
    _authStateSubscription.cancel();
    return super.close();
  }

  // ? get curr user
  AppUser? get currentUser => _currentUser;

  // ? sign in with email

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final AppUser? user = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        _currentUser = user;
        // emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: "Authentication error: ${e.message}"));
      // emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // emit(AuthUnauthenticated());
    }
  }

  // ? sign up with email

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required UserRole role,
    String? organizationName,
  }) async {
    try {
      emit(AuthLoading());
      if (organizationName != null && organizationName.isNotEmpty) {
        await authRepository.signUpWithEmail(
          email: email,
          password: password,
          username: username,
          fullName: fullName,
          role: role,
          organizationName: organizationName,
        );
      } else {
        await authRepository.signUpWithEmail(
          email: email,
          password: password,
          username: username,
          fullName: fullName,
          role: role,
        );
      }
      // print("User from auth_cubit $user");
      // print("SignUp called in Cubit, waiting for stream update...");
      // if (user != null) {
      //   _currentUser = user;
      //   emit(AuthAuthenticated(user: user));
      // } else {
      //   emit(AuthUnauthenticated());
      // }
    } on AuthException catch (e) {
      // print("Auth exception error from cubit during signup ");
      emit(AuthError(message: "Signup error: ${e.message}"));
      // emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // emit(AuthUnauthenticated());
    }
  }

  // ? sing out

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
      // print("SignOut called in Cubit, waiting for stream update...");
    } catch (e) {
      emit(AuthError(message: "Failed to sign out ${e.toString()}"));
    }
  }
}
