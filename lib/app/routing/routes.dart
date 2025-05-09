class Routes {
  Routes._();
  //? welcome screen
  static const String welcomeScreen = "/welcome";

  // ? select role screen (base)
  static const String selectRoleScreen = "select-role";

  // ? select role screen (the actual path)
  static const String nestedSelectRoleScreen =
      "$welcomeScreen/$selectRoleScreen";

  // ? select auth screen (base)
  static const String authScreen =
      "auth"; //? or split it between sign up and sign in

  // ? select auth screen (the actual path)
  static const String nestedAuthScreen = "$nestedSelectRoleScreen/$authScreen";

  // ? home screen
  static const String homeScreen = "/home";

  // ? chat screen (base)
  static const String chatScreen = "chat";

  // ? chat screen (the actual path)
  static const String nestedChatScreen =
      "$homeScreen/$chatScreen"; //? after the deaf user clicked the available sub-spaces

  // ? devices screen
  static const String devicesScreen =
      "/devices"; //? screen for the deaf user to connect the device

  // ? profile screen
  static const String profileScreen = "/profile"; //? profile screen
}
