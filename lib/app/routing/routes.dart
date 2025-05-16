//* centralized place for all route paths (simultaneoulsy the route name too) used in the application.
//* helps in managing navigation paths and avoids string literals scattered throughout the codebase.

class Routes {
  Routes._();
  //? welcome screen
  static const String welcomeScreen = "/welcome";

  // ? select role screen (base)
  static const String selectRoleScreen = "select-role";

  // ? sign in screen (base)
  static const String signInScreen = "sign-in";

  // ? sign up screen (base)
  static const String signUpScreen = "sign-up";

  // ? home screen
  static const String deafUserHome = "/home";
  static const String officialDashboard = "/official-dashboard";
  static const String orgAdminHome = "/org-admin-dashboard";

  // ? chat screen (base)
  static const String chatScreen = "chat";
  static const String deafUserChatScreen = "deaf-user-chat";

  // ? hearAI screen
  static const String hearAIScreen =
      "/hear-ai"; //? screen for the deaf user to scan enviroment

  // ? devices screen
  static const String devicesScreen =
      "/devices"; //? screen for the deaf user to connect the device

  // ? profile screen
  static const String profileScreen = "/profile"; //? profile screen

  static const String officialProfileScreen =
      "/official-profile"; //? profile screen

  static const String orgAdminProfileScreen =
      "/org-admin-profile"; //? profile screen
}
