import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  // ? helper function for stream stuffs
  AppUser? _mapSupabaseUserToAppUser({User? supabaseUser}) {
    if (supabaseUser == null) {
      return null;
    }
    try {
      final Map<String, dynamic> userData = {
        "id": supabaseUser.id,
        "email": supabaseUser.email,
        "user_metadata": supabaseUser.userMetadata ?? {},
      };
      // print("Mapping Supabase User ${userData["id"]}");
      return AppUser.fromJson(userData);
    } catch (e) {
      // print("Error mapping Supabase User to AppUser: $e");
      return null;
    }
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return supabase.auth.onAuthStateChange
        .map((AuthState authState) {
          final User? supabaseUser = authState.session?.user;
          // print(
          // "Supabase AuthStateChange: Event=${authState.event}, User=${supabaseUser?.id}",
          //   ); //? debug
          return _mapSupabaseUserToAppUser(supabaseUser: supabaseUser);
        })
        .handleError((error) {
          //? handle potential errors within the stream pipeline itself
          // print("Error in onAuthStateChange stream: $error");
          //? emit null to indicate an unauthenticated state due to stream error
          return null;
        });
  }

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

      AppUser? user = _mapSupabaseUserToAppUser(
        supabaseUser: authResponse.user,
      );
      // print(user);

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
    String? organizationName,
  }) async {
    try {
      final Map<String, dynamic> userMetadata = {
        "username": username,
        "full_name": fullName,
        "role": role.name,
      };

      if (organizationName != null && organizationName.isNotEmpty) {
        userMetadata["organization_name"] = organizationName;
      }

      //? user sign up
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );

      AppUser? user = _mapSupabaseUserToAppUser(
        supabaseUser: authResponse.user,
      );
      // print("SignUp response User: ${authResponse.user?.id}"); // Debug
      return user;
    } on AuthException catch (_) {
      // print("Auth exception error from supa_repo");
      rethrow;
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  //? this synchronous check might still be useful,
  //? but the cubit should primarily rely on the stream (hopefully)
  @override
  Future<AppUser?> getCurrentUser() async {
    final User? supabaseUser = supabase.auth.currentUser;
    final AppUser? user = _mapSupabaseUserToAppUser(supabaseUser: supabaseUser);
    return user;
  }
}
