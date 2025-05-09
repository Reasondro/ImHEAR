class Routes {
  Routes._();

  static const String welcomeScreen = "/welcome"; //? welcome screen
  static const String roleScreen = "role";
  static const String nestedRoleScreen = "$welcomeScreen/$roleScreen";
  static const String authScreen = "auth";
  static const String nestedAuthScreen = "$nestedRoleScreen/$authScreen";

  static const String homeScreen =
      "/home"; //? should i name this like deaf home screen? because
  static const String chatScreen = "chat";
  static const String nestedChatScreen =
      "$homeScreen/$chatScreen"; //? after the deaf user clicked the available sub-spaces

  static const String devicesScreen =
      "/devices"; //? screen for the deaf user to connect the device
  static const String profileScreen = "/profile"; //? profile screen
}
