// ignore_for_file: constant_identifier_names

import 'dart:convert';

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

// class UserRoleCodec extends Codec<UserRole, String> {
//   const UserRoleCodec();

//   @override
//   Converter<String, UserRole> get decoder => const _UserRoleDecoder();

//   @override
//   Converter<UserRole, String> get encoder => const _UserRoleEncoder();
// }

// class _UserRoleEncoder extends Converter<UserRole, String> {
//   const _UserRoleEncoder();
//   @override
//   String convert(UserRole input) => input.name; // Converts enum to its string name
// }

// class _UserRoleDecoder extends Converter<String, UserRole> {
//   const _UserRoleDecoder();
//   @override
//   UserRole convert(String input) {
//     // Uses your existing fromString method, or you can use UserRole.values.byName(input)
//     // if you are sure the string will always be a valid enum name.
//     // UserRole.fromString is safer if it handles defaults or errors.
//     return UserRole.fromString(input);
//   }

// }
