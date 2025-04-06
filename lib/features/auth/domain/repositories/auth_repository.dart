import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';

// ? Outlines the possible auth operations

abstract class AuthRepository {
  Future<AppUser?> signInWithEmail(String email, String password);
  Future<AppUser?> signUpWithEmail(
    String email,
    String password,
    String username,
    String fullName,
    UserRole role,
  );
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
}
