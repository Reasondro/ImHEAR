import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/layouts/layout_scaffold_with_nav.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:komunika/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:komunika/features/chat/presentation/screens/chat_screen.dart';
// import 'package:komunika/features/dashboard/presentation/screens/deaf_user_dashboard_screen.dart';
import 'package:komunika/features/devices/presentation/devices_screen.dart';
import 'package:komunika/features/home/presentation/screens/home_screen.dart';
import 'package:komunika/features/dashboard/presentation/screens/official_dashboard_screen.dart';
import 'package:komunika/features/dashboard/presentation/screens/org_admin_dashboard_screen.dart';
import 'package:komunika/features/onboarding/presentation/screens/select_role_screen.dart';
import 'package:komunika/features/profile/presentation/profile_screen.dart';
import 'package:komunika/features/onboarding/presentation/screens/welcome_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "root",
);
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
//   debugLabel: "shell",
// );

// ? helper class to use a stream with gorotuer refreshlistenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class RoutingService {
  final AuthCubit authCubit;

  RoutingService({required this.authCubit});
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,

    // initialLocation: Routes.homeScreen, //? in production might be use home screen instead
    initialLocation: Routes.welcomeScreen,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    // extraCodec: const UserRoleCodec(),
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStates currentAuthState = authCubit.state;
      final bool isAuthenticated = currentAuthState is AuthAuthenticated;
      final String location = state.matchedLocation;

      final List<String> unauthenticatedRoutes = [
        Routes.welcomeScreen,
        "/welcome/${Routes.selectRoleScreen}",
        "/welcome/${Routes.selectRoleScreen}/${Routes.signUpScreen}",
        "/welcome/${Routes.signInScreen}",
      ];

      // final List<String> authenticatedBaseRoutes = [
      //   Routes.deafUserHome,
      //   Routes.officialHome,
      //   Routes.orgAdminHome,
      //   Routes.devicesScreen,
      //   Routes.profileScreen,
      //   //? Add more base paths for authenticated areas if needed (like /settings)
      // ];

      // ? not authenticated
      if (!isAuthenticated) {
        if (!unauthenticatedRoutes.contains(location) &&
            !location.startsWith("/error")) {
          print(
            "Redirecting to WelcomeScreen: Not authenticated and trying to access $location",
          );
          return Routes.welcomeScreen;
        }
      }
      // ? authenticated
      else {
        // ? if user are on an unauthenticated route, redirect them to their role-specific home
        if (unauthenticatedRoutes.contains(location)) {
          final UserRole userRole = currentAuthState.user.role;
          print(
            "Redirecting to role-specific home: Authenticated and on $location",
          );
          switch (userRole) {
            case UserRole.deaf_user:
              return Routes.deafUserHome;
            case UserRole.official:
              return Routes.officialHome;
            case UserRole.org_admin:
              return Routes.orgAdminHome;
            // default:
            //   return Routes.welcomeScreen; //? should not happen
          }
        }
      }
      print("No redirection needed for location: $location");
      return null;
    },
    routes: [
      // ? routes for unauthenticated users
      GoRoute(
        path: Routes.welcomeScreen,
        builder: (context, state) => const WelcomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            name: Routes.signInScreen,
            path: Routes.signInScreen,
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            name: Routes.selectRoleScreen,
            path: Routes.selectRoleScreen,
            builder: (context, state) => const SelectRoleScreen(),
            routes: <RouteBase>[
              GoRoute(
                name: Routes.signUpScreen,
                path: Routes.signUpScreen,
                builder: (context, state) {
                  final UserRole? selectedRole = state.extra as UserRole?;
                  if (selectedRole == null) {
                    //? this case shouldn't be hit if navigation is always from SelectRoleScreen
                    return const Scaffold(
                      body: Center(
                        child: Text("Error: Role not provided for Sign Up."),
                      ),
                    );
                  }
                  return SignUpScreen(selectedRole: selectedRole);
                },
              ),
            ],
          ),
        ],
      ),

      // ? routes for Authenticated deaf users
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => LayoutScaffoldWithNav(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          // ? branch 1 : Deaf user home
          StatefulShellBranch(
            // navigatorKey: _shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: Routes.deafUserHome,
                path: Routes.deafUserHome,
                builder: (context, state) => const HomeScreen(),
                // builder: (context, state) => const DeafUserDashboardScreen(), // ? for testing
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: Routes.deafUserChatScreen,
                    path: "${Routes.chatScreen}/:roomId/:subSpaceName",
                    // path: "${Routes.chatScreen}/:subSpaceName/:roomId",
                    builder: (context, state) {
                      final int? roomId = int.tryParse(
                        state.pathParameters["roomId"] ?? "",
                      );
                      final String subSpaceName =
                          state.pathParameters["subSpaceName"] ?? "Chat";
                      if (roomId == null) {
                        return const Scaffold(
                          body: Center(
                            child: Text("Error: Room ID missing or invalid."),
                          ),
                        );
                      } else {
                        return ChatScreen(
                          roomId: roomId,
                          subSpaceName: subSpaceName,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // ? branch 2 : Deaf user devices
          StatefulShellBranch(
            // navigatorKey: _shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: Routes.devicesScreen,
                path: Routes.devicesScreen,
                builder: (context, state) => const DevicesScreen(),
              ),
            ],
          ),

          // ? branch 3 : Deaf user profile
          StatefulShellBranch(
            // navigatorKey: _shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: Routes.profileScreen,
                path: Routes.profileScreen,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: Routes.officialHome,
        path: Routes.officialHome,
        builder: (context, state) => const OfficialDashboardScreen(),
      ),
      GoRoute(
        name: Routes.orgAdminHome,
        path: Routes.orgAdminHome,
        builder: (context, state) => const OrgAdminDashboardScreen(),
      ),
    ],
  );
}
