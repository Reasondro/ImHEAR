import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("User is null");
      }
      AppUser user = AppUser.fromJson(authResponse.user!.toJson());
      print(user);

      return user;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      //? user sign up
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {"username": username, "full_name": fullName, "role": role.name},
      );
      print("Auth response from supa_repo $authResponse");
      if (authResponse.user == null) {
        throw Exception("User is null");
      }
      print("AuthResponeUser from supa_repo ${authResponse.user}");

      AppUser user = AppUser.fromJson(authResponse.user!.toJson());

      print("User from supa_repo $user");
      return user;
    } on AuthException catch (_) {
      print("Auth exception error from supa_repo");
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
    try {
      final User? supabaseUser = supabase.auth.currentUser;

      if (supabaseUser == null) {
        return null;
      }

      //? Construct the proper structure expected by AppUser.fromJson
      final Map<String, dynamic> userData = {
        "id": supabaseUser.id,
        "email": supabaseUser.email,
        "user_metadata": supabaseUser.userMetadata ?? {},
      };

      return AppUser.fromJson(userData);
    } catch (e) {
      print("Error parsing user data: $e");
      return null; //? will trigger AuthUnauthenticated
    }
  }
}
