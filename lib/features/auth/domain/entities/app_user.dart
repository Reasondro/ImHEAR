class AppUser {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String role;

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
      "role": role,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      id: jsonUser["id"],
      email: jsonUser["email"],
      username: jsonUser["username"],
      fullName: jsonUser["full_name"],
      avatarUrl: jsonUser["avatar_url"],
      role: jsonUser["role"],
    );
  }
}
