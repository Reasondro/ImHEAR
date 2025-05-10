// ignore_for_file: constant_identifier_names

enum UserRole {
  deaf_user,
  org_admin,
  official;

  //? helper method to convert String to enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.deaf_user, //? default role
    );
  }
}
