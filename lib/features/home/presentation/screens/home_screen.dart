import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
import 'package:komunika/features/home/presentation/widgets/nearby_space_list_item.dart';
import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';
import 'package:komunika/features/nearby_officials/presentation/cubit/nearby_officials_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_state.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _isAttemptingToEnableLocationFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ? addd observer
    //? schedule a callback for after the first frame is rendered.
    // ? ensures the UI is ready before attempting to show a permission dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        //? ensure the widget is still in the tree
        final UserLocationState userLocationState =
            context.read<UserLocationCubit>().state;
        //? check if tracking needs to be initiated
        if (userLocationState is UserLocationInitial ||
            userLocationState is UserLocationPermissionDenied) {
          // print(
          //   "HomeScreen (initState post-frame): Attempting to start location tracking.",
          // );
          context.read<UserLocationCubit>().startTracking();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        _isAttemptingToEnableLocationFromSettings) {
      // print(
      //   "HomeScreen: App resumed, and was attempting to enable location from settings. Re-trying startTracking.",
      // );
      //? reset the flag
      _isAttemptingToEnableLocationFromSettings = false;
      //? attempt to start tracking again
      context.read<UserLocationCubit>().startTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthStates authState = context.watch<AuthCubit>().state;
    String username = "User";

    if (authState is AuthAuthenticated) {
      username =
          authState.user.username.isNotEmpty
              ? authState.user.username
              : authState.user.fullName;
      // if (authState.user.fullName.contains(" ")) {
      //   username = authState.user.fullName.split(" ").first;
      // }
    }
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BlocListener<UserLocationCubit, UserLocationState>(
      listener: (ctx, userLocationState) {
        if (userLocationState is UserLocationTracking) {
          // print(
          //   "HomeScreen(Listener): Location updated, trigerring fetch nearby officials",
          // );
          ctx.read<NearbyOfficialsCubit>().findNearbyOfficials(
            position: userLocationState.position,
          );
        } else if (userLocationState is UserLocationInitial ||
            userLocationState is UserLocationPermissionDenied ||
            userLocationState is UserLocationServiceDisabled ||
            userLocationState is UserLocationPermissionDeniedForever) {
          // print(
          //   "HomeScreen(Listener): Location tracking stopped or unavailabl, clearing officials", //todo TEST THSI
          // );
          ctx.read<NearbyOfficialsCubit>().clearOfficials();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
          bottom: 0,
          top: 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ? hello usernanme
            RichText(
              text: TextSpan(
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.haiti,
                ),
                children: <TextSpan>[
                  const TextSpan(text: "Hello, "),
                  TextSpan(
                    text: "$username!",
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.bittersweet,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // !--------------  new logic
            Expanded(
              child: BlocBuilder<UserLocationCubit, UserLocationState>(
                builder: (context, locationState) {
                  if (locationState is UserLocationServiceDisabled) {
                    return _buildLocationDisabledUI(
                      context,
                      "Location Services Disabled",
                      "Please enable location services to find nearby spaces.",
                      "Open Location Settings",
                      () async {
                        _isAttemptingToEnableLocationFromSettings = true;
                        await Geolocator.openLocationSettings();
                        // print(
                        //   "Just opened location settings, will attempt tracking on app resume.",
                        // );
                      },
                      secondaryButtonText: "Retry Scan",
                      onSecondaryButtonPressed: () {
                        // print(
                        //   "Retry Scan button pressed for disabled service.",
                        // );
                        context.read<UserLocationCubit>().startTracking();
                      },
                    );
                  }
                  if (locationState is UserLocationPermissionDenied) {
                    return _buildLocationDisabledUI(
                      context,
                      "Location Permission Denied",
                      "This app needs location permission to find nearby spaces.",
                      "Grant Permission",
                      () =>
                          context
                              .read<UserLocationCubit>()
                              .startTracking(), //? re-request after service permitted the first time
                    );
                  }
                  if (locationState is UserLocationPermissionDeniedForever) {
                    return _buildLocationDisabledUI(
                      context,
                      "Location Permission Denied",
                      "Permission is permanently denied. Please enable it from app settings.",
                      "Open App Settings",
                      () async {
                        // ? set the flag before opening settings - useful to recheck on resume
                        _isAttemptingToEnableLocationFromSettings = true;
                        await Geolocator.openAppSettings();
                        // print(
                        //   "Just opened app settings, will attempt tracking on app resume if relevant.",
                        // );
                      },
                    );
                  }
                  if (locationState is UserLocationError) {
                    return _buildLocationDisabledUI(
                      context,
                      "Location Error",
                      locationState.message,
                      "Retry Scan",
                      () => context.read<UserLocationCubit>().startTracking(),
                    );
                  }

                  // ? if location is Initial, Loading, or Tracking, show main UI
                  // ? (radar, count, search, list)
                  return Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.read<UserLocationCubit>().stopTracking();
                            context.read<UserLocationCubit>().startTracking();
                            context.customShowSnackBar(
                              "Radar tapped, attempting to start/restart location tracking.",
                            );
                          },
                          child:
                              BlocBuilder<UserLocationCubit, UserLocationState>(
                                builder: (context, locationState) {
                                  return BlocBuilder<
                                    NearbyOfficialsCubit,
                                    NearbyOfficialsState
                                  >(
                                    builder: (context, nearbyState) {
                                      bool isLoading =
                                          locationState
                                              is UserLocationLoading ||
                                          nearbyState is NearbyOfficialsLoading;

                                      if (isLoading) {
                                        return Lottie.asset(
                                          height: 250,
                                          "assets/images/radar_searching.json",
                                        );
                                      } else {
                                        return Lottie.asset(
                                          height: 250,
                                          "assets/images/radar_idle.json",
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ? subspaces around the user text & count
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Spaces Around You",
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.haiti,
                              ),
                            ),
                            BlocBuilder<
                              NearbyOfficialsCubit,
                              NearbyOfficialsState
                            >(
                              builder: (context, state) {
                                String count = "-";
                                if (state is NearbyOfficialsLoaded) {
                                  count = state.officials.length.toString();
                                }
                                return Text(
                                  count,
                                  style: textTheme.headlineLarge?.copyWith(
                                    color: AppColors.bittersweet,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10), // ? search bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: AppColors.haiti),
                              decoration: InputDecoration(
                                hintText: "Search nearby spaces here!",
                                hintStyle: TextStyle(
                                  color: AppColors.deluge.withAlpha(179),
                                ),

                                filled: true,
                                fillColor: AppColors.white.withAlpha(122),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.deluge,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.deluge,
                                    width: 2.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                // TODO implement search/filter logic

                                // print("Search term: $value");
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.deluge,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // TODO implmeent search action
                                // print(
                                //   "Search button pressed with: ${_searchController.text}",
                                // );
                                FocusScope.of(context).unfocus();
                              },
                              icon: const Icon(
                                Icons.search,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // ? list of nearby spaces
                      Expanded(
                        child: BlocBuilder<
                          NearbyOfficialsCubit,
                          NearbyOfficialsState
                        >(
                          builder: (context, state) {
                            if (state is NearbyOfficialsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is NearbyOfficialsError) {
                              return Center(
                                child: Text(
                                  "Error finding spaces: ${state.message}",
                                ),
                              );
                            }
                            if (state is NearbyOfficialsLoaded) {
                              if (state.officials.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No active spaces found nearby",
                                    style: TextStyle(
                                      color: AppColors.bittersweet,
                                    ),
                                  ),
                                );
                              }
                              final List<NearbyOfficial> displayedOfficials =
                                  state.officials.where((official) {
                                    final String searchTerm =
                                        _searchController.text.toLowerCase();
                                    if (searchTerm.isEmpty) return true;
                                    return official.locationName
                                            .toLowerCase()
                                            .contains(searchTerm) ||
                                        official.officialFullName
                                            .toLowerCase()
                                            .contains(searchTerm);
                                  }).toList();
                              if (displayedOfficials.isEmpty &&
                                  _searchController.text.isNotEmpty) {
                                return const Center(
                                  child: Text(
                                    "No spaces match your search.",
                                    style: TextStyle(color: AppColors.deluge),
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.only(top: 0),

                                itemCount: displayedOfficials.length,
                                itemBuilder: (context, index) {
                                  final NearbyOfficial official =
                                      displayedOfficials[index];
                                  return NearbySpaceListItem(
                                    official: official,
                                    onTap: () async {
                                      try {
                                        final ChatRepository chatRepository =
                                            context.read<ChatRepository>();
                                        final int roomId = await chatRepository
                                            .getOrCreateChatRoom(
                                              subSpaceId: official.subSpaceId,
                                            );

                                        if (context.mounted) {
                                          GoRouter.of(context).goNamed(
                                            Routes.deafUserChatScreen,
                                            pathParameters: {
                                              "roomId": roomId.toString(),
                                              // "subSpaceName": Uri.encodeComponent(
                                              "subSpaceName":
                                                  official.locationName,
                                            },
                                            extra: official.officialUserName,
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          context.customShowErrorSnackBar(
                                            "Error opening chat: $e",
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                            }
                            //? fallback or Initial State / location is disabled when app opens
                            return const Center(
                              child: Text(
                                "Scanning for nearby spaces...",
                                style: TextStyle(color: AppColors.deluge),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDisabledUI(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    VoidCallback onButtonPressed, {
    String? secondaryButtonText, //? optional: text for a second button
    VoidCallback?
    onSecondaryButtonPressed, //? optional: action for a second button
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 60,
              color: AppColors.bittersweet.withAlpha(179),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.haiti,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.deluge),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bittersweet,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            if (secondaryButtonText != null &&
                onSecondaryButtonPressed != null) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onSecondaryButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deluge,
                ),
                child: Text(
                  secondaryButtonText,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
