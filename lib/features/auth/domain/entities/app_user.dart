import 'package:komunika/features/auth/domain/entities/user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "full_name": fullName,
      "avatar_url": avatarUrl,
      "role": role.name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    try {
      final id = jsonUser['id'];
      final email = jsonUser['email'];
      final userMetadata = jsonUser['user_metadata'];

      // ? --- validate top-level fields ---
      if (id == null || id is! String) {
        throw FormatException(
          "Invalid or missing 'id' ($id) in user JSON: $jsonUser",
        );
      }
      if (email == null || email is! String) {
        throw FormatException(
          "Invalid or missing 'email' ($email) in user JSON: $jsonUser",
        );
      }
      if (userMetadata == null || userMetadata is! Map<String, dynamic>) {
        throw FormatException(
          "Invalid or missing 'user_metadata' ($userMetadata) in user JSON: $jsonUser",
        );
      }
      // ? --- extract fields from user_metadata ---
      final username = userMetadata['username'];
      final fullName = userMetadata['full_name'];
      final avatarUrl = userMetadata['avatar_url']; // Optional
      final roleString = userMetadata['role'];

      // ? --- validate user_metadata fields ---
      if (username == null || username is! String) {
        throw FormatException(
          "Invalid or missing 'username' ($username) in user_metadata: $userMetadata",
        );
      }
      if (fullName == null || fullName is! String) {
        throw FormatException(
          "Invalid or missing 'full_name' ($fullName) in user_metadata: $userMetadata",
        );
      }
      // ? avatarUrl is optional, but if present, must be a String
      if (avatarUrl != null && avatarUrl is! String) {
        throw FormatException(
          "Invalid 'avatar_url' type (${avatarUrl.runtimeType}) in user_metadata: $userMetadata",
        );
      }
      if (roleString == null || roleString is! String) {
        throw FormatException(
          "Invalid or missing 'role' ($roleString) in user_metadata: $userMetadata",
        );
      }
      // ? --- parse Role ---
      final UserRole role;
      try {
        role = UserRole.fromString(roleString);
      } catch (e) {
        throw FormatException(
          "Failed to parse 'role' ($roleString) in user_metadata: $e",
        );
      }
      return AppUser(
        id: id,
        email: email,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl, //? already checked for String? type
        role: role,
      );
    } catch (e) {
      //? log the error and the problematic JSON for debugging
      print("Error parsing AppUser from JSON: $jsonUser");
      print("Parsing Error: $e");
      //? rethrow a more specific error or handle as needed
      throw Exception("Failed to parse AppUser data: $e");
    }
  }
}
