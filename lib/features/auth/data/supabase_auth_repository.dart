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
      AppUser user = AppUser(id: authResponse.user!.id, email: email, name: "");
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
    String? name,
  ) async {
    try {
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      AppUser user = AppUser(
        id: authResponse.user!.id,
        email: email,
        name: name,
      );
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
    AppUser user = AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email!,
      name: "",
    );
    return user;
  }
}
