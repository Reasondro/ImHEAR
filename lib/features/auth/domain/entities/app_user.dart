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
    return AppUser(
      id: jsonUser["id"],
      email: jsonUser["email"],
      username: jsonUser["user_metadata"]["username"],
      fullName: jsonUser["user_metadata"]["full_name"],
      avatarUrl: jsonUser["user_metadata"]["avatar_url"],
      role: UserRole.fromString(jsonUser["user_metadata"]["role"]),
    );
  }
}
