import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _initialLocationTrackingStarted = false;

  // @override
  // void initState() {
  //   super.initState();
  // Optional: Start location tracking when screen initializes if desired.
  // Or rely on a button if LayoutScaffoldWithNav will have one.
  // For now, let's assume we want to start it if it's not already active.
  // However, this might be better handled by a global app state or when the
  // user navigates to this shell section.
  // For simplicity in this step, let's assume tracking is initiated elsewhere or via a button.
  // If you want to auto-start:
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   if (mounted && context.read<UserLocationCubit>().state is UserLocationInitial) {
  //     context.read<UserLocationCubit>().startTracking();
  //   }
  // });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //? start tracking once when the screen is first displayed and dependencies are available
    // ? ensures cubits are available via context.read
    if (!_initialLocationTrackingStarted) {
      final UserLocationState userLocationState =
          context.read<UserLocationCubit>().state;
      if (userLocationState is UserLocationInitial ||
          userLocationState is UserLocationPermissionDenied) {
        //? only attempt to start if not already tracking or loading to avoid multiple calls if screen rebuilds.
        print("HomeScreen: Attempting to start location tracking.");
        context.read<UserLocationCubit>().startTracking();
      }
      _initialLocationTrackingStarted = true;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
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
          print(
            "HomeScreen(Listener): Location updated, trigerring fetch nearby officials",
          );
          ctx.read<NearbyOfficialsCubit>().findNearbyOfficials(
            position: userLocationState.position,
          );
        } else if (userLocationState is UserLocationInitial ||
            userLocationState is UserLocationPermissionDenied ||
            userLocationState is UserLocationServiceDisabled ||
            userLocationState is UserLocationPermissionDeniedForever) {
          print(
            "HomeScreen(Listener): Location tracking stopped or unavailabl, clearing officials", //todo TEST THSI
          );
          ctx.read<NearbyOfficialsCubit>().clearOfficials();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
          // bottom: 12.0,
          bottom: 0,
          top: 50.0,
          // top: 40.0,
          // top: 16.0, //? or 20 for whole screen scrool
        ),
        // child: ListView( //? for whole screen scrool
        child: Column(
          //? for whole screen scrool
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ? hello usernanme
            RichText(
              text: TextSpan(
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.haiti,
                ),
                children: <TextSpan>[
                  const TextSpan(text: "Hello, "),
                  TextSpan(
                    text: "$username!",
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.bittersweet,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ? radar lottie
            Center(
              child: BlocBuilder<UserLocationCubit, UserLocationState>(
                builder: (context, locationState) {
                  return BlocBuilder<
                    NearbyOfficialsCubit,
                    NearbyOfficialsState
                  >(
                    builder: (context, nearbyState) {
                      bool isLoading =
                          locationState is UserLocationLoading ||
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
                  BlocBuilder<NearbyOfficialsCubit, NearbyOfficialsState>(
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
            // const SizedBox(height: 20), // ? search bar
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

                      print("Search term: $value");
                      // setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.deluge,
                    // border: Border.all(color: AppColors.deluge, width: 5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO implmeent search action
                      print(
                        "Search button pressed with: ${_searchController.text}",
                      );
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.search, color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), //? for whole scrool screen
            // ? list of nearby spaces
            Expanded(
              child: BlocBuilder<NearbyOfficialsCubit, NearbyOfficialsState>(
                builder: (context, state) {
                  if (state is NearbyOfficialsLoading
                  // && !(state is NearbyOfficialsLoaded &&
                  //     state.officials.loaded)
                  ) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is NearbyOfficialsError) {
                    return Center(
                      child: Text("Error finding spaces: ${state.message}"),
                    );
                  }
                  if (state is NearbyOfficialsLoaded) {
                    if (state.officials.isEmpty) {
                      return const Center(
                        child: Text(
                          "No active spaces found nearby",
                          style: TextStyle(color: AppColors.bittersweet),
                        ),
                      );
                    }
                    final List<NearbyOfficial> displayedOfficials =
                        state.officials.where((official) {
                          final String searchTerm =
                              _searchController.text.toLowerCase();
                          if (searchTerm.isEmpty) return true;
                          return official.locationName.toLowerCase().contains(
                                searchTerm,
                              ) ||
                              official.officialFullName.toLowerCase().contains(
                                searchTerm,
                              );
                        }).toList();

                    // ---- START: For testing with many items ----
                    if (displayedOfficials.isNotEmpty) {
                      final List<NearbyOfficial> originalList = List.from(
                        displayedOfficials,
                      );
                      for (int i = 0; i < 10; i++) {
                        // Multiply by 10 (adjust as needed)
                        displayedOfficials.addAll(originalList);
                      }
                    }
                    // ---- END: For testing with many items ----
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
                      // shrinkWrap: true, //? for whole screen scrool
                      // physics: const NeverScrollableScrollPhysics(), //? for whole screen scrool
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
                                    "subSpaceName": official.locationName,
                                  },
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
        ),
      ),
    );
  }
}
