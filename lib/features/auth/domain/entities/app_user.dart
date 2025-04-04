class AppUser {
  final String id;
  final String email;
  final String? name;
  // final String? avatarUrl;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    //  this.avatarUrl
  });

  Map<String, dynamic> toJson() {
    return {"id": id, "email": email, "name": name};
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      id: jsonUser["id"],
      email: jsonUser["email"],
      name: jsonUser["name"],
      // avatarUrl: jsonUser["avatarUrl"],
    );
  }
}
