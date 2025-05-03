import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
import 'package:komunika/features/chat/presentation/screens/chat_screen.dart';
import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';
import 'package:komunika/features/nearby_officials/presentation/cubit/nearby_officials_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_state.dart'; //? for openAppSettings/openLocationSettings
import 'package:komunika/core/extensions/snackbar_extension.dart';

class DeafUserDashboardScreen extends StatelessWidget {
  const DeafUserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //     //! --- Important: Initiate tracking ---
    //     //? decision to  startTracking.
    //     //? option 1: Call it here if the dashboard is the primary place tracking starts.
    //     // context.read<UserLocationCubit>().startTracking();
    //     //? pption 2: Call it earlier (e.g., after signin, in main.dart) if tracking
    //     //?           should start as soon as the app knows it's needed.
    //     //? option 3: Add a button in the UI for the user to manually start tracking.

    //     //? ALT1 ,  assume tracking  started elsewhere,
    //     //? or add a button. If starting automatically here, uncomment the line above.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deaf User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Start Tracking',
            onPressed: () => context.read<UserLocationCubit>().startTracking(),
          ),
          IconButton(
            icon: const Icon(Icons.social_distance),
            tooltip: "Find nearby officials",
            onPressed: () {
              final UserLocationState userLocationState =
                  context.read<UserLocationCubit>().state;
              if (userLocationState is UserLocationTracking) {
                context.read<NearbyOfficialsCubit>().findNearbyOfficials(
                  position: userLocationState.position,
                );
              } else {
                context.customShowErrorSnackBar(
                  "Start location tracking first",
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'Stop Tracking',
            onPressed: () {
              context.read<UserLocationCubit>().stopTracking;
              context.read<NearbyOfficialsCubit>().clearOfficials();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              // Call the signOut method from AuthCubit
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
      body: BlocListener<UserLocationCubit, UserLocationState>(
        listener: (ctx, UserLocationState userLocationState) {
          if (userLocationState is UserLocationTracking) {
            print("Location updated, triggering fetch nearby officials.");
            context.read<NearbyOfficialsCubit>().findNearbyOfficials(
              position: userLocationState.position,
            );
          } else if (userLocationState is UserLocationInitial ||
              userLocationState is UserLocationPermissionDenied) {
            context.read<NearbyOfficialsCubit>().clearOfficials();
          }
        },
        child: Center(
          // padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ? --- Section 1: Display User Location Status ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        "Location Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      //? use BlocBuilder for location status UI
                      BlocBuilder<UserLocationCubit, UserLocationState>(
                        builder: (context, state) {
                          if (state is UserLocationInitial) {
                            return const Text(
                              'Location tracking stopped or not started.',
                            );
                          } else if (state is UserLocationLoading) {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 10),
                                Text('Getting location...'),
                              ],
                            );
                          } else if (state is UserLocationServiceDisabled) {
                            return const Text(
                              'Location services are disabled.',
                              style: TextStyle(color: Colors.orange),
                            );
                            //? add button to open settings if needed
                          } else if (state is UserLocationPermissionDenied ||
                              state is UserLocationPermissionDeniedForever) {
                            return const Text(
                              'Location permission denied.',
                              style: TextStyle(color: Colors.red),
                            );
                            //? add button to open settings if needed
                          } else if (state is UserLocationTracking) {
                            return Text(
                              'Tracking Active:\n'
                              'Lat: ${state.position.latitude.toStringAsFixed(4)}, '
                              'Lon: ${state.position.longitude.toStringAsFixed(4)}\n'
                              'Accuracy: ${state.position.accuracy.toStringAsFixed(1)} m',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.green),
                            );
                          } else if (state is UserLocationError) {
                            return Text(
                              'Location Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            );
                          } else {
                            return const Text('Unknown location state.');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Nearby Officials",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                //? use BlocBuilder for nearby officials UI
                child: BlocBuilder<NearbyOfficialsCubit, NearbyOfficialsState>(
                  builder: (context, state) {
                    if (state is NearbyOfficialsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is NearbyOfficialsError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is NearbyOfficialsLoaded) {
                      if (state.officials.isEmpty) {
                        return const Center(
                          child: Text('No officials found nearby.'),
                        );
                      }
                      //? display the list of officials
                      return ListView.builder(
                        itemCount: state.officials.length,
                        itemBuilder: (context, index) {
                          final NearbyOfficial official =
                              state.officials[index];
                          final String subSpaceName = official.locationName;
                          final String subSpaceId = official.subSpaceId;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              title: Text(subSpaceName),
                              subtitle: Text(
                                "Handled by: ${official.officialFullName} (${official.officialUserName})\n${official.locationDescription ?? 'No description'}\nDistance: ${official.distanceMeters.toStringAsFixed(0)}m",
                              ),
                              isThreeLine: true,
                              onTap: () async {
                                try {
                                  final ChatRepository chatRepository =
                                      context.read<ChatRepository>();
                                  print("Tapped on SubSpace ID: $subSpaceId");
                                  final int roomId = await chatRepository
                                      .getOrCreateChatRoom(
                                        subSpaceId: subSpaceId,
                                      );
                                  print(
                                    "Obtained Room ID: $roomId for SubSpace ID: $subSpaceId",
                                  );

                                  if (context.mounted) {
                                    // Navigator.of(context).push(ChatScreen(roomId: roomId, subSpaceName: subSpaceName))
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ChatScreen(
                                              roomId: roomId,
                                              subSpaceName: subSpaceName,
                                            ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print(
                                    "Error in onTap getOrCreateChatRoom: $e",
                                  );
                                  if (context.mounted) {
                                    context.customShowErrorSnackBar(
                                      "Error opening chat: ${e.toString()}",
                                    );
                                  }
                                }
                              },
                            ),
                          );
                          // ! --------- BEFORE CHAT SCREEN
                          // final NearbyOfficial official =
                          //     state.officials[index];
                          // return Card(
                          //   margin: const EdgeInsets.symmetric(vertical: 4.0),
                          //   child: ListTile(
                          //     title: Text(
                          //       official.locationName,
                          //     ), // Or FullName?
                          //     subtitle: Text(
                          //       '${official.officialFullName} (${official.officialUserName})\n${official.locationDescription ?? 'No description'}\nDistance: ${official.distanceMeters.toStringAsFixed(0)}m',
                          //     ),
                          //     isThreeLine: true,
                          //     // TODO: Add onTap to potentially open a chat?
                          //     onTap: () {
                          //       //? placeholder for future chat functionality
                          //       print("Tapped on ${official.officialUserName}");
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: Text(
                          //             "Tapped on ${official.officialUserName}",
                          //           ),
                          //           duration: Duration(seconds: 1),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // );
                          // ! --------- BEFORE CHAT SCREEN
                        },
                      );
                    } else {
                      //? nearbyOfficialsInitial state
                      return const Center(
                        child: Text(
                          'Start location tracking to find officials.',
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      //! -------------- ! BEFORE !  --------------  //
      // Center(
      //   //! use BlocBuilder to automatically rebuild the UI based on the Cubit's state
      //   child: BlocBuilder<UserLocationCubit, UserLocationState>(
      //     builder: (context, state) {
      //       //? --- handle different states ---

      //       if (state is UserLocationInitial) {
      //         return const Text('Location tracking stopped or not started.');
      //       } else if (state is UserLocationLoading) {
      //         return const Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             CircularProgressIndicator(),
      //             SizedBox(height: 10),
      //             Text('Getting location...'),
      //           ],
      //         );
      //       } else if (state is UserLocationServiceDisabled) {
      //         return Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             const Text('Location services are disabled.'),
      //             const SizedBox(height: 10),
      //             ElevatedButton(
      //               onPressed: () async {
      //                 //? attempting to open settings
      //                 await Geolocator.openLocationSettings();
      //                 //? optionally recheck after returning from settings
      //                 if (!context.mounted) {
      //                   return;
      //                 }
      //                 context.read<UserLocationCubit>().startTracking();
      //               },
      //               child: const Text('Open Location Settings'),
      //             ),
      //           ],
      //         );
      //       } else if (state is UserLocationPermissionDenied) {
      //         return Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             const Text('Location permission denied.'),
      //             const SizedBox(height: 10),
      //             ElevatedButton(
      //               onPressed: () {
      //                 //? retr starting => include the permission request
      //                 context.read<UserLocationCubit>().startTracking();
      //               },
      //               child: const Text('Request Permission Again'),
      //             ),
      //           ],
      //         );
      //       } else if (state is UserLocationPermissionDeniedForever) {
      //         return Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             const Text(
      //               'Location permission permanently denied. Please enable it in your device\'s app settings.',
      //             ),
      //             const SizedBox(height: 10),
      //             ElevatedButton(
      //               onPressed: () async {
      //                 // Open the app settings page for the user
      //                 await Geolocator.openAppSettings();
      //               },
      //               child: const Text('Open App Settings'),
      //             ),
      //           ],
      //         );
      //       } else if (state is UserLocationTracking) {
      //         //? display curr location
      //         return Text(
      //           'Current Location:\n'
      //           'Latitude: ${state.position.latitude.toStringAsFixed(6)}\n'
      //           'Longitude: ${state.position.longitude.toStringAsFixed(6)}\n'
      //           'Accuracy: ${state.position.accuracy.toStringAsFixed(1)} m\n'
      //           'Timestamp: ${state.position.timestamp}',
      //           textAlign: TextAlign.center,
      //         );
      //       } else if (state is UserLocationError) {
      //         //? display error message
      //         return Text(
      //           'Error fetching location:\n${state.message}',
      //           style: const TextStyle(color: Colors.red),
      //           textAlign: TextAlign.center,
      //         );
      //       } else {
      //         //? fallback for any unhandled state
      //         return const Text('Unknown location state.');
      //       }
      //     },
      //   ),
      // ),
      //! -------------- ! BEFORE !  --------------  //
    );
  }
}
