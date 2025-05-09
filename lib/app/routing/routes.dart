class Routes {
  Routes._();

  static const String splashScreen = "/splash";
  static const String roleScreen = "role";
  static const String nestedRoleScreen = "$splashScreen/$roleScreen";
  static const String authScreen = "auth";
  static const String nestedAuthScreen = "$nestedRoleScreen/$authScreen";

  static const String deafHomeScreen = "/home";
  static const String officialHomeScreen = "/home";

  static const String deafChatScreen = "chat";
  static const String officialChatScreen = "chat";

  static const String nestedDeafChatScreen = "$deafHomeScreen/$deafChatScreen";
  static const String nestedOfficialChatScreen =
      "$officialChatScreen/$officialChatScreen";
}
