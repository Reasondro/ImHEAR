enum UserRole {
  deaf_user,
  official;

  // Helper method to convert String to enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.deaf_user, // Default role
    );
  }
}
