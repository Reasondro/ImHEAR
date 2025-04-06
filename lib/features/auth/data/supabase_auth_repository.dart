import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("User is null");
      }

      AppUser user = AppUser.fromJson(authResponse.user!.toJson());
      return user;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  @override
  Future<AppUser?> signUpWithEmail(
    String email,
    String password,
    String username,
    String fullName,
    String role,
  ) async {
    try {
      //? user sign up
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {"username": username, "full_name": fullName, "role": role},
      );

      if (authResponse.user == null) {
        throw Exception("User is null");
      }
      AppUser user = AppUser.fromJson(authResponse.user!.toJson());

      return user;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final User? supabaseUser = supabase.auth.currentUser;

    if (supabaseUser == null) {
      return null;
    }
    AppUser user = AppUser.fromJson(supabaseUser.userMetadata!);
    return user;
  }
}
