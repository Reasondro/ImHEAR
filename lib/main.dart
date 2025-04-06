import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:komunika/app/themes/light_mode.dart';
import 'package:komunika/features/auth/data/supabase_auth_repository.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/auth/presentation/screens/auth_screen.dart';
import 'package:komunika/features/deaf_user_dashboard/presentation/screens/deaf_user_dashboard_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_PROJECT_URL"]!,
    anonKey: dotenv.env["SUPABASE_API_KEY"]!,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final SupabaseAuthRepository authRepository = SupabaseAuthRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserLocationCubit>(
          create:
              (_) => UserLocationCubit(
                //* optional: customize accuracy, distanceFilter, debounceDuration
                //* accuracy: LocationAccuracy.best,
                //* debounceDuration: const Duration(seconds: 2),
              ),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository: authRepository)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        title: 'Kotaba',
        debugShowCheckedModeBanner: false,
        theme: kotabaLightTheme,
        home: BlocConsumer<AuthCubit, AuthStates>(
          builder: (_, authState) {
            print(authState);
            //? unauthenticated

            if (authState is AuthAuthenticated) {
              return DeafUserDashboardScreen();
            } else if (authState is AuthUnauthenticated ||
                authState is AuthLoading) {
              return const AuthScreen();
            }
            //? authenticated
            else
            // ? unknown stuffs/errors
            {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("$authState"), CircularProgressIndicator()],
                  ),
                ),
              );
            }
          },
          listener: (ctx, state) {
            print(state);
            if (state is AuthError) {
              ctx.customShowErrorSnackBar(state.message);
            }
          },
        ),
      ),
    );
  }
}


// TODO LIST


//! 3. Key Considerations & Next Steps:

// ? DONE    Permissions: geolocator provides methods like checkPermission, requestPermission. Handle denied/permanently denied cases gracefully in UserLocationBloc. Explain clearly why location is needed.

//? DONE     Accuracy vs. Battery: Configure geolocator's LocationSettings (accuracy, distanceFilter) carefully, especially for the Official broadcasting. High accuracy drains battery faster. distanceFilter prevents updates if the user hasn't moved significantly.

// ? not yet     Background Location (Officials): If Officials need to broadcast while the app is not in the foreground, this adds significant complexity. You'll need background execution capabilities (geolocator has some, but platform restrictions are strict, especially iOS), foreground services (Android), and "Always Allow" location permission. Start without background first.

// ? SEMI DONE    Throttling/Debouncing: Absolutely critical for NearbyOfficialsBloc RPC calls and recommended for OfficialBroadcastingBloc database updates. Prevents spamming your backend.

// ? SEMI DONE    Error Handling: Implement robust error handling in BLoCs and UI (network issues, DB errors, permission errors).

//? SEMI DONE     State Management: Ensure BLoCs are provided correctly and UI widgets rebuild efficiently based on state changes.

//* NOT YET     Chat Room Joining: Once a Deaf user taps a nearby official in the list, you'll need logic to navigate to a chat screen, passing the official_location_id or official_user_id to identify the correct chat context. This will involve a separate ChatBloc/feature.

//* fuck this     Testing: Write unit tests for BLoCs and integration tests for repository/provider interactions.
// * CHAT APP TUTOR
// * DATABSE DESGIN???
// * BLUETOOTH CONNNECTION