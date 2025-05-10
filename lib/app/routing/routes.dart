class Routes {
  Routes._();
  //? welcome screen
  static const String welcomeScreen = "/welcome";

  // ? select role screen (base)
  static const String selectRoleScreen = "select-role";

  // // ? select role screen (the actual path)
  // static const String nestedSelectRoleScreen =
  //     "$welcomeScreen/$selectRoleScreen";

  // ? sign in screen (base)
  static const String signInScreen = "sign-in";
  // // ? sign in screen (the actual path)
  // static const String nestedSignInScreen = "$welcomeScreen/$signInScreen";

  // ? sign up screen (base)
  static const String signUpScreen = "sign-up";
  // // ? sign up screen (the actual path)
  // static const String nestedSignUpScreen =
  //     "$nestedSelectRoleScreen/$signUpScreen";

  // ? home screen
  static const String deafUserHome = "/home";
  static const String officialHome = "/official-dashboard";
  static const String orgAdminHome = "/org-admin-dashboard";

  // ? chat screen (base)
  static const String chatScreen = "chat";
  static const String deafUserChatScreen = "deaf-user-chat";

  // // ? chat screen (the actual path)
  // static const String nestedChatScreen =
  //     "$homeScreen/$chatScreen"; //? after the deaf user clicked the available sub-spaces

  // ? devices screen
  static const String devicesScreen =
      "/devices"; //? screen for the deaf user to connect the device

  // ? profile screen
  static const String profileScreen = "/profile"; //? profile screen
}
