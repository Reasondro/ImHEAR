import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';

// ? Outlines the possible auth operations

abstract class AuthRepository {
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  });
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required UserRole role,
  });
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> get authStateChanges;
}
