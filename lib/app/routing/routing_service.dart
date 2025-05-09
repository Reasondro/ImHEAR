import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/layouts/layout_scaffold_with_nav.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/features/devices/presentation/devices_screen.dart';
import 'package:komunika/features/home/presentation/screens/home_screen.dart';
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
      ), //? how to link this with auth wrapper
    ],
  );
}
