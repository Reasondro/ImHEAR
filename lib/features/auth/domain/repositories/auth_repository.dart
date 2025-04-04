import 'package:komunika/features/auth/domain/entities/app_user.dart';

// ? Outlines the possible auth operations

abstract class AuthRepository {
  Future<AppUser?> signInWithEmail(String email, String password);
  Future<AppUser?> signUpWithEmail(String email, String password, String? name);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
}
