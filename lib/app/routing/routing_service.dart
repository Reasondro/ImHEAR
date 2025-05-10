import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/layouts/layout_scaffold_with_nav.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:komunika/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:komunika/features/devices/presentation/devices_screen.dart';
import 'package:komunika/features/home/presentation/screens/home_screen.dart';
import 'package:komunika/features/onboarding/presentation/screens/select_role_screen.dart';
import 'package:komunika/features/profile/presentation/profile_screen.dart';
import 'package:komunika/features/onboarding/presentation/screens/welcome_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "root",
);

class RoutingService {
  final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    // initialLocation: Routes.homeScreen,
    initialLocation: Routes.welcomeScreen,
    routes: [
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => LayoutScaffoldWithNav(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: "Home",
                path: Routes.homeScreen,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: "Devices",
                path: Routes.devicesScreen,
                builder: (context, state) => const DevicesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: "Profile",
                path: Routes.profileScreen,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.welcomeScreen,
        builder: (context, state) => const WelcomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            name: "Sign In",
            path: Routes.signInScreen,
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            name: "Select Role",
            path: Routes.selectRoleScreen,
            builder: (context, state) => const SelectRoleScreen(),
            routes: <RouteBase>[
              GoRoute(
                name: "Sign Up",
                path: Routes.signUpScreen,
                builder: (context, state) {
                  final UserRole? selectedRole = state.extra as UserRole?;

                  if (selectedRole == null) {
                    assert(
                      selectedRole != null,
                      "SignUpScreen was navigated to without a 'selectedRole' in 'extra'. "
                      "Please ensure it's passed during navigation from SelectRoleScreen.",
                    );
                    return const Scaffold(
                      body: Center(child: Text("Error: Role not provided.")),
                    );
                  }
                  return SignUpScreen(selectedRole: selectedRole);
                },
              ),
            ],
          ),
        ],
      ), //? how to link this with auth wrapper
    ],
  );
}
