import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_state.dart'; // For openAppSettings/openLocationSettings

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
            tooltip: "Find distance",
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'Stop Tracking',
            onPressed: () => context.read<UserLocationCubit>().stopTracking(),
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
      body: Center(
        //! use BlocBuilder to automatically rebuild the UI based on the Cubit's state
        child: BlocBuilder<UserLocationCubit, UserLocationState>(
          builder: (context, state) {
            //? --- handle different states ---

            if (state is UserLocationInitial) {
              return const Text('Location tracking stopped or not started.');
            } else if (state is UserLocationLoading) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Getting location...'),
                ],
              );
            } else if (state is UserLocationServiceDisabled) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Location services are disabled.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      //? attempting to open settings
                      await Geolocator.openLocationSettings();
                      //? optionally recheck after returning from settings
                      if (!context.mounted) {
                        return;
                      }
                      context.read<UserLocationCubit>().startTracking();
                    },
                    child: const Text('Open Location Settings'),
                  ),
                ],
              );
            } else if (state is UserLocationPermissionDenied) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Location permission denied.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      //? retr starting => include the permission request
                      context.read<UserLocationCubit>().startTracking();
                    },
                    child: const Text('Request Permission Again'),
                  ),
                ],
              );
            } else if (state is UserLocationPermissionDeniedForever) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Location permission permanently denied. Please enable it in your device\'s app settings.',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      // Open the app settings page for the user
                      await Geolocator.openAppSettings();
                    },
                    child: const Text('Open App Settings'),
                  ),
                ],
              );
            } else if (state is UserLocationTracking) {
              //? display curr location
              return Text(
                'Current Location:\n'
                'Latitude: ${state.position.latitude.toStringAsFixed(6)}\n'
                'Longitude: ${state.position.longitude.toStringAsFixed(6)}\n'
                'Accuracy: ${state.position.accuracy.toStringAsFixed(1)} m\n'
                'Timestamp: ${state.position.timestamp}',
                textAlign: TextAlign.center,
              );
            } else if (state is UserLocationError) {
              //? display error message
              return Text(
                'Error fetching location:\n${state.message}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              );
            } else {
              //? fallback for any unhandled state
              return const Text('Unknown location state.');
            }
          },
        ),
      ),
    );
  }
}
