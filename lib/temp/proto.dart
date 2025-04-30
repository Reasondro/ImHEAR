import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DeafUserDashboardScreen extends StatefulWidget {
  const DeafUserDashboardScreen({super.key, required this.title});

  final String title;

  @override
  State<DeafUserDashboardScreen> createState() =>
      _DeafUserDashboardScreenState();
}

class _DeafUserDashboardScreenState extends State<DeafUserDashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled ");
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  void _nearbyRestaurants() async {
    Position currPos = await _determinePosition();
    double lat = currPos.latitude;
    double long = currPos.longitude;
    final data = await supabase.rpc(
      'nearby_restaurants',
      params: {"lat": lat, "long": long},
    );
    print(data);
  }

  void _addRestaurants() async {
    await supabase.from('restaurants').insert([
      {
        'name': 'Insittut Teknologi Bandung',
        'location': 'POINT(107.61014828217186 -6.890138014763959)',
      },
      {
        'name': 'Warunk Upnormal Sumur Bandung',
        'location': 'POINT(107.61307820317128 -6.885419093134816)',
      },
      {
        'name': 'McDonald\'s Dago',
        'location': 'POINT(107.6134826886188 -6.884932983955189)',
      },
    ]);
    print("success");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Location....",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 15,
        children: [
          FloatingActionButton(
            onPressed: _determinePosition,
            child: const Icon(Icons.location_searching),
          ),
          FloatingActionButton(
            onPressed: _nearbyRestaurants,
            child: const Icon(Icons.food_bank),
          ),
          FloatingActionButton(
            onPressed: _addRestaurants,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

Future<void> findNearbyOfficials() async {
  double long = 107.61307820317128;
  double lat = -6.885419093134816;
  double distance = 1000;

  final dynamic data = await Supabase.instance.client.rpc(
    "find_nearby_officials",
    params: {
      "user_lat": lat,
      "user_lon": long,
      "search_radius_meters": distance,
    },
  );
  print(data);
}



// class UserLocationCubit extends Cubit<UserLocationState> {
//   StreamSubscription<Position>? _positionStreamSubscription;

//   final LocationSettings _locationSettings;
//   final Duration _debounceDuration;

//   bool _permissionRequested = false;

//   UserLocationCubit({
//     // ? (ato bisa juga gini) required LocationAccuracy accuracy,
//     LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
//     int distanceFilter = 10,
//     Duration? debounceDuration,
//   }) : _locationSettings = LocationSettings(
//          accuracy: accuracy,
//          distanceFilter: distanceFilter,
//        ),
//        _debounceDuration =
//            debounceDuration ?? const Duration(milliseconds: 500),
//        super(UserLocationInitial());

//   Future<void> startTracking() async {
//     //? PENTING prevent start  if tracking / loading
//     if (state is UserLocationTracking || state is UserLocationLoading) return;
//     emit(UserLocationLoading());
//     _permissionRequested = false;

//     try {
//       //? check location service
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

//       if (!serviceEnabled) {
//         emit(UserLocationServiceDisabled());
//         return;
//       }

//       //? check & request fo r permisisoin
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         _permissionRequested = true;
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           emit(UserLocationPermissionDenied());
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         emit(UserLocationPermissionDeniedForever());
//         return;
//       }
//       // ? permission granted ==> start listen
//       await _positionStreamSubscription?.cancel(); //? cancel any prev streams

//       //  Get last known position first for faster initial feedback (optional)
//       Position? lastKnown = await Geolocator.getLastKnownPosition();
//       if (lastKnown != null && !isClosed) {
//         emit(UserLocationTracking(position: lastKnown));
//       }

//       final Stream<Position> positionStream = Geolocator.getPositionStream(
//         locationSettings: _locationSettings,
//       );

//       // ? apply debounce if duration is greater than zero
//       final Stream<Position> streamToListen =
//           (_debounceDuration > Duration.zero)
//               ? positionStream.debounceTime(_debounceDuration)
//               : positionStream;

//       _positionStreamSubscription = streamToListen.listen(
//         (Position p) {
//           if (!isClosed) {
//             print("Location Emitted: ${p.latitude}, ${p.longitude}");
//           }
//         },
//         onError: (error) {
//           //? Handle potential errors from the stream (e.g., GPS signal loss)
//           print("Location Stream Error: $error");
//           if (!isClosed) {
//             emit(UserLocationError(message: "Error getting location: $error"));
//             // Optionally try restarting tracking after an error? Depends on desired behavior.
//             // stopTracking();
//           }
//         },
//         onDone: () {
//           // ? stream closed unexpectedely
//           // If we were tracking and the stream just stops, maybe emit initial?
//           print("Location stream done.");
//           // emit(UserLocationInitial()); // Or another appropriate state
//         },
//         cancelOnError: false, //? Keep listening even after an error if desired
//       );
//     } catch (e) {
//       print("Error starting location tracking: $e");
//       if (!isClosed) {
//         //? Handle errors during setup (e.g., platform exceptions)
//         if (e is PermissionRequestInProgressException) {
//           emit(
//             UserLocationError(
//               message: "Permission request already in progress.",
//             ),
//           );
//         } else if (e is LocationServiceDisabledException) {
//           emit(UserLocationServiceDisabled());
//         } else {
//           emit(
//             UserLocationError(
//               message: "Failed to start tracking: ${e.toString()}",
//             ),
//           );
//         }
//       }
//     }
//   }

//   Future<LocationPermission> checkPermissionStatus() async {
//     return await Geolocator.checkPermission();
//   }

//   Future<bool> isServiceEnabled() async {
//     return await Geolocator.isLocationServiceEnabled();
//   }

//   void stopTracking() {
//     _positionStreamSubscription?.cancel();
//     _positionStreamSubscription = null;
//     if (state is! UserLocationInitial) {
//       emit(UserLocationInitial());
//     }
//     print("User location tracking stopped.");
//   }

//   @override
//   Future<void> close() {
//     stopTracking();
//     return super.close();
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:komunika/features/user_location/cubit/user_location_cubit.dart';
// import 'package:komunika/features/user_location/cubit/user_location_state.dart';

// class DeafUserDashboardView extends StatelessWidget {
//   const DeafUserDashboardView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     //! --- Important: Initiate tracking ---
//     //? decision to  startTracking.
//     //? option 1: Call it here if the dashboard is the primary place tracking starts.
//     // context.read<UserLocationCubit>().startTracking();
//     //? pption 2: Call it earlier (e.g., after signin, in main.dart) if tracking
//     //?           should start as soon as the app knows it's needed.
//     //? option 3: Add a button in the UI for the user to manually start tracking.

//     //? ALT1 ,  assume tracking  started elsewhere,
//     //? or add a button. If starting automatically here, uncomment the line above.
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Deaf User Dashboard"),
//         actions: [
//           IconButton(
//             onPressed: () => context.read<UserLocationCubit>().startTracking(),
//             icon: const Icon(Icons.play_arrow),
//             tooltip: "Start Tracking",
//           ),
//           IconButton(
//             onPressed: () => context.read<UserLocationCubit>().stopTracking(),
//             icon: const Icon(Icons.stop),
//             tooltip: "Stop Tracking",
//           ),
//         ],
//       ),
//       body: Center(
//         child: BlocBuilder<UserLocationCubit, UserLocationState>(
//           builder: (context, state) {
//             if (state is UserLocationInitial) {
//               return const Text("Location tracking stopped or not stareted");
//             } else if (state is UserLocationLoading) {
//               return const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),

//                   Text("Getting location..."),
//                 ],
//               );
//             } else if (state is UserLocationServiceDisabled) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Location services are disabled.'),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Attempt to open settings
//                       await Geolocator.openLocationSettings();
//                       // Optionally re-check after returning from settings
//                       if (!context.mounted) {
//                         return;
//                       }
//                       context.read<UserLocationCubit>().startTracking();
//                     },
//                     child: const Text('Open Location Settings'),
//                   ),
//                 ],
//               );
//             } else if (state is UserLocationPermissionDenied) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Location permission denied.'),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Retry starting, which includes the permission request
//                       context.read<UserLocationCubit>().startTracking();
//                     },
//                     child: const Text('Request Permission Again'),
//                   ),
//                 ],
//               );
//             } else if (state is UserLocationPermissionDeniedForever) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Location permission permanently denied. Please enable it in your device\'s app settings.',
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Open the app settings page for the user
//                       await Geolocator.openAppSettings();
//                     },
//                     child: const Text('Open App Settings'),
//                   ),
//                 ],
//               );
//             } else if (state is UserLocationTracking) {
//               return Text(
//                 'Current Location:\n'
//                 'Latitude: ${state.position.latitude.toStringAsFixed(6)}\n'
//                 'Longitude: ${state.position.longitude.toStringAsFixed(6)}\n'
//                 'Accuracy: ${state.position.accuracy.toStringAsFixed(1)} m\n'
//                 'Timestamp: ${state.position.timestamp}',
//                 textAlign: TextAlign.center,
//               );
//             } else if (state is UserLocationError) {
//               return Text(
//                 'Error fetching location:\n${state.message}',
//                 style: const TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center,
//               );
//             } else {
//               // Fallback for any unhandled state (shouldn't happen with sealed classes/exhaustive checks)
//               return const Text('Unknown location state.');
//             }
//           },
//         ),
//       ),
//     );
//   }
// }